# dotfiles

Personal macOS dotfiles. Managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Setup on a new machine

```sh
git clone <this-repo> ~/dotfiles
cd ~/dotfiles
./install.sh
```

`install.sh` installs Homebrew (if missing), runs `brew bundle`, and stows each package into `$HOME`.

## Layout

Each top-level dir is a Stow "package". Its contents mirror the layout that will appear in `$HOME`.

```
zsh/      → ~/.zshrc, ~/.zprofile, ~/.zshenv, ~/.profile
git/      → ~/.gitconfig
ghostty/  → ~/.config/ghostty/config
```

## Common commands

```sh
stow -t ~ zsh           # link zsh package into ~
stow -R -t ~ zsh        # restow (refresh links)
stow -D -t ~ zsh        # unstow (remove links)
```

## Adding a new package

1. `mkdir foo` at the repo root.
2. Place files inside under the same path they'd take in `$HOME` (e.g. `foo/.config/foo/config`).
3. Add `foo` to the `PACKAGES` array in `install.sh`.
4. `stow -t ~ foo`.
