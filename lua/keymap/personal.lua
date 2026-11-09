local bind = require("keymap.bind")
local map_cr, map_cmd, map_callback = bind.map_cr, bind.map_cmd, bind.map_callback

local function reindent()
	local view = vim.fn.winsaveview()
	vim.cmd("silent keepjumps normal! gg=G")
	vim.fn.winrestview(view)
end

local mappings = {
	-- macros: record with Q instead of q, so q can't start one by accident
	["n|q"] = map_cmd("<Nop>"):with_noremap():with_desc("edit: Disabled (use Q to record)"),
	["nx|Q"] = map_cmd("q"):with_noremap():with_desc("edit: Record macro / stop recording"),
	["ic|<C-BS>"] = map_cmd("<C-w>"):with_noremap():with_desc("edit: Delete previous word"),
	["n|<leader>="] = map_callback(reindent):with_noremap():with_silent():with_desc("edit: Reindent buffer"),
	["x|<leader>="] = map_cmd("="):with_noremap():with_desc("edit: Reindent selection"),

	-- help
	["n|<leader>/"] = map_cr("Cheatsheet"):with_silent():with_desc("help: Cheatsheet"),
	["n|<leader>?"] = map_cr("WhichKey"):with_silent():with_desc("help: All keymaps"),
	["n|<leader>fC"] = map_cr("CheatsheetEdit"):with_silent():with_desc("help: Edit cheatsheet"),

	-- files / buffers
	["n|<leader>e"] = map_cr("NvimTreeToggle"):with_silent():with_desc("filetree: Toggle"),
	["n|<leader>E"] = map_cr("NvimTreeFindFile"):with_silent():with_desc("filetree: Reveal file"),
	["n|<leader>fb"] = map_cr("Telescope buffers"):with_silent():with_desc("tool: Buffers"),
	["n|]b"] = map_cr("BufferLineCycleNext"):with_silent():with_desc("buffer: Next"),
	["n|[b"] = map_cr("BufferLineCyclePrev"):with_silent():with_desc("buffer: Previous"),
	["n|<leader>bp"] = map_cr("BufferLinePick"):with_silent():with_desc("buffer: Pick"),
	["n|<leader>bo"] = map_cr("BufferLineCloseOthers"):with_silent():with_desc("buffer: Close others"),
	["n|<leader>bP"] = map_cr("BufferLineTogglePin"):with_silent():with_desc("buffer: Pin"),

	-- substitute
	["n|s"] = map_callback(function() require("substitute").operator() end):with_noremap():with_desc("edit: Substitute with motion"),
	["n|ss"] = map_callback(function() require("substitute").line() end):with_noremap():with_desc("edit: Substitute line"),
	["n|S"] = map_callback(function() require("substitute").eol() end):with_noremap():with_desc("edit: Substitute to end of line"),
	["x|s"] = map_callback(function() require("substitute").visual() end):with_noremap():with_desc("edit: Substitute selection"),
	["n|sx"] = map_callback(function() require("substitute.exchange").operator() end):with_noremap():with_desc("edit: Exchange with motion"),
	["n|sxx"] = map_callback(function() require("substitute.exchange").line() end):with_noremap():with_desc("edit: Exchange line"),
	["x|X"] = map_callback(function() require("substitute.exchange").visual() end):with_noremap():with_desc("edit: Exchange selection"),
	["n|sxc"] = map_callback(function() require("substitute.exchange").cancel() end):with_noremap():with_desc("edit: Cancel exchange"),

	-- time machine
	["n|<leader>tt"] = map_cr("TimeMachineToggle"):with_silent():with_desc("undo: Toggle tree"),
	["n|<leader>tx"] = map_cr("TimeMachinePurgeBuffer"):with_silent():with_desc("undo: Purge history (buffer)"),
	["n|<leader>tX"] = map_cr("TimeMachinePurgeAll"):with_silent():with_desc("undo: Purge history (all)"),
	["n|<leader>tl"] = map_cr("TimeMachineLogShow"):with_silent():with_desc("undo: Show log"),

	-- theme
	["n|<leader>ut"] = map_cr("Themery"):with_silent():with_desc("ui: Pick theme"),
}

bind.nvim_load_mapping(mappings)
