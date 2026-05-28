local M = {}

local topics = { "tmux", "vim", "nvim", "all" }

local function helper_command()
  local path = vim.fn.expand("~/.local/bin/helpme")
  if vim.fn.executable(path) == 1 then
    return path
  end
  return "helpme"
end

local function open_plain(topic)
  local lines = vim.fn.systemlist({ helper_command(), "--no-pager", topic })
  if vim.v.shell_error ~= 0 then
    lines = {
      "Could not run helpme.",
      "",
      "Try from a shell:",
      "  helpme " .. topic,
    }
  end

  vim.cmd("tabnew")
  local buf = vim.api.nvim_get_current_buf()
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].swapfile = false
  vim.bo[buf].filetype = "markdown"
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false
  vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = buf, silent = true, desc = "Close cheatsheet" })
end

function M.open(topic)
  topic = topic or "nvim"

  vim.cmd("tabnew")
  local buf = vim.api.nvim_get_current_buf()
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].filetype = "helpme"
  vim.bo[buf].swapfile = false

  local ok, job = pcall(vim.fn.termopen, { helper_command(), topic }, {
    on_exit = function(_, code)
      if code == 0 then
        vim.schedule(function()
          if not vim.api.nvim_buf_is_valid(buf) then
            return
          end
          for _, win in ipairs(vim.fn.win_findbuf(buf)) do
            pcall(vim.api.nvim_win_close, win, true)
          end
        end)
      end
    end,
  })

  if not ok or job <= 0 then
    pcall(vim.api.nvim_buf_delete, buf, { force = true })
    open_plain(topic)
    return
  end

  vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = buf, silent = true, desc = "Close cheatsheet" })
  vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { buffer = buf, silent = true, desc = "Terminal normal mode" })
  vim.cmd("startinsert")
end

function M.setup()
  local function open_from_opts(opts)
    M.open(opts.args ~= "" and opts.args or "nvim")
  end

  local command_opts = {
    nargs = "?",
    complete = function()
      return topics
    end,
  }

  vim.api.nvim_create_user_command("Helpme", open_from_opts, command_opts)
  vim.api.nvim_create_user_command("Cheatsheet", open_from_opts, command_opts)

  vim.keymap.set("n", "<leader>?", function()
    M.open("nvim")
  end, { desc = "Open keybinding cheatsheet" })
end

return M
