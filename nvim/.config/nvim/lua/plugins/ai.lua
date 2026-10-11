-- AI completion: codex-complete drives ghost text through `codex app-server`,
-- so it uses the ChatGPT subscription from `codex login`, not an API key.
-- Threads are ephemeral, read-only, with no network and no approvals.
return {
  {
    "joegoggin/codex-complete.nvim",
    main = "codex_complete",
    event = "VeryLazy",
    cond = vim.fn.executable("codex") == 1,
    opts = {
      loading_indicator = false,
      highlights = { suggestion = "Comment", background = false },
      -- Related-context lookup calls the deprecated client.supports_method();
      -- Codex reads project files itself, so the extra LSP snippets are optional.
      context = { related = { enabled = false } },
      keymaps = {
        accept = "<C-l>",
        trigger = "<M-s>",
        comment_trigger = "<leader>ai",
        comment_accept = "<M-;>",
        toggle = "<leader>as",
        select_model = "<leader>aM",
        select_effort = "<leader>aR",
      },
    },
  },
}
