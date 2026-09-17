local M = {}

local function git(args, cwd)
  local out = vim.fn.systemlist(vim.list_extend({ 'git', '-C', cwd }, args))
  if vim.v.shell_error ~= 0 then
    return nil
  end
  return out[1]
end

-- Convert any git remote URL into an https browse URL.
-- git@github.com:user/repo.git      -> https://github.com/user/repo
-- ssh://git@github.com/user/repo.git -> https://github.com/user/repo
-- https://github.com/user/repo.git   -> https://github.com/user/repo
local function remote_to_web(remote)
  local url = remote
  url = url:gsub('^ssh://', '')
  url = url:gsub('^git@([^:/]+)[:/]', 'https://%1/')
  url = url:gsub('^[%w%-%.]+@([^:/]+)[:/]', 'https://%1/')
  url = url:gsub('^http://', 'https://')
  url = url:gsub('%.git$', '')
  url = url:gsub('/$', '')
  return url
end

--- Build the browse URL for the current buffer.
---@param line1 integer
---@param line2 integer
---@return string|nil url
---@return string|nil err
function M.get_url(line1, line2)
  local file = vim.api.nvim_buf_get_name(0)
  if file == '' then
    return nil, 'buffer has no file'
  end
  local dir = vim.fn.fnamemodify(file, ':p:h')

  local root = git({ 'rev-parse', '--show-toplevel' }, dir)
  if not root then
    return nil, 'not inside a git repository'
  end

  local remote = git({ 'remote', 'get-url', 'origin' }, dir)
  if not remote then
    return nil, 'no "origin" remote'
  end

  -- Prefer the commit hash so the link keeps pointing at the same lines.
  local rev = git({ 'rev-parse', 'HEAD' }, dir)
  if not rev then
    return nil, 'cannot resolve HEAD'
  end

  local rel = vim.fn.fnamemodify(file, ':p'):sub(#root + 2)
  local base = remote_to_web(remote)

  local path_seg = string.format('blob/%s/%s', rev, rel)
  local line_seg
  if line1 == line2 then
    line_seg = string.format('#L%d', line1)
  else
    line_seg = string.format('#L%d-L%d', line1, line2)
  end

  return string.format('%s/%s%s', base, path_seg, line_seg)
end

--- Resolve the line range from the current mode (visual selection or cursor line).
local function current_range()
  local mode = vim.fn.mode()
  if mode:match '^[vV\22]' then
    local l1 = vim.fn.line 'v'
    local l2 = vim.fn.line '.'
    if l1 > l2 then
      l1, l2 = l2, l1
    end
    return l1, l2
  end
  local l = vim.fn.line '.'
  return l, l
end

---@param opts? { copy?: boolean }
function M.open(opts)
  opts = opts or {}
  local l1, l2 = current_range()
  local url, err = M.get_url(l1, l2)
  if not url then
    vim.notify('git_browse: ' .. err, vim.log.levels.WARN)
    return
  end

  if opts.copy then
    vim.fn.setreg('+', url)
    -- v:echospace is the real room on the cmdline (columns minus showcmd/ruler).
    -- Truncate to it so the message never wraps into a hit-enter prompt.
    local prefix = 'Copied: '
    local max = vim.v.echospace - #prefix
    local shown = #url > max and ('…' .. url:sub(-(max - 1))) or url
    vim.api.nvim_echo({ { prefix, 'MoreMsg' }, { shown } }, false, {})
    return
  end

  vim.ui.open(url)
end

function M.setup()
  vim.keymap.set({ 'n', 'v' }, 'go', function()
    M.open()
    -- leave visual mode after opening
    if vim.fn.mode():match '^[vV\22]' then
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'n', false)
    end
  end, { desc = '[G]it [o]pen line(s) on GitHub' })

  vim.keymap.set({ 'n', 'v' }, 'gy', function()
    M.open { copy = true }
    if vim.fn.mode():match '^[vV\22]' then
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'n', false)
    end
  end, { desc = '[G]it [y]ank GitHub link to line(s)' })
end

return M
