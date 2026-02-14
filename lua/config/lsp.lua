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

local vue_language_server_path = vim.fn.stdpath 'data' .. '/mason/packages/vue-language-server/node_modules/@vue/language-server'
local tsserver_filetypes = { 'typescript', 'javascript', 'javascriptreact', 'typescriptreact', 'vue' }
local vue_plugin = {
  name = '@vue/typescript-plugin',
  location = vue_language_server_path,
  languages = { 'vue' },
  configNamespace = 'typescript',
}
local vtsls_config = {
  settings = {
    vtsls = {
      tsserver = {
        globalPlugins = {
          vue_plugin,
        },
      },
    },
  },
  filetypes = tsserver_filetypes,
}

local ts_ls_config = {
  init_options = {
    plugins = {
      vue_plugin,
    },
  },
  filetypes = tsserver_filetypes,
}

local vue_ls_config = {}

vim.lsp.config('vtsls', vtsls_config)
vim.lsp.config('vue_ls', vue_ls_config)
vim.lsp.config('ts_ls', ts_ls_config)
vim.lsp.enable { 'vtsls', 'vue_ls' } -- If using `ts_ls` replace `vtsls` to `ts_ls`
