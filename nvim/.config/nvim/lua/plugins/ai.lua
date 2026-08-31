-- AI completion: Minuet provides local/model-agnostic suggestions.
local function env_set(name)
  return vim.env[name] ~= nil and vim.env[name] ~= ""
end

local function strip_trailing_slash(value)
  return (value or ""):gsub("/+$", "")
end

local function opencode_api_key(provider, env_name)
  if env_name and env_set(env_name) then
    return vim.env[env_name]
  end
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

local function minuet_provider(has_subscription)
  if env_set("MINUET_PROVIDER") then
    return vim.env.MINUET_PROVIDER
  end
  if has_subscription then
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

local preset_labels = {
  opencode_go = "DeepSeek V4 Flash — OpenCode Go",
  deepseek_free = "DeepSeek V4 Flash Free — OpenCode Zen",
  glm = "GLM-5.3-Flash — Z.AI Coding Plan",
}

local function change_preset(name)
  local minuet = require("minuet")
  if not minuet.presets[name] then
    vim.notify("Minuet credential unavailable for " .. preset_labels[name], vim.log.levels.WARN)
    return
  end
  minuet.change_preset(name)
end

return {
  {
    "milanglacier/minuet-ai.nvim",
    event = "InsertEnter",
    cmd = "Minuet",
    keys = {
      { "<leader>as", "<cmd>Minuet virtualtext toggle<cr>", desc = "AI inline toggle" },
      { "<leader>aM", "<cmd>Minuet change_model<cr>", desc = "AI model picker" },
      { "<leader>ag", function() change_preset("glm") end, desc = "AI use GLM" },
      { "<leader>ao", function() change_preset("opencode_go") end, desc = "AI use OpenCode Go" },
      { "<leader>af", function() change_preset("deepseek_free") end, desc = "AI use DeepSeek free" },
      {
        "<leader>aP",
        function()
          local minuet = require("minuet")
          local available = {}
          for _, name in ipairs({ "opencode_go", "deepseek_free", "glm" }) do
            if minuet.presets[name] then
              table.insert(available, { name = name, label = preset_labels[name] })
            end
          end
          vim.ui.select(available, {
            prompt = "Minuet provider",
            format_item = function(item) return item.label end,
          }, function(choice)
            if choice then
              change_preset(choice.name)
            end
          end)
        end,
        desc = "AI provider preset",
      },
    },
    opts = function()
      local go_key = opencode_api_key("opencode-go", "OPENCODE_GO_API_KEY")
      local zen_key = opencode_api_key("opencode", "OPENCODE_API_KEY") or go_key
      local zai_key = opencode_api_key("zai-coding-plan", "ZAI_API_KEY")
        or opencode_api_key("zai", "ZAI_API_KEY")
      local automatic = not env_set("MINUET_PROVIDER") and not env_set("MINUET_ENDPOINT")
      local use_zai = zai_key ~= nil and automatic
      local use_go = not use_zai and go_key ~= nil and automatic
      local ollama_model = vim.env.MINUET_MODEL or "qwen2.5-coder:1.5b"
      local function compatible(key, name, endpoint, model)
        return {
          api_key = function()
            return key
          end,
          name = name,
          end_point = endpoint,
          model = model,
          optional = {
            max_tokens = tonumber(vim.env.MINUET_MAX_TOKENS) or 56,
            top_p = 0.9,
            thinking = { type = "disabled" },
          },
        }
      end

      local presets = {}
      if go_key then
        presets.opencode_go = {
          provider = "openai_compatible",
          provider_options = {
            openai_compatible = compatible(
              go_key,
              "OpenCode Go",
              "https://opencode.ai/zen/go/v1/chat/completions",
              "deepseek-v4-flash"
            ),
          },
        }
      end
      if zen_key then
        presets.deepseek_free = {
          provider = "openai_compatible",
          provider_options = {
            openai_compatible = compatible(
              zen_key,
              "OpenCode Zen Free",
              "https://opencode.ai/zen/v1/chat/completions",
              "deepseek-v4-flash-free"
            ),
          },
        }
      end
      if zai_key then
        presets.glm = {
          provider = "openai_compatible",
          provider_options = {
            openai_compatible = compatible(
              zai_key,
              "Z.AI Coding Plan",
              "https://api.z.ai/api/coding/paas/v4/chat/completions",
              "glm-5.3-flash"
            ),
          },
        }
      end

      return {
        provider = minuet_provider(use_go or use_zai),
        presets = presets,
        request_timeout = tonumber(vim.env.MINUET_TIMEOUT) or 8,
        throttle = tonumber(vim.env.MINUET_THROTTLE) or 700,
        debounce = tonumber(vim.env.MINUET_DEBOUNCE) or 300,
        context_window = tonumber(vim.env.MINUET_CONTEXT) or 2048,
        n_completions = tonumber(vim.env.MINUET_COMPLETIONS) or 1,
        notify = "warn",
        blink = {
          -- Automatic requests come from virtual text only. <A-y> still
          -- invokes Minuet manually inside blink.cmp when desired.
          enable_auto_complete = false,
        },
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
          show_on_completion_menu = true,
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
            api_key = (use_go or use_zai) and function()
              return use_go and go_key or zai_key
            end or (env_set("MINUET_API_KEY") and "MINUET_API_KEY" or "OPENROUTER_API_KEY"),
            name = vim.env.MINUET_NAME
              or (use_go and "OpenCode Go" or (use_zai and "Z.AI Coding Plan" or "OpenAI-compatible")),
            end_point = use_go and "https://opencode.ai/zen/go/v1/chat/completions"
              or (use_zai and "https://api.z.ai/api/coding/paas/v4/chat/completions")
              or minuet_endpoint("/v1/chat/completions"),
            model = vim.env.MINUET_MODEL
              or (use_go and "deepseek-v4-flash" or (use_zai and "glm-5.3-flash" or ollama_model)),
            optional = {
              max_tokens = tonumber(vim.env.MINUET_MAX_TOKENS) or 56,
              top_p = 0.9,
              thinking = { type = "disabled" },
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
