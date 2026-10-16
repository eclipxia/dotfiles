#!/usr/bin/env bash
# Install packages on Fedora. Run as your normal user; sudo is requested only for dnf.
# Usage: ./fedoraInstall.sh [--dry-run] [--i3] [--niri]
set -euo pipefail

DRY_RUN=0
WMS=()
for a in "$@"; do
  case "$a" in
    --dry-run) DRY_RUN=1 ;;
    --i3)      WMS+=(i3) ;;
    --niri)    WMS+=(niri) ;;
    *) printf 'error: unknown flag: %s\n' "$a" >&2; exit 1 ;;
  esac
done
dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

log() { printf '==> %s\n' "$*"; }
die() { printf 'error: %s\n' "$*" >&2; exit 1; }

[[ $EUID -ne 0 ]] || die "don't run as root; the script calls sudo itself"

# Refuse to run on anything that isn't Fedora
# shellcheck disable=SC1091
. /etc/os-release
[[ "${ID:-}" == "fedora" ]] || die "this script is for Fedora (found: ${ID:-unknown})"

sudo dnf install dnf-plugins-core

sudo dnf config-manager addrepo --from-repofile=https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo
# EDIT THIS
packages=(
  git
  curl
  neovim
  tmux
  zsh
  zsh-autosuggestions
  zoxide
  ripgrep
  fzf
  util-linux-user   # provides chsh on Fedora
  eza 
  clang
  golang
  luarocks
  python3
  nodejs            # codex is installed via npm
  npm
  zip              # sdkman needs zip/unzip
  unzip
  qemu-kvm          # virtualization stack
  libvirt
  virt-manager
  virt-install
  edk2-ovmf         # UEFI guests
  swtpm             # TPM emulation (Windows 11 guests)
  swtpm-tools
  virt-viewer
  libguestfs-tools  # virt-sysprep, guestfish, etc.
  bridge-utils
  virtiofsd         # shared folders
  dnsmasq           # libvirt default NAT network
)
packages+=("${WMS[@]}")

# Only install what's missing, so reruns are quick and quiet
missing=()
for p in "${packages[@]}"; do
  rpm -q "$p" >/dev/null 2>&1 || missing+=("$p")
done

if (( ${#missing[@]} == 0 )); then
  log "all packages already installed"
elif (( DRY_RUN )); then
  printf '[dry-run] sudo dnf install -y %s\n' "${missing[*]}"
else
  log "installing: ${missing[*]}"
  sudo dnf install -y "${missing[@]}"
fi

# libvirt daemon + group access (log out/in for the group to apply)
if (( DRY_RUN )); then
  log "[dry-run] enable libvirtd, add $USER to libvirt group"
else
  sudo systemctl enable --now libvirtd
  id -nG "$USER" | grep -qw libvirt || sudo usermod -aG libvirt "$USER"
fi

# Window manager configs: expects $dir/i3/config and $dir/niri/config.kdl
for wm in "${WMS[@]}"; do
  case "$wm" in
    i3)   src="$dir/i3/config";       dst=~/.config/i3/config ;;
    niri) src="$dir/niri/config.kdl"; dst=~/.config/niri/config.kdl ;;
  esac
  [[ -f "$src" ]] || { log "no $src, skipping $wm config"; continue; }
  log "copying $wm config"
  (( DRY_RUN )) || { mkdir -p "$(dirname "$dst")"; cp "$src" "$dst"; }
done

# SDKMAN (rcupdate=false: don't touch shell rc files, dotfiles manage them)
if (( DRY_RUN )); then
  log "[dry-run] install sdkman"
elif [[ ! -d ~/.sdkman ]]; then
  curl -s "https://get.sdkman.io?rcupdate=false" | bash
fi

# Starship prompt, installed to ~/.local/bin (no sudo)
if (( DRY_RUN )); then
  log "[dry-run] install starship"
elif ! command -v starship >/dev/null && [[ ! -x ~/.local/bin/starship ]]; then
  mkdir -p ~/.local/bin
  curl -sS https://starship.rs/install.sh | sh -s -- -y -b ~/.local/bin
fi

# Claude Code (native installer -> ~/.local/bin) and Codex (npm, prefix ~/.local, no sudo)
if (( DRY_RUN )); then
  log "[dry-run] install claude code and codex"
else
  command -v claude >/dev/null || [[ -x ~/.local/bin/claude ]] || curl -fsSL https://claude.ai/install.sh | bash
  command -v codex >/dev/null || [[ -x ~/.local/bin/codex ]] || npm install -g --prefix ~/.local @openai/codex
fi

# Dotfiles: shell/git/tmux rc files, zsh plugin submodules, and app configs
if (( DRY_RUN )); then
  log "[dry-run] copy dotfiles from $dir into ~"
else
  log "copying dotfiles"
  git -C "$dir" submodule update --init --recursive
  cp -r "$dir/fzf-tab" "$dir/fast-syntax-highlighting" ~/
  cp "$dir"/.zshrc "$dir"/.zprofile "$dir"/.gitconfig "$dir"/.tmux.conf "$dir"/.vsvimrc ~/
  mkdir -p ~/.config/kitty ~/.zsh/cache ~/scrips ~/.local/bin
  cp "$dir/starship.toml" ~/.config/starship.toml
  cp "$dir/kitty/kitty.conf" ~/.config/kitty/kitty.conf
  cp "$dir/scrips/project-fzf.sh" ~/scrips/
  cp "$dir/local-bin/tmux-dev" ~/.local/bin/
  chmod +x ~/.local/bin/tmux-dev
fi

# Neovim config has its own install script
if (( DRY_RUN )); then
  log "[dry-run] clone nvim repo and run its install.sh"
else
  [[ -d ~/.config/nvim/.git ]] || git clone https://github.com/eclipxia/nvim ~/.config/nvim
  bash ~/.config/nvim/install.sh
fi

# Last step: make zsh the login shell (takes effect on next login)
zsh_path="$(command -v zsh)"
if (( DRY_RUN )); then
  log "[dry-run] chsh -s $zsh_path"
elif [[ "$(getent passwd "$USER" | cut -d: -f7)" != "$zsh_path" ]]; then
  log "switching login shell to zsh"
  sudo chsh -s "$zsh_path" "$USER"
fi
