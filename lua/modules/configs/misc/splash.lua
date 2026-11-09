-- Art from splash/art/<name>.<tier>.txt (splash/generate.py). The picture is chosen once per
-- session; its tier is the largest that fits the window, so re-renders on resize keep the picture.
local chrome_rows = 18 -- keys list and paddings below the art
local picked

local function read(file)
	local lines = vim.fn.readfile(file)
	local cols = 0
	for _, l in ipairs(lines) do
		cols = math.max(cols, vim.fn.strdisplaywidth(l))
	end
	return { lines = lines, rows = #lines, cols = cols }
end

return function(self)
	local root = vim.fn.stdpath("config") .. "/splash/art"
	if not picked then
		local names = {}
		for _, f in ipairs(vim.fn.glob(root .. "/*.1x.txt", false, true)) do
			names[#names + 1] = (vim.fn.fnamemodify(f, ":t"):gsub("%.1x%.txt$", ""))
		end
		if #names == 0 then
			return { header = "", padding = 0 }
		end
		math.randomseed(vim.uv.hrtime())
		picked = names[math.random(#names)]
	end
	local win = self:size()
	local best, smallest
	for _, f in ipairs(vim.fn.glob(root .. "/" .. picked .. ".*.txt", false, true)) do
		local art = read(f)
		if not smallest or art.rows < smallest.rows then
			smallest = art
		end
		if art.rows + chrome_rows <= win.height and art.cols + 2 <= win.width and (not best or art.rows > best.rows) then
			best = art
		end
	end
	local art = best or smallest
	return { header = table.concat(art.lines, "\n"), padding = 2 }
end
