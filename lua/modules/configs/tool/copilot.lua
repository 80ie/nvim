return function()
	require("modules.utils").load_plugin("copilot", {
		suggestion = { enabled = false },
		panel = { enabled = false },
	})
end
