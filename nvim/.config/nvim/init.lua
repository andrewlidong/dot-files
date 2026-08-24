-- ─────────────────────────────────────────────────────────────
--  init.lua — deliberately small. No plugin manager; the one
--  plugin (tokyonight) is cloned into nvim's native package dir
--  by install.sh, so there is nothing to bootstrap on first run.
--
--  Grow this by adding files under lua/ and requiring them here.
-- ─────────────────────────────────────────────────────────────

vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- ─── Editing ─────────────────────────────────────────────────
vim.opt.expandtab = true          -- spaces, not tabs
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.smartindent = true
vim.opt.wrap = false

-- ─── Display ─────────────────────────────────────────────────
vim.opt.number = true
vim.opt.relativenumber = true     -- 5j / 3k without counting lines
vim.opt.signcolumn = "yes"        -- stops the text jogging left and right
vim.opt.cursorline = true
vim.opt.scrolloff = 8             -- keep context above and below
vim.opt.termguicolors = true      -- Ghostty does truecolor; use it
vim.opt.showmode = false

-- ─── Search ──────────────────────────────────────────────────
vim.opt.ignorecase = true
vim.opt.smartcase = true          -- …unless the pattern has a capital
vim.opt.incsearch = true
vim.opt.hlsearch = true

-- ─── Files & undo ────────────────────────────────────────────
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undofile = true           -- undo survives closing the file
vim.opt.updatetime = 250

-- ─── Splits ──────────────────────────────────────────────────
vim.opt.splitright = true         -- same direction as tmux's C-a |
vim.opt.splitbelow = true         -- and C-a -

-- ─── Misc ────────────────────────────────────────────────────
vim.opt.clipboard = "unnamedplus" -- yank goes to the macOS clipboard
vim.opt.mouse = "a"
vim.opt.confirm = true            -- ask instead of failing on :q with changes

-- ─── Keymaps ─────────────────────────────────────────────────
local map = vim.keymap.set
map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "clear search highlight" })
map("n", "<leader>w", "<cmd>write<CR>", { desc = "write" })
map("n", "<leader>q", "<cmd>quit<CR>", { desc = "quit" })

-- Window nav with the same hjkl muscle memory as tmux's C-a h/j/k/l.
map("n", "<C-h>", "<C-w>h", { desc = "window left" })
map("n", "<C-j>", "<C-w>j", { desc = "window down" })
map("n", "<C-k>", "<C-w>k", { desc = "window up" })
map("n", "<C-l>", "<C-w>l", { desc = "window right" })

-- Keep the cursor put when joining, and centred when paging.
map("n", "J", "mzJ`z")
map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")

-- Visual-mode indent that doesn't drop the selection.
map("v", "<", "<gv")
map("v", ">", ">gv")

-- ─── Highlight on yank ───────────────────────────────────────
vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "briefly highlight yanked text",
  -- vim.highlight was renamed vim.hl in 0.11 and goes away in 2.0.
  callback = function() (vim.hl or vim.highlight).on_yank() end,
})

-- ─── Colours ─────────────────────────────────────────────────
-- Cloned by install.sh into ~/.local/share/nvim/site/pack/*/start/.
-- pcall so a fresh checkout without it still opens, just uncoloured.
if not pcall(vim.cmd.colorscheme, "tokyonight-night") then
  vim.notify("tokyonight not installed — run ~/dotfiles/install.sh", vim.log.levels.WARN)
end
