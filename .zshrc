stty -ixon
set rtp+=/opt/homebrew/opt/fzf
unset SSH_AGENT_PID
unset SSH_AUTH_SOCK
source ~/fzf-tab/fzf-tab.plugin.zsh
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh
source <(fzf --zsh)
if type brew &>/dev/null; then
FPATH=$(brew --prefix)/share/zsh-completions:$FPATH

autoload -Uz compinit
compinit
fi
bindkey -v
eval "$(starship init zsh)"
eval "$(zoxide init zsh)"
# Enable Zsh completion system
autoload -Uz compinit
compinit -d ~/.zsh/cache/zcompdump
# Make completion menus nicer
zmodload zsh/complist
zstyle ':completion:*' menu select
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%B%d%b'
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
source ~/scrips/project-fzf.sh
export MANPAGER='nvim +Man!'
alias rebuild="sudo -H nix run nix-darwin#darwin-rebuild -- switch --flake ~/.config/nix-darwin
"
alias nano ="nvim"
alias cp="cp -r"
alias g="git"
alias v="nvim"
alias tree='eza --color always --icons --hyperlink --group-directories-first --tree'
alias l='eza --color always --icons --hyperlink'
alias l1='eza --color always --icons --hyperlink --group-directories-first --tree --level=1'
alias l2='eza --color always --icons --hyperlink --group-directories-first --tree --level=2'
alias l3='eza --color always --icons --hyperlink --group-directories-first --tree --level=3'
alias ll='eza --color always --icons --hyperlink --group-directories-first --tree --level=1 --long --header --inode --links'
alias la='eza --color always --icons --hyperlink --group-directories-first --tree --level=1 --long --header --inode --links --all'
alias brew-updrade="brew upgrade; brew cleanup"
export PATH="/opt/homebrew/opt/tcl-tk/bin:$PATH"
export LDFLAGS="-L/opt/homebrew/opt/tcl-tk/lib"
export CPPFLAGS="-I/opt/homebrew/opt/tcl-tk/include"
export PKG_CONFIG_PATH="/opt/homebrew/opt/tcl-tk/lib/pkgconfig"
export FUNCNEST=100
extract() {
	for archive in "$@"; do
		if [ -f "$archive" ]; then
			case $archive in
			*.tar.gz) tar xvzf "$archive" ;;
			*.tar.bz2) tar xvjf "$archive" ;;
			*.bz2) bunzip2 "$archive" ;;
			*.tar.xz) tar xf "$archive" ;; 
			*.rar) rar x "$archive" ;;
			*.gz) gunzip "$archive" ;;
			*.tar) tar xvf "$archive" ;;
			*.tbz2) tar xvjf "$archive" ;;
			*.tgz) tar xvzf "$archive" ;;
			*.zip) unzip "$archive" ;;
			*.Z) uncompress "$archive" ;;
			*.7z) 7z x "$archive" ;;
			*) echo "don't know how to extract '$archive'..." ;;
			esac
		else
			echo "'$archive' is not a valid file!"
		fi
	done
}
export PATH="/opt/homebrew/opt/util-linux/bin:$PATH"
export PATH="/opt/homebrew/opt/util-linux/sbin:$PATH"

# Created by `pipx` on 2025-09-05 16:22:07
export PATH="$PATH:/Users/eclipxia/.local/bin"
alias cs="cd /Users/eclipxia/Documents/school
"

export PATH="$HOME/.jenv/bin:$PATH"
eval "$(jenv init -)"

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
export PATH="$HOME/bin:$PATH"
export PATH="$PATH:$HOME/.dotnet/tools"

# sqlcmd workaround for azure-sql-edge self-signed cert (negative serial)
export GODEBUG=x509negativeserial=1

# Per-language nvim profiles (see ~/.config/nvim/lua/lang.lua)
alias jvim='NVIM_LANG=java nvim'
alias csvim='NVIM_LANG=cs nvim'
alias pvim='NVIM_LANG=python nvim'
alias sqlvim='NVIM_LANG=sql nvim'
alias webvim='NVIM_LANG=web nvim'
alias cvim='NVIM_LANG=c nvim'
