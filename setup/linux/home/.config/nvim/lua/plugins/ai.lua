return {
  -- COPILOT: Autocomplete (Sugestões de código IA, inline)
  {
    "github/copilot.vim", -- caso prefira versão vim/nvim nativa mais estável
    event = "InsertEnter",
    -- Para versões mais novas, consulte :Copilot setup na documentação LazyVim.
  },
  -- COPILOT-CHAT: Chat Copilot context-aware
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    dependencies = {
      { "nvim-lua/plenary.nvim", branch = "master" },
    },
    build = "make tiktoken",
    opts = {
      -- See Configuration section for options
      model = "claude-sonnet-4",
      temperature = 0.1,
      window = {
        layout = "float", -- 'float' or 'vertical'
        width = 160, -- Fixed width in columns
        height = 40, -- Fixed height in rows
        border = "single", -- 'single', 'double', 'rounded', 'solid'
        title = "🤖 AI Assistant",
        zindex = 100, -- Ensure window stays on top
      },

      headers = {
        user = "👤 You",
        assistant = "🤖 Copilot",
        tool = "🔧 Tool",
      },

      separator = "━━",
      auto_fold = true, -- Automatically folds non-assistant messages
    },
    keys = {
      -- Atalho para abrir Copilot Chat
      { "<leader>cc", ":CopilotChatOpen<CR>", desc = "Abrir Copilot Chat" },
      -- Atalho para fechar Copilot Chat
      { "<leader>cq", ":CopilotChatClose<CR>", desc = "Fechar Copilot Chat" },
      -- Atalho para alternar Copilot Chat (toggle)
      { "<leader>ct", ":CopilotChatToggle<CR>", desc = "Toggle Copilot Chat" },
    },
  },

  -- CLAUDE CODE (Anthropic): LLM e agente completo via Neovim
  {
    "coder/claudecode.nvim",
    dependencies = {
      "folke/snacks.nvim",
      "nvim-lua/plenary.nvim", -- Dependência adicional comum
    },
    config = true,
    keys = {
      -- Grupo principal AI/Claude
      { "<leader>a", desc = "+AI/Claude Code" },

      -- Comandos básicos
      { "<leader>ac", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude" },
      { "<leader>af", "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude" },
      { "<leader>ar", "<cmd>ClaudeCode --resume<cr>", desc = "Resume Claude" },
      { "<leader>aC", "<cmd>ClaudeCode --continue<cr>", desc = "Continue Claude" },
      { "<leader>am", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Select Claude model" },

      -- Adicionar arquivos/conteúdo
      { "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", desc = "Add current buffer" },
      { "<leader>as", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send selection to Claude" },
      {
        "<leader>at",
        "<cmd>ClaudeCodeTreeAdd<cr>",
        desc = "Add file from tree",
        ft = { "NvimTree", "neo-tree", "oil", "minifiles", "snacks_explorer" }, -- Adicionei snacks_explorer
      },

      -- Gestão de diffs
      { "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
      { "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Deny diff" },

      -- Atalhos adicionais úteis
      { "<leader>aq", "<cmd>ClaudeCodeStop<cr>", desc = "Stop Claude" },
      { "<leader>ah", "<cmd>ClaudeCodeHistory<cr>", desc = "Show history" },
    },
  },

  -- Snacks (dependência para floating terminals do Claude/LLMs)
}
