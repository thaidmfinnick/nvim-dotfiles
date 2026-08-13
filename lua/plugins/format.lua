return { -- Autoformat
  'stevearc/conform.nvim',
  lazy = false,
  keys = {
    {
      '<leader>fm',
      function()
        require('conform').format { async = true, lsp_format = 'fallback', timeout_ms = 5000 }
      end,
      mode = '',
      desc = '[F]ormat buffer',
    },
  },
  opts = {
    notify_on_error = false,
    format_on_save = function(bufnr)
      -- Disable "format_on_save lsp_fallback" for languages that don't
      -- have a well standardized coding style. You can add additional
      -- languages here or re-enable it for the disabled ones.
      local disable_filetypes = { query = true }
      local filetype = vim.bo[bufnr].filetype
      if disable_filetypes[filetype] then
        return nil
      end
      -- swift-format/ktlint are slower to start and need more headroom.
      local slow_filetypes = { swift = true, kotlin = true }
      return {
        timeout_ms = slow_filetypes[filetype] and 5000 or 500,
        lsp_format = 'fallback',
      }
    end,
    formatters = {
      -- Apple's swift-format from the Xcode toolchain (not Nick Lockwood's
      -- SwiftFormat). Resolved via xcrun so it isn't required on PATH.
      swift_format = {
        command = 'xcrun',
        args = { 'swift-format', 'format', '--in-place', '$FILENAME' },
        stdin = false,
        condition = function()
          return vim.fn.executable 'xcrun' == 1
        end,
      },
      dart_format = {
        command = 'dart',
        args = { 'format', '$FILENAME' },
        condition = function()
          return vim.fn.executable 'dart' == 1
        end,
      },
    },
    formatters_by_ft = {
      lua = { 'stylua' },
      dart = { 'dart_format' },
      elixir = { 'mix' },
      swift = { 'swift_format' },
      kotlin = { 'ktlint' },
      javascript = { 'prettierd', 'prettier', stop_after_first = true },
      vue = { 'prettierd', 'prettier', stop_after_first = true },
    },
  },
}
