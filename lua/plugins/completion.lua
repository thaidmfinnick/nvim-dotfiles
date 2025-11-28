return {
  {
    'saghen/blink.cmp',
    lazy = false,
    dependencies = {
      {
        'L3MON4D3/LuaSnip',
        build = (function()
          if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then
            return
          end
          return 'make install_jsregexp'
        end)(),
        dependencies = {
          {
            'rafamadriz/friendly-snippets',
            config = function()
              require('luasnip.loaders.from_vscode').lazy_load { paths = { './snippets' } }
            end,
          },
        },
      },
    },
    version = '1.*',
    opts = {
      keymap = {
        preset = 'default',
        ['<C-n>'] = { 'select_next', 'fallback' },
        ['<C-p>'] = { 'select_prev', 'fallback' },
        ['<C-b>'] = { 'scroll_documentation_up', 'fallback' },
        ['<C-f>'] = { 'scroll_documentation_down', 'fallback' },
        ['<C-y>'] = { 'accept', 'fallback' },
        ['<C-Space>'] = { 'show', 'fallback' },
        ['<C-l>'] = { 'snippet_forward', 'fallback' },
        ['<C-h>'] = { 'snippet_backward', 'fallback' },
        ['<C-e>'] = function()
          local luasnip = require('luasnip')
          if luasnip.choice_active() then
            luasnip.change_choice(1)
          end
        end,
      },
      cmdline = {
        keymap = {
          ['<C-p>'] = { 'select_prev', 'fallback' },
          ['<C-n>'] = { 'select_next', 'fallback' },
          ['<CR>'] = {},
        },
        completion = {
          menu = {
            auto_show = true,
          },
          list = {
            selection = { preselect = false },
          },
        },
      },
      completion = {
        keyword = {
          range = 'full',
        },
        list = {
          selection = { preselect = false, auto_insert = true },
        },
        accept = {
          dot_repeat = true,
          auto_brackets = {
            enabled = true,
            semantic_token_resolution = {
              enabled = false,
            },
          },
        },
        menu = {
          border = 'single',
          winhighlight = 'Normal:BlinkCmpMenu,CursorLine:BlinkCmpMenuSelection,Search:None',
        },
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 500,
          window = {
            border = 'single',
          },
        },
      },
      signature = { enabled = true },
      appearance = {
        use_nvim_cmp_as_default = true,
        nerd_font_variant = 'mono',
      },
      sources = {
        default = { 'lsp', 'path', 'luasnip' },
      },
      snippets = { preset = 'luasnip' },
    },
    opts_extend = { 'sources.default' },
    config = function(_, opts)
      -- Setup LuaSnip
      local luasnip = require('luasnip')
      luasnip.config.setup {}
      
      -- Setup blink.cmp
      require('blink.cmp').setup(opts)
      
      -- Set up choice navigation keymap
      vim.keymap.set({ 'i', 's' }, '<C-E>', function()
        if luasnip.choice_active() then
          luasnip.change_choice(1)
        end
      end, { silent = true })
    end,
  },
}
