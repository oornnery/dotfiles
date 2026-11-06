-- ~/.config/nvim/lua/plugins/dial.lua
-- dial.nvim — make Ctrl-a / Ctrl-x smarter:
--   true ↔ false, yes ↔ no, on ↔ off, day-of-week, months, dates, hex colors, etc.

return {
  {
    "monaqa/dial.nvim",
    keys = {
      { "<C-a>", function() require("dial.map").manipulate("increment", "normal") end, desc = "Increment" },
      { "<C-x>", function() require("dial.map").manipulate("decrement", "normal") end, desc = "Decrement" },
      { "g<C-a>", function() require("dial.map").manipulate("increment", "gnormal") end, desc = "Inc (cumulative)" },
      { "g<C-x>", function() require("dial.map").manipulate("decrement", "gnormal") end, desc = "Dec (cumulative)" },
      { "<C-a>", function() require("dial.map").manipulate("increment", "visual") end, mode = "v", desc = "Increment" },
      { "<C-x>", function() require("dial.map").manipulate("decrement", "visual") end, mode = "v", desc = "Decrement" },
    },
    config = function()
      local augend = require("dial.augend")
      require("dial.config").augends:register_group({
        default = {
          augend.integer.alias.decimal,
          augend.integer.alias.hex,
          augend.date.alias["%Y-%m-%d"],
          augend.date.alias["%Y/%m/%d"],
          augend.constant.alias.bool,                                  -- true ↔ false
          augend.constant.new({ elements = { "yes", "no" }, word = true, cyclic = true }),
          augend.constant.new({ elements = { "on", "off" }, word = true, cyclic = true }),
          augend.constant.new({ elements = {
            "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday",
          }, word = true, cyclic = true }),
          augend.constant.new({ elements = {
            "January", "February", "March", "April", "May", "June",
            "July", "August", "September", "October", "November", "December",
          }, word = true, cyclic = true }),
          augend.semver.alias.semver,
          augend.hexcolor.new({ case = "lower" }),
        },
      })
    end,
  },
}
