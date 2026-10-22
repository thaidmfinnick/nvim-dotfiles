return {
  {
    'ChmaraX/herdr-nvim',
    -- <leader>a is Harpoon add, so herdr-nvim lives under <leader>i
    opts = {
      prefix = '<leader>i',
    },
    config = function(_, opts)
      require('herdr-nvim').setup(opts)

      -- The plugin's label is `kind · status · cwd tail`, which is identical for
      -- two agents in the same repo. Lead with the session title the agent sets
      -- on its terminal (Claude Code names it after the conversation) instead.
      local agents = require('herdr-nvim.agents')
      agents.display = function(agent)
        -- Drop the leading status glyph (✳ / spinner) and its space, but not an
        -- accented first letter of a Vietnamese title.
        local title = (agent.title or ''):gsub('^[^%w%s]+%s+', '')
        local tail = vim.fn.fnamemodify(agent.cwd, ':t')
        return string.format('%s · %s · %s · %s', title, agent.kind, agent.status, tail)
      end
    end,
  },
}
