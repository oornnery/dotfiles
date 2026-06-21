-- AI assistance: CodeCompanion chat/actions and Minuet local/model-agnostic completions.
local function env_set(name)
  return vim.env[name] ~= nil and vim.env[name] ~= ""
end

local function strip_trailing_slash(value)
  return (value or ""):gsub("/+$", "")
end

local function http_adapter()
  if env_set("OPENAI_API_KEY") then
    return "openai"
  end
  if env_set("ANTHROPIC_API_KEY") then
    return "anthropic"
  end
  if env_set("GEMINI_API_KEY") then
    return "gemini"
  end
  if env_set("OLLAMA_HOST") or vim.fn.executable("ollama") == 1 then
    return "ollama"
  end
  return "copilot"
end

local function chat_adapter()
  if vim.fn.executable("opencode") == 1 then
    return { name = "opencode" }
  end
  return http_adapter()
end

local function minuet_provider()
  if env_set("MINUET_PROVIDER") then
    return vim.env.MINUET_PROVIDER
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
    "olimorris/codecompanion.nvim",
    version = "^19.0.0",
    cmd = {
      "CodeCompanion",
      "CodeCompanionActions",
      "CodeCompanionChat",
      "CodeCompanionCLI",
      "CodeCompanionCmd",
    },
    keys = {
      { "<leader>aa", "<cmd>CodeCompanionActions<cr>", mode = { "n", "v" }, desc = "AI actions" },
      { "<leader>ac", "<cmd>CodeCompanionChat Toggle<cr>", desc = "AI chat toggle" },
      { "<leader>aC", "<cmd>CodeCompanionChat<cr>", desc = "AI chat" },
      { "<leader>ad", "<cmd>CodeCompanionChat Add<cr>", mode = "v", desc = "AI add selection to chat" },
      { "<leader>ai", "<cmd>CodeCompanion<cr>", mode = "n", desc = "AI inline prompt" },
      { "<leader>ai", ":CodeCompanion<cr>", mode = "v", desc = "AI inline selection" },
      { "<leader>ae", ":CodeCompanion /explain<cr>", mode = "v", desc = "AI explain selection" },
      { "<leader>af", ":CodeCompanion /fix<cr>", mode = "v", desc = "AI fix selection" },
      { "<leader>at", ":CodeCompanion /tests<cr>", mode = "v", desc = "AI tests for selection" },
      { "<leader>am", "<cmd>CodeCompanionCmd<cr>", desc = "AI command" },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    opts = function()
      local http = http_adapter()
      return {
        interactions = {
          chat = { adapter = chat_adapter() },
          inline = { adapter = http },
          cmd = { adapter = http },
          background = { adapter = http },
        },
        opts = {
          log_level = "ERROR",
        },
      }
    end,
  },

  {
    "milanglacier/minuet-ai.nvim",
    event = "InsertEnter",
    cmd = "Minuet",
    keys = {
      { "<leader>as", "<cmd>Minuet virtualtext toggle<cr>", desc = "AI inline toggle" },
      { "<leader>aS", "<cmd>Minuet blink toggle<cr>", desc = "AI completion toggle" },
      { "<leader>aM", "<cmd>Minuet change_model<cr>", desc = "AI model picker" },
      { "<leader>aP", ":Minuet change_provider ", desc = "AI provider" },
    },
    opts = function()
      local ollama_model = vim.env.MINUET_MODEL or "qwen2.5-coder:7b"
      return {
        provider = minuet_provider(),
        request_timeout = tonumber(vim.env.MINUET_TIMEOUT) or 3,
        throttle = tonumber(vim.env.MINUET_THROTTLE) or 1500,
        debounce = tonumber(vim.env.MINUET_DEBOUNCE) or 600,
        context_window = tonumber(vim.env.MINUET_CONTEXT) or 4096,
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
              max_tokens = tonumber(vim.env.MINUET_MAX_TOKENS) or 96,
              top_p = 0.9,
            },
          },
          openai_compatible = {
            api_key = env_set("MINUET_API_KEY") and "MINUET_API_KEY" or "OPENROUTER_API_KEY",
            name = vim.env.MINUET_NAME or "OpenAI-compatible",
            end_point = minuet_endpoint("/v1/chat/completions"),
            model = ollama_model,
            optional = {
              max_tokens = tonumber(vim.env.MINUET_MAX_TOKENS) or 96,
              top_p = 0.9,
            },
          },
          openai = {
            api_key = "OPENAI_API_KEY",
            model = vim.env.MINUET_MODEL or "gpt-4.1-mini",
            optional = {
              max_tokens = tonumber(vim.env.MINUET_MAX_TOKENS) or 96,
            },
          },
          claude = {
            api_key = "ANTHROPIC_API_KEY",
            model = vim.env.MINUET_MODEL or "claude-3-5-haiku-latest",
            max_tokens = tonumber(vim.env.MINUET_MAX_TOKENS) or 96,
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
