-- Random pick from splash/art/*.txt (made by splash/generate.sh), chosen each time the dashboard opens
return function()
	local files = vim.fn.glob(vim.fn.stdpath("config") .. "/splash/art/*.txt", false, true)
	if #files == 0 then
		return { header = "", padding = 0 }
	end
	math.randomseed(vim.uv.hrtime())
	local lines = vim.fn.readfile(files[math.random(#files)])
	return { header = table.concat(lines, "\n"), padding = 2 }
end
