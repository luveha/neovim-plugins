vim.g.mapleader = " "

vim.pack.add({
    'https://github.com/nvim-treesitter/nvim-treesitter',
    'https://github.com/nvim-mini/mini.nvim',
    'https://github.com/MeanderingProgrammer/render-markdown.nvim',

    -- completion
    'https://github.com/hrsh7th/nvim-cmp',
    'https://github.com/hrsh7th/cmp-cmdline',
    'https://github.com/hrsh7th/cmp-path',
    'https://github.com/hrsh7th/cmp-buffer',

    -- terminal for lazygit
    'https://github.com/akinsho/toggleterm.nvim',
})

vim.pack.add({
  {
    src = 'https://github.com/nvim-neo-tree/neo-tree.nvim',
    version = vim.version.range('3')
  },
  -- dependencies
  "https://github.com/nvim-lua/plenary.nvim",
  "https://github.com/MunifTanjim/nui.nvim",
  -- optional, but recommended
  "https://github.com/nvim-tree/nvim-web-devicons",
})

require('render-markdown').setup({})
require("neo-tree").setup({})

local cmp = require('cmp')

cmp.setup({
    sources = {
        { name = 'buffer' },
    },
})

-- ":" command completion
cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
        { name = 'path' }
    }, {
        { name = 'cmdline' }
    })
})

-- "/" and "?" search completion
cmp.setup.cmdline({ '/', '?' }, {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
        { name = 'buffer' }
    }
})

vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    require("neo-tree.command").execute({
      toggle = false,
      position = "left",
    })
  end,
})

require("toggleterm").setup({
  direction = "float",
  float_opts = {
    border = "rounded",
  },
})

local Terminal = require("toggleterm.terminal").Terminal

local lazygit = Terminal:new({
  cmd = "lazygit",
  hidden = true,
  direction = "float",
  close_on_exit = false,
  dir = "git_dir",
  float_opts = {
    border = "rounded",
  },
  on_open = function()
    vim.cmd("startinsert!")
  end,
})

vim.keymap.set("n", "<leader>gg", function()
  lazygit:toggle()
end, { desc = "Open LazyGit" })
