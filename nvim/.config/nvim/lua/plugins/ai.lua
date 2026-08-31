-- AI completion: Minuet provides local/model-agnostic suggestions.
local function env_set(name)
  return vim.env[name] ~= nil and vim.env[name] ~= ""
end

local function strip_trailing_slash(value)
  return (value or ""):gsub("/+$", "")
end

local function opencode_api_key(provider)
  local data_home = vim.env.XDG_DATA_HOME or vim.fn.expand("~/.local/share")
  local path = data_home .. "/opencode/auth.json"
  local ok_read, lines = pcall(vim.fn.readfile, path)
  if not ok_read then
    return nil
  end
  local ok_decode, auth = pcall(vim.json.decode, table.concat(lines, "\n"))
  local entry = ok_decode and auth[provider] or nil
  return entry and entry.type == "api" and entry.key or nil
end

local function minuet_provider(has_zai)
  if env_set("MINUET_PROVIDER") then
    return vim.env.MINUET_PROVIDER
  end
  if has_zai then
    return "openai_compatible"
  end
  if env_set("OLLAMA_HOST") or vim.fn.executable("ollama") == 1 then
    return "openai_fim_compatible"
  end
  if env_set("OPENAI_API_KEY") then
    return "openai"
  end
  if env_set("ANTHROPIC_API_KEY") then
    return "claude"
  end
  if env_set("GEMINI_API_KEY") then
    return "gemini"
  end
  return "openai_fim_compatible"
end

local function minuet_endpoint(path)
  if env_set("MINUET_ENDPOINT") then
    return vim.env.MINUET_ENDPOINT
  end
  return strip_trailing_slash(vim.env.OLLAMA_HOST or "http://localhost:11434") .. path
end

return {
  {
    "milanglacier/minuet-ai.nvim",
    event = "InsertEnter",
    cmd = "Minuet",
    keys = {
      { "<leader>as", "<cmd>Minuet virtualtext toggle<cr>", desc = "AI inline toggle" },
      { "<leader>aM", "<cmd>Minuet change_model<cr>", desc = "AI model picker" },
    },
    opts = function()
      local zai_key = opencode_api_key("zai-coding-plan") or opencode_api_key("zai")
      local use_zai = zai_key ~= nil and not env_set("MINUET_PROVIDER") and not env_set("MINUET_ENDPOINT")
      local ollama_model = vim.env.MINUET_MODEL or "qwen2.5-coder:1.5b"
      return {
        provider = minuet_provider(use_zai),
        request_timeout = tonumber(vim.env.MINUET_TIMEOUT) or 3,
        throttle = tonumber(vim.env.MINUET_THROTTLE) or 1500,
        debounce = tonumber(vim.env.MINUET_DEBOUNCE) or 600,
        context_window = tonumber(vim.env.MINUET_CONTEXT) or 1024,
        n_completions = tonumber(vim.env.MINUET_COMPLETIONS) or 1,
        notify = "warn",
        virtualtext = {
          auto_trigger_ft = {
            "lua",
            "python",
            "javascript",
            "typescript",
            "javascriptreact",
            "typescriptreact",
            "rust",
            "go",
            "sh",
            "bash",
            "zsh",
            "html",
            "css",
            "json",
            "yaml",
            "toml",
          },
          auto_trigger_ignore_ft = { "help", "lazy", "mason", "neo-tree", "oil", "Trouble", "codecompanion" },
          keymap = {
            accept = "<C-l>",
            accept_line = "<C-j>",
            next = "<A-n>",
            prev = "<A-p>",
            dismiss = "<C-]>",
          },
        },
        provider_options = {
          openai_fim_compatible = {
            api_key = "TERM",
            name = "Ollama",
            end_point = minuet_endpoint("/v1/completions"),
            model = ollama_model,
            optional = {
              max_tokens = tonumber(vim.env.MINUET_MAX_TOKENS) or 56,
              top_p = 0.9,
            },
          },
          openai_compatible = {
            api_key = use_zai and function()
              return zai_key
            end or (env_set("MINUET_API_KEY") and "MINUET_API_KEY" or "OPENROUTER_API_KEY"),
            name = vim.env.MINUET_NAME or (use_zai and "Z.AI Coding Plan" or "OpenAI-compatible"),
            end_point = use_zai and "https://api.z.ai/api/coding/paas/v4/chat/completions"
              or minuet_endpoint("/v1/chat/completions"),
            model = vim.env.MINUET_MODEL or (use_zai and "glm-5.3-flash" or ollama_model),
            optional = {
              max_tokens = tonumber(vim.env.MINUET_MAX_TOKENS) or 56,
              top_p = 0.9,
            },
          },
          openai = {
            api_key = "OPENAI_API_KEY",
            model = vim.env.MINUET_MODEL or "gpt-4.1-mini",
            optional = {
              max_tokens = tonumber(vim.env.MINUET_MAX_TOKENS) or 56,
            },
          },
          claude = {
            api_key = "ANTHROPIC_API_KEY",
            model = vim.env.MINUET_MODEL or "claude-3-5-haiku-latest",
            max_tokens = tonumber(vim.env.MINUET_MAX_TOKENS) or 56,
          },
          gemini = {
            api_key = "GEMINI_API_KEY",
            model = vim.env.MINUET_MODEL or "gemini-2.5-flash",
          },
        },
      }
    end,
    config = function(_, opts)
      require("minuet").setup(opts)
    end,
  },
}
