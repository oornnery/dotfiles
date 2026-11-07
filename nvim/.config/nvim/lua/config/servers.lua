-- Language servers. `needs` is the runtime Mason requires to install one, so a
-- machine without it skips that server instead of showing install errors.
local M = {}

local servers = {
  { "lua_ls" },
  { "ruff" },
  { "ty" },
  { "bashls", needs = "node" },
  { "ts_ls", needs = "node" },
  { "html", needs = "node" },
  { "cssls", needs = "node" },
  { "tailwindcss", needs = "node" },
  { "eslint", needs = "node" },
  { "jsonls", needs = "node" },
  { "yamlls", needs = "node" },
  { "dockerls", needs = "node" },
  { "docker_compose_language_service", needs = "node" },
  { "graphql", needs = "node" },
  { "vue_ls", needs = "node" },
  { "svelte", needs = "node" },
  { "taplo" },
  { "marksman" },
  { "clangd" },
  { "rust_analyzer" },
  { "gopls", needs = "go" },
  { "terraformls" },
  { "jdtls", needs = "java" },
  { "zls", needs = "zig" },
}

function M.installable()
  local names = {}
  for _, server in ipairs(servers) do
    if not server.needs or vim.fn.executable(server.needs) == 1 then
      table.insert(names, server[1])
    end
  end
  return names
end

-- A server with no command on this machine stays off.
function M.available()
  local names = {}
  for _, server in ipairs(servers) do
    local config = vim.lsp.config[server[1]]
    local cmd = config and config.cmd
    if type(cmd) == "function" or (type(cmd) == "table" and vim.fn.executable(cmd[1]) == 1) then
      table.insert(names, server[1])
    end
  end
  return names
end

return M
