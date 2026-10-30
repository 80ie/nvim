vim.lsp.config('clangd', {
	cmd = { 'clangd' },
	filetypes = { 'c', 'cpp', 'objc', 'objcpp' },
	root_markers = { 'compile_commands.json', 'compile_flags.txt', '.clangd', '.git' },
})

vim.api.nvim_create_autocmd('LspAttach', {
	callback = function(event)
		local client = vim.lsp.get_client_by_id(event.data.client_id)
		if not client or client.name ~= 'clangd' then return end
		local function map(keys, action, desc)
			vim.keymap.set('n', keys, action, { buffer = event.buf, desc = desc })
		end
		map('gd', vim.lsp.buf.definition, 'Go to definition')
		map('gr', vim.lsp.buf.references, 'Find references')
		map('K', vim.lsp.buf.hover, 'Show documentation')
		map('<leader>rn', vim.lsp.buf.rename, 'Rename symbol')
		map('<leader>ca', vim.lsp.buf.code_action, 'Code action')
		map('<leader>cf', function() vim.lsp.buf.format({ bufnr = event.buf, id = client.id }) end, 'Format code')
		map('<leader>cd', vim.diagnostic.open_float, 'Show diagnostic')
		if client:supports_method('textDocument/completion') then
			vim.lsp.completion.enable(true, client.id, event.buf, { autotrigger = true })
		end
	end,
})

vim.lsp.enable('clangd')
