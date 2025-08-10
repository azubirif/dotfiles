plugins=(git)

export LANG=es_ES.UTF-8

# Preferred editor for local and remote sessions
 if [[ -n $SSH_CONNECTION ]]; then
   export EDITOR='vim'
 else
   export EDITOR='nvim'
 fi

alias cdgh="cd ~/Documentos/GitHub/"
alias cdapuntes="cd ~/Documentos/GitHub/apuntes-carrera/source/content/"

alias condaenv='eval "$(/home/azubirif/anaconda3/bin/conda shell.zsh hook)"'
alias hx="helix"
alias vim="nvim"
alias c="clear"

# Para Arch
alias log_out="hyprctl dispatch exit"
alias waybar_reload="killall -SIGUSR2 waybar"
alias hyprpaper_reload="killall hyprpaper && nohup hyprpaper &"
alias set_wallpaper="~/dotfiles/scripts/set_wallpaper.sh"


export EDITOR=nvim
export VISUAL=nvim
export PATH=$PATH:$HOME/.cargo/bin
export MANPATH
export INFOPATH

cat ~/.cache/wal/sequences

clear

#eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
# eval "$(oh-my-posh init zsh --config 'https://github.com/JanDeDobbeleer/oh-my-posh/blob/main/themes/easy-term.omp.json')"

# . "$HOME/.local/bin/env"

# pnpm
export PNPM_HOME="/home/azubirif/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
export PATH=$HOME/.local/bin:$PATH

# bun completions
[ -s "/home/azubirif/.bun/_bun" ] && source "/home/azubirif/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

eval "$(oh-my-posh init zsh --config '~/dotfiles/.config/omp.toml')"
POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true

fastfetch
