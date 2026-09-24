
for brew_prefix in /opt/homebrew /usr/local /home/linuxbrew/.linuxbrew "$HOME/.linuxbrew"; do
	if [ -x "$brew_prefix/bin/brew" ]; then
		eval "$("$brew_prefix/bin/brew" shellenv)"
		break
	fi
done
unset brew_prefix


# Created by `pipx` on 2025-09-05 16:22:07
export PATH="$PATH:/Users/eclipxia/.local/bin"
export PATH="/opt/homebrew/bin:$PATH"

# Added by Toolbox App
export PATH="$PATH:/Users/eclipxia/Library/Application Support/JetBrains/Toolbox/scripts"

