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

-- ============================================================
-- Plugins
-- ============================================================

vim.pack.add({
  -- Syntax / UI
  "https://github.com/nvim-treesitter/nvim-treesitter",
  "https://github.com/nvim-mini/mini.nvim",
  "https://github.com/MeanderingProgrammer/render-markdown.nvim",
  "https://github.com/nvim-telescope/telescope.nvim",

  -- Completion
  "https://github.com/hrsh7th/nvim-cmp",
  "https://github.com/hrsh7th/cmp-cmdline",
  "https://github.com/hrsh7th/cmp-path",
  "https://github.com/hrsh7th/cmp-buffer",
  "https://github.com/hrsh7th/cmp-nvim-lsp",

  -- Terminal
  "https://github.com/akinsho/toggleterm.nvim",
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

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "go", "lua", "vim" },
  callback = function()
    local ok = pcall(vim.treesitter.start)
    if not ok then
      vim.schedule(function()
        vim.notify(
          "Tree-sitter parser missing for " .. vim.bo.filetype .. '. Run :TSInstall ' .. vim.bo.filetype,
          vim.log.levels.WARN
        )
      end)
    end
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "go" },
  callback = function()
    vim.bo.syntax = "go"
    vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  end,
})

-- ============================================================
-- Render Markdown
-- ============================================================

require("render-markdown").setup({})

-- ============================================================
-- Editing Essentials
-- ============================================================

require("mini.ai").setup({})
require("mini.comment").setup({})
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

vim.lsp.enable("gopls")

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
