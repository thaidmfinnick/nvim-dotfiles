return {
  {
    'lervag/vimtex',
    lazy = false, -- we don't want to lazy load VimTeX
    -- tag = "v2.15", -- uncomment to pin to a specific release
    init = function()
      -- VimTeX configuration goes here, e.g.
      vim.g.vimtex_view_method = 'zathura'

      -- Quickfix never opens itself; inspect errors with :VimtexErrors (<localleader>le).
      -- (0 = never open automatically, 1 = open + jump, 2 = open, stay put)
      vim.g.vimtex_quickfix_mode = 0
      vim.g.vimtex_quickfix_open_on_warning = 0
      -- Close it again as soon as you move the cursor a couple of times.
      vim.g.vimtex_quickfix_autoclose_after_keystrokes = 3
    end,
  },
}
