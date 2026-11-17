return function()
	require("modules.utils").load_plugin("aerial", {
		-- treesitter/markdown need no LSP, so this works for .md and .tex too
		-- marksman (when installed) attaches to markdown and wins an lsp-first order
		-- but gives empty results here, so markdown goes treesitter-first.
		backends = {
			["_"] = { "lsp", "treesitter", "markdown", "man" },
			markdown = { "treesitter", "markdown" },
		},
		layout = {
			-- edgy docks the window; "edge" keeps aerial a full-height sidebar for it to claim
			placement = "edge",
			default_direction = "left",
		},
		attach_mode = "global",
		show_guides = true,
		close_automatic_events = {},
	})
end
