-- Python: run through uv in dedicated toggleterms, so the project's .venv and
-- dependencies are used. #9 runs commands, #8 holds the REPL, #1 is untouched.
local RUN, REPL = 9, 8

local function root()
  return vim.fs.root(0, { "pyproject.toml", ".git" })
end

local function run(cmd, num)
  return function()
    require("toggleterm").exec(cmd, num or RUN, 14, root(), "horizontal")
  end
end

local function file_cmd(prefix)
  return function()
    vim.cmd("silent update")
    run(prefix .. " " .. vim.fn.shellescape(vim.fn.expand("%:p")))()
  end
end

-- Bracketed paste keeps the 3.13+ REPL from auto-indenting pasted blocks twice.
local function send(lines)
  local term = require("toggleterm.terminal").get(REPL)
  if not term or not term.job_id or vim.fn.jobwait({ term.job_id }, 0)[1] ~= -1 then
    vim.notify("Python REPL is not open: start it with <localleader>i", vim.log.levels.WARN)
    return
  end
  vim.api.nvim_chan_send(term.job_id, "\27[200~" .. table.concat(lines, "\n") .. "\27[201~\n\n")
end

local map = function(mode, lhs, rhs, desc)
  vim.keymap.set(mode, lhs, rhs, { buffer = true, desc = "Python: " .. desc })
end

map("n", "<localleader>r", file_cmd("uv run python"), "run file")
map("n", "<localleader>t", file_cmd("uv run pytest"), "pytest file")
map("n", "<localleader>T", run("uv run pytest"), "pytest project")
map("n", "<localleader>c", run("uvx ty check; uvx ruff check"), "ty + ruff check")
map("n", "<localleader>i", run("uv run python", REPL), "REPL")
map("n", "<localleader>s", function()
  send({ vim.api.nvim_get_current_line() })
end, "send line to REPL")
map("x", "<localleader>s", function()
  send(vim.fn.getregion(vim.fn.getpos("v"), vim.fn.getpos("."), { type = vim.fn.mode() }))
  vim.api.nvim_feedkeys(vim.keycode("<Esc>"), "n", false)
end, "send selection to REPL")
