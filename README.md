# dist

Distribution repository for shell tools and utilities.

## Available Tools

### [sshh](sshh/) - SSH with History

SSH wrapper with history tracking and fuzzy search.

**Quick install:**
```bash
curl -fsSL https://raw.githubusercontent.com/0x23me/dist/main/sshh/install.sh | bash
```

**Features:**
- Record every SSH connection to history
- Fuzzy search with fzf integration
- Auto-complete from history, config, and known_hosts

[Read more →](sshh/README.md)

---

### [sshp](sshp/) - SSH Probe

Auto-detect SSH keys and add hosts to config with a single command.

**Quick install:**
```bash
curl -fsSL https://raw.githubusercontent.com/0x23me/dist/main/sshp/install.sh | bash
```

**Features:**
- Auto-detects which SSH key was accepted
- One command to connect and add to `~/.ssh/config`
- Smart updates with prompts before overwriting

[Read more →](sshp/README.md)

---

## About

This repository hosts installation scripts and tools designed for easy distribution via curl one-liners.

Each tool is self-contained in its own directory with its own README and install script.

## License

MIT License (Non-Commercial)

Free for personal and non-commercial use. For commercial licensing inquiries, contact [in@0x23.me](mailto:in@0x23.me)

See [LICENSE](LICENSE) for full terms.
