-- Editor integrations: file explorers, gitsigns, smear-cursor, autopairs.
return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    cmd = "Neotree",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    keys = {
      { "<leader>e", "<cmd>Neotree toggle reveal left<cr>", desc = "Explorer sidebar" },
      { "<leader>E", "<cmd>Neotree reveal float<cr>", desc = "Explorer float" },
      { "<leader>ge", "<cmd>Neotree git_status toggle left<cr>", desc = "Git explorer" },
      { "<leader>be", "<cmd>Neotree buffers toggle left<cr>", desc = "Buffer explorer" },
    },
    opts = {
      close_if_last_window = true,
      enable_git_status = true,
      enable_diagnostics = true,
      sources = { "filesystem", "buffers", "git_status" },
      source_selector = {
        winbar = true,
        statusline = false,
      },
      filesystem = {
        hijack_netrw_behavior = "disabled",
        follow_current_file = {
          enabled = true,
          leave_dirs_open = true,
        },
        group_empty_dirs = true,
        use_libuv_file_watcher = true,
        filtered_items = {
          visible = false,
          hide_dotfiles = true,
          hide_gitignored = true,
          never_show = { ".git", ".DS_Store", "thumbs.db" },
        },
        window = {
          mappings = {
            ["H"] = "toggle_hidden",
            ["/"] = "fuzzy_finder",
          },
        },
      },
      window = {
        position = "left",
        width = 34,
        mappings = {
          ["<space>"] = "toggle_node",
          ["<cr>"] = "open",
          ["l"] = "open",
          ["h"] = "close_node",
          ["S"] = "open_split",
          ["s"] = "open_vsplit",
          ["t"] = "open_tabnew",
          ["P"] = "toggle_preview",
          ["R"] = "refresh",
          ["q"] = "close_window",
          ["?"] = "show_help",
        },
      },
    },
  },

  {
    "stevearc/oil.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = "Oil",
    keys = {
      { "-", "<cmd>Oil<cr>", desc = "Open parent dir (oil)" },
      { "<leader>o", "<cmd>Oil<cr>", desc = "Open Oil dir buffer" },
      {
        "<leader>O",
        function()
          require("oil").open_float()
        end,
        desc = "Open Oil float",
      },
    },
    opts = {
      default_file_explorer = true,
      columns = { "icon" },
      view_options = {
        natural_order = "fast",
        show_hidden = false,
      },
      skip_confirm_for_simple_edits = true,
      delete_to_trash = true,
      win_options = {
        signcolumn = "no",
        wrap = false,
        spell = false,
        list = false,
      },
      float = { border = "rounded" },
      keymaps = {
        ["g?"] = "actions.show_help",
        ["<CR>"] = "actions.select",
        ["<C-s>"] = { "actions.select", opts = { vertical = true } },
        ["<C-h>"] = { "actions.select", opts = { horizontal = true } },
        ["<C-t>"] = { "actions.select", opts = { tab = true } },
        ["<C-p>"] = "actions.preview",
        ["<C-c>"] = "actions.close",
        ["<C-l>"] = "actions.refresh",
        ["-"] = "actions.parent",
        ["_"] = "actions.open_cwd",
        ["g."] = "actions.toggle_hidden",
      },
    },
  },

  {
    "lewis6991/gitsigns.nvim",
    event = "BufReadPre",
    opts = {
      signs = {
        add = { text = "┃" },
        change = { text = "┃" },
        delete = { text = "_" },
        topdelete = { text = "‾" },
        changedelete = { text = "~" },
        untracked = { text = "┆" },
      },
      on_attach = function(bufnr)
        local gs = require("gitsigns")
        local function map(mode, lhs, rhs, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, lhs, rhs, opts)
        end
        map("n", "]c", function()
          if vim.wo.diff then
            vim.cmd.normal({ "]c", bang = true })
          else
            gs.nav_hunk("next")
          end
        end, { desc = "Next hunk" })
        map("n", "[c", function()
          if vim.wo.diff then
            vim.cmd.normal({ "[c", bang = true })
          else
            gs.nav_hunk("prev")
          end
        end, { desc = "Prev hunk" })
        map("n", "<leader>hs", gs.stage_hunk, { desc = "Stage hunk" })
        map("n", "<leader>hr", gs.reset_hunk, { desc = "Reset hunk" })
        map("v", "<leader>hs", function()
          gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end, { desc = "Stage hunk (v)" })
        map("v", "<leader>hr", function()
          gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end, { desc = "Reset hunk (v)" })
        map("n", "<leader>hS", gs.stage_buffer, { desc = "Stage buffer" })
        map("n", "<leader>hR", gs.reset_buffer, { desc = "Reset buffer" })
        map("n", "<leader>hp", gs.preview_hunk, { desc = "Preview hunk" })
        map("n", "<leader>hb", function()
          gs.blame_line({ full = true })
        end, { desc = "Blame line" })
        map("n", "<leader>hd", gs.diffthis, { desc = "Diff this" })
        map({ "o", "x" }, "ih", gs.select_hunk, { desc = "Select hunk" })
      end,
    },
  },

  {
    "sphamba/smear-cursor.nvim",
    lazy = false,
    opts = {
      smear_between_buffers = true,
      smear_between_neighbor_lines = true,
      smear_insert_mode = true,
      scroll_buffer_space = true,
      hide_target_hack = true,
      cursor_color = "none",
      time_interval = 17,
      stiffness = 0.7,
      trailing_stiffness = 0.5,
    },
  },

  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {
      check_ts = true,
      disable_filetype = { "TelescopePrompt", "vim", "lazy", "mason", "oil", "neo-tree", "codecompanion" },
      enable_check_bracket_line = true,
      map_cr = true,
      map_bs = true,
    },
  },
}
