-- fzf-lua: fuzzy finder (wraps fzf binary).
return {
  {
    "ibhagwan/fzf-lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = "FzfLua",
    keys = {
      { "<leader>ff", "<cmd>FzfLua files<cr>", desc = "Find files" },
      { "<leader>fg", "<cmd>FzfLua live_grep<cr>", desc = "Live grep" },
      { "<leader>fb", "<cmd>FzfLua buffers<cr>", desc = "Buffers" },
      { "<leader>fh", "<cmd>FzfLua helptags<cr>", desc = "Help tags" },
      { "<leader>fr", "<cmd>FzfLua resume<cr>", desc = "Resume last" },
      { "<leader>fs", "<cmd>FzfLua lsp_document_symbols<cr>", desc = "Document symbols" },
      { "<leader>fS", "<cmd>FzfLua lsp_workspace_symbols<cr>", desc = "Workspace symbols" },
      { "<leader>fk", "<cmd>FzfLua keymaps<cr>", desc = "Keymaps" },
      { "<leader>fc", "<cmd>FzfLua command_history<cr>", desc = "Command history" },
      { "<leader>fo", "<cmd>FzfLua oldfiles<cr>", desc = "Recent files" },
    },
    opts = {
      "fzf-vim",
      winopts = {
        width = 0.8,
        height = 0.6,
        preview = {
          horizontal = "right:50%",
          vertical = "up:45%",
        },
      },
      fzf_opts = {
        ["--cycle"] = "",
        ["--layout"] = "reverse",
      },
    },
  },
}