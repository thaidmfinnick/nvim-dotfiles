vim.lsp.config('lua_ls', {
  settings = {
    Lua = {
      diagnostics = {
        globals = { 'vim' },
      },
    },
  },
})

vim.lsp.config('ts_query_ls', {
  settings = {
    parser_install_directories = {
      vim.fs.joinpath(vim.fn.stdpath 'data', '/lazy/nvim-treesitter/parser/'),
    },
    -- This setting is provided by default
    parser_aliases = {
      ecma = 'javascript',
      jsx = 'javascript',
      php_only = 'php',
      query = 'scm',
    },
    language_retrieval_patterns = {
      'languages/src/([^/]+)/[^/]+\\.scm$',
      '*/query_editor.scm$',
    },
  },
})
