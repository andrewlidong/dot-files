-- Tokyo Night — the same palette as ghostty, tmux, starship, bat and delta.
-- lazy.nvim owns this now; install.sh no longer clones it by hand.
return {
  "folke/tokyonight.nvim",
  lazy = false,      -- the colourscheme is not optional
  priority = 1000,   -- …and must load before anything that sets highlights
  opts = {
    style = "night",
    styles = { comments = { italic = true } },
  },
  config = function(_, opts)
    require("tokyonight").setup(opts)
    vim.cmd.colorscheme("tokyonight-night")
  end,
}
