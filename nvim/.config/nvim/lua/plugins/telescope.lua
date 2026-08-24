-- Telescope — fuzzy finder. The single biggest change to daily use:
-- open any file by name, grep the whole project, without leaving home row.
--
-- Uses the ripgrep and fd already in the Brewfile.
return {
  "nvim-telescope/telescope.nvim",
  -- master, not the 0.1.x tag branch: 0.1.x predates the treesitter rewrite
  -- and calls nvim-treesitter.parsers.ft_to_lang(), which main removed — the
  -- pcall around the require succeeds, then the nil field crashes the picker.
  -- master uses core vim.treesitter.language.get_lang() instead.
  --
  -- Note the asymmetry: telescope's current branch is master, treesitter's is
  -- main. They are the opposite of each other; don't "fix" one to match.
  branch = "master",
  dependencies = {
    "nvim-lua/plenary.nvim",
    -- Native sorter, compiled on install. Makes big repos feel instant.
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
  },
  -- Listed here rather than in init.lua so lazy loads Telescope on first use.
  keys = {
    { "<leader>f", "<cmd>Telescope find_files<cr>", desc = "find file" },
    { "<leader>g", "<cmd>Telescope live_grep<cr>", desc = "grep project" },
    { "<leader>b", "<cmd>Telescope buffers<cr>", desc = "open buffers" },
    { "<leader>r", "<cmd>Telescope oldfiles<cr>", desc = "recent files" },
    { "<leader>/", "<cmd>Telescope current_buffer_fuzzy_find<cr>", desc = "search this buffer" },
    { "<leader>?", "<cmd>Telescope help_tags<cr>", desc = "search help" },
    { "<leader>d", "<cmd>Telescope diagnostics<cr>", desc = "diagnostics" },
  },
  opts = {
    defaults = {
      -- Same fzf muscle memory as the shell: ctrl-j/k to move, esc to close.
      mappings = {
        i = {
          ["<C-j>"] = "move_selection_next",
          ["<C-k>"] = "move_selection_previous",
          ["<Esc>"] = "close",
        },
      },
      path_display = { "truncate" },
      layout_config = { prompt_position = "top" },
      sorting_strategy = "ascending",
    },
    pickers = {
      find_files = { hidden = true },   -- dotfiles are the point of this repo
    },
  },
  config = function(_, opts)
    local telescope = require("telescope")
    telescope.setup(opts)
    -- pcall: if `make` failed, the rest of Telescope still works.
    pcall(telescope.load_extension, "fzf")
  end,
}
