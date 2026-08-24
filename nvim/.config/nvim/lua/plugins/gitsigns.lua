-- Gitsigns — changed-line marks in the sign column, hunk staging, blame.
-- Complements lazygit (C-a g in tmux) rather than replacing it: this is
-- for the line under the cursor, lazygit is for the commit.
--
-- Hunk motions are ]h / [h, not the more usual ]c / [c, because
-- treesitter-textobjects already uses ]c / [c for "next class".
return {
  "lewis6991/gitsigns.nvim",
  event = { "BufReadPre", "BufNewFile" },
  opts = {
    signs = {
      add =          { text = "▎" },
      change =       { text = "▎" },
      delete =       { text = "▁" },
      topdelete =    { text = "▔" },
      changedelete = { text = "▎" },
      untracked =    { text = "▎" },
    },
    on_attach = function(bufnr)
      local gs = require("gitsigns")
      local function map(mode, lhs, rhs, desc)
        vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
      end

      map("n", "]h", function() gs.nav_hunk("next") end, "next hunk")
      map("n", "[h", function() gs.nav_hunk("prev") end, "previous hunk")

      map("n", "<leader>hp", gs.preview_hunk, "preview hunk")
      map("n", "<leader>hs", gs.stage_hunk, "stage hunk")
      map("n", "<leader>hr", gs.reset_hunk, "reset hunk")
      map("n", "<leader>hb", function() gs.blame_line({ full = true }) end, "blame line")
      map("n", "<leader>hd", gs.diffthis, "diff this file")
    end,
  },
}
