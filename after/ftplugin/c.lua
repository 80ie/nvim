-- A Makefile in cwd wins, then a CMake project (preset "dev" if any), else compile the current file
if vim.fn.filereadable("Makefile") == 0 and vim.fn.filereadable("makefile") == 0 then
	local root = vim.fs.root(0, "CMakeLists.txt")
	if root then
		local target = vim.uv.fs_stat(root .. "/CMakePresets.json") and "--preset dev" or "build"
		vim.opt_local.makeprg = "cd " .. vim.fn.shellescape(root) .. " && cmake --build " .. target
	else
		vim.opt_local.makeprg = "gcc -g -O0 -Wall -Wextra %:S -o %:r:S"
	end
end

vim.keymap.set("n", "<leader>m", "<Cmd>silent make | cwindow | redraw!<CR>", { buffer = true, desc = "build: make" })
vim.keymap.set("n", "<leader>M", "<Cmd>!%:p:r:S<CR>", { buffer = true, desc = "build: run binary" })
