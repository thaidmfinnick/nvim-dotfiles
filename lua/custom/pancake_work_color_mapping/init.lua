local M = {}

local ns_id = vim.api.nvim_create_namespace 'pancake_work_color_mapping'
local color_file_path = '/Users/admin/Documents/projects/pancake-work/pancake-work-client/packages/pancake_work_ui/lib/pancake_work_colors.dart'

M.color_map = nil
M.color_pair_map = nil

---@return table<string, string>
local function get_color_map()
  if M.color_map then
    return M.color_map
  end

  local color_map = {}

  -- pcall to handle file not found without erroring
  local ok, file = pcall(io.open, color_file_path, 'r')
  if not ok or not file then
    vim.notify('Could not open Pancake Work color file: ' .. color_file_path, vim.log.levels.WARN)
    M.color_map = {} -- cache empty table to avoid retrying
    return M.color_map
  end

  for line in file:lines() do
    -- Matches lines like: final Color grey1 = const Color(0xFFFFFFFF);
    local name, color = line:match('final Color%s+(%w+)%s*=%s*const%s*Color%((0x' .. ('[a-fA-F0-9]'):rep(8) .. ')%)')
    if name and color then
      -- Map from color hex to color name
      color_map[string.upper(color)] = name
    end
  end

  file:close()
  M.color_map = color_map
  return M.color_map
end

---@return table<string, string>
local function get_color_pair_map()
  if M.color_pair_map then
    return M.color_pair_map
  end

  local color_map = get_color_map()
  if vim.tbl_isempty(color_map) then
    M.color_pair_map = {}
    return M.color_pair_map
  end

  -- Create a reverse map from name to color hex
  local name_to_color_map = {}
  for color, name in pairs(color_map) do
    name_to_color_map[name] = color
  end

  local color_pair_map = {}

  local ok, file = pcall(io.open, color_file_path, 'r')
  if not ok or not file then
    -- Already notified in get_color_map
    M.color_pair_map = {}
    return M.color_pair_map
  end

  for line in file:lines() do
    -- Matches lines like: Color get display => {PancakeWorkTheme.dark: darkGrey2, PancakeWorkTheme.light: grey12}[theme]!;
    local pair_name, dark_name, light_name = line:match 'Color get (%w+)%s*=>%s*{%s*PancakeWorkTheme.dark:%s*(%w+),%s*PancakeWorkTheme.light:%s*(%w+)%s*}'
    if pair_name and dark_name and light_name then
      local dark_color = name_to_color_map[dark_name]
      local light_color = name_to_color_map[light_name]

      if dark_color and light_color then
        local key = dark_color .. light_color
        if color_pair_map[key] == nil then
          color_pair_map[key] = { pair_name }
        else
          vim.list_extend(color_pair_map[key], { pair_name })
        end
      end
    end
  end

  file:close()
  M.color_pair_map = color_pair_map
  return M.color_pair_map
end

local function parse_color(line, color_map)
  local last_pos = 1
  local result = {}

  while true do
    -- Find colors like 0xFF123456
    local start_col, end_col = line:find('0x' .. ('[a-fA-F0-9]'):rep(8), last_pos)
    if not start_col then
      return result
    end

    local color = line:sub(start_col, end_col)
    local color_key = string.upper(color)
    local color_name = color_map[color_key]

    if color_name then
      vim.list_extend(result, { { name = color_name, color = color_key, start_col = start_col, end_col = end_col } })
    end

    last_pos = end_col + 1
  end
end

function M.display_color_names()
  -- Clear previous virtual text
  vim.api.nvim_buf_clear_namespace(0, ns_id, 0, -1)

  local color_map = get_color_map()
  local color_pair_map = get_color_pair_map()

  if vim.tbl_isempty(color_map) and vim.tbl_isempty(color_pair_map) then
    return
  end

  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

  for i, line in ipairs(lines) do
    if not vim.tbl_isempty(color_map) then
      for _, entry in ipairs(parse_color(line, color_map)) do
        -- Display the color name as virtual text
        local virt_text = { { ' ' .. entry.name, 'Comment' } }
        vim.api.nvim_buf_set_extmark(0, ns_id, i - 1, entry.end_col, {
          virt_text = virt_text,
          virt_text_pos = 'inline',
        })
      end
    end

    if not vim.tbl_isempty(color_pair_map) then
      -- isDark ? const Color(0xff25282A) : const Color(0xffF2F4F7)
      if line:match 'isDark %?' then
        local colors = parse_color(line, color_map)

        if #colors == 2 then
          local key = string.upper(colors[1].color) .. string.upper(colors[2].color)
          local pair_name = color_pair_map[key]

          if pair_name then
            local text = vim.iter(pair_name):join ' or '
            local virt_text = { { ' ' .. text, 'Comment' } }
            vim.api.nvim_buf_set_extmark(0, ns_id, i - 1, -1, {
              virt_text = virt_text,
              virt_text_pos = 'eol',
            })
          end
        end
      end
    end
  end
end

function M.setup()
  -- Using a group to easily clear autocmds if needed
  local group = vim.api.nvim_create_augroup('PancakeWorkColorMapping', { clear = true })

  vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost' }, {
    group = group,
    pattern = '*.dart',
    callback = function()
      -- Defer to avoid running on every event in quick succession
      vim.defer_fn(M.display_color_names, 100)
    end,
  })
end

return M
