#!/bin/sh

set -eu

usage() {
  cat <<'EOF'
Usage: install-skills.sh [--copy] [--force] [--target DIR]

Install all top-level skill directories from this repository into the
Codex global skills directory.

Options:
  --copy         Copy skill directories instead of creating symlinks
  --force        Replace existing targets when they conflict
  --target DIR   Override the default target directory
  --help         Show this help message

Defaults:
  target dir: ${CODEX_HOME:-$HOME/.codex}/skills
  mode: symlink
EOF
}

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
REPO_ROOT=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)
TARGET_ROOT=${CODEX_HOME:-"$HOME/.codex"}/skills
MODE=symlink
FORCE=0

while [ "$#" -gt 0 ]; do
  case "$1" in
    --copy)
      MODE=copy
      ;;
    --force)
      FORCE=1
      ;;
    --target)
      shift
      if [ "$#" -eq 0 ]; then
        echo "error: --target requires a directory" >&2
        exit 1
      fi
      TARGET_ROOT=$1
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

mkdir -p "$TARGET_ROOT"

installed_count=0
skipped_count=0

install_skill() {
  skill_path=$1
  skill_name=$(basename "$skill_path")
  target_path=$TARGET_ROOT/$skill_name

  if [ -L "$target_path" ]; then
    current_link=$(readlink "$target_path" || true)
    if [ "$MODE" = "symlink" ] && [ "$current_link" = "$skill_path" ]; then
      echo "skip  $skill_name -> $current_link"
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
    echo "copy  $skill_name -> $target_path"
  else
    ln -s "$skill_path" "$target_path"
    echo "link  $skill_name -> $target_path"
  fi

  installed_count=$((installed_count + 1))
}

found_any=0

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
  install_skill "$path"
done

if [ "$found_any" -ne 1 ]; then
  echo "error: no skill directories found under $REPO_ROOT" >&2
  exit 1
fi

echo
echo "Installed: $installed_count"
echo "Skipped:   $skipped_count"
echo "Target:    $TARGET_ROOT"
