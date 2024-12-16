# If you come from bash you might have to change your $PATH.
#export PATH=$HOME/bin:/usr/local/bin:$PATH

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

export ZSH="$HOME/.oh-my-zsh"

# Set prompt
ZSH_THEME="powerlevel10k/powerlevel10k"

# Set editor
export EDITOR="nvim"
export SUDO_EDITOR="nvim"
export VISUAL="${EDITOR}"

# Set bat as manpager
export BAT_THEME="ansi"
export BAT_STYLE="full"
#export MANPAGER="sh -c 'col -bx | bat -l man -p'"

# Set neovim as manpager
export MANPAGER="nvim +Man!"

# Set some cool ZSH options
setopt nocaseglob          # Case insensitive autocompletions
setopt nocasematch         # Case insensitive autocompletions
setopt MENU_COMPLETE       # Automatically highlight first element of completion menu
setopt LIST_PACKED         # The completion menu takes less space
setopt AUTO_LIST           # Automatically list choices on ambiguous completion
setopt COMPLETE_IN_WORD    # Complete from both ends of a word
setopt correct             # Auto-corrections
setopt AUTOCD              # Change directory just by typing its name
setopt PROMPT_SUBST        # Enable command substitution in prompt

# Load engine (completions)
autoload -Uz compinit

for dump in ~/.config/zsh/zcompdump(N.mh+24); do
  compinit -d ~/.config/zsh/zcompdump
done

compinit -C -d ~/.config/zsh/zcompdump

autoload -Uz add-zsh-hook
autoload -Uz vcs_info
precmd () { vcs_info }
_comp_options+=(globdots)

zstyle ':completion:*' verbose true
zstyle ':completion:*:*:*:*:*' menu select
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS} 'ma=48;5;197;1'
zstyle ':completion:*' matcher-list \
		'm:{a-zA-Z}={A-Za-z}' \
		'+r:|[._-]=* r:|=*' \
		'+l:|=*'
zstyle ':completion:*:warnings' format "%B%F{red}No matches for:%f %F{magenta}%d%b"
zstyle ':completion:*:descriptions' format '%F{yellow}[-- %d --]%f'
zstyle ':vcs_info:*' formats ' %B%s-[%F{magenta}%f %F{yellow}%b%f]-'

# Set waiting dots
expand-or-complete-with-dots() {
  echo -n "\e[31m…\e[0m"
  zle expand-or-complete
  zle redisplay
}
zle -N expand-or-complete-with-dots
bindkey "^I" expand-or-complete-with-dots

# Set command not found handler (fetch pacman files database first with pacman -Fy)
function command_not_found_handler {
    local purple='\e[1;35m' bright='\e[0;1m' green='\e[1;32m' reset='\e[0m'
    printf 'zsh: Command not found!: %s\n' "$1"
    local entries=(
        ${(f)"$(/usr/bin/pacman -F --machinereadable -- "/usr/bin/$1")"}
    )
    if (( ${#entries[@]} ))
    then
        printf "${bright}$1${reset} may be found in the following packages:\n"
        local pkg
        for entry in "${entries[@]}"
        do
            # (repo package version file)
            local fields=(
                ${(0)entry}
            )
            if [[ "$pkg" != "${fields[2]}" ]]
            then
                printf "${purple}%s/${bright}%s ${green}%s${reset}\n" "${fields[1]}" "${fields[2]}" "${fields[3]}"
            fi
            printf '    /%s\n' "${fields[4]}"
            pkg="${fields[2]}"
        done
    fi
    return 127
}

# History
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Check archlinux plugin commands here
#https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/archlinux

plugins=(
    archlinux
    auto-notify
    colored-man-pages
    colorize
    fancy-ctrl-z
    git
    sudo
    web-search
    you-should-use
    zsh-autopair
    zsh-autosuggestions
    zsh-syntax-highlighting
    zsh-vi-mode
)

# Bind ESC to jj in zsh-vi-mode
function zvm_config() {
  ZVM_VI_INSERT_ESCAPE_BINDKEY=jj
}

# Replace zsh's default readkey engine (ZLE to NEX)
ZVM_READKEY_ENGINE=$ZVM_READKEY_ENGINE_NEX

source $ZSH/oh-my-zsh.sh

# Some useful aliases
alias ls='eza -a --icons'
alias lal='eza -al --icons'
alias la='eza -a --tree --level=1 --icons'
alias q='exit'
alias z='cd'
alias yayd='yay --devel'
alias yayrsn='yay -Rsn'
alias yayrsu='yay -Rsu'
alias yayrsnu='yay -Rsnu'
alias yays='yay -S'
alias yayss='yay -Ss'
alias yayqdtq='yay -Qdtq'
alias yayqet='yay -Qet'
alias yayqi='yay -Qi'
alias yaysi='yay -Si'
alias yaysii='yay -Sii' # List reverse dependencies
alias yayrq='yay -Rsn $(yay -Qdtq)' # List & remove all unneeded dependencies
alias pacsyu='sudo pacman -Syu'
alias pacrsn='sudo pacman -Rsn'
alias pacrsu='sudo pacman -Rsu'
alias pacrsnu='sudo pacman -Rsnu'
alias pacs='sudo pacman -S'
alias pacss='pacman -Ss'
alias pacqdtq='pacman -Qdtq'
alias pacqet='pacman -Qet'
alias pacqi='pacman -Qi'
alias pacsi='pacman -Si'
alias pacsii='pacman -Sii' # List reverse dependencies
alias pacrq='sudo pacman -Rsn $(pacman -Qtdq)' # List & remove all unneeded dependencies
alias ftldr='compgen -c | fzf | xargs tldr' # Search for man pages with tldr + fzf
alias fman='compgen -c | fzf | xargs man' # Search for man pages with man + fzf
alias src='source ~/.zshrc'
alias nnn='nnn -d -c -H -r -D -i'
alias ttc='tty-clock -C6 -c'
alias expacs="expac -S '%r/%n: %D'" # List dependencies w/o additional info
alias nv='nvim'

# FZF integration + key bindings (CTRL R for fuzzy history finder)
source <(fzf --zsh)

# FZF previews
export FZF_CTRL_T_OPTS="--preview 'bat --color=always -n --line-range :500 {}'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"

# Zoxide integration
eval "$(zoxide init zsh)"

# Zellij integration
eval "$(zellij setup --generate-auto-start zsh)"

# Display Pokemon-colorscripts
#Project page: https://gitlab.com/phoneybadger/pokemon-colorscripts#on-other-distros-and-macos
#pokemon-colorscripts --no-title -s -r

# Start colorscript
#source $HOME/scripts/arch

# Auto-start "zombie-zfetch"
source $HOME/.config/zfetch/zfetchrc

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Atuin integration (pretty history)
. "$HOME/.atuin/bin/env"
eval "$(atuin init zsh)"

# Wikiman integration
source /usr/share/wikiman/widgets/widget.zsh

# Pay-respects (better command-not-found) integration
eval "$(pay-respects zsh --alias)"

