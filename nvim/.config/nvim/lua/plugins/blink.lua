-- blink.cmp: completion engine (Rust-backed fuzzy). Requires nvim 0.12+.
return {
	{
		"saghen/blink.cmp",
		version = "1.*",
		dependencies = {
			"saghen/blink.lib",
			"rafamadriz/friendly-snippets",
		},
		-- Build fuzzy matcher (Rust). Pre-built binary on tagged releases.
		-- `build()` is only needed when building from source / main branch.
		build = "cargo build --release",
		---@module 'blink.cmp'
		---@type blink.cmp.Config
		opts = {
			keymap = { preset = "super-tab" },
			sources = {
				default = { "lsp", "path", "snippets", "buffer" },
			},
			completion = {
				trigger = { prefetch_on_insert = false },
				documentation = { auto_show = true, auto_show_delay_ms = 300, window = { border = "rounded" } },
				menu = { auto_show = true, border = "rounded" },
				ghost_text = { enabled = true },
				accept = { auto_brackets = { enabled = true } },
			},
			signature = { enabled = true, window = { border = "rounded" } },
			fuzzy = { implementation = "prefer_rust_with_warning" },
			appearance = { nerd_font_variant = "mono" },
		},
	},
}
