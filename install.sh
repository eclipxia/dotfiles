#!/usr/bin/env bash
set -euo pipefail

dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ "$(uname -s)" == "Darwin" ]]; then
	if ! command -v brew >/dev/null; then
		echo "Homebrew not found, installing it" >&2
		NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
		eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv)"
	fi
	brew bundle --file="$dir/Brewfile"
	brew bundle --file="$dir/Brewfile.mac"
else
	pkgs=(zsh tmux fzf git-delta zoxide eza zsh-autosuggestions zsh-completions)
	if command -v apt-get >/dev/null; then
		sudo apt-get update && sudo apt-get install -y "${pkgs[@]}"
	elif command -v dnf >/dev/null; then
		sudo dnf install -y "${pkgs[@]}"
	elif command -v pacman >/dev/null; then
		sudo pacman -Sy --noconfirm "${pkgs[@]}"
	elif command -v zypper >/dev/null; then
		sudo zypper install -y "${pkgs[@]}"
	else
		echo "no known package manager found" >&2
	fi || true

	if ! command -v brew >/dev/null; then
		echo "Installing Homebrew as a fallback for anything the system package manager missed" >&2
		NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" \
			|| echo "Homebrew install failed, continuing without it" >&2
	fi
	eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv 2>/dev/null || ~/.linuxbrew/bin/brew shellenv 2>/dev/null)" || true
	command -v brew >/dev/null && brew bundle --file="$dir/Brewfile"

	if ! command -v docker >/dev/null; then
		echo "Docker not found, installing it" >&2
		curl -fsSL https://get.docker.com | sudo sh
		sudo usermod -aG docker "$USER"
		command -v systemctl >/dev/null && sudo systemctl enable --now docker
	fi
fi

git -C "$dir" submodule update --init --recursive

cp -r "$dir/fzf-tab" "$dir/fast-syntax-highlighting" ~/
cp "$dir/.zshrc" "$dir/.zprofile" "$dir/.gitconfig" "$dir/.tmux.conf" ~/

mkdir -p ~/.config
cp "$dir/starship.toml" ~/.config/starship.toml
bash "$dir/nvim/install.sh"
rsync -a "$dir/sketchybar/" ~/.config/sketchybar/
mkdir -p ~/.config/aerospace
cp "$dir/aerospace/aerospace.toml" ~/.config/aerospace/aerospace.toml

mkdir -p ~/scrips
cp "$dir/scrips/project-fzf.sh" ~/scrips/

mkdir -p ~/.local/bin
cp "$dir/local-bin/tmux-dev" ~/.local/bin/
chmod +x ~/.local/bin/tmux-dev

zsh_path="$(command -v zsh)"
if [ "$SHELL" != "$zsh_path" ]; then
	chsh -s "$zsh_path"
fi
