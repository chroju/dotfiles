# dotfiles

The setting files for my development PC.

## Usage

Work with bash and `setup_*.sh` scripts.

```bash
$ mkdir -p ~/dev/src/github/com/chroju
$ cd ~/dev/src/github/com/chroju
$ git clone https://github.com/chroju/dotfiles
$ cd dotfiles

# must execute setup_default.sh with sudo
$ sudo ./setup_default.sh
$ ./setup_symlinks.sh
$ ./setup_homebrew.sh
```

## Devcontainer

Other repositories can reuse this dotfiles setup via the devcontainer [dotfiles feature](https://containers.dev/implementors/json_reference/#_devcontainerjson).

### Prerequisites

Run `setup_symlinks.sh` on the host first. This installs `devcontainer-init` to `/usr/local/bin/`.

### Setup

Copy `.devcontainer/devcontainer.json` from this repository to your project. Change `name` and add project-specific features as needed. Add `"dotfiles.repository": "chroju/dotfiles"` to enable the dotfiles feature.

### How it works

- `devcontainer-init` (host, `initializeCommand`): Sets up SSH agent forwarding via Podman VM and writes `GH_TOKEN` / `SSH_AUTH_SOCK` to `.devcontainer/.env.devcontainer`.
- `install.sh` (container, dotfiles feature): Creates symlinks from `dotfiles/HOME/` to `$HOME`, installs Claude Code and mise, configures SSH agent socket.
- Mounts share host credentials (SSH, AWS, Claude Code sessions/settings) into the container. Claude Code credentials and config use devcontainer-specific files to keep authentication separate.
