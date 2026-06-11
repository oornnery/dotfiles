return {
  "smartinellimarco/nvcheatsheet.nvim",
  event = "VeryLazy", -- Carrega quando digitar <F1>
  opts = {
    header = {
      " ",
      "█▀▀ █░█ █▀▀ ▄▀█ ▀█▀ █▀ █░█ █▀▀ █▀▀ ▀█▀",
      "█▄▄ █▀█ ██▄ █▀█ ░█░ ▄█ █▀█ ██▄ ██▄ ░█░",
      " ",
    },
    keymaps = {
      ["Básico"] = {
        { "Salvar", ":w" },
        { "Fechar buffer", ":bd" },
        { "Fechar todos", ":qall" },
        { "Salvar e sair", ":wq" },
        { "Próximo buffer", ":bn" },
        { "Buffer anterior", ":bp" },
        { "Split vertical", ":vsplit" },
        { "Split horizontal", ":split" },
        { "Novo arquivo", "<leader>fn" },
        { "Explorador de arquivos", ":Ex" },
      },

      ["Movimentação"] = {
        { "Descer", "j" },
        { "Subir", "k" },
        { "Direita", "l" },
        { "Esquerda", "h" },
        { "Ir para início da linha", "0" },
        { "Ir para fim da linha", "$" },
        { "Página acima", "<C-u>" },
        { "Página abaixo", "<C-d>" },
        { "Ir para início do arquivo", "gg" },
        { "Ir para fim do arquivo", "G" },
      },

      ["Busca"] = {
        { "Buscar texto", "/texto" },
        { "Repetir busca (próximo)", "n" },
        { "Repetir busca (anterior)", "N" },
        { "Substituir", ":%s/velho/novo/g" },
        { "Telescope: busca arquivos", "<leader>ff" },
        { "Telescope: grep", "<leader>fg" },
        { "Telescope: buffers", "<leader>fb" },
      },

      ["Edição"] = {
        { "Copiar linha", "yy" },
        { "Recortar linha", "dd" },
        { "Colar", "p" },
        { "Desfazer", "u" },
        { "Refazer", "<C-r>" },
        { "Visual mode", "v" },
        { "Visual block mode", "<C-v>" },
        { "Editar várias linhas", "V" },
      },

      ["Comentários"] = {
        { "Comentar linha", "gcc" },
        { "Comentar bloco", "gbc" },
        { "Comentar seleção", "gc" },
        { "Descomentar", "gc" },
      },

      ["Buffers/Windows"] = {
        { "Trocar para outro buffer", "<leader>bb" },
        { "Deletar buffer", "<leader>bd" },
        { "Deletar outros buffers", "<leader>bo" },
        { "Split abaixo", "<leader>-" },
        { "Split à direita", "<leader>|" },
        { "Fechar janela", "<leader>wd" },
        { "Toggle Zoom", "<leader>wm" },
        { "Fechar outros tabs", "<leader><tab>o" },
      },

      ["LSP (Inteligência de código)"] = {
        { "Info LSP", "<leader>cl" },
        { "Definição", "gd" },
        { "Referências", "gr" },
        { "Implementação", "gI" },
        { "Tipo", "gy" },
        { "Declaração", "gD" },
        { "Hover", "K" },
        { "Ajuda assinatura (param)", "gK" },
        { "Renomear", "<leader>cr" },
        { "Ações de código", "<leader>ca" },
        { "Formatar", "<leader>cf" },
        { "Diagnóstico rápido", "<leader>cd" },
      },

      ["Copilot Chat"] = {
        { "Abrir Chat", "<leader>cc" },
        { "Fechar Chat", "<leader>cq" },
        { "Toggle Chat", "<leader>ct" },
        { "Prompt rápido", "<leader>aq" },
        { "Limpar chat", "<leader>ax" },
      },

      ["Destaques do LazyVim"] = {
        { "Salvar (Ctrl+S)", "<C-s>" },
        { "Próxima busca", "n" },
        { "Busca anterior", "N" },
        { "Formatar arquivo", "<leader>cf" },
        { "Próximo erro", "]e" },
        { "Erro anterior", "[e" },
        { "Próximo warning", "]w" },
        { "Warning anterior", "[w" },
        { "Mudar cor tema", "<leader>uC" },
        { "Changelog LazyVim", "<leader>L" },
        { "Abrir Lazy (plugins)", "<leader>l" },
      },

      ["Outros"] = {
        { "Abrir cheatsheet", "<F1>" },
        { "Mostrar Keymaps which-key", "<leader>sk" },
        { "Pesquisar comandos", "<leader>sC" },
        { "Desfazer macro", "u" },
        { "Inserir", "i" },
        { "Sair do modo inserção", "<Esc>" },
      },
    },
  },
  config = function(_, opts)
    local nvcheatsheet = require("nvcheatsheet")
    nvcheatsheet.setup(opts)
    -- Aplique os highlights DEPOIS do setup
    vim.api.nvim_set_hl(0, "NvChAsciiHeader", { bg = "#1e222a", fg = "#b4f9f8", bold = true })
    vim.api.nvim_set_hl(0, "NvChSection", { bg = "#181c24" })
    vim.api.nvim_set_hl(0, "NvCheatsheetBlue", { fg = "#82aaff" })
    vim.api.nvim_set_hl(0, "NvCheatsheetRed", { fg = "#ff5189" })
    vim.api.nvim_set_hl(0, "NvCheatsheetYellow", { fg = "#ffe066" })
    vim.api.nvim_set_hl(0, "NvCheatsheetGreen", { fg = "#a3be8c" })
    vim.api.nvim_set_hl(0, "NvCheatsheetWhite", { fg = "#ffffff" })
    vim.keymap.set("n", "<F1>", nvcheatsheet.toggle, { desc = "Cheatsheet" })
  end,
}
