-- regular vim config
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.expandtab = true
vim.opt.background = "dark"
vim.opt.clipboard = "unnamedplus"
vim.opt.completeopt = menu, menuone, noselect
vim.opt.signcolumn = "yes"
vim.opt.splitright = true
vim.opt.encoding = "utf-8"
vim.opt.switchbuf = "usetab"

-- set light background if set in ~/shell_bg
local bg_file = io.open(os.getenv("HOME") .. "/.config/colorschemes/shell_bg", "r")
if bg_file ~= nil then
	local content = bg_file:read("*a")
	if string.find(content, "light") then
		vim.opt.background = "light"
	end
end

-- add :E command to spawn netrw
-- (ambiguous since nvim 0.10)
vim.api.nvim_create_user_command("E", "Ex", {})

-- clear state folder that contains all swap files
vim.api.nvim_create_user_command("ClearState", "!rm -vfr ~/.local/state/nvim", {})

-- netrw
vim.g.netrw_banner = 0
vim.g.netrw_liststyle = 3
vim.g.netrw_winsize = 25

-- -- floating window borders
-- local _border = "single"
--
-- vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
--     border = _border,
-- })
--
-- vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
--     border = _border,
-- })
-- vim.lsp.handlers["textDocument/completion"] = vim.lsp.with(vim.lsp.handlers.completion, {
--     border = _border,
-- })
--
-- vim.diagnostic.config({
--     float = { border = _border },
-- })

local signs = { Error = "■ ", Warn = "■ ", Hint = "■ ", Info = "■ " }
for type, icon in pairs(signs) do
	local hl = "DiagnosticSign" .. type
	vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

-- config specific options
local M = {}
M.autoformat = true

ToggleAutoformat = function()
	M.autoformat = not M.autoformat
end

-- core keymaps
local map = function(mode, lhs, rhs, opts)
	local options = { noremap = true }
	if opts then
		options = vim.tbl_extend("force", options, opts)
	end
	vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

map("n", "<tab>", ":bnext<cr>", { silent = true })
map("n", "<s-tab>", ":bprevious<cr>", { silent = true })

map("n", "<a-h>", "<c-w>h")
map("n", "<a-j>", "<c-w>j")
map("n", "<a-k>", "<c-w>k")
map("n", "<a-l>", "<c-w>l")

map("n", "<c-left>", "<c-w><")
map("n", "<c-right>", "<c-w>>")
map("n", "<c-up>", "<c-w>+")
map("n", "<c-down>", "<c-w>-")

map("n", "<leader>bd", ":bd<cr>", { silent = true })
map("n", "<leader>wd", "<c-w>q")

map("n", "<esc>", "<cmd>noh<cr>", { silent = true })
map("n", "<leader>uf", "<cmd>lua ToggleAutoformat()<cr>", { silent = true })

-- terminal
map("t", "<esc>", "<c-\\><c-n>", { silent = true })

-- copy breakpoint location
map(
	"n",
	"<leader>b",
	'<cmd>execute "let @+=\'".expand(\'%:p\').":".getpos(\'.\')[1]."\'"<cr>:echo "filename copied: ".@+<cr>'
)

-- bootstrap package manager
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	if vim.fn.executable("git") <= 0 then
		print("error: git not found, cannot bootstrap lazy.vim.")
	end
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

-- plugins list
local plugins = {
	"nvim-lua/plenary.nvim",
	-- LSP
	{
		"neovim/nvim-lspconfig",
		config = function()
			-- Global mappings.
			-- See `:help vim.diagnostic.*` for documentation on any of the below functions
			vim.keymap.set("n", "<space>e", vim.diagnostic.open_float)
			vim.keymap.set("n", "[d", vim.diagnostic.goto_prev)
			vim.keymap.set("n", "]d", vim.diagnostic.goto_next)
			vim.keymap.set("n", "<space>q", vim.diagnostic.setloclist)

			-- Use LspAttach autocommand to only map the following keys
			-- after the language server attaches to the current buffer
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("UserLspConfig", {}),
				callback = function(ev)
					-- Enable completion triggered by <c-x><c-o>
					vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"
					vim.diagnostic.config({
						virtual_text = false,
						underline = true,
					})
					-- Buffer local mappings.
					-- See `:help vim.lsp.*` for documentation on any of the below functions
					local opts = { buffer = ev.buf }
					vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
					vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
					vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
					vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
					vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)
					vim.keymap.set("n", "<space>wa", vim.lsp.buf.add_workspace_folder, opts)
					vim.keymap.set("n", "<space>wr", vim.lsp.buf.remove_workspace_folder, opts)
					vim.keymap.set("n", "<space>wl", function()
						print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
					end, opts)
					vim.keymap.set("n", "<space>D", vim.lsp.buf.type_definition, opts)
					vim.keymap.set("n", "<space>rn", vim.lsp.buf.rename, opts)
					vim.keymap.set({ "n", "v" }, "<space>ca", vim.lsp.buf.code_action, opts)
					vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
					vim.keymap.set("n", "<space>f", function()
						vim.lsp.buf.format({ async = true })
					end, opts)
				end,
			})

			-- Format on save
			vim.api.nvim_create_autocmd("BufWritePre", {
				callback = function()
					if M.autoformat then
						vim.lsp.buf.format()
					end
				end,
			})

			-- require("lspconfig.ui.windows").default_options = {
			--     border = _border,
			-- }
		end,
	},
	{
		"williamboman/mason.nvim",
		config = function()
			require("mason").setup()
		end,
	},
	{
		"williamboman/mason-lspconfig.nvim",
		config = function()
			local mason_lspconfig = require("mason-lspconfig")
			--
			-- autoload installed LSPs
			mason_lspconfig.setup()
			-- mason_lspconfig.setup_handlers({
			-- 	function(server_name)
			-- 		require("lspconfig")[server_name].setup({})
			-- 	end,
			-- })
		end,
	},
	-- {
	-- 	"jose-elias-alvarez/null-ls.nvim",
	-- 	config = function()
	-- 		local null_ls = require("null-ls")
	-- 		null_ls.setup({
	-- 			sources = {
	-- 				null_ls.builtins.formatting.stylua,
	-- 				-- null_ls.builtins.formatting.black,
	-- 				-- null_ls.builtins.diagnostics.cpplint,
	-- 			},
	-- 		})
	-- 	end,
	-- },
	-- autocompletion
	{
		"hrsh7th/nvim-cmp",
		config = function()
			local cmp = require("cmp")
			cmp.setup({
				enabled = function()
					return vim.api.nvim_buf_get_option(0, "buftype") ~= "prompt" or require("cmp_dap").is_dap_buffer()
				end,
				snippet = {
					expand = function(args)
						require("luasnip").lsp_expand(args.body)
					end,
				},
				-- window = {
				-- 	completion = cmp.config.window.bordered(),
				-- 	documentation = cmp.config.window.bordered(),
				-- },
				mapping = cmp.mapping.preset.insert({
					["<c-b>"] = cmp.mapping.scroll_docs(-4),
					["<c-f>"] = cmp.mapping.scroll_docs(4),
					["<c-Space>"] = cmp.mapping.complete(),
					["<c-e>"] = cmp.mapping.abort(),
					["<s-cr>"] = cmp.mapping.confirm({ select = true }),
				}),
				sources = cmp.config.sources({
					{ name = "nvim_lsp" },
					{ name = "buffer" },
					{ name = "dap" },
					{ name = "vimtex" },
				}),
			})

			-- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
			cmp.setup.cmdline({ "/", "?" }, {
				mapping = cmp.mapping.preset.cmdline(),
				sources = {
					{ name = "buffer" },
				},
			})

			-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
			cmp.setup.cmdline(":", {
				mapping = cmp.mapping.preset.cmdline(),
				sources = cmp.config.sources({
					{ name = "path" },
				}, {
					{ name = "cmdline" },
				}),
			})
		end,
	},
	"hrsh7th/cmp-nvim-lsp",
	"hrsh7th/cmp-buffer",
	"hrsh7th/cmp-path",
	"hrsh7th/cmp-cmdline",
	{
		"L3MON4D3/LuaSnip",
		build = "make install_jsregexp",
	},
	{
		"ray-x/lsp_signature.nvim",
		config = function()
			require("lsp_signature").setup({
				bind = true,
				handler_opts = {
					border = "single",
				},
			})
		end,
	},
	{
		"nvim-treesitter/nvim-treesitter",
		run = function()
			local ts_update = require("nvim-treesitter.install").update({ with_sync = true })
			ts_update()
		end,
		config = function()
			require("nvim-treesitter.configs").setup({
				-- ensure_installed = { "python", "zig" },
				sync_install = false,
				auto_install = true,
				highlight = {
					enable = true,
				},
				incremental_selection = {
					enable = true,
				},
				auto_indent = {
					enable = true,
					keymaps = {
						init_selection = "gnn", -- set to `false` to disable one of the mappings
						node_incremental = "grn",
						scope_incremental = "grc",
						node_decremental = "grm",
					},
				},
			})
		end,
	},
	-- dap
	{
		-- use multiline fork for python
		"mfussenegger/nvim-dap",
		-- "LiadOz/nvim-dap",
		-- branch = "LiadOz/multiline-inputs",
		config = function()
			local dap = require("dap")
			dap.defaults.fallback.terminal_win_cmd = "tabnew"

			vim.keymap.set("n", "<F3>", function()
				dap.repl.toggle({}, "vertical split")
			end)
			-- vim.keymap.set("n", "<F4>", function()
			-- 	dapui.toggle()
			-- end)
			vim.keymap.set("n", "<F5>", function()
				dap.continue()
			end)
			vim.keymap.set("n", "<F6>", function()
				dap.terminate()
			end)
			vim.keymap.set("n", "<F7>", function()
				dap.restart()
			end)
			vim.keymap.set("n", "<F10>", function()
				dap.step_over()
			end)
			vim.keymap.set("n", "<F11>", function()
				dap.step_into()
			end)
			vim.keymap.set("n", "<F12>", function()
				dap.step_out()
			end)
			vim.keymap.set("n", "<F2>", function()
				dap.toggle_breakpoint()
			end)
			vim.keymap.set({ "n", "v" }, "<Leader>dh", function()
				require("dap.ui.widgets").hover()
			end)
			vim.keymap.set({ "n", "v" }, "<Leader>dp", function()
				require("dap.ui.widgets").preview()
			end)
			vim.keymap.set("n", "<Leader>df", function()
				local widgets = require("dap.ui.widgets")
				widgets.centered_float(widgets.frames)
			end)
			vim.keymap.set("n", "<Leader>ds", function()
				local widgets = require("dap.ui.widgets")
				widgets.centered_float(widgets.scopes)
			end)
			vim.keymap.set("n", "<Leader>dc", function()
				dap.run_to_cursor()
			end)

			-- remove HL when stopped on breakpoint
			vim.fn.sign_define("DapStopped", { text = "→", texthl = "", linehl = "", numhl = "" })
		end,
	},
	{
		"rcarriga/cmp-dap",
		config = function() end,
	},
	{
		"jay-babu/mason-nvim-dap.nvim",
		config = function()
			require("mason-nvim-dap").setup({
				automatic_setup = true,
				ensure_installed = {
					"python",
				},
				handlers = {},
			})
		end,
	},
	{
		"theHamsta/nvim-dap-virtual-text",
		config = function()
			local setup = {
				virt_text_pos = "eol",
			}

			-- -- enable inline virtual text if nvim version is >= 0.10
			-- local ver = vim.inspect(vim.version())
			-- if vim.version.ge(ver, { 0, 10, 0 }) then
			--     print("sava")
			--     setup["virt_pos_text"] = "inline"
			-- end

			require("nvim-dap-virtual-text").setup(setup)
		end,
	},
	-- refactoring
	{
		"nvim-pack/nvim-spectre",
		config = function()
			require("spectre").setup()
		end,
	},
	-- utils
	{
		"numToStr/Comment.nvim",
		config = function()
			require("Comment").setup()
		end,
	},
	{
		"windwp/nvim-autopairs",
		config = function()
			require("nvim-autopairs").setup()
		end,
	},
	{
		"lewis6991/gitsigns.nvim",
		config = function()
			require("gitsigns").setup({
				on_attach = function(bufnr)
					local gitsigns = require("gitsigns")

					local function map(mode, l, r, opts)
						opts = opts or {}
						opts.buffer = bufnr
						vim.keymap.set(mode, l, r, opts)
					end

					-- Navigation
					map("n", "]h", function()
						if vim.wo.diff then
							vim.cmd.normal({ "]h", bang = true })
						else
							gitsigns.nav_hunk("next")
						end
					end)

					map("n", "[h", function()
						if vim.wo.diff then
							vim.cmd.normal({ "[h", bang = true })
						else
							gitsigns.nav_hunk("prev")
						end
					end)

					-- Actions
					map("n", "<leader>hs", gitsigns.stage_hunk)
					map("n", "<leader>hr", gitsigns.reset_hunk)
					map("v", "<leader>hs", function()
						gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
					end)
					map("v", "<leader>hr", function()
						gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
					end)
					map("n", "<leader>hS", gitsigns.stage_buffer)
					map("n", "<leader>hu", gitsigns.undo_stage_hunk)
					map("n", "<leader>hR", gitsigns.reset_buffer)
					map("n", "<leader>hp", gitsigns.preview_hunk)
					map("n", "<leader>hb", function()
						gitsigns.blame_line({ full = true })
					end)
					map("n", "<leader>tb", gitsigns.toggle_current_line_blame)
					map("n", "<leader>hd", gitsigns.diffthis)
					map("n", "<leader>hD", function()
						gitsigns.diffthis("~")
					end)
					map("n", "<leader>td", gitsigns.toggle_deleted)

					-- Text object
					map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>")
				end,
			})
		end,
	},
	{
		"ggandor/leap.nvim",
		config = function()
			require("leap").add_default_mappings()
		end,
	},
	{
		"ggandor/leap-spooky.nvim",
		config = function()
			require("leap-spooky").setup({
				-- Mappings will be generated corresponding to all native text objects,
				-- like: (ir|ar|iR|aR|im|am|iM|aM){obj}.
				-- Special line objects will also be added, by repeating the affixes.
				-- E.g. `yrr<leap>` and `ymm<leap>` will yank a line in the current
				-- window.
				affixes = {
					-- The cursor moves to the targeted object, and stays there.
					magnetic = { window = "m", cross_window = "M" },
					-- The operation is executed seemingly remotely (the cursor boomerangs
					-- back afterwards).
					remote = { window = "r", cross_window = "R" },
				},
				-- Defines text objects like `riw`, `raw`, etc., instead of
				-- targets.vim-style `irw`, `arw`.
				prefix = false,
				-- The yanked text will automatically be pasted at the cursor position
				-- if the unnamed register is in use.
				paste_on_remote_yank = false,
			})
		end,
	},
	{
		"nvim-telescope/telescope.nvim",
		-- tag = "0.1.0",
		requires = { { "nvim-lua/plenary.nvim" } },
		config = function()
			require("telescope").setup({
				defaults = {
					borderchars = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
				},
			})
			local builtin = require("telescope.builtin")
			vim.keymap.set("n", "<leader>ff", builtin.find_files, {})
			vim.keymap.set("n", "<leader>fg", builtin.live_grep, {})
			vim.keymap.set("n", "<leader>fb", builtin.buffers, {})
			vim.keymap.set("n", "<leader>fh", builtin.help_tags, {})
			vim.keymap.set("n", "<leader>fj", builtin.jumplist, {})
		end,
	},
	"nvim-telescope/telescope-dap.nvim",
	{
		"kylechui/nvim-surround",
		version = "*", -- Use for stability; omit to use `main` branch for the latest features
		event = "VeryLazy",
		config = function()
			require("nvim-surround").setup({
				-- Configuration here, or leave empty to use defaults
			})
		end,
	},
	{
		"nvim-lualine/lualine.nvim",
		requires = { "kyazdani42/nvim-web-devicons", opt = true },
		config = function()
			require("lualine").setup({
				options = {
					component_separators = { left = "", right = "" },
					section_separators = { left = "", right = "" },
				},
				sections = {
					lualine_a = { "mode" },
					lualine_b = { "branch", "diff", "diagnostics" },
					lualine_c = { "filename" },
					lualine_x = {
						function()
							return require("dap").status()
						end,
					},
					lualine_y = { "progress" },
					lualine_z = { "location" },
				},
				inactive_sections = {
					lualine_a = {},
					lualine_b = {},
					lualine_c = { "filename" },
					lualine_x = { "location" },
					lualine_y = {},
					lualine_z = {},
				},
			})
		end,
	},
	{
		"rmagatti/auto-session",
		config = function()
			require("auto-session").setup({
				log_level = "error",
				auto_session_suppress_dirs = { "~/", "~/Projects", "~/Downloads", "/" },
			})
		end,
	},
	{
		"lervag/vimtex",
		lazy = false,
		init = function()
			vim.g.fomat_enabled = true
			-- vim.g.vimtex_view_general_viewer = "okular"
			-- vim.g.vimtex_view_general_options = "--unique file:@pdf#src:@line@tex"
			vim.g.vimtex_view_method = "zathura"
			-- vim.g.vimtex_compiler_method = "latexrun"
			vim.g.vimtex_compiler_latexmk = {
				options = {
					"--shell-escape",
					"--verbose",
					"--file-line-error",
					"--synctex=1",
					"--interaction=nonstopmode",
				},
			}
		end,
	},
	{
		"micangl/cmp-vimtex",
	},
	{
		"ellisonleao/gruvbox.nvim",
		config = function()
			require("gruvbox").setup({
				-- overrides = { SignColumn = { bg = "#282828" } },
			})
		end,
	},
	{ "catppuccin/nvim", name = "catppuccin", priority = 1000 },
	{
		"projekt0n/github-nvim-theme",
		name = "github-theme",
		config = function()
			require("github-theme").setup({
				palettes = {
					github_dark = {
						bg1 = "#000000",
					},
				},
				specs = {
					github_dark = {
						bg1 = "#232627", -- from breeze
					},
					github_light = {
						bg1 = "#fafafa", -- from breeze
					},
				},
			})
		end,
	},
    {
      "f-person/auto-dark-mode.nvim",
      opts = {
        -- your configuration comes here
        -- or leave it empty to use the default settings
        -- refer to the configuration section below
            
        set_dark_mode = function()
            vim.cmd([[colorscheme github_dark]])
        end,
        set_light_mode = function()
            vim.cmd([[colorscheme github_light]])
        end,
        update_interval = 2000,
        fallback = "dark"
           
      }
}
}
require("lazy").setup(plugins)

vim.cmd([[colorscheme github_dark]])

-- Make Lua lsp vim aware
require("lspconfig").lua_ls.setup({
	settings = {
		Lua = {
			runtime = {
				version = "LuaJIT",
			},
			diagnostics = {
				globals = {
					"vim",
					"require",
				},
			},
			workspace = {
				library = vim.api.nvim_get_runtime_file("", true),
				checkThirdParty = false,
			},
			telemetry = {
				enable = false,
			},
		},
	},
})
