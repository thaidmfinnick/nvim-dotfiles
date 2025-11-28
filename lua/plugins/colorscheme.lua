return {

  {
    'EdenEast/nightfox.nvim',
    priority = 1000,
    init = function()
      -- vim.cmd.colorscheme 'nightfox'
    end,
  },
  {
    'folke/tokyonight.nvim',
    priority = 1000, -- Make sure to load this before all the other start plugins.
    init = function()
      -- any other, such as 'tokyonight-storm', 'tokyonight-moon', or 'tokyonight-day'.
      vim.cmd.colorscheme 'tokyonight'

      -- You can configure highlights by doing something like:
      -- vim.cmd.hi 'Comment gui=none'
    end,
  },

  {
    'oxfist/night-owl.nvim',
    lazy = false, -- make sure we load this during startup if it is your main colorscheme
    priority = 1000, -- make sure to load this before all the other start plugins
    opts = {},
    config = function()
      -- require('night-owl').setup()
      -- vim.cmd.colorscheme 'night-owl'
    end,
  },

  { 'bluz71/vim-nightfly-colors', name = 'nightfly', lazy = false, priority = 1000 },

  {
    'catppuccin/nvim',
    name = 'catppuccin',
    priority = 1000,
    init = function()
      -- vim.cmd.colorscheme 'catppuccin-mocha'
    end,
    config = function()
      require('catppuccin').setup {
        flavour = 'mocha',
        highlight_overrides = {
          all = function(colors)
            return {
              CurSearch = { bg = colors.sky },
              IncSearch = { bg = colors.sky },
              CursorLineNr = { fg = colors.blue, style = { 'bold' } },
              DashboardFooter = { fg = colors.overlay0 },
              TreesitterContextBottom = { style = {} },
              WinSeparator = { fg = colors.overlay0, style = { 'bold' } },
              ['@markup.italic'] = { fg = colors.blue, style = { 'italic' } },
              ['@markup.strong'] = { fg = colors.blue, style = { 'bold' } },
              Headline = { style = { 'bold' } },
              Headline1 = { fg = colors.blue, style = { 'bold' } },
              Headline2 = { fg = colors.pink, style = { 'bold' } },
              Headline3 = { fg = colors.lavender, style = { 'bold' } },
              Headline4 = { fg = colors.green, style = { 'bold' } },
              Headline5 = { fg = colors.peach, style = { 'bold' } },
              Headline6 = { fg = colors.flamingo, style = { 'bold' } },
              rainbow1 = { fg = colors.blue, style = { 'bold' } },
              rainbow2 = { fg = colors.pink, style = { 'bold' } },
              rainbow3 = { fg = colors.lavender, style = { 'bold' } },
              rainbow4 = { fg = colors.green, style = { 'bold' } },
              rainbow5 = { fg = colors.peach, style = { 'bold' } },
              rainbow6 = { fg = colors.flamingo, style = { 'bold' } },
            }
          end,
        },
        color_overrides = {
          mocha = {
            rosewater = '#efc9c2',
            flamingo = '#ebb2b2',
            pink = '#f2a7de',
            mauve = '#b889f4',
            red = '#ea7183',
            maroon = '#ea838c',
            peach = '#f39967',
            yellow = '#eaca89',
            green = '#96d382',
            teal = '#78cec1',
            sky = '#91d7e3',
            sapphire = '#68bae0',
            blue = '#739df2',
            lavender = '#a0a8f6',
            text = '#b5c1f1',
            subtext1 = '#a6b0d8',
            subtext0 = '#959ec2',
            overlay2 = '#848cad',
            overlay1 = '#717997',
            overlay0 = '#63677f',
            surface2 = '#505469',
            surface1 = '#3e4255',
            surface0 = '#2c2f40',
            base = '#1a1c2a',
            mantle = '#141620',
            crust = '#0e0f16',
          },
        },
      }
    end,
  },
}
