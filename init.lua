vim.pack.add({
    'https://github.com/nvim-treesitter/nvim-treesitter',
    'https://github.com/nvim-mini/mini.nvim',
    'https://github.com/MeanderingProgrammer/render-markdown.nvim',

    -- completion
    'https://github.com/hrsh7th/nvim-cmp',
    'https://github.com/hrsh7th/cmp-cmdline',
    'https://github.com/hrsh7th/cmp-path',
    'https://github.com/hrsh7th/cmp-buffer',
})

require('render-markdown').setup({})

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
