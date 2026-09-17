# pataphaw-skills

Personal skill collection for Codex, Claude Code, and OpenCode.

## Install

Use the installer script from the repo root:

```sh
sh bin/install-skills.sh
```

By default it installs every top-level skill in this repository into each
agent's global skills directory:

- Codex: `~/.agents/skills`
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
- Codex installation uses `~/.agents/skills` independently of `CODEX_HOME`.
  Use `--target` for a custom location.
- Before installing for Codex, migrate any matching skills from the legacy
  `~/.codex/skills` directory. The installer stops before writing to any agent
  if legacy entries would cause duplicate installations; `--force` does not
  remove them. Existing destination conflicts still require explicit handling.
- Codex may recreate `~/.codex/skills/.system` for its bundled skills after
  the legacy directory is removed. This does not mean your migrated user
  skills have moved back; the installer does not manage bundled skills.
