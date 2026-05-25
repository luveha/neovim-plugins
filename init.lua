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

require("neo-tree").setup({})

vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    require("neo-tree.command").execute({
      toggle = false,
      position = "left",
    })
  end,
})

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
-- ============================================================
-- Completion
-- ============================================================

local cmp = require("cmp")

cmp.setup({
  sources = {
    { name = "buffer" },
    { name = "nvim_lsp" },
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
})

vim.lsp.enable("gopls")
