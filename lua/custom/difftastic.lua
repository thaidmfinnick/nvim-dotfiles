local M = {}

function M.open_difftastic()
  local height = math.floor(vim.o.lines * 0.9)
  local width = math.floor(vim.o.columns * 0.9)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = width,
    height = height,
    row = row,
    col = col,
    style = 'minimal',
    border = 'rounded',
  })

  local view = require('diffview.lib').get_current_view()

  if view then
    local current_file = view:infer_cur_file()

    if current_file then
      local left_commit = view.left.commit
      local right_commit = view.right.commit

      local commit_range
      if left_commit == nil and right_commit == nil then
        commit_range = 'HEAD'
      elseif right_commit == nil then
        commit_range = left_commit
      else
        commit_range = left_commit .. '...' .. right_commit
      end

      local cmd = 'git --no-pager ddiff ' .. commit_range .. ' -- ' .. current_file.absolute_path
      vim.fn.jobstart(cmd, { term = true })
      vim.keymap.set('n', 'q', ':close<CR>', { buffer = buf, silent = true })
    else
      vim.notify("Can't get current file in diffview", vim.log.levels.ERROR)
    end
  else
    vim.notify('No diffview tab found', vim.log.levels.ERROR)
  end
end

return M
