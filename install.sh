#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
#  Bootstrap this machine. Safe to re-run — every step is idempotent.
#    ./install.sh            # everything
#    ./install.sh --no-brew  # skip package installation
# ─────────────────────────────────────────────────────────────
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGES=(ghostty tmux zsh starship bat git bin nvim)
SKIP_BREW=false
[[ "${1:-}" == "--no-brew" ]] && SKIP_BREW=true

info() { printf '\033[1;34m▸\033[0m %s\n' "$*"; }
ok()   { printf '\033[1;32m✓\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!\033[0m %s\n' "$*"; }

# ─── 1. Packages ─────────────────────────────────────────────
if ! $SKIP_BREW; then
  if ! command -v brew >/dev/null 2>&1; then
    info "installing Homebrew"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
  info "brew bundle"
  brew bundle install --file="$DOTFILES/Brewfile"
  ok "packages installed"
fi

# ─── 2. Back up anything stow would collide with ──────────────
STAMP="$(date +%Y%m%d-%H%M%S)"
backup_if_real() {
  local target="$1"
  if [[ -e "$target" && ! -L "$target" ]]; then
    mv "$target" "$target.pre-dotfiles.$STAMP"
    warn "moved $target → $(basename "$target").pre-dotfiles.$STAMP"
  fi
}
backup_if_real "$HOME/.zshrc"
backup_if_real "$HOME/.config/ghostty/config"
backup_if_real "$HOME/.config/starship.toml"
backup_if_real "$HOME/.config/bat/config"

# ─── 3. Symlink the packages ──────────────────────────────────
mkdir -p "$HOME/.config" "$HOME/.local/bin"
info "stowing: ${PACKAGES[*]}"
cd "$DOTFILES"
stow --restow --target="$HOME" "${PACKAGES[@]}"
ok "symlinks in place"

# ─── 4. tmux plugin manager ───────────────────────────────────
TPM="$HOME/.config/tmux/plugins/tpm"
if [[ ! -d "$TPM" ]]; then
  info "cloning tpm"
  git clone -q --depth 1 https://github.com/tmux-plugins/tpm "$TPM"
fi
info "installing tmux plugins"
"$TPM/bin/install_plugins" >/dev/null 2>&1 || warn "tpm: run 'C-a I' inside tmux to finish"
ok "tmux plugins ready"

# ─── 5. fzf-tab (no brew formula, so clone it) ────────────────
FZF_TAB="$HOME/.config/zsh/plugins/fzf-tab"
if [[ ! -d "$FZF_TAB" ]]; then
  info "cloning fzf-tab"
  git clone -q --depth 1 https://github.com/Aloxaf/fzf-tab "$FZF_TAB"
fi
ok "fzf-tab ready"

# ─── 6. neovim colourscheme ───────────────────────────────────
# No plugin manager — nvim loads anything under site/pack/*/start
# on its own, so a plain clone is the whole install.
TOKYONIGHT="$HOME/.local/share/nvim/site/pack/colors/start/tokyonight.nvim"
if [[ ! -d "$TOKYONIGHT" ]]; then
  info "cloning tokyonight.nvim"
  git clone -q --depth 1 https://github.com/folke/tokyonight.nvim "$TOKYONIGHT"
fi
ok "tokyonight ready"

# ─── 7. bat theme cache ───────────────────────────────────────
if command -v bat >/dev/null 2>&1; then
  info "building bat theme cache"
  bat cache --build >/dev/null 2>&1 && ok "bat themes built"
fi

# ─── 8. Wire the shared git config into ~/.gitconfig ──────────
# ~/.gitconfig stays machine-local (credential helpers, identity);
# it just includes the shared file from this repo.
if ! git config --global --get-all include.path 2>/dev/null | grep -qx "$HOME/.config/git/shared.gitconfig"; then
  info "adding include.path to ~/.gitconfig"
  git config --global --add include.path "$HOME/.config/git/shared.gitconfig"
fi
# shared.gitconfig carries an identity, so the include above hands it to
# anyone who cloned this repo. Say whose it is rather than let them author
# commits as someone else by accident.
SHARED="$HOME/.config/git/shared.gitconfig"
eff_name="$(git config --get user.name  || true)"
eff_mail="$(git config --get user.email || true)"
origin="$(git config --show-origin --get user.email 2>/dev/null | cut -f1)"
origin="${origin#file:}"
if [[ -z "$eff_mail" ]]; then
  warn "git identity not set — run:"
  warn "  git config --global user.name  'Your Name'"
  warn "  git config --global user.email 'you@example.com'"
elif [[ -e "$origin" && "$origin" -ef "$SHARED" ]]; then
  warn "commits will be authored as $eff_name <$eff_mail>,"
  warn "which comes from this repo's shared.gitconfig. If that isn't you:"
  warn "  git config --global user.name  'Your Name'"
  warn "  git config --global user.email 'you@example.com'"
else
  ok "git identity: $eff_name <$eff_mail>"
fi
ok "git configured"

# ─── 9. Secret-scanning pre-commit hook ───────────────────────
# This repo is public, so a leaked secret would have to be rotated rather
# than just removed. Scoped to this repo — other clones stay untouched.
git -C "$DOTFILES" config core.hooksPath hooks
if command -v gitleaks >/dev/null 2>&1; then
  ok "pre-commit secret scan enabled"
else
  warn "pre-commit hook wired up, but gitleaks is missing — commits won't be scanned"
  warn "  brew install gitleaks"
fi

# ─── 10. Nudges ───────────────────────────────────────────────
printf '\n'
ok "done. next:"
echo "   • Ghostty → restart it (or cmd+shift+, to reload)"
echo "   • shell   → exec zsh"
echo "   • tmux    → tmux, then C-a f to pick a project"
