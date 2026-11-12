-- <leader>u UI toggles. Keymaps are real (work before which-key loads);
-- `M.spec` gives which-key a live on/off icon and Enable/Disable label.
local bind = require("keymap.bind")

local ICON_ON, ICON_OFF = "\u{f205}", "\u{f204}"

---@param opt string window-local option
local function wo(opt, on, off)
	if on == nil then
		on, off = true, false
	end
	return function()
		return vim.wo[opt] == on
	end, function(v)
		vim.wo[opt] = v and on or off
	end
end

local function plugin_state(mod, get, set)
	return function()
		local ok, m = pcall(require, mod)
		return ok and get(m) or false
	end, function(v, cur)
		if v ~= cur then
			require(mod)[set]()
		end
	end
end

-- Read-only 100-column column centered on an opaque Normal-bg backdrop (Snacks.zen).
-- Hides gutter and diagnostics, and never reveals raw markdown on the cursor line.
local function reading_buf(buf, on, saved)
	vim.bo[buf].modifiable = not on and saved.modifiable
	vim.diagnostic.enable(not on and saved.diag, { bufnr = buf })
	local ok, rm = pcall(require, "render-markdown.state")
	local cfg = ok and rm.get_config(buf)
	if cfg then
		cfg.anti_conceal.enabled = not on
		-- conceal on the cursor line too, so scrolling never shows raw markdown
		cfg.win_options.concealcursor.rendered = on and "nc" or ""
		require("render-markdown.api").render({ buf = buf })
	end
end

local function reading_view(on)
	if not on then
		return Snacks.zen.win:close()
	end
	local buf = vim.api.nvim_get_current_buf()
	local saved = { modifiable = vim.bo[buf].modifiable, diag = vim.diagnostic.is_enabled({ bufnr = buf }) }
	Snacks.zen({
		toggles = {},
		win = {
			width = 100,
			backdrop = { transparent = false, bg = Snacks.util.color("Normal", "bg"), blend = 0 },
			wo = {
				number = false,
				relativenumber = false,
				signcolumn = "no",
				foldcolumn = "0",
				statuscolumn = "",
				cursorline = false,
				wrap = true,
				linebreak = true,
				showbreak = "NONE",
			},
		},
		on_open = function()
			reading_buf(buf, true, saved)
		end,
		on_close = function()
			reading_buf(buf, false, saved)
		end,
	})
end

local function t(key, name, get, set)
	return { key = key, name = name, get = get, set = set }
end

---@type { key: string, name: string, get: fun(): boolean, set: fun(v: boolean, cur: boolean) }[]
local toggles = {
	t("w", "wrap", wo("wrap")),
	t("s", "spell", wo("spell")),
	t("l", "line numbers", wo("number")),
	t("L", "relative numbers", wo("relativenumber")),
	t("i", "invisible chars", wo("list")),
	t("c", "conceal", wo("conceallevel", 2, 0)),
	t("d", "diagnostics", function()
		return vim.diagnostic.is_enabled({ bufnr = 0 })
	end, function(v)
		vim.diagnostic.enable(v, { bufnr = 0 })
	end),
	t("h", "inlay hints", function()
		return vim.lsp.inlay_hint.is_enabled({ bufnr = 0 })
	end, function(v)
		vim.lsp.inlay_hint.enable(v, { bufnr = 0 })
	end),
	t("b", "dark background", function()
		return vim.o.background == "dark"
	end, function(v)
		vim.o.background = v and "dark" or "light"
	end),
	t("f", "format on save", function()
		return pcall(vim.api.nvim_get_autocmds, { group = "format_on_save", event = "BufWritePre" })
	end, function(_, cur)
		require("completion.formatting")[cur and "disable_format_on_save" or "enable_format_on_save"](true)
	end),
	t("v", "virtual lines", plugin_state("tiny-inline-diagnostic", function()
		return require("tiny-inline-diagnostic.state").user_toggle_state
	end, "toggle")),
	t("C", "treesitter context", plugin_state("treesitter-context", function(m)
		return m.enabled()
	end, "toggle")),
	t("H", "color preview", plugin_state("nvim-highlight-colors", function(m)
		return m.is_active()
	end, "toggle")),
	t("m", "reading view", function()
		return Snacks.zen.win ~= nil and Snacks.zen.win:valid()
	end, reading_view),
}

local M = { spec = {} }

for _, tg in ipairs(toggles) do
	local lhs = "<leader>u" .. tg.key
	local function flip()
		local cur = tg.get()
		tg.set(not cur, cur)
		vim.notify(tg.name .. (tg.get() and " enabled" or " disabled"), vim.log.levels.INFO, { title = "UI toggle" })
	end

	bind.nvim_load_mapping({
		["n|" .. lhs] = bind.map_callback(flip):with_noremap():with_silent():with_desc("ui: Toggle " .. tg.name),
	})
	table.insert(M.spec, {
		lhs,
		desc = function()
			return (tg.get() and "Disable " or "Enable ") .. tg.name
		end,
		icon = function()
			return { icon = tg.get() and ICON_ON or ICON_OFF }
		end,
	})
end

return M
