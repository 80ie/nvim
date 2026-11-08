vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

local function on_attach(bufnr)
	local api = require('nvim-tree.api')
	api.config.mappings.default_on_attach(bufnr)

	local function map(lhs, fn, desc)
		vim.keymap.set('n', lhs, fn, { buffer = bufnr, nowait = true, desc = 'nvim-tree: ' .. desc })
	end

	map('l', function()
		local node = api.tree.get_node_under_cursor()
		if node.type == 'directory' and node.open then
			vim.cmd('normal! j')
		else
			api.node.open.edit()
		end
	end, 'Expand dir / open file')

	map('h', function()
		local node = api.tree.get_node_under_cursor()
		if node.type == 'directory' and node.open then
			api.node.open.edit()
		else
			api.node.navigate.parent_close()
		end
	end, 'Close dir / go to parent')
end

require('nvim-tree').setup({
	on_attach = on_attach,
	view = { width = 35 },
	update_focused_file = { enable = true },
	git = { ignore = false },
})
