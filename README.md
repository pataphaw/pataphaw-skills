# pataphaw-skills

Personal skill collection for Codex, Claude Code, and OpenCode.

## Install

Use the installer script from the repo root:

```sh
sh bin/install-skills.sh
```

By default it installs every top-level skill in this repository into each
agent's own global skills directory:

- Codex: `~/.codex/skills`
- Claude Code: `~/.claude/skills`
- OpenCode: `~/.config/opencode/skills`

The script creates symlinks by default. Use `--copy` if you want physical
copies instead.

## Usage

Install for all supported agents:

```sh
sh bin/install-skills.sh
```

Install only for one agent:

```sh
sh bin/install-skills.sh --agent codex
sh bin/install-skills.sh --agent claudecode
sh bin/install-skills.sh --agent opencode
```

Install for a subset of agents:

```sh
sh bin/install-skills.sh --agent codex --agent opencode
```

Replace conflicting targets:

```sh
sh bin/install-skills.sh --force
```

Install into a custom directory:

```sh
sh bin/install-skills.sh --target /path/to/skills
```

## Notes

- `claudecode` is accepted as an alias for `claude`
- `--target` overrides the built-in agent directories and cannot be combined
  with `--agent`
- The installer only picks top-level directories that contain `SKILL.md`
