# dotfiles

Ghostty + tmux + zsh, themed **Tokyo Night** throughout.
macOS / Apple Silicon. Managed with [GNU Stow](https://www.gnu.org/software/stow/).

```
ghostty/    → ~/.config/ghostty/config
tmux/       → ~/.config/tmux/tmux.conf
zsh/        → ~/.zshrc
starship/   → ~/.config/starship.toml
bat/        → ~/.config/bat/{config,themes/}
git/        → ~/.config/git/{shared.gitconfig,ignore}
bin/        → ~/.local/bin/tmux-sessionizer
```

## New machine

```sh
git clone <this-repo> ~/dotfiles && cd ~/dotfiles && ./install.sh
```

Idempotent — re-run it any time. It installs the Brewfile, backs up any real
file that would collide (as `*.pre-dotfiles.<timestamp>`), stows every package,
fetches tpm + fzf-tab, builds the bat theme cache, and adds an `[include]` line
to `~/.gitconfig`.

## How it fits together

`~/.gitconfig` stays **machine-local** — credential helpers and your git
identity live there and are not in this repo. It just `[include]`s
`git/.config/git/shared.gitconfig`. Same idea for the shell: `~/.zshrc.local`
is sourced if it exists and is never committed.

Language runtimes and CLI versions come from **mise**, not brew. The Brewfile
is only terminal furniture.

## Editing

Every path above is a symlink into this repo, so edit either location — it's one
file. After changing:

| Config    | Apply with                    |
| --------- | ----------------------------- |
| Ghostty   | `cmd+shift+,`                 |
| tmux      | `C-a r`                       |
| zsh       | `reload` (aliased to `exec zsh`) |
| starship  | takes effect on next prompt   |

Adding a new package: `mkdir -p newthing/.config/newthing`, put the file at the
path it should have relative to `$HOME`, add the name to `PACKAGES` in
`install.sh`, then `stow newthing`.

---

# Cheatsheet

## tmux — prefix is `C-a`

The mental model: **one Ghostty window, tmux owns everything inside it.**
Sessions outlive the terminal — quit Ghostty, reopen, `tmux a`, nothing lost.

### Sessions

| Key       | Does                                                    |
| --------- | ------------------------------------------------------- |
| `C-a f`   | **fzf project picker** — the main way to move around     |
| `C-a s`   | visual session/window tree                              |
| `C-a (` / `)` | previous / next session                             |
| `C-a L`   | last session (toggle back and forth)                    |
| `C-a d`   | detach (session keeps running)                          |
| `C-a S`   | rename session                                          |

From a bare shell: `ts` (sessionizer), `ta <name>` (attach), `tl` (list).

`C-a f` searches `~/conductor/repos`, `~/src`, `~/code`, `~/work`,
`~/Developer`, `~/projects`, plus git repos in `$HOME` and a few pinned dirs.
Edit the `ROOTS` / `ALWAYS` arrays at the top of
`bin/.local/bin/tmux-sessionizer` to change that.

### Windows & panes

| Key            | Does                                          |
| -------------- | --------------------------------------------- |
| `C-a c`        | new window (in the current directory)         |
| `C-a \|`       | split right                                   |
| `C-a -`        | split down                                    |
| `C-a h/j/k/l`  | move between panes (repeatable — hold prefix)  |
| `M-h/j/k/l`    | move between panes, **no prefix**             |
| `C-a H/J/K/L`  | resize (repeatable)                           |
| `C-a z`        | zoom pane to full window (toggle)             |
| `C-a Space`    | cycle layouts                                 |
| `C-a b`        | break pane into its own window                |
| `C-a @`        | pull another window in as a pane              |
| `M-1`…`M-5`    | jump to window N, no prefix                   |
| `S-Left/Right` | previous / next window                        |
| `C-a x` / `X`  | kill pane / window                            |
| `C-a m`        | rename window                                 |

`M-` is Option, which works because Ghostty sets `macos-option-as-alt = true`.

### Popups

| Key     | Does                                    |
| ------- | --------------------------------------- |
| `C-a g` | lazygit, floating, in the pane's repo   |
| `C-a t` | scratch shell                           |
| `C-a e` | edit `tmux.conf`                        |

### Copy mode (vi keys)

`C-a Enter` to enter · `v` select · `C-v` block select · `y` copy to macOS
clipboard · `Escape` cancel. Dragging with the mouse also copies.

### Persistence

resurrect + continuum save every 15 min and restore on server start.
`C-a C-s` forces a save, `C-a C-r` a restore.
`C-a I` installs plugins, `C-a U` updates them.

## Ghostty

Deliberately minimal, since tmux does the splitting.

| Key                | Does                                     |
| ------------------ | ---------------------------------------- |
| `cmd+``            | **quick terminal** — dropdown from anywhere in macOS |
| `cmd+shift+enter`  | zoom split                               |
| `cmd+k`            | clear screen                             |
| `cmd+shift+,`      | reload config                            |
| `cmd+d` / `cmd+shift+d` | native split right / down (still there if you want it) |

The quick terminal needs Accessibility permission the first time.

Knobs worth knowing in `ghostty/.config/ghostty/config`: `background-opacity`
(0.94) and `background-blur` (24) for translucency, `adjust-cell-height` (14%)
for line spacing, and `macos-titlebar-style` — swap `tabs` for `hidden` if you
want zero chrome.

## Shell

| Key      | Does                                                  |
| -------- | ----------------------------------------------------- |
| `C-r`    | fuzzy history search (`C-y` copies the command)        |
| `C-t`    | fuzzy file picker, with a `bat` preview                |
| `M-c`    | fuzzy cd                                              |
| `Tab`    | completion in an fzf popup, with previews (fzf-tab)    |
| `↑` / `↓`| history search using what you've already typed         |
| `C-space`| accept the greyed-out autosuggestion                   |

`z <partial>` jumps to a frecent directory, `zi` picks interactively (zoxide).
`d` lists recent directories; `cd -2` jumps back to one.

Aliases: `ls`/`l`/`ll`/`la`/`lt` (eza), `lg` (lazygit), `gs`/`gd`/`gl`/… (git),
`ts`/`ta`/`tl` (tmux), `k` (kubectl), `ports`, `path`, `reload`.
`help <cmd>` pipes `--help` through bat.

## Where the colors live

Tokyo Night hexes are duplicated in a few places by necessity — each tool has
its own config format:

- `ghostty` — `theme = TokyoNight Night` (built in) plus explicit cursor/selection
- `tmux` — `%hidden` vars at the top of the status-line section
- `starship` — inline per module
- `zsh` — `FZF_DEFAULT_OPTS`, autosuggest style, `ZSH_HIGHLIGHT_STYLES`
- `bat` / `delta` — `bat/.config/bat/themes/tokyonight_night.tmTheme`

Palette: bg `#1a1b26` · bg-alt `#24283b` · fg `#c0caf5` · grey `#565f89`
blue `#7aa2f7` · purple `#bb9af7` · cyan `#7dcfff` · green `#9ece6a`
yellow `#e0af68` · orange `#ff9e64` · red `#f7768e`
