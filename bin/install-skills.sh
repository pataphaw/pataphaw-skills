#!/bin/sh

set -eu

usage() {
  cat <<'EOF'
Usage: install-skills.sh [--copy] [--force] [--agent NAME]... [--target DIR]

Install all top-level skill directories from this repository into one or more
global skills directories.

Options:
  --copy         Copy skill directories instead of creating symlinks
  --force        Replace existing targets when they conflict
  --agent NAME   Install for a specific agent: codex, claude, claudecode,
                 opencode
                 Can be provided multiple times
  --target DIR   Override all built-in targets and install only into DIR
  --help         Show this help message

Defaults:
  agents: codex, claude, opencode
  codex target: ${CODEX_HOME:-$HOME/.codex}/skills
  claude target: ${CLAUDE_HOME:-$HOME/.claude}/skills
  opencode target: ${OPENCODE_HOME:-$HOME/.config/opencode}/skills

Notes:
  mode: symlink
EOF
}

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
REPO_ROOT=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)
CODEX_TARGET_ROOT=${CODEX_HOME:-"$HOME/.codex"}/skills
CLAUDE_TARGET_ROOT=${CLAUDE_HOME:-"$HOME/.claude"}/skills
OPENCODE_TARGET_ROOT=${OPENCODE_HOME:-"$HOME/.config/opencode"}/skills
MODE=symlink
FORCE=0
CUSTOM_TARGET_ROOT=
SELECTED_AGENTS=
AGENT_OVERRIDE=0
TARGET_SUMMARY=

add_selected_agent() {
  new_agent=$1

  for existing_agent in $SELECTED_AGENTS; do
    if [ "$existing_agent" = "$new_agent" ]; then
      return
    fi
  done

  if [ -n "$SELECTED_AGENTS" ]; then
    SELECTED_AGENTS="$SELECTED_AGENTS $new_agent"
  else
    SELECTED_AGENTS=$new_agent
  fi
}

has_agent() {
  wanted_agent=$1

  for existing_agent in $SELECTED_AGENTS; do
    if [ "$existing_agent" = "$wanted_agent" ]; then
      return 0
    fi
  done

  return 1
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --copy)
      MODE=copy
      ;;
    --force)
      FORCE=1
      ;;
    --agent)
      shift
      if [ "$#" -eq 0 ]; then
        echo "error: --agent requires a name" >&2
        exit 1
      fi

      case "$1" in
        codex|claude|claudecode|opencode)
          ;;
        *)
          echo "error: unsupported agent: $1" >&2
          echo "hint: supported agents are codex, claude, claudecode, opencode" >&2
          exit 1
          ;;
      esac

      if [ "$AGENT_OVERRIDE" -ne 1 ]; then
        SELECTED_AGENTS=
        AGENT_OVERRIDE=1
      fi

      selected_agent=$1
      if [ "$selected_agent" = "claudecode" ]; then
        selected_agent=claude
      fi

      add_selected_agent "$selected_agent"
      ;;
    --target)
      shift
      if [ "$#" -eq 0 ]; then
        echo "error: --target requires a directory" >&2
        exit 1
      fi
      CUSTOM_TARGET_ROOT=$1
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      echo "error: unknown argument: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
  shift
done

if [ -n "$CUSTOM_TARGET_ROOT" ] && [ "$AGENT_OVERRIDE" -eq 1 ]; then
  echo "error: --target cannot be combined with --agent" >&2
  exit 1
fi

if [ "$AGENT_OVERRIDE" -ne 1 ]; then
  SELECTED_AGENTS="codex claude opencode"
fi

installed_count=0
skipped_count=0

install_skill() {
  skill_path=$1
  target_root=$2
  target_label=$3
  skill_name=$(basename "$skill_path")
  target_path=$target_root/$skill_name

  if [ -L "$target_path" ]; then
    current_link=$(readlink "$target_path" || true)
    if [ "$MODE" = "symlink" ] && [ "$current_link" = "$skill_path" ]; then
      echo "skip  [$target_label] $skill_name -> $current_link"
      skipped_count=$((skipped_count + 1))
      return
    fi

    if [ "$FORCE" -ne 1 ]; then
      echo "error: $target_path already exists as a different symlink" >&2
      echo "hint: rerun with --force to replace it" >&2
      exit 1
    fi

    rm -f "$target_path"
  elif [ -e "$target_path" ]; then
    if [ "$FORCE" -ne 1 ]; then
      echo "error: $target_path already exists" >&2
      echo "hint: rerun with --force to replace it" >&2
      exit 1
    fi

    rm -rf "$target_path"
  fi

  if [ "$MODE" = "copy" ]; then
    cp -R "$skill_path" "$target_path"
    echo "copy  [$target_label] $skill_name -> $target_path"
  else
    ln -s "$skill_path" "$target_path"
    echo "link  [$target_label] $skill_name -> $target_path"
  fi

  installed_count=$((installed_count + 1))
}

install_target() {
  target_root=$1
  target_label=$2
  found_any=0

  mkdir -p "$target_root"

  if [ -n "$TARGET_SUMMARY" ]; then
    TARGET_SUMMARY="$TARGET_SUMMARY
$target_label: $target_root"
  else
    TARGET_SUMMARY="$target_label: $target_root"
  fi

  for path in "$REPO_ROOT"/*; do
    [ -d "$path" ] || continue

    name=$(basename "$path")
    case "$name" in
      .git|bin)
        continue
        ;;
    esac

    [ -f "$path/SKILL.md" ] || continue

    found_any=1
    install_skill "$path" "$target_root" "$target_label"
  done

  if [ "$found_any" -ne 1 ]; then
    echo "error: no skill directories found under $REPO_ROOT" >&2
    exit 1
  fi
}

if [ -n "$CUSTOM_TARGET_ROOT" ]; then
  install_target "$CUSTOM_TARGET_ROOT" custom
else
  if has_agent codex; then
    install_target "$CODEX_TARGET_ROOT" codex
  fi

  if has_agent claude; then
    install_target "$CLAUDE_TARGET_ROOT" claude
  fi

  if has_agent opencode; then
    install_target "$OPENCODE_TARGET_ROOT" opencode
  fi
fi

echo
echo "Installed: $installed_count"
echo "Skipped:   $skipped_count"
echo "Targets:"
printf '%s\n' "$TARGET_SUMMARY"
