return {
  {
    dir = '~/.config/nvim/lua/custom/pancake_work_color_mapping',
    main = 'custom.pancake_work_color_mapping',
    name = 'custom.pancake_work_color_mapping',
    config = true,
  },
  {
    dir = '~/.config/nvim/lua/custom/pancake_work_intl',
    main = 'custom.pancake_work_intl',
    name = 'custom.pancake_work_intl',
    config = true,
  },
  {
    dir = '/Users/admin/Documents/projects/personal/silver-lining.nvim',
    name = 'custom.silver-lining',
    config = function()
      require('silver-lining').setup()
    end,
  },
}
