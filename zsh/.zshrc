# ─────────────────────────────────────────────────────────────
#  ~/.zshrc  —  managed in ~/dotfiles (stow package: zsh)
#  Machine-specific junk goes in ~/.zshrc.local (git-ignored).
# ─────────────────────────────────────────────────────────────

BREW_PREFIX="/opt/homebrew"

# ─── PATH ────────────────────────────────────────────────────
export PATH="$HOME/.local/bin:$PATH"

# ─── Environment ─────────────────────────────────────────────
export EDITOR="vim"
export VISUAL="$EDITOR"
export PAGER="less"
export LESS="-R -F -X --mouse"
export MANPAGER="less -R --use-color -Dd+r -Du+b"
export CLICOLOR=1

# ─── History ─────────────────────────────────────────────────
HISTFILE="$HOME/.zsh_history"
HISTSIZE=200000
SAVEHIST=200000
setopt EXTENDED_HISTORY          # timestamp each entry
setopt INC_APPEND_HISTORY        # write as you go, not just at exit
setopt SHARE_HISTORY             # sync across open shells
setopt HIST_IGNORE_ALL_DUPS      # keep only the newest copy of a command
setopt HIST_IGNORE_SPACE         # " secret cmd" stays out of history
setopt HIST_REDUCE_BLANKS
setopt HIST_VERIFY               # expand !! instead of running it blind

# ─── Shell options ───────────────────────────────────────────
setopt AUTO_CD                   # `..` and bare dir names cd
setopt AUTO_PUSHD                # every cd builds a stack (see `d`)
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_SILENT
setopt EXTENDED_GLOB             # **, ^, ~ in globs
setopt GLOB_DOTS                 # globs match dotfiles
setopt INTERACTIVE_COMMENTS      # # comments at the prompt
setopt NO_BEEP
setopt NO_FLOW_CONTROL           # frees up C-s / C-q
unsetopt CORRECT_ALL             # no "did you mean" nagging

# ─── Completion ──────────────────────────────────────────────
fpath=("$BREW_PREFIX/share/zsh/site-functions" $fpath)

autoload -Uz compinit
# Rebuild the completion cache at most once a day — keeps startup fast.
_zcompdump="$HOME/.zcompdump"
if [[ -n "$_zcompdump"(#qN.mh+24) ]]; then
  compinit -d "$_zcompdump"
else
  compinit -C -d "$_zcompdump"
fi

zmodload -i zsh/complist

zstyle ':completion:*' menu select                       # arrow-key menu
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' group-name ''
zstyle ':completion:*' verbose true
zstyle ':completion:*:descriptions' format '%F{#7aa2f7}%B %d%b%f'
zstyle ':completion:*:messages'     format '%F{#bb9af7} %d%f'
zstyle ':completion:*:warnings'     format '%F{#f7768e} no matches%f'
zstyle ':completion:*:corrections'  format '%F{#e0af68} %d (errors: %e)%f'
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$HOME/.cache/zsh/zcompcache"
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:cd:*' ignore-parents parent pwd    # don't offer `cd ..` → cwd

# ─── Keybindings ─────────────────────────────────────────────
bindkey -e                                               # emacs-style

# Up/Down search history for what you've already typed.
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey '^[[A' up-line-or-beginning-search
bindkey '^[[B' down-line-or-beginning-search
bindkey '^P'   up-line-or-beginning-search
bindkey '^N'   down-line-or-beginning-search

# Make C-w / M-b / M-f treat /paths/like/this as multiple words.
autoload -Uz select-word-style && select-word-style bash

bindkey '^[[1;5C' forward-word          # ctrl+right
bindkey '^[[1;5D' backward-word         # ctrl+left
bindkey '^[[3~'   delete-char
bindkey '^U'      backward-kill-line    # bash-like, not kill-whole-line
bindkey '^[m'     copy-prev-shell-word

# Menu navigation with hjkl while the completion menu is open.
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char

# ─── fzf ─────────────────────────────────────────────────────
# bg is left unset so Ghostty's translucency shows through the picker.
export FZF_DEFAULT_OPTS="
  --height=45% --layout=reverse --border=rounded --margin=0,1
  --prompt='  ' --pointer='▶' --marker='✓'
  --info=inline-right
  --color=fg:#c0caf5,hl:#7aa2f7
  --color=fg+:#c0caf5,bg+:#292e42,hl+:#7dcfff
  --color=info:#565f89,prompt:#7dcfff,pointer:#bb9af7
  --color=marker:#9ece6a,spinner:#bb9af7,header:#565f89
  --color=border:#3b4261,label:#7aa2f7"

if command -v fd >/dev/null 2>&1; then
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
fi
export FZF_CTRL_T_OPTS="--preview 'bat --style=numbers --color=always --line-range=:300 {} 2>/dev/null || eza --tree --level=2 --color=always {}' --preview-window=right,60%,border-left"
export FZF_ALT_C_OPTS="--preview 'eza --tree --level=2 --color=always --icons=always {}'"
export FZF_CTRL_R_OPTS="--preview 'echo {}' --preview-window=down,3,wrap,border-top --bind='ctrl-y:execute-silent(echo -n {2..} | pbcopy)+abort' --header='  ctrl-y: copy command'"

command -v fzf >/dev/null 2>&1 && source <(fzf --zsh)

# ─── Plugins ─────────────────────────────────────────────────
# fzf-tab must load after compinit and before syntax-highlighting.
[[ -f "$HOME/.config/zsh/plugins/fzf-tab/fzf-tab.plugin.zsh" ]] \
  && source "$HOME/.config/zsh/plugins/fzf-tab/fzf-tab.plugin.zsh"
zstyle ':fzf-tab:*' fzf-flags --height=40% --layout=reverse --border=rounded
zstyle ':fzf-tab:*' switch-group '<' '>'
zstyle ':fzf-tab:complete:cd:*'      fzf-preview 'eza --tree --level=2 --color=always --icons=always $realpath'
zstyle ':fzf-tab:complete:z:*'       fzf-preview 'eza --tree --level=2 --color=always --icons=always $realpath'
zstyle ':fzf-tab:complete:git-*:*'   fzf-preview 'git log --oneline --color=always -20 $word 2>/dev/null'
zstyle ':fzf-tab:complete:kill:argument-rest' fzf-preview 'ps -p $word -o comm,args'

if [[ -f "$BREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
  source "$BREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
  ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#565f89'
  ZSH_AUTOSUGGEST_STRATEGY=(history completion)
  bindkey '^ ' autosuggest-accept          # ctrl+space accepts the ghost text
fi

# ─── Tools ───────────────────────────────────────────────────
command -v mise     >/dev/null 2>&1 && eval "$(mise activate zsh)"
command -v starship >/dev/null 2>&1 && eval "$(starship init zsh)"
command -v zoxide   >/dev/null 2>&1 && eval "$(zoxide init zsh)"   # z / zi

# ─── Aliases ─────────────────────────────────────────────────
if command -v eza >/dev/null 2>&1; then
  alias ls='eza --group-directories-first --icons=auto'
  alias l='eza -l  --group-directories-first --icons=auto --git --no-user --time-style=relative'
  alias ll='eza -l --group-directories-first --icons=auto --git'
  alias la='eza -la --group-directories-first --icons=auto --git'
  alias lt='eza --tree --level=2 --group-directories-first --icons=auto'
  alias ltt='eza --tree --level=4 --group-directories-first --icons=auto'
else
  alias ls='ls -G'
  alias ll='ls -lh'
  alias la='ls -lah'
fi

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias d='dirs -v | head -10'          # recent dirs; `cd -2` to jump

command -v bat >/dev/null 2>&1 && alias bathelp='bat --plain --language=help'
help() { "$@" --help 2>&1 | bat --plain --language=help; }

# git
alias gs='git status --short --branch'
alias gd='git diff'
alias gds='git diff --staged'
alias ga='git add'
alias gaa='git add --all'
alias gc='git commit'
alias gcm='git commit -m'
alias gca='git commit --amend'
alias gco='git checkout'
alias gsw='git switch'
alias gb='git branch'
alias gp='git push'
alias gpl='git pull'
alias gl='git log --oneline --graph --decorate -20'
alias gll='git log --graph --pretty=fancy'
alias gst='git stash'
command -v lazygit >/dev/null 2>&1 && alias lg='lazygit'

# tmux
alias t='tmux'
alias ts='tmux-sessionizer'
alias ta='tmux attach -t'
alias tl='tmux list-sessions'
alias tn='tmux new-session -s'
alias tk='tmux kill-session -t'
alias tka='tmux kill-server'

# kubectl (installed via mise)
if command -v kubectl >/dev/null 2>&1; then
  alias k='kubectl'
  alias kgp='kubectl get pods'
  alias kctx='kubectl config current-context'
fi

alias reload='exec zsh'
alias path='echo -e ${PATH//:/\\n}'
alias ports='lsof -iTCP -sTCP:LISTEN -P -n'
alias ip='curl -s https://ifconfig.me && echo'
alias df='df -h'
alias du='du -h'
command -v btop >/dev/null 2>&1 && alias top='btop'

# Make a directory and cd into it.
mkcd() { mkdir -p "$1" && cd "$1"; }

# ─── Local overrides (not in git) ────────────────────────────
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"

# ─── Syntax highlighting — must be LAST ──────────────────────
if [[ -f "$BREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]]; then
  source "$BREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
  ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)
  typeset -A ZSH_HIGHLIGHT_STYLES
  ZSH_HIGHLIGHT_STYLES[comment]='fg=#565f89'
  ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=#f7768e,bold'
  ZSH_HIGHLIGHT_STYLES[command]='fg=#9ece6a'
  ZSH_HIGHLIGHT_STYLES[builtin]='fg=#9ece6a'
  ZSH_HIGHLIGHT_STYLES[function]='fg=#9ece6a'
  ZSH_HIGHLIGHT_STYLES[alias]='fg=#9ece6a'
  ZSH_HIGHLIGHT_STYLES[precommand]='fg=#9ece6a,italic'
  ZSH_HIGHLIGHT_STYLES[path]='fg=#c0caf5,underline'
  ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=#e0af68'
  ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=#e0af68'
  ZSH_HIGHLIGHT_STYLES[dollar-double-quoted-argument]='fg=#7dcfff'
  ZSH_HIGHLIGHT_STYLES[redirection]='fg=#bb9af7'
  ZSH_HIGHLIGHT_STYLES[commandseparator]='fg=#bb9af7'
  ZSH_HIGHLIGHT_STYLES[reserved-word]='fg=#bb9af7'
fi
