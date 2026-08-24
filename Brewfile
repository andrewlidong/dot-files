# Brewfile — `brew bundle install` from ~/dotfiles rebuilds this setup.
# Language runtimes and CLI versions are managed by mise, not brew.

# ─── Terminal & multiplexer ──────────────────────────────────
cask "ghostty"
brew "tmux"

# ─── Shell ───────────────────────────────────────────────────
brew "mise"                      # runtime/version manager (.zshrc activates it)
brew "starship"                  # prompt
brew "zsh-autosuggestions"
brew "zsh-syntax-highlighting"
brew "stow"                      # symlinks this repo into $HOME

# ─── Core CLI replacements ───────────────────────────────────
brew "fzf"                       # fuzzy finder (ctrl-r, ctrl-t, sessionizer)
brew "zoxide"                    # smarter cd (z)
brew "eza"                       # ls
brew "bat"                       # cat/pager with syntax highlighting
brew "fd"                        # find
brew "ripgrep"                   # grep
brew "git-delta"                 # git diff pager
brew "tree"

# ─── Safety ──────────────────────────────────────────────────
brew "gitleaks"                  # pre-commit secret scan (hooks/pre-commit)

# ─── Editor ──────────────────────────────────────────────────
brew "neovim"                    # config in nvim/, colourscheme via install.sh

# ─── TUIs ────────────────────────────────────────────────────
brew "lazygit"
brew "btop"

# ─── Fonts ───────────────────────────────────────────────────
cask "font-jetbrains-mono-nerd-font"
