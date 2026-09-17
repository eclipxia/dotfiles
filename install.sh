#!/usr/bin/env bash
set -euo pipefail

dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if ! command -v zsh >/dev/null; then
	if command -v apt-get >/dev/null; then
		sudo apt-get update && sudo apt-get install -y zsh
	elif command -v dnf >/dev/null; then
		sudo dnf install -y zsh
	elif command -v pacman >/dev/null; then
		sudo pacman -Sy --noconfirm zsh
	elif command -v zypper >/dev/null; then
		sudo zypper install -y zsh
	else
		echo "no known package manager found, install zsh manually" >&2
		exit 1
	fi
fi

cp -r "$dir/fzf-tab" "$dir/fast-syntax-highlighting" ~/
cp "$dir/.zshrc" ~/

zsh_path="$(command -v zsh)"
if [ "$SHELL" != "$zsh_path" ]; then
	chsh -s "$zsh_path"
fi

rm -f ~/.gitconfig
cp "$dir/.gitconfig" ~/
