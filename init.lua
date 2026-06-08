if vim.fn.has("nvim-0.12") == 0 then
	vim.api.nvim_echo({
		{
			"This Neovim config requires Neovim 0.12+; detected an older version. Please upgrade Neovim.",
			"ErrorMsg",
		},
	}, true, {})
	return
end

-- ============================================================
-- Keys
-- ============================================================

vim.g.mapleader = " "

-- Escapes from terminal mode
vim.keymap.set("t", "<C-n>", [[<C-\><C-n>]])

-- ============================================================
-- Editor Settings
-- ============================================================

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.clipboard = "unnamedplus"
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.mouse = "a"
vim.opt.scrolloff = 4
vim.opt.sidescrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.termguicolors = true
vim.opt.undofile = true
vim.opt.updatetime = 250

local undo_dir = vim.fn.stdpath("state") .. "/undo"
if vim.fn.isdirectory(undo_dir) == 0 then
	pcall(vim.fn.mkdir, undo_dir, "p")
end
if vim.fn.isdirectory(undo_dir) == 1 then
	vim.opt.undodir = undo_dir
end

-- ============================================================
-- Plugins
-- ============================================================

vim.pack.add({
	-- Syntax / UI
	"https://github.com/nvim-treesitter/nvim-treesitter",
	"https://github.com/nvim-mini/mini.nvim",
	"https://github.com/MeanderingProgrammer/render-markdown.nvim",
	"https://github.com/nvim-telescope/telescope.nvim",
	"https://github.com/brenoprata10/nvim-highlight-colors",

	-- Completion
	"https://github.com/hrsh7th/nvim-cmp",
	"https://github.com/hrsh7th/cmp-cmdline",
	"https://github.com/hrsh7th/cmp-path",
	"https://github.com/hrsh7th/cmp-buffer",
	"https://github.com/hrsh7th/cmp-nvim-lsp",

	-- Terminal
	"https://github.com/akinsho/toggleterm.nvim",

	-- Rails
	"https://github.com/tpope/vim-rails",
	"https://github.com/tpope/vim-bundler",
}, { load = true })

vim.pack.add({
	-- File tree
	{
		src = "https://github.com/nvim-neo-tree/neo-tree.nvim",
		version = vim.version.range("3"),
	},

	-- Neo-tree dependencies
	"https://github.com/nvim-lua/plenary.nvim",
	"https://github.com/MunifTanjim/nui.nvim",
	"https://github.com/nvim-tree/nvim-web-devicons",
}, { load = true })

-- ============================================================
-- Treesitter
-- ============================================================

require("nvim-treesitter").setup({
	install_dir = vim.fn.stdpath("data") .. "/site",
})

local treesitter_parser_by_filetype = {
	eruby = "embedded_template",
}

vim.api.nvim_create_autocmd("FileType", {
	pattern = {
		"css",
		"eruby",
		"go",
		"html",
		"javascript",
		"json",
		"lua",
		"odin",
		"ruby",
		"scss",
		"sql",
		"typescript",
		"vim",
		"yaml",
	},
	callback = function()
		local ok = pcall(vim.treesitter.start)
		if not ok then
			local parser = treesitter_parser_by_filetype[vim.bo.filetype] or vim.bo.filetype

			vim.schedule(function()
				vim.notify(
					"Tree-sitter parser missing for " ..
					vim.bo.filetype ..
						'. Run :lua require("nvim-treesitter").install({ "' .. parser .. '" })',
					vim.log.levels.WARN
				)
			end)
		end
	end,
})

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
	pattern = { "*.odin", "*.html.erb", "*.erb" },
	callback = function(event)
		if event.file:match("%.odin$") then
			vim.bo.filetype = "odin"
		else
			vim.bo.filetype = "eruby"
		end
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = { "go", "odin" },
	callback = function()
		vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
	end,
})

-- ============================================================
-- Render Markdown
-- ============================================================

require("render-markdown").setup({})

-- ============================================================
-- Color Highlighting
-- ============================================================

require("nvim-highlight-colors").setup({
	render = "virtual",
	enable_named_colors = false,
	enable_tailwind = true,
})

-- ============================================================
-- Editing Essentials
-- ============================================================

require("mini.ai").setup({})
require("mini.comment").setup({})
require("mini.clue").setup({
	triggers = {
		{ mode = "n", keys = "<Leader>" },
		{ mode = "x", keys = "<Leader>" },
		{ mode = "n", keys = "g" },
		{ mode = "x", keys = "g" },
		{ mode = "n", keys = "[" },
		{ mode = "n", keys = "]" },
	},
	clues = {
		require("mini.clue").gen_clues.builtin_completion(),
		require("mini.clue").gen_clues.g(),
		require("mini.clue").gen_clues.marks(),
		require("mini.clue").gen_clues.registers(),
		require("mini.clue").gen_clues.windows(),
		require("mini.clue").gen_clues.z(),
		{ mode = "n", keys = "<Leader>c",  desc = "+codex/code" },
		{ mode = "n", keys = "<Leader>ca", desc = "Code action" },
		{ mode = "n", keys = "<Leader>cc", desc = "Open Codex" },
		{ mode = "n", keys = "<Leader>d",  desc = "Line diagnostics" },
		{ mode = "n", keys = "<Leader>e",  desc = "Toggle file tree" },
		{ mode = "n", keys = "<Leader>f",  desc = "+find/format" },
		{ mode = "n", keys = "<Leader>fb", desc = "Find buffers" },
		{ mode = "n", keys = "<Leader>ff", desc = "Find files" },
		{ mode = "n", keys = "<Leader>fg", desc = "Live grep" },
		{ mode = "n", keys = "<Leader>fh", desc = "Help tags" },
		{ mode = "n", keys = "<Leader>gg", desc = "Open LazyGit" },
		{ mode = "n", keys = "<Leader>q",  desc = "Diagnostics to loclist" },
		{ mode = "n", keys = "<Leader>rn", desc = "Rename symbol" },
	},
})
require("mini.pairs").setup({})
require("mini.surround").setup({})


-- ============================================================
-- Telescope
-- ============================================================

local telescope = require("telescope")
local builtin = require("telescope.builtin")

telescope.setup({
	defaults = {
		mappings = {
			i = {
				["<Esc>"] = require("telescope.actions").close,
				["<C-n>"] = require("telescope.actions").close,
			},
		},
	},
})

vim.keymap.set("n", "<leader>ff", builtin.find_files, {
	desc = "Find files",
})

vim.keymap.set("n", "<leader>fg", builtin.live_grep, {
	desc = "Live grep",
})

vim.keymap.set("n", "<leader>fb", builtin.buffers, {
	desc = "Find buffers",
})

vim.keymap.set("n", "<leader>fh", builtin.help_tags, {
	desc = "Help tags",
})


-- ============================================================
-- Neo-tree
-- ============================================================

require("neo-tree").setup({
	filesystem = {
		window = {
			mappings = {
				["gn"] = "open_in_nautilus",
			},
		},
		commands = {
			open_in_nautilus = function(state)
				local node = state.tree:get_node()
				if not node then
					return
				end

				local path = node.path

				if vim.fn.isdirectory(path) == 0 then
					path = vim.fn.fnamemodify(path, ":h")
				end

				vim.fn.jobstart({ "nautilus", path }, { detach = true })
			end,
		},
	},
})

vim.api.nvim_create_autocmd("VimEnter", {
	callback = function()
		require("neo-tree.command").execute({
			toggle = false,
			position = "left",
		})
	end,
})

vim.keymap.set("n", "<leader>e", function()
	require("neo-tree.command").execute({
		toggle = true,
		position = "left",
	})
end, {
	desc = "Toggle file tree",
})
-- ============================================================
-- Completion
-- ============================================================

local cmp = require("cmp")

cmp.setup({
	completion = {
		completeopt = "menu,menuone,noinsert",
	},
	snippet = {
		expand = function(args)
			vim.snippet.expand(args.body)
		end,
	},
	mapping = cmp.mapping.preset.insert({
		["<C-Space>"] = cmp.mapping.complete(),
		["<CR>"] = cmp.mapping.confirm({ select = true }),
		["<Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_next_item()
			else
				fallback()
			end
		end, { "i", "s" }),
		["<S-Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_prev_item()
			else
				fallback()
			end
		end, { "i", "s" }),
	}),
	sources = {
		{ name = "nvim_lsp" },
		{ name = "buffer" },
	},
	window = {
		completion = cmp.config.window.bordered(),
		documentation = cmp.config.window.bordered(),
	},
})

cmp.setup.cmdline(":", {
	mapping = cmp.mapping.preset.cmdline(),
	sources = cmp.config.sources({
		{ name = "path" },
	}, {
		{ name = "cmdline" },
	}),
})

cmp.setup.cmdline({ "/", "?" }, {
	mapping = cmp.mapping.preset.cmdline(),
	sources = {
		{ name = "buffer" },
	},
})

-- ============================================================
-- LSP UX / Diagnostics
-- ============================================================

vim.diagnostic.config({
	severity_sort = true,
	float = {
		border = "rounded",
		source = "if_many",
	},
	signs = true,
	underline = true,
	update_in_insert = false,
	virtual_text = {
		spacing = 2,
		source = "if_many",
	},
})

vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(event)
		local client = assert(vim.lsp.get_client_by_id(event.data.client_id))
		local map = function(mode, lhs, rhs, desc)
			vim.keymap.set(mode, lhs, rhs, {
				buffer = event.buf,
				desc = desc,
			})
		end

		map("n", "gd", vim.lsp.buf.definition, "Go to definition")
		map("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
		map("n", "gi", vim.lsp.buf.implementation, "Go to implementation")
		map("n", "gr", vim.lsp.buf.references, "List references")
		map("n", "K", vim.lsp.buf.hover, "Hover")
		map("n", "<leader>rn", vim.lsp.buf.rename, "Rename symbol")
		map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "Code action")
		map("n", "<leader>f", function()
			vim.lsp.buf.format({ async = false })
		end, "Format buffer")
		map("n", "<leader>d", vim.diagnostic.open_float, "Line diagnostics")
		map("n", "[d", vim.diagnostic.goto_prev, "Previous diagnostic")
		map("n", "]d", vim.diagnostic.goto_next, "Next diagnostic")
		map("n", "<leader>q", vim.diagnostic.setloclist, "Diagnostics to loclist")

		if client:supports_method("textDocument/documentHighlight") then
			local group = vim.api.nvim_create_augroup("lsp-highlight-" .. event.buf, { clear = true })
			vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
				buffer = event.buf,
				group = group,
				callback = vim.lsp.buf.document_highlight,
			})
			vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
				buffer = event.buf,
				group = group,
				callback = vim.lsp.buf.clear_references,
			})
		end
	end,
})


-- ============================================================
-- Terminal / LazyGit
-- ============================================================

require("toggleterm").setup({
	direction = "float",
	close_on_exit = true,
	shell = vim.o.shell,
	float_opts = {
		border = "rounded",
	},
})

local Terminal = require("toggleterm.terminal").Terminal

local lazygit = Terminal:new({
	cmd = "lazygit",
	hidden = true,
	direction = "float",
	close_on_exit = true,
	float_opts = {
		border = "rounded",
	},
})

vim.keymap.set("n", "<leader>gg", function()
	vim.cmd("silent! write")
	lazygit:toggle()
end, {
	desc = "Open LazyGit",
})

-- ============================================================
-- Terminal / Codex
-- ============================================================

local codex = Terminal:new({
	cmd = "codex",
	hidden = true,
	direction = "float",
	close_on_exit = false,
	float_opts = {
		border = "rounded",
	},
})

vim.keymap.set("n", "<leader>cc", function()
	vim.cmd("silent! write")
	codex:toggle()
end, {
	desc = "Open Codex",
})


-- ============================================================
-- LSP's
-- ============================================================

vim.pack.add({
	{ src = 'https://github.com/neovim/nvim-lspconfig' },
}, { load = true })

local capabilities = require("cmp_nvim_lsp").default_capabilities()

local function enable_lsp(name, executable)
	if executable and vim.fn.executable(executable) == 0 then
		return false
	end

	vim.lsp.enable(name)
	return true
end

vim.lsp.config("gopls", {
	capabilities = capabilities,
	settings = {
		gopls = {
			analyses = {
				unusedparams = true,
			},
			gofumpt = true,
			staticcheck = true,
		},
	},
})

local home = vim.fn.expand("$HOME")

vim.lsp.config("ols", {
	capabilities = capabilities,
	cmd = { home .. "/ols/ols" },
	cmd_env = {
		OLS_BUILTIN_FOLDER = home .. "/ols/builtin",
	},
	filetypes = { "odin" },
	root_markers = { "ols.json", ".git" },
	init_options = {
		odin_command = home .. "/odin/odin",
		enable_semantic_tokens = true,
		enable_document_symbols = true,
		enable_hover = true,
		enable_snippets = true,
		enable_format = true,
	},
})

vim.lsp.config("lua_ls", {
	capabilities = capabilities,
	cmd = {
		home .. "/lua-language-server/bin/lua-language-server",
		"--logpath=" .. vim.fn.stdpath("state") .. "/lua-language-server/log",
		"--metapath=" .. vim.fn.stdpath("cache") .. "/lua-language-server/meta",
	},
	settings = {
		Lua = {
			runtime = {
				version = "LuaJIT",
			},
			diagnostics = {
				globals = { "vim" },
			},
			workspace = {
				checkThirdParty = false,
				library = vim.api.nvim_get_runtime_file("", true),
			},
			telemetry = {
				enable = false,
			},
		},
	},
})

local ruby_lsp_cmd = { "ruby-lsp" }

if vim.fn.executable("ruby-lsp") == 0 and vim.fn.executable("bundle") == 1 then
	ruby_lsp_cmd = { "bundle", "exec", "ruby-lsp" }
end

vim.lsp.config("ruby_lsp", {
	capabilities = capabilities,
	cmd = ruby_lsp_cmd,
	filetypes = { "ruby", "eruby" },
	root_markers = { "Gemfile", ".ruby-version", ".ruby-lsp", ".git" },
	init_options = {
		formatter = "auto",
		linters = { "rubocop" },
		addonSettings = {
			["Ruby LSP Rails"] = {
				enablePendingMigrationsPrompt = false,
			},
		},
	},
})

vim.lsp.config("erb_lint", {
	capabilities = capabilities,
	filetypes = { "eruby" },
	root_markers = { ".erb-lint.yml", ".erb-lint.yaml", "Gemfile", ".git" },
})

vim.lsp.config("html", {
	capabilities = capabilities,
	filetypes = { "html", "eruby" },
})

vim.lsp.config("cssls", {
	capabilities = capabilities,
})

vim.lsp.config("tailwindcss", {
	capabilities = capabilities,
	root_markers = {
		"tailwind.config.js",
		"tailwind.config.cjs",
		"tailwind.config.mjs",
		"tailwind.config.ts",
		"postcss.config.js",
		"postcss.config.cjs",
		"package.json",
		"Gemfile",
		".git",
	},
	filetypes = {
		"css",
		"eruby",
		"html",
		"javascript",
		"javascriptreact",
		"ruby",
		"scss",
		"typescript",
		"typescriptreact",
	},
	settings = {
		tailwindCSS = {
			includeLanguages = {
				eruby = "html",
				ruby = "html",
			},
		},
	},
})

vim.lsp.config("jsonls", {
	capabilities = capabilities,
})

vim.lsp.config("yamlls", {
	capabilities = capabilities,
	settings = {
		yaml = {
			keyOrdering = false,
		},
	},
})

enable_lsp("gopls", "gopls")
vim.lsp.enable("ols")
vim.lsp.enable("lua_ls")
enable_lsp("ruby_lsp", ruby_lsp_cmd[1])
enable_lsp("erb_lint", "erb_lint")
enable_lsp("html", "vscode-html-language-server")
enable_lsp("cssls", "vscode-css-language-server")
enable_lsp("tailwindcss", "tailwindcss-language-server")
enable_lsp("jsonls", "vscode-json-language-server")
enable_lsp("yamlls", "yaml-language-server")

local go_lsp_group = vim.api.nvim_create_augroup("go-lsp-format", { clear = true })

vim.api.nvim_create_autocmd("BufWritePre", {
	group = go_lsp_group,
	pattern = "*.go",
	callback = function(event)
		local params = vim.lsp.util.make_range_params(event.buf, "utf-8")
		params.context = { only = { "source.organizeImports" } }

		local results = vim.lsp.buf_request_sync(event.buf, "textDocument/codeAction", params, 1000)
		if results then
			for client_id, result in pairs(results) do
				for _, action in ipairs(result.result or {}) do
					if action.edit then
						vim.lsp.util.apply_workspace_edit(action.edit, client_id)
					end
					if action.command then
						vim.lsp.buf.execute_command(action.command)
					end
				end
			end
		end

		vim.lsp.buf.format({
			async = false,
			bufnr = event.buf,
			timeout_ms = 2000,
		})
	end,
})

local odin_lsp_group = vim.api.nvim_create_augroup("odin-lsp-format", { clear = true })

vim.api.nvim_create_autocmd("BufWritePre", {
	group = odin_lsp_group,
	pattern = "*.odin",
	callback = function(event)
		vim.lsp.buf.format({
			async = false,
			bufnr = event.buf,
			timeout_ms = 2000,
			filter = function(client)
				return client.name == "ols"
			end,
		})
	end,
})

local lua_lsp_group = vim.api.nvim_create_augroup("lua-lsp-format", { clear = true })

vim.api.nvim_create_autocmd("BufWritePre", {
	group = lua_lsp_group,
	pattern = "*.lua",
	callback = function(event)
		vim.lsp.buf.format({
			async = false,
			bufnr = event.buf,
			timeout_ms = 2000,
			filter = function(client)
				return client.name == "lua_ls"
			end,
		})
	end,
})
