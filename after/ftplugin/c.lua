-- % expands to the current file, so this works from any cwd; a Makefile in cwd wins
if vim.fn.filereadable("Makefile") == 0 and vim.fn.filereadable("makefile") == 0 then
	vim.opt_local.makeprg = "gcc -g -O0 -Wall -Wextra %:S -o %:r:S"
end

vim.keymap.set("n", "<leader>m", "<Cmd>silent make | cwindow | redraw!<CR>", { buffer = true, desc = "build: make" })
vim.keymap.set("n", "<leader>M", "<Cmd>!%:p:r:S<CR>", { buffer = true, desc = "build: run binary" })
