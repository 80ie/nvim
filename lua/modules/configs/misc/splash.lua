-- Random art from the largest splash/art/<cols>x<rows> that fits the window (see splash/generate.sh)
local chrome_rows = 18 -- keys list, paddings and the statusline below the art

return function(self)
	local root = vim.fn.stdpath("config") .. "/splash/art"
	local win = self:size()
	local sizes = {}
	for _, d in ipairs(vim.fn.glob(root .. "/*x*", false, true)) do
		local cols, rows = vim.fn.fnamemodify(d, ":t"):match("^(%d+)x(%d+)$")
		if cols then
			sizes[#sizes + 1] = { dir = d, cols = tonumber(cols), rows = tonumber(rows) }
		end
	end
	table.sort(sizes, function(a, b)
		return a.rows < b.rows
	end)
	local pick = sizes[1]
	for _, s in ipairs(sizes) do
		if s.rows + chrome_rows <= win.height and s.cols + 2 <= win.width then
			pick = s
		end
	end
	if not pick then
		return { header = "", padding = 0 }
	end
	local files = vim.fn.glob(pick.dir .. "/*.txt", false, true)
	math.randomseed(vim.uv.hrtime())
	local lines = vim.fn.readfile(files[math.random(#files)])
	return { header = table.concat(lines, "\n"), padding = 2 }
end
