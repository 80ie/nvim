return function()
	require("modules.utils").load_plugin("codecompanion", {
		interactions = {
			-- Chat runs the Claude Code CLI over ACP; uses the existing `claude` login.
			chat = { adapter = "claude_code" },
			-- ACP can't do inline/cmd; these need ANTHROPIC_API_KEY in the environment.
			inline = { adapter = "anthropic" },
			cmd = { adapter = "anthropic" },
		},
	})
end
