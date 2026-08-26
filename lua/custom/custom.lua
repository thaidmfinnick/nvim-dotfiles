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
    dir = '~/.config/nvim/lua/custom/smart_select',
    main = 'custom.smart_select',
    name = 'custom.smart_select',
    event = { 'BufReadPost', 'BufNewFile' },
    config = true,
  },
  {
    dir = '/Users/admin/Data/projects/personal/silver-lining.nvim',
    name = 'custom.silver-lining',
    config = function()
      require('silver-lining').setup()
    end,
  },
}
