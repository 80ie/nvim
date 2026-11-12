local HR_STEPS = 10

local function blend(fg, bg, a)
	local c = 0
	for shift = 0, 16, 8 do
		local f, b = bit.band(bit.rshift(fg, shift), 0xff), bit.band(bit.rshift(bg, shift), 0xff)
		c = c + bit.lshift(math.floor(b + (f - b) * a + 0.5), shift)
	end
	return c
end

local callout_bg = {} -- callout highlight -> tinted bg group, rebuilt per colorscheme

-- Code bg is a lighter shade of Normal; divider fades from Normal bg at the edges to Title fg.
local function set_highlights()
	callout_bg = {}
	local normal = vim.api.nvim_get_hl(0, { name = "Normal", link = false })
	local bg, fg = normal.bg or 0, normal.fg or 0xffffff
	local code_bg = blend(fg, bg, 0.07)
	vim.api.nvim_set_hl(0, "RenderMarkdownCode", { bg = code_bg })
	vim.api.nvim_set_hl(0, "RenderMarkdownCodeInline", { bg = code_bg })
	local title = vim.api.nvim_get_hl(0, { name = "Title", link = false }).fg or fg
	for i = 1, HR_STEPS do
		vim.api.nvim_set_hl(0, "RenderMarkdownHr" .. i, { fg = blend(title, bg, i / HR_STEPS) })
	end
end

local function hr_side(len, reverse)
	local chunks = {}
	for i = 1, HR_STEPS do
		local n = math.floor(len * i / HR_STEPS) - math.floor(len * (i - 1) / HR_STEPS)
		local level = reverse and HR_STEPS + 1 - i or i
		chunks[#chunks + 1] = { string.rep("─", n), "RenderMarkdownHr" .. level }
	end
	return chunks
end

local hr_query
local function gradient_hr(ctx)
	hr_query = hr_query or vim.treesitter.query.parse("markdown", "(thematic_break) @hr")
	local win = vim.api.nvim_get_current_buf() == ctx.buf and vim.api.nvim_get_current_win() or vim.fn.bufwinid(ctx.buf)
	local info = win ~= -1 and vim.fn.getwininfo(win)[1]
	if not info then
		return {}
	end
	local center = " ✦ "
	local side = math.max(0, math.floor((info.width - info.textoff - vim.api.nvim_strwidth(center)) / 2))
	local line = hr_side(side, false)
	line[#line + 1] = { center, "RenderMarkdownHr" .. HR_STEPS }
	vim.list_extend(line, hr_side(side, true))

	local marks = {}
	for _, node in hr_query:iter_captures(ctx.root, ctx.buf) do
		marks[#marks + 1] = {
			conceal = true,
			start_row = node:start(),
			start_col = 0,
			opts = { virt_text = line, virt_text_pos = "overlay" },
		}
	end
	return marks
end

local function callout_bg_group(hl)
	if not callout_bg[hl] then
		local fg = vim.api.nvim_get_hl(0, { name = hl, link = false }).fg
		local bg = vim.api.nvim_get_hl(0, { name = "Normal", link = false }).bg or 0
		callout_bg[hl] = "RenderMarkdownCalloutBg" .. hl:gsub("^RenderMarkdown", "")
		vim.api.nvim_set_hl(0, callout_bg[hl], { bg = fg and blend(fg, bg, 0.12) or nil })
	end
	return callout_bg[hl]
end

-- Tint each callout's lines with a faded version of its own color.
local quote_query
local function callout_backgrounds(ctx)
	quote_query = quote_query or vim.treesitter.query.parse("markdown", "(block_quote) @quote")
	local cfg = require("render-markdown.state").get_config(ctx.buf)
	local marks = {}
	for _, node in quote_query:iter_captures(ctx.root, ctx.buf) do
		local start_row, _, end_row, end_col = node:range()
		local first = vim.api.nvim_buf_get_lines(ctx.buf, start_row, start_row + 1, false)[1] or ""
		local tag = (first:match("^[%s>]*(%[!%w+%])") or ""):lower()
		for _, callout in pairs(cfg and tag ~= "" and cfg.callout or {}) do
			if callout.raw:lower() == tag then
				local group = callout_bg_group(callout.highlight)
				for row = start_row, end_col == 0 and end_row - 1 or end_row do
					marks[#marks + 1] = { conceal = false, start_row = row, start_col = 0, opts = { line_hl_group = group } }
				end
				break
			end
		end
	end
	return marks
end

return function()
	set_highlights()
	vim.api.nvim_create_autocmd("ColorScheme", { callback = set_highlights })

	require("modules.utils").load_plugin("render-markdown", {
		-- math is rendered by Snacks.image
		latex = { enabled = false },
		file_types = { "markdown", "codecompanion" },
		enabled = true,
		max_file_size = 2.0,
		debounce = 100,
		render_modes = { "n", "c", "t" },
		-- Show raw markdown on the cursor line; the <leader>um reading view turns this off
		anti_conceal = { enabled = true },
		log_level = "error",
		heading = { sign = false, width = "block", left_pad = 1, right_pad = 2 },
		code = {
			sign = false,
			width = "block",
			min_width = 60,
			left_pad = 2,
			right_pad = 2,
			language_pad = 1,
			border = "thin",
		},
		pipe_table = { preset = "round" },
		dash = { enabled = false },
		custom_handlers = {
			markdown = {
				extends = true,
				parse = function(ctx)
					return vim.list_extend(gradient_hr(ctx), callout_backgrounds(ctx))
				end,
			},
		},
	})
end
