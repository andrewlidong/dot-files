export PATH="$HOME/.local/bin:$PATH"

# Docker CLI completions
fpath=(/Users/andrewdong/.docker/completions $fpath)
autoload -Uz compinit
compinit
