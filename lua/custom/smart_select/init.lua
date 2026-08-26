local M = {}

local query_dir = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":h") .. "/queries"
local cache = {}

local aliases = { tsx = "typescript" }

-- Custom directive to combine ranges of two captures into a single named range.
-- Usage in queries: (#make-range! "subject" @_start @_end)
-- Lets a single "subject" span multiple sibling nodes (e.g. `pairs[index]` in
-- Dart, where identifier and selector are separate `value:` field children).
vim.treesitter.query.add_directive("make-range!", function(match, _, _, pred, metadata)
  local name = pred[2]
  local start_nodes = match[pred[3]]
  local end_nodes = match[pred[4]]
  if not start_nodes or not end_nodes then
    return
  end
  local start_node = type(start_nodes) == "table" and start_nodes[1] or start_nodes
  local end_node = type(end_nodes) == "table" and end_nodes[#end_nodes] or end_nodes
  local sr, sc = start_node:start()
  local _, _, er, ec = end_node:range()
  metadata[name] = metadata[name] or {}
  metadata[name].range = { sr, sc, er, ec }
end, { force = true, all = true })

-- Span every child of a parent that has a given field name, producing one
-- range from the first such child to the last. Useful when a grammar splits a
-- conceptual expression across N sibling field children (e.g. Dart's
-- `value:` chain for `below.message.senderId`), which can't be expressed as a
-- fixed-arity pattern.
-- Usage in queries: (#span-field-children! "subject" @_parent "value")
vim.treesitter.query.add_directive("span-field-children!", function(match, _, _, pred, metadata)
  local name = pred[2]
  local parent_nodes = match[pred[3]]
  local field = pred[4]
  if not parent_nodes then
    return
  end
  local parent = type(parent_nodes) == "table" and parent_nodes[1] or parent_nodes
  local children = parent:field(field)
  if not children or #children == 0 then
    return
  end
  local first = children[1]
  local last = children[#children]
  local sr, sc = first:start()
  local _, _, er, ec = last:range()
  metadata[name] = metadata[name] or {}
  metadata[name].range = { sr, sc, er, ec }
end, { force = true, all = true })

local function get_query(lang)
  if cache[lang] ~= nil then
    return cache[lang] or nil
  end
  local file_lang = aliases[lang] or lang
  local path = query_dir .. "/" .. file_lang .. ".scm"
  if vim.fn.filereadable(path) ~= 1 then
    cache[lang] = false
    return nil
  end
  local source = table.concat(vim.fn.readfile(path), "\n")
  local ok, parsed = pcall(vim.treesitter.query.parse, lang, source)
  if not ok then
    vim.notify("smart_select: failed to parse query for " .. lang .. ": " .. tostring(parsed), vim.log.levels.ERROR)
    cache[lang] = false
    return nil
  end
  cache[lang] = parsed
  return parsed
end

local function contains(sr, sc, er, ec, row, col)
  local after_start = sr < row or (sr == row and sc <= col)
  local before_end = er > row or (er == row and ec > col)
  return after_start and before_end
end

local function is_subject(name)
  return name == "subject" or name == "subject.linewise"
end

function M.select()
  local bufnr = vim.api.nvim_get_current_buf()
  local ok, parser = pcall(vim.treesitter.get_parser, bufnr)
  if not ok or not parser then
    return
  end

  local lang = parser:lang()
  local query = get_query(lang)
  if not query then
    return
  end

  local trees = parser:parse()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local row, col = cursor[1] - 1, cursor[2]

  local best_size, best_sr, best_sc, best_er, best_ec, best_linewise

  local function consider(sr, sc, er, ec, linewise)
    if not contains(sr, sc, er, ec, row, col) then
      return
    end
    local size = (er - sr) * 1e6 + (ec - sc)
    if not best_size or size < best_size then
      best_size = size
      best_sr, best_sc, best_er, best_ec = sr, sc, er, ec
      best_linewise = linewise
    end
  end

  for _, tree in ipairs(trees) do
    for _, match, metadata in query:iter_matches(tree:root(), bufnr, 0, -1, { all = true }) do
      local seen = {}
      -- Synthetic ranges from #make-range! take precedence over direct captures
      -- of the same name (the directive's whole point is to override).
      for key, m in pairs(metadata) do
        if type(key) == "string" and is_subject(key) and m.range then
          seen[key] = true
          consider(m.range[1], m.range[2], m.range[3], m.range[4], key == "subject.linewise")
        end
      end
      for id, nodes in pairs(match) do
        local name = query.captures[id]
        if is_subject(name) and not seen[name] then
          local node = nodes[1]
          local sr, sc, er, ec = node:range()
          consider(sr, sc, er, ec, name == "subject.linewise")
        end
      end
    end
  end

  if not best_size then
    return
  end

  -- In visual mode the callback fires while visual is still active, so a bare
  -- `normal! v` would toggle it off. Exit visual first; skip the escape when in
  -- operator-pending mode (would cancel the pending operator like d/y/gc).
  local mode = vim.fn.mode()
  if mode == "v" or mode == "V" or mode == "\22" then
    vim.cmd([[execute "normal! \<Esc>"]])
  end
  vim.api.nvim_win_set_cursor(0, { best_sr + 1, best_sc })
  if best_linewise then
    vim.cmd("normal! V")
    local end_row = best_ec == 0 and best_er or best_er + 1
    vim.api.nvim_win_set_cursor(0, { end_row, 0 })
  else
    vim.cmd("normal! v")
    if best_ec == 0 then
      local last_col = math.max(vim.fn.col({ best_er, "$" }) - 2, 0)
      vim.api.nvim_win_set_cursor(0, { best_er, last_col })
    else
      vim.api.nvim_win_set_cursor(0, { best_er + 1, best_ec - 1 })
    end
  end
end

-- `.` is a text object, so `v.` selects the node and `d.` / `y.` / `c.`
-- operate on the same region.
function M.setup(opts)
  opts = opts or {}
  local key = opts.key or "."
  vim.keymap.set({ "x", "o" }, key, M.select, { silent = true, desc = "Smart select node at cursor" })
end

return M
