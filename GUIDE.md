# Neovim config guide: what's new since `master`

The `integrate` branch moves the config onto the nvimdots module layout (lazy.nvim, `lua/modules/...`, `lua/keymap/...`). Master was a flat `vim-plug` setup with one file per plugin in `plugin/`.

- **Leader** is `<Space>`. `<A-x>` means Alt+x.
- Press `<Space>` and wait: which-key lists every group. `<leader>?` opens the full keymap list, `<C-p>` or `<leader>/` fuzzy-searches all keymaps live.
- Plugins load lazily. If a key does nothing the first time, the plugin is probably still loading from its trigger event.
- Manage plugins with `<leader>ph` (Lazy UI), `<leader>ps` (sync), `<leader>pu` (update).

## 1. What changed for plugins you already used

| Plugin | Master | Now |
|---|---|---|
| snacks.nvim | picker, notifier, lazygit, indent, scroll, input, statuscolumn, animate, image, dashboard | Only `image` (math in markdown/LaTeX) and the dashboard. Everything else has a dedicated replacement below. |
| nvim-autopairs | Pairs, custom `<CR>` | Replaced by **autoclose.nvim**. The master `<CR>`/`<C-n>`/`<C-p>` pum mappings are gone; blink.cmp owns them. |
| gitsigns | `]c` `[c` `<leader>hp/hs/hr` | `]g` `[g` `<leader>gp/gs/gr/gR/gb`. Current-line blame is off by default. |
| clangd LSP | Hand-written `vim.lsp.config`, keys `gd gr K <leader>rn <leader>ca <leader>cf <leader>cd` | Full LSP stack (section 3). Rename and format keys moved; see the table there. |
| nvim-tree, bufferline, telescope, which-key, substitute, time-machine, vimtex, render-markdown, melange | Own config files | Same plugins, same keys (see "Kept as is"). `<leader>e`, `<leader>E`, `]b`, `[b` still work. |
| `<C-h/j/k/l>` | Plain `<C-w>` moves | smart-splits (same keys, plus `<A-h/j/k/l>` to resize). |
| `<leader>ff`, `<leader>fg`, `<leader>fb`, `<leader><space>` | Snacks pickers | Telescope "collections" (section 2). `<leader><space>` and `<leader>fn` are gone. |
| `<leader>gg` | `Snacks.lazygit()` | lazygit in a toggleterm float. |
| `<leader>u*` toggles (wrap, spell, diagnostics…) | Snacks toggles | `lua/keymap/toggle.lua`: same idea, no Snacks. which-key shows an on/off icon and Enable/Disable label per toggle. `<leader>ut` is the theme picker. |
| runner-nvim (`<leader>r`, `<leader>o`, `<leader>T`) | Run a command, repeat the last one | Removed. Use toggleterm (`:TermExec cmd="..."`) or `<leader>m` in C files. `<leader>r` in visual mode runs the selection with SnipRun. |

Kept as is: `Q` records macros (`q` is disabled), `<C-BS>` deletes a word, `<leader>=` reindents, `s`/`ss`/`S`/`sx`/`X` (substitute.nvim), `<leader>t*` (time-machine), `<F1>` toggles render-markdown.

## 2. Finding things: Telescope collections (`search.nvim`)

`telescope.nvim` plus `ayamir/search.nvim` group pickers into tabbed collections. Open one, then press `<Tab>` to cycle through its tabs.

| Key | Collection | Tabs |
|---|---|---|
| `<leader>ff` | file | Files, Frecency, Oldfiles, Buffers |
| `<leader>fp` | pattern | Word in project (live grep with args), Word under cursor |
| `<leader>fg` | git | Branches, Commits, Commit content, Diff current file |
| `<leader>fd` | dossier | Sessions, Projects, Zoxide |
| `<leader>fm` | misc | Colorschemes (live preview), Notify history, Undo history |
| `<leader>fc` | | Pick a collection from a list |
| `<leader>fb` | | Buffers |
| `<leader>fr` | | Resume last search |
| `<leader>fs` (visual) | | Grep the selection |

Tips:
- In the live-grep tab, `<C-k>` quotes the prompt so you can add flags (`"foo" -t lua`), and `<C-i>` appends ` --iglob ` for glob filters.
- Undo History tab: `<CR>` yanks the added lines, `<S-CR>` yanks the deleted lines, `<C-CR>` restores that state.
- Frecency ranks files by how often and how recently you opened them.
- In `~/.config/nvim` file and grep searches ignore `.gitignore`, so vendored files show up.
- Zoxide needs the `zoxide` binary. It isn't installed on this machine, so that tab will error until you install it. `rg`, `fd`, `fzf` and `lazygit` are present.
- Set `search_backend = "fzf"` in `lua/core/settings.lua` to use fzf-lua instead (needs `fzf`).

**project.nvim** (`DrKJeff16/project.nvim`) tracks project roots (`.git`, `Makefile`, `package.json`, …) and `chdir`s to them silently. Browse them in `<leader>fd` → Projects.

**advanced-git-search** powers the git collection tabs. Diffs open in diffview.

## 3. LSP, completion, formatting

Servers install through **mason.nvim** (`:Mason`). The configured set is in `lua/core/settings.lua`: bashls, clangd, gopls, html, jsonls, lua_ls, ruff, pyrefly. Formatters via **none-ls**: clang-format, gofumpt, goimports, prettier, shfmt, stylua, vint. Treesitter parsers install themselves on first start.

### LSP keys (only active in buffers with a server attached)

| Key | Action |
|---|---|
| `gd` | Go to definition |
| `gr` | References (quickfix) |
| `gh` | References in Telescope |
| `gm` | Implementations in Telescope |
| `K` | Hover docs |
| `gs` | Signature help |
| `<leader>ca` | Code action (normal and visual) |
| `go` | Symbol outline (Trouble, docked on the left through edgy) |
| `<leader>ls` | Document symbols in Telescope |
| `<leader>ld` | Diagnostics for this buffer |
| `<leader>lw` / `<leader>lp` | Workspace / project diagnostics |
| `<leader>lx` | Line diagnostic float |
| `<leader>lv` | Toggle inline diagnostic lines |
| `<leader>lh` | Toggle inlay hints |
| `<leader>lk` | Toggle the docs pane: hover docs for the symbol under the cursor in a right sidebar (nvim-docs-view, updates as you move; `:DocsViewUpdate` forces a refresh) |
| `<leader>li` / `<leader>lr` | `LspInfo` / `LspRestart` |

**Rename:** master's `<leader>rn` is gone and nothing replaces it. Use Neovim's built-in `grn`, or add a mapping in `lua/keymap/completion.lua` if you miss it.

### Completion (blink.cmp)

Menu opens as you type, docs pop up after 200 ms.

| Key | Action |
|---|---|
| `<Tab>` / `<S-Tab>` | Next / previous item, or jump snippet placeholders |
| `<C-n>` / `<C-p>` | Next / previous item |
| `<CR>` | Accept |
| `<C-d>` / `<C-f>` | Scroll docs up / down |
| `<C-w>` | Cancel |

Sources, with the tag shown in the menu: LSP, snippets (LuaSnip + friendly-snippets, plus your own in `snips/`), path, buffer, `[RG]` ripgrep over the project, `[SPELL]` dictionary, `[TMUX]` words from other tmux panes, `[LTEX]` LaTeX symbols (type `\alpha` and accept). Lua files also get Neovim API completion from **lazydev**. Menu labels get syntax colors from colorful-menu.

### Formatting

Format on save is **on** (1 s timeout).

| Key / command | Action |
|---|---|
| `<A-S-f>` or `:Format` | Format the buffer now |
| `<A-f>` or `:FormatToggle` | Toggle format on save |
| `:FormatterToggleFt <ft>` | Disable or enable formatting for one filetype |
| `:NullLsToggle <name>` | Toggle a single none-ls source |

Master's `<leader>cf` is gone; use `<A-S-f>`. clangd, lua_ls and ts_ls skip their own formatting so clang-format, stylua and prettier handle it.

### Diagnostics display

**tiny-inline-diagnostic** draws diagnostic messages inline next to the code (toggle with `<leader>lv`). **Trouble** is the list view. **lsp-signature** and **neoconf** (project-local LSP settings in `.neoconf.json`) round out the stack.

## 4. Editing and motion

**Jumping**

| Key | Plugin | Action |
|---|---|---|
| `f` `F` `t` `T` `;` `,` | flash.nvim | Enhanced char motions. Search integration is off. |
| `<leader>w` | hop | Jump to a word (all windows) |
| `<leader>j` / `<leader>k` | hop | Jump to a line |
| `<leader>c` / `<leader>C` | hop | Jump to 1 / 2 typed characters |
| `m` (after `d`, `y`, `v`) | treehopper | Select a syntax node by label, for example `dm` |

Press `<Esc>` to cancel a hop. In normal mode `<Esc>` also hides flash's char labels, then clears search highlight.

**Treesitter text objects** (`nvim-treesitter-textobjects`, `main` branch)

| Key | Action |
|---|---|
| `af` `if` | Select function outer / inner |
| `ac` `ic` | Select class outer / inner |
| `][` / `]]` | Next function: start / end |
| `[[` / `[]` | Previous function: start / end |
| `]m` / `]M` | Next class: start / end |
| `[m` / `[M` | Previous class: start / end |
| `<leader>a` | Swap argument with the next (inner) |
| `<leader>A` | Swap argument with the next (outer) |
| `;` | Repeat the last textobject move |

Lookahead is on, so `daf` works with the cursor before the function.

**Other editing plugins**

- **Comment.nvim**: `gcc` line, `gc{motion}`, `gbc` block, `gb{motion}`; visual `gc` / `gb`. **ts-context-commentstring** picks the right comment style inside embedded languages (JSX, Vue, HTML with CSS/JS).
- **mini.align**: `gea` aligns a selection or motion, `geA` shows a live preview first. Example: `geap` in a paragraph, then type `=` to align on `=`.
- **grug-far** (project search and replace):
  - `<leader>Ss` opens the panel.
  - `<leader>Sp` searches the word under the cursor, or the visual selection.
  - `<leader>Sf` restricts to the current file.
  - Inside the panel (localleader is `,`): `,r` replace all, `,q` send to quickfix, `,s` sync under cursor, `,o` open location, `,c` close, `g?` help. `<Tab>` moves between fields.
- **suda.vim**: `<A-s>` or `:SudaWrite` saves a root-owned file via sudo.
- **vim-matchup**: `%` jumps between matching `if`/`end`, tags, and so on. Off-screen matches show in a popup.
- **vim-cool**: search highlight clears itself when you move. `<Esc>` also clears it.
- **vim-sleuth**: detects indent width from the file.
- **nvim-ts-autotag**: closes and renames HTML/JSX tags as you type.
- **autoclose.nvim**: auto-pairs `() [] {} "" '' ``` ` ```. Typing the closer steps over it. `<>` pairs only in Rust.
- **nvim-bufdel**: `<A-q>` closes the buffer without wrecking the window layout.
- **smartyank**: yanks also reach the system clipboard, tmux, and OSC52 over SSH.
- **faster.nvim**: files over 2 MiB open with syntax, treesitter, LSP, and similar features turned off.
- **persisted.nvim** sessions (saved per directory and git branch, autosave on):
  - `<leader>ss` save, `<leader>sl` load the current directory's session, `<leader>sd` delete.
  - `<leader>fd` → Sessions picks any session.
  - Sessions do not auto-restore; load one by hand.

**Builtin keys added by the new core** (`lua/keymap/editor.lua`, `ui.lua`)

| Key | Action |
|---|---|
| `<C-s>` | Save (also in insert mode) |
| `<C-q>` | Save **and quit** (`:wq`), so don't hit it by reflex |
| `<A-S-q>` | Force quit (`:q!`) |
| `J` / `K` (visual) | Move the selected lines down / up and reindent |
| `<` / `>` (visual) | Indent and keep the selection |
| `n` / `N` | Next / previous match, centered |
| `J` (normal) | Join lines without moving the cursor |
| `Y` / `D` | Yank / delete to end of line |
| `<S-Tab>` | Toggle fold |
| `tn` `tk` `tj` `to` | New tab, next tab, previous tab, close other tabs |
| `<C-a>` `<C-b>` (insert) | Start of line, one char left |
| `<C-a>` `<C-e>` `<C-b>` `<C-f>` (command line) | Home, end, left, right |

## 5. Interface

- **lualine**: the status line.
- **bufferline**: `<A-i>` / `<A-o>` next / previous buffer, `<A-S-i>` / `<A-S-o>` move the buffer, `<A-1>`…`<A-9>` go to buffer N, `<leader>bn` new buffer, `<leader>bp` pick, `<leader>bo` close others, `<leader>bP` pin, `<leader>be` / `<leader>bd` sort by extension / directory. `]b` `[b` still work.
- **dropbar**: a winbar showing the filename plus the LSP/treesitter/markdown symbol under the cursor. Click it with the mouse to open the symbol menu.
- **edgy.nvim**: pins sidebars into place. `<C-n>` toggles the left sidebar (nvim-tree on top, Trouble symbol outline below). The docs pane docks on the right. Quickfix, a horizontal terminal and help windows dock at the bottom. `<A-h/j/k/l>` resize an edgy window.
- **nvim-tree**: `<leader>e` toggle, `<leader>E` reveal current file, `<leader>nf` find file, `<leader>nr` refresh. `l` opens a file or enters a directory, `h` closes or goes to parent. Closing the last real window quits Neovim.
- **smart-splits**: `<C-h/j/k/l>` move between splits, `<A-h/j/k/l>` resize by 3, `<leader>Wh/j/k/l` swap the window with its neighbor.
- **todo-comments**: highlights `TODO`, `FIX`/`FIXME`/`BUG`, `WARN`, `PERF`, `NOTE`, `TEST` inside comments. `HACK` is deliberately off.
- **indent-blankline**: indent guides. **nvim-scrollview**: scrollbar with fold, mark, and search markers. **neoscroll**: animated `<C-u/d/b/f/e/y>` and `zt/zz/zb`.
- **rainbow-delimiters**: colored brackets. **nvim-treesitter-context**: pins up to 3 lines of enclosing scope at the top of the window. **mini.cursorword**: underlines other uses of the word under the cursor. **nvim-highlight-colors**: paints hex, rgb, hsl, and CSS variables with their color.
- **paint.nvim**: extra highlights, currently Lua `---@tag` annotations and Python `name:` keys.
- **nvim-notify**: popup notifications at INFO and above, 2 s timeout. Browse history from `<leader>fm` → Notify.
- **UI toggles** (`<leader>u`): `w` wrap, `s` spell, `l` numbers, `L` relative numbers, `i` invisible chars, `c` conceal, `d` diagnostics, `h` inlay hints, `b` dark background, `f` format on save, `v` virtual lines, `C` treesitter context, `H` color preview, `m` reading view.
- **Themery**: `<leader>ut` opens a theme picker with live preview. It lists every installed colorscheme: melange (default), gruvbox, mellifluous, darkearth. The choice persists across restarts.
- **Splash**: opening `nvim` with no file shows a random picture rendered as braille dots, sized to the window. Pictures live in `splash/img`; regenerate art with `splash/generate.py`.

## 6. Git

| Key | Action |
|---|---|
| `]g` / `[g` | Next / previous hunk |
| `<leader>gs` | Stage or unstage hunk (works on a visual range too) |
| `<leader>gr` | Reset hunk (visual range too) |
| `<leader>gR` | Reset buffer |
| `<leader>gp` | Preview hunk |
| `<leader>gb` | Blame line (full commit) |
| `ih` | Text object: the hunk (`dih`, `vih`) |
| `<leader>gd` / `<leader>gD` | Open / close diffview |
| `<leader>gG` | Fugitive (`:Git`) |
| `<leader>gg` | lazygit in a floating terminal |
| `gps` / `gpl` | `git push` / `git pull` |

Inside diffview, `g?` lists its keys. Use it for three-way merge conflicts too.

## 7. Terminal and running code

- **toggleterm**: `<C-\>` horizontal terminal, `<A-\>` or `<F5>` vertical, `<A-d>` floating. The same key hides it again, including from terminal mode. `<Esc><Esc>` leaves terminal mode. `<C-w>h/j/k/l` move out of a terminal window. The horizontal terminal docks at the bottom through edgy.
- **sniprun**: visual select, then `<leader>r` runs the snippet. Output shows as virtual text and in the command line.
- **C files** (`after/ftplugin/c.lua`): `<leader>m` runs `make` and opens the quickfix list. Without a Makefile, a CMake project builds with `cmake --build --preset dev` (or `build/` when there are no presets). Otherwise it compiles the current file with `gcc -g -O0 -Wall -Wextra`. `<leader>M` runs the built binary. In C and C++ buffers, `<leader>h` also switches between header and source (clangd).
- **nvim-bqf** improves the quickfix window with a preview pane. With its default keys, `<Tab>` marks entries and `zf` opens fzf inside the list.

## 8. Debugging (nvim-dap + dap-ui)

Adapters install through mason-nvim-dap: codelldb (C/C++/Rust), delve (Go), debugpy (Python). Key bindings:

| Key | Action |
|---|---|
| `<F6>` | Start or continue |
| `<F7>` | Stop |
| `<F8>` | Toggle breakpoint |
| `<F9>` / `<F10>` / `<F11>` | Step into / out / over |
| `<leader>db` | Conditional breakpoint |
| `<leader>dc` | Run to cursor |
| `<leader>dl` | Re-run last session |
| `<leader>do` | Open the REPL |
| `<leader>dC` | Close the debug UI |
| `K` (only while debugging) | Evaluate the expression under the cursor |

The dap-ui panels open automatically when a session starts. `K` is rebound to evaluate while a session runs, and the hover mapping returns afterwards.

`<F5>` is the vertical terminal here, not "continue". Use `<F6>`.

## 9. Language extras

- **Rust**: rustaceanvim runs rust-analyzer (not mason's). Builds run in toggleterm. **crates.nvim** adds version info in `Cargo.toml`. In a `Cargo.toml` buffer: `<leader>ct` toggle, `<leader>cr` reload, `<leader>cv` versions popup, `<leader>cf` features, `<leader>cd` dependencies, `<leader>cu` / `<leader>ca` update current / all, `<leader>cU` / `<leader>cA` upgrade current / all, `<leader>cH` homepage, `<leader>cR` repository, `<leader>cD` docs, `<leader>cC` crates.io page. These are buffer-local, so `<leader>ca` is code action everywhere else.
- **Go**: go.nvim supplies `:Go*` commands (`:GoTest`, `:GoImpl`, `:GoFillStruct`, and so on) with its own LSP, DAP, and keymaps turned off, so gopls and delve stay in charge. First run builds its helper binaries (`:GoInstallBinaries`).
- **Markdown**: render-markdown shows rendered headings, tables, and code in the buffer (`<F1>` toggles). `<leader>um` opens a read-only reading view: a centered 100-column column on a plain background, with no gutter or diagnostics, and raw markdown stays hidden on the cursor line; press it again to go back. markdown-preview opens a browser preview (`<F12>`). Math is rendered by Snacks.image.
- **CSV**: csv.vim.
- **LaTeX**: vimtex is unchanged, including the Zathura/Okular settings.
- **Lua config work**: lazydev gives completion and type info for the Neovim API.

## 10. Where to change things

| To change | Edit |
|---|---|
| Default theme, formatters, LSP list, treesitter parsers, search backend | `lua/core/settings.lua` |
| A keymap | `lua/keymap/*.lua`. Personal and master-carried keys live in `personal.lua`. |
| A plugin's options | `lua/modules/configs/<group>/<plugin>.lua` |
| Add or remove a plugin | `lua/modules/plugins/<group>.lua` |
| Per-user overrides without touching the above | `lua/user/` (settings, keymaps, LSP servers, DAP clients). The folder does not exist yet; the loader picks it up if you create it. |

## Known gaps to decide on

- No rename keybinding (master's `<leader>rn`). Neovim's `grn` works.
- Snacks pickers, notifier, and scroll from master are gone, as are their keys (`<leader><space>`, `<leader>fn`).
- `zoxide` is missing, so the Zoxide tab in `<leader>fd` errors.
