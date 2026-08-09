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
      --
      -- swift/kotlin are formatted manually with <leader>fm only.
      local disable_filetypes = { query = true, cpp = true, swift = true, kotlin = true }
      if disable_filetypes[vim.bo[bufnr].filetype] then
        return nil
      end
      return {
        timeout_ms = 500,
        lsp_format = 'fallback',
      }
    end,
    formatters = {
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
      swift = { 'swiftformat' },
      kotlin = { 'ktlint' },
      javascript = { 'prettierd', 'prettier', stop_after_first = true },
      vue = { 'prettierd', 'prettier', stop_after_first = true },
    },
  },
}
