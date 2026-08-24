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
nvim/       → ~/.config/nvim/init.lua
bin/        → ~/.local/bin/{tmux-sessionizer,dotfiles-doctor}
hooks/      → git hooks for this repo itself (not stowed)
```

Run **`dotfiles-doctor`** any time to verify everything is installed, linked,
and rendering — it checks symlinks, tools, config validity, and prints colour
and Nerd Font samples for your eyes. Exits non-zero if anything is broken.

## New machine

```sh
git clone <this-repo> ~/dotfiles && cd ~/dotfiles && ./install.sh
```

Idempotent — re-run it any time. It installs the Brewfile, backs up any real
file that would collide (as `*.pre-dotfiles.<timestamp>`), stows every package,
fetches tpm + fzf-tab + tokyonight.nvim, builds the bat theme cache, adds an
`[include]` line to `~/.gitconfig`, and points this repo's `core.hooksPath`
at `hooks/`.

## How it fits together

`~/.gitconfig` stays **machine-local** — credential helpers live there and are
not in this repo. It `[include]`s `git/.config/git/shared.gitconfig`, which
carries everything else **including a `[user]` identity**. If you cloned this
repo, override that in `~/.gitconfig` or you will author commits as its author;
`install.sh` says whose identity is in effect and warns when it came from here
rather than from your machine.

Same idea for the shell: `~/.zshrc.local` is sourced if it exists and is never
committed. Anything machine-specific or secret belongs there.

Language runtimes and CLI versions come from **mise**, not brew — the Brewfile
installs mise itself plus the rest of the terminal furniture, nothing more.

## Secrets

This repo is public, so a credential that lands in a commit has to be rotated,
not just deleted — the old object stays reachable in history. `hooks/pre-commit`
runs [gitleaks](https://github.com/gitleaks/gitleaks) over the staged patch and
refuses the commit if anything looks like a secret. `core.hooksPath` is set on
this repo only, so other clones on the machine keep their own hooks.

If gitleaks isn't installed the hook warns and exits 0, so a fresh clone isn't
uncommittable before `brew bundle` has run. `git commit --no-verify` bypasses it
for a false positive.

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

tmux owns the day-to-day splitting, but the native bindings are all here for
throwaway panes outside a session. Everything is Cmd-based, so none of it
collides with tmux's `C-a`.

| Key                      | Does                                          |
| ------------------------ | --------------------------------------------- |
| ``cmd+` ``               | **quick terminal** — drops down from the top   |
| `cmd+d` / `cmd+shift+d`  | split right / down                            |
| `cmd+[` / `cmd+]`        | previous / next split                         |
| `cmd+ctrl+arrows`        | resize split by 30                            |
| `cmd+alt+=`              | equalize splits                               |
| `cmd+shift+enter`        | zoom split                                    |
| `cmd+w`                  | close split/tab                               |
| `cmd+t`                  | new tab                                       |
| `cmd+shift+[` / `]`      | previous / next tab                           |
| `cmd+=` / `cmd+-` / `cmd+0` | font size up / down / reset                |
| `cmd+k`                  | clear screen                                  |
| `cmd+shift+r`            | reload config (`cmd+shift+,` also works)      |

The quick terminal needs Accessibility permission the first time.

Knobs worth knowing in `ghostty/.config/ghostty/config`: `background-opacity`
(0.94) and `background-blur` (24) for translucency, `adjust-cell-height` (14%)
for line spacing, `cursor-style` (bar, blinking), and `macos-titlebar-style` —
swap `tabs` for `hidden` if you want zero chrome.

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

## Editor

`EDITOR` is neovim when it's installed and plain vim otherwise, and `vim` is
aliased to `nvim` so the muscle memory still lands. `C-a e` in tmux opens a
popup on whatever `$EDITOR` resolves to.

The config is a single ~70-line `nvim/.config/nvim/init.lua` with no plugin
manager. The one plugin is the Tokyo Night colourscheme, which `install.sh`
clones into nvim's native `~/.local/share/nvim/site/pack/colors/start/` — nvim
loads anything there by itself, so there's no bootstrap on first run.

| Key                       | Does                                        |
| ------------------------- | ------------------------------------------- |
| `Space`                   | leader                                      |
| `<leader>w` / `<leader>q` | write / quit                                |
| `Esc`                     | clear search highlight                      |
| `C-h/j/k/l`               | move between splits — same hjkl as tmux     |
| `C-d` / `C-u`             | half page, cursor stays centred             |
| `J`                       | join lines without moving the cursor        |
| `<` / `>` in visual       | indent, keeping the selection               |

Splits open right and below, matching `C-a |` and `C-a -` in tmux. Yanks go to
the macOS clipboard, and undo history survives closing a file.

To grow it, add files under `nvim/.config/nvim/lua/` and `require` them from
`init.lua`. tmux-resurrect already has `@resurrect-strategy-nvim 'session'` set,
so nvim sessions come back with the tmux session.

## Where the colors live

Tokyo Night hexes are duplicated in a few places by necessity — each tool has
its own config format:

- `ghostty` — `theme = TokyoNight Night` (built in) plus explicit cursor/selection
- `tmux` — `%hidden` vars at the top of the status-line section
- `starship` — inline per module
- `zsh` — `FZF_DEFAULT_OPTS`, autosuggest style, `ZSH_HIGHLIGHT_STYLES`
- `bat` / `delta` — `bat/.config/bat/themes/tokyonight_night.tmTheme`
- `nvim` — `folke/tokyonight.nvim`, same author as the bat theme above

Palette: bg `#1a1b26` · bg-alt `#24283b` · fg `#c0caf5` · grey `#565f89`
blue `#7aa2f7` · purple `#bb9af7` · cyan `#7dcfff` · green `#9ece6a`
yellow `#e0af68` · orange `#ff9e64` · red `#f7768e`
