return function()
	require("modules.utils").load_plugin("codecompanion", {
		interactions = {
			-- Chat runs the Claude Code CLI over ACP; uses the existing `claude` login.
			chat = {
				adapter = "claude_code",
				-- HTTP adapters (copilot etc.) get no tools unless loaded; ACP ignores this.
				tools = { opts = { default_tools = { "agent" } } },
				-- Saves HTTP chats only (not ACP) to stdpath("data")/codecompanion/sessions.
				sessions = { autosave = true },
			},
			-- ACP can't do inline/cmd; use Copilot (sign in via :Copilot auth).
			inline = { adapter = "copilot" },
			cmd = { adapter = "copilot" },
		},
	})
end
