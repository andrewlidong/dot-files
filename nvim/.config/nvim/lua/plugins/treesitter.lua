-- Treesitter — parses the file into a real syntax tree, which buys two
-- things: highlighting that understands the language, and text objects
-- that know what a function or a block is (daf, cif, vac).
return {
  "nvim-treesitter/nvim-treesitter",
  branch = "master",
  build = ":TSUpdate",
  event = { "BufReadPost", "BufNewFile" },
  dependencies = { "nvim-treesitter/nvim-treesitter-textobjects" },
  main = "nvim-treesitter.configs",
  opts = {
    ensure_installed = {
      "bash", "lua", "vim", "vimdoc", "query",
      "ruby", "embedded_template",     -- .rb and .erb
      "javascript", "typescript", "tsx",
      "html", "css", "json", "yaml", "toml", "markdown", "markdown_inline",
      "git_config", "gitcommit", "diff", "regex", "sql",
    },
    auto_install = true,               -- grab a parser when you open a new filetype
    highlight = { enable = true },
    indent = { enable = true },
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = "<C-space>",    -- start from the node under the cursor
        node_incremental = "<C-space>",  -- …and widen to the enclosing node
        node_decremental = "<BS>",
      },
    },
    textobjects = {
      select = {
        enable = true,
        lookahead = true,              -- jump forward to the next one if not inside
        keymaps = {
          ["af"] = "@function.outer",  -- daf deletes a whole method
          ["if"] = "@function.inner",
          ["ac"] = "@class.outer",
          ["ic"] = "@class.inner",
          ["aa"] = "@parameter.outer",
          ["ia"] = "@parameter.inner",
        },
      },
      move = {
        enable = true,
        set_jumps = true,              -- so C-o walks back out
        goto_next_start = { ["]f"] = "@function.outer", ["]c"] = "@class.outer" },
        goto_previous_start = { ["[f"] = "@function.outer", ["[c"] = "@class.outer" },
      },
    },
  },
}
