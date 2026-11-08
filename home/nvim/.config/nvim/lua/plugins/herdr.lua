-- herdr ↔ Neovim navigation.
--
-- One movement vocabulary: <C-h/j/k/l> moves between Neovim splits and, at a
-- split edge, hands the key to herdr so focus crosses into the neighbouring
-- pane. Outside herdr the file falls back to tmux or plain wincmd.
--
-- The herdr half is the same repository, cloned and `herdr plugin link`ed by
-- scripts/arch/dev/herdr.sh at the commit pinned below. Keep the two in sync:
-- the plugin forwards literal ctrl+h/j/k/l into the pane, so a mismatch changes
-- navigation semantics silently.

local PINNED = "79679dacc791f70fc34de8b29a3cf9706c0f5b2f"

return {
  {
    "paulbkim-dev/vim-herdr-navigation",
    commit = PINNED,
    -- VeryLazy, not lazy=false: init.lua requires config.keymaps *after* lazy
    -- sets up, and those plain <C-w>h/j/k/l maps must stay as the fallback when
    -- herdr is absent. Loading here means the plugin overrides them last.
    event = "VeryLazy",
    enabled = vim.fn.executable("herdr") == 1,
    config = function(plugin)
      dofile(plugin.dir .. "/editor/nvim.lua")
    end,
  },
}
