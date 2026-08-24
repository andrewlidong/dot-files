-- Treesitter — parses the file into a real syntax tree, which buys two
-- things: highlighting that understands the language, and text objects
-- that know what a function or a block is (daf, cif, vac).
--
-- Branch `main`, not `master`: master is frozen and explicitly does not
-- support Neovim 0.12 — on 0.12 its highlighter throws mid-redraw and
-- every buffer renders unhighlighted. main is the rewrite, and its API
-- is different: nothing is enabled implicitly, so highlighting is
-- started per-buffer below.
return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter").setup()

      local want = {
        "bash", "lua", "luadoc", "vim", "vimdoc", "query",
        "ruby", "embedded_template",     -- .rb and .erb
        "javascript", "typescript", "tsx",
        "html", "css", "json", "yaml", "toml",
        "markdown", "markdown_inline",   -- _inline is what colours **bold** and `code`
        "git_config", "gitcommit", "diff", "regex", "sql",
      }

      -- Only fetch what's missing, so startup doesn't shell out every launch.
      local installed = require("nvim-treesitter.config").get_installed("parsers")
      local missing = vim.tbl_filter(function(lang)
        return not vim.tbl_contains(installed, lang)
      end, want)
      if #missing > 0 then
        require("nvim-treesitter").install(missing)
      end

      vim.api.nvim_create_autocmd("FileType", {
        desc = "enable treesitter highlighting where a parser exists",
        callback = function(ev)
          local lang = vim.treesitter.language.get_lang(vim.bo[ev.buf].filetype)
          if not lang then return end
          if not pcall(vim.treesitter.start, ev.buf, lang) then return end
          vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end,
      })
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("nvim-treesitter-textobjects").setup({
        select = { lookahead = true },  -- jump forward to the next one if not inside
        move = { set_jumps = true },    -- so C-o walks back out
      })

      local select = require("nvim-treesitter-textobjects.select")
      local move = require("nvim-treesitter-textobjects.move")

      local function pick(lhs, obj, desc)
        vim.keymap.set({ "x", "o" }, lhs, function()
          select.select_textobject(obj, "textobjects")
        end, { desc = desc })
      end
      pick("af", "@function.outer", "a function")   -- daf deletes a whole method
      pick("if", "@function.inner", "inside a function")
      pick("ac", "@class.outer", "a class")
      pick("ic", "@class.inner", "inside a class")
      pick("aa", "@parameter.outer", "an argument")
      pick("ia", "@parameter.inner", "inside an argument")

      local function jump(lhs, fn, obj, desc)
        vim.keymap.set({ "n", "x", "o" }, lhs, function()
          fn(obj, "textobjects")
        end, { desc = desc })
      end
      jump("]f", move.goto_next_start, "@function.outer", "next function")
      jump("[f", move.goto_previous_start, "@function.outer", "previous function")
      jump("]c", move.goto_next_start, "@class.outer", "next class")
      jump("[c", move.goto_previous_start, "@class.outer", "previous class")
    end,
  },
}
