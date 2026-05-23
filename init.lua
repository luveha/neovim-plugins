-- ============================================================
-- Leader key
-- ============================================================

vim.g.mapleader = " "


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

  -- Completion
  "https://github.com/hrsh7th/nvim-cmp",
  "https://github.com/hrsh7th/cmp-cmdline",
  "https://github.com/hrsh7th/cmp-path",
  "https://github.com/hrsh7th/cmp-buffer",

  -- Terminal
  "https://github.com/akinsho/toggleterm.nvim",
})

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
})


-- ============================================================
-- Render Markdown
-- ============================================================

require("render-markdown").setup({})


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


-- ============================================================
-- Completion
-- ============================================================

local cmp = require("cmp")

cmp.setup({
  sources = {
    { name = "buffer" },
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
