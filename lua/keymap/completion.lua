local bind = require("keymap.bind")
local map_cr = bind.map_cr
local map_callback = bind.map_callback
local helpers = require("keymap.helpers")

local mappings = {
	fmt = {
		["n|<A-f>"] = map_cr("FormatToggle"):with_noremap():with_silent():with_desc("formatter: Toggle format on save"),
		["n|<A-S-f>"] = map_cr("Format"):with_noremap():with_silent():with_desc("formatter: Format buffer manually"),
	},
}
bind.nvim_load_mapping(mappings.fmt)

--- The following code allows this file to be exported ---
---    for use with LSP lazy-loaded keymap bindings    ---

local M = {}

---@param buf integer
function M.lsp(buf)
	local map = {
		-- LSP-related keymaps, ONLY effective in buffers with LSP(s) attached
		["n|<leader>li"] = map_cr("LspInfo"):with_silent():with_buffer(buf):with_desc("lsp: Info"),
		["n|<leader>lr"] = map_cr("LspRestart"):with_silent():with_buffer(buf):with_nowait():with_desc("lsp: Restart"),
		["n|go"] = map_cr("Trouble symbols toggle win.position=right")
			:with_silent()
			:with_buffer(buf)
			:with_desc("lsp: Toggle outline"),
		["n|gto"] = map_callback(function()
				helpers.picker("lsp_document_symbols")
			end)
			:with_silent()
			:with_buffer(buf)
			:with_desc("lsp: Toggle outline in Telescope"),
		["n|<leader>lx"] = map_callback(vim.diagnostic.open_float)
			:with_silent()
			:with_buffer(buf)
			:with_desc("lsp: Line diagnostic"),
		["n|gs"] = map_callback(vim.lsp.buf.signature_help):with_desc("lsp: Signature help"),
		["n|gd"] = map_callback(vim.lsp.buf.definition):with_buffer(buf):with_desc("lsp: Goto definition"),
		["n|gr"] = map_callback(vim.lsp.buf.references):with_buffer(buf):with_desc("lsp: References"),
		["n|K"] = map_callback(vim.lsp.buf.hover):with_buffer(buf):with_desc("lsp: Show doc"),
		["nv|<leader>ca"] = map_callback(vim.lsp.buf.code_action):with_buffer(buf):with_desc("lsp: Code action"),
		["n|gh"] = map_callback(function()
				helpers.picker("lsp_references")
			end)
			:with_noremap()
			:with_nowait()
			:with_silent()
			:with_desc("lsp: show finder"),
		["n|gm"] = map_callback(function()
				helpers.picker("lsp_implementations")
			end)
			:with_noremap()
			:with_nowait()
			:with_silent()
			:with_desc("lsp: show implementations"),
		["n|<leader>lv"] = map_callback(function()
				helpers.toggle_virtuallines()
			end)
			:with_noremap()
			:with_silent()
			:with_desc("lsp: Toggle virtual lines"),
		["n|<leader>lh"] = map_callback(function()
				helpers.toggle_inlayhint()
			end)
			:with_noremap()
			:with_silent()
			:with_desc("lsp: Toggle inlay hints"),
	}
	bind.nvim_load_mapping(map)

	local ok, user_mappings = pcall(require, "user.keymap.completion")
	if ok and type(user_mappings.lsp) == "function" then
		require("modules.utils.keymap").replace(user_mappings.lsp(buf))
	end
end

return M
