local M = {}

local function find_git_root()
  local current_dir = vim.fn.expand '%:p:h'
  while current_dir ~= '/' do
    if vim.fn.isdirectory(current_dir .. '/.git') == 1 then
      return current_dir
    end
    current_dir = vim.fn.fnamemodify(current_dir, ':h')
  end
  return nil
end

local function read_arb_file(filepath)
  local file = io.open(filepath, 'r')
  if not file then
    return nil
  end
  local content = file:read '*all'
  file:close()
  return content
end

local function write_arb_file(filepath, content)
  local file = io.open(filepath, 'w')
  if not file then
    return false
  end
  file:write(content)
  file:close()
  return true
end

local function add_key_to_arb(arb_content, key_name, value)
  local lines = vim.split(arb_content, '\n')
  if #lines == 0 then
    return nil -- Cannot process empty file
  end

  -- 1. Find the index of the *final* closing brace
  local final_brace_index = -1
  for i = #lines, 1, -1 do -- Iterate backwards
    if lines[i]:match '^%s*}%s*$' then
      final_brace_index = i
      break
    end
  end

  if final_brace_index == -1 then
    vim.notify('Could not find closing brace in ARB file', vim.log.levels.ERROR)
    return arb_content -- Return original content to avoid breaking
  end

  -- 2. Find the last meaningful line *before* the final brace
  local last_content_line_index = -1
  local indentation = '  ' -- Default indentation
  for i = final_brace_index - 1, 1, -1 do
    if not lines[i]:match '^%s*$' then -- If not just whitespace
      last_content_line_index = i
      -- Steal the indentation from the previous line
      indentation = lines[i]:match '^%s*' or indentation
      break
    end
  end

  -- 3. Add a comma to that last line if it needs one
  if last_content_line_index ~= -1 then
    local last_line = lines[last_content_line_index]
    -- Add comma if it doesn't end with one and isn't an opening brace
    if last_line:match '[^,]%s*$' and not last_line:match '^%s*{%s*$' then
      lines[last_content_line_index] = last_line .. ','
    end
  end

  -- 4. Create and insert the new line with correct indentation
  local new_line = indentation .. '"' .. key_name .. '": "' .. value .. '"'
  table.insert(lines, final_brace_index, new_line)

  return table.concat(lines, '\n')
end
local function create_arb_file_if_not_exists(filepath, key_name, value)
  local dir = vim.fn.fnamemodify(filepath, ':h')
  vim.fn.mkdir(dir, 'p')

  local content = '{\n  "' .. key_name .. '": "' .. value .. '"\n}'
  return write_arb_file(filepath, content)
end

local function process_locale_file(filepath, key_name, value)
  local content = read_arb_file(filepath)

  if content then
    content = add_key_to_arb(content, key_name, value)
    if not write_arb_file(filepath, content) then
      vim.notify('Failed to write to ' .. filepath, vim.log.levels.ERROR)
      return false
    end
  else
    if not create_arb_file_if_not_exists(filepath, key_name, value) then
      vim.notify('Failed to create ' .. filepath, vim.log.levels.ERROR)
      return false
    end
  end

  return true
end

local function add_translation_key()
  -- Get visual selection
  local start_pos = vim.fn.getpos "'<"
  local end_pos = vim.fn.getpos "'>"

  if start_pos[2] == 0 or end_pos[2] == 0 then
    vim.notify('No visual selection found', vim.log.levels.ERROR)
    return
  end

  -- Get the selected text
  local lines = vim.fn.getline(start_pos[2], end_pos[2])
  if #lines == 0 then
    vim.notify('No content in selection', vim.log.levels.ERROR)
    return
  end

  local translation_content
  if #lines == 1 then
    local line = lines[1]
    local start_col = start_pos[3]
    local end_col = end_pos[3]
    translation_content = string.sub(line, start_col, end_col)
  else
    vim.notify('Multi-line selection is not supported yet', vim.log.levels.ERROR)
    return
  end

  vim.ui.input({ prompt = 'Translation key (scope.keyName): ' }, function(translation_key)
    if not translation_key or translation_key == '' then
      vim.notify('Translation key is required', vim.log.levels.ERROR)
      return
    end

    local scope, key_name = translation_key:match '^([^%.]+)%.(.+)$'
    if not scope or not key_name then
      vim.notify('Invalid key format. Use: scope.keyName', vim.log.levels.ERROR)
      return
    end

    -- Find git root
    local git_root = find_git_root()
    if not git_root then
      vim.notify('Git repository not found', vim.log.levels.ERROR)
      return
    end

    local base_path = git_root .. '/packages/pancake_work_intl/lib/l10n/' .. scope

    -- Define locales with their values
    local locales = {
      { code = 'en', value = translation_content },
      { code = 'vi', value = 'TODO(translate): ' .. translation_content },
      { code = 'es', value = 'TODO(translate): ' .. translation_content },
    }

    -- Process each locale file
    for _, locale in ipairs(locales) do
      local filepath = base_path .. '/intl_' .. locale.code .. '.arb'
      if not process_locale_file(filepath, key_name, locale.value) then
        return
      end
    end

    local replacement = 'L.' .. scope .. '.' .. key_name

    vim.api.nvim_buf_set_text(0, start_pos[2] - 1, start_pos[3] - 2, end_pos[2] - 1, end_pos[3] + 1, { replacement })
  end)
end

function M.setup()
  vim.api.nvim_create_user_command('PancakeWorkIntl', add_translation_key, { range = true })
end

return M
