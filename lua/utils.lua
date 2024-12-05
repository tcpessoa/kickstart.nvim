local M = {}

function M.insert_snippet(snippet_name, from_visual)
  local word

  if from_visual then
    -- Reselect the visual selection
    vim.cmd 'normal! gv'
    local start_pos = vim.fn.getpos "'<"
    local end_pos = vim.fn.getpos "'>"

    if start_pos[2] > end_pos[2] or (start_pos[2] == end_pos[2] and start_pos[3] > end_pos[3]) then
      -- Swap if start is after end
      start_pos, end_pos = end_pos, start_pos
    end

    local lines = vim.api.nvim_buf_get_text(0, start_pos[2] - 1, start_pos[3] - 1, end_pos[2] - 1, end_pos[3], {})
    word = table.concat(lines, ' ')
  else
    word = vim.fn.expand '<cword>'
  end

  local file_name = vim.fn.expand '%:t'
  local line_number = vim.api.nvim_win_get_cursor(0)[1]

  local snippet = {
    clog = 'console.log(`\\x1b[1;30;42m ' .. file_name .. ':' .. line_number .. ' ' .. word .. ': ${' .. word .. '} \\x1b[0m`);',
    clogo = 'console.log(`\\x1b[1;30;42m ' .. file_name .. ':' .. line_number .. ' ' .. word .. ': ${JSON.stringify(' .. word .. ', null, 2)} \\x1b[0m`);',
  }

  vim.api.nvim_buf_set_lines(0, line_number, line_number, false, { snippet[snippet_name] })
  local target_line = vim.api.nvim_buf_get_lines(0, line_number, line_number + 1, false)[1]
  local target_col = target_line:find '}' or (#target_line + 1)

  vim.api.nvim_win_set_cursor(0, { line_number + 1, target_col - 1 })
  -- Hit the escape key to exit visual mode if we are in visual mode
  local esc = vim.api.nvim_replace_termcodes('<esc>', true, false, true)
  vim.api.nvim_feedkeys(esc, 'x', false)
end

-- Run a script from the `Makefile` or `package.json`
-- This function will open a telescope picker with all the scripts found in the Makefile or package.json
-- It runs as a detached job in a new tmux split
function M.fzf_run()
  local makefile_exists = vim.fn.filereadable 'Makefile' == 1
  local package_json_exists = vim.fn.filereadable 'package.json' == 1

  local scripts = {}

  if makefile_exists then
    local makefile_targets = vim.fn.systemlist "awk -F: '/^[a-zA-Z0-9_-]+:/' Makefile | awk '{print $1}'"
    for _, target in ipairs(makefile_targets) do
      table.insert(scripts, 'Make: ' .. target)
    end
  end

  if package_json_exists then
    local package_json_scripts = vim.fn.systemlist "jq -r '.scripts | keys[]' package.json"
    for _, script in ipairs(package_json_scripts) do
      table.insert(scripts, 'NPM: ' .. script)
    end
  end

  if #scripts == 0 then
    vim.notify('No Makefile or package.json scripts found', vim.log.levels.WARN)
    return
  end

  require('telescope.pickers')
    .new({}, {
      prompt_title = 'Select script',
      finder = require('telescope.finders').new_table {
        results = scripts,
      },
      sorter = require('telescope.config').values.generic_sorter {},
      attach_mappings = function(prompt_bufnr, map)
        local actions = require 'telescope.actions'
        local action_state = require 'telescope.actions.state'

        actions.select_default:replace(function()
          actions.close(prompt_bufnr)
          local selected_script = action_state.get_selected_entry()[1]
          local cmd

          if selected_script:match '^Make: ' then
            local target = selected_script:sub(7)
            cmd = 'tmux split-window -h "make ' .. target .. ' && read"'
          elseif selected_script:match '^NPM: ' then
            local script = selected_script:sub(6)
            cmd = 'tmux split-window -h "npm run ' .. script .. ' && read"'
          else
            vim.notify('Selected script not found in Makefile or package.json', vim.log.levels.ERROR)
            return
          end

          vim.fn.jobstart(cmd, { detach = true })
        end)

        return true
      end,
    })
    :find()
end

-- Base function that handles the common logic
function M.run_in_node(from_visual, transform)
  local line_start, line_end

  if from_visual then
    vim.cmd 'normal! gv'
    line_start = vim.fn.getpos("'<")[2]
    line_end = vim.fn.getpos("'>")[2]
  else
    line_start = vim.fn.line '.'
    line_end = vim.fn.line '.'
  end

  local lines = vim.api.nvim_buf_get_lines(0, line_start - 1, line_end, false)
  local code = table.concat(lines, '\n')

  if transform then
    code = transform(code)
  end

  local tmp_file = vim.fn.tempname() .. '.js'
  local file = io.open(tmp_file, 'w')
  if file == nil then
    vim.notify('Failed to open file for writing: ' .. tmp_file, vim.log.levels.ERROR)
  else
    file:write(code)
    file:close()
  end

  -- Load file content to node REPL and leave it open
  local cmd = 'vsplit term://node -i -e \\"$(< ' .. tmp_file .. ' )\\"'
  vim.cmd(cmd)
end

-- Run current line or visual selection in Node REPL
function M.run_node(from_visual)
  M.run_in_node(from_visual) -- No transform, code as is
end

-- Analyze the current object in Node REPL
-- This function will load the object as `obj` in the Node REPL
function M.run_node_with_obj(from_visual)
  M.run_in_node(from_visual, function(code)
    return string.format(
      [[
const obj = %s;
console.log('Object loaded as "obj". You can explore it.');
    ]],
      code
    )
  end)
end

-- Open the current file with the system's default application
function M.system_open(path)
  if not path then
    path = vim.fn.expand '<cfile>'
  elseif not path:match '%w+:' then
    path = vim.fn.expand(path)
  end
  -- TODO: remove deprecated method check after dropping support for neovim v0.9
  if vim.ui.open then
    return vim.ui.open(path)
  end
  local cmd
  if vim.fn.has 'mac' == 1 then
    cmd = { 'open' }
  elseif vim.fn.has 'win32' == 1 then
    if vim.fn.executable 'rundll32' then
      cmd = { 'rundll32', 'url.dll,FileProtocolHandler' }
    else
      cmd = { 'cmd.exe', '/K', 'explorer' }
    end
  elseif vim.fn.has 'unix' == 1 then
    if vim.fn.executable 'explorer.exe' == 1 then
      cmd = { 'explorer.exe' }
    elseif vim.fn.executable 'xdg-open' == 1 then
      cmd = { 'xdg-open' }
    end
  end
  if not cmd then
    vim.notify('Available system opening tool not found!', vim.log.levels.ERROR)
  end
  vim.fn.jobstart(vim.list_extend(cmd, { path }), { detach = true })
end

function M.escape_for_regex()
  -- Reselect the visual selection
  vim.cmd 'normal! gv'
  local start_pos = vim.fn.getpos "'<"
  local end_pos = vim.fn.getpos "'>"
  if start_pos[2] > end_pos[2] or (start_pos[2] == end_pos[2] and start_pos[3] > end_pos[3]) then
    -- Swap if start is after end
    start_pos, end_pos = end_pos, start_pos
  end

  local start_line, start_col = start_pos[2] - 1, start_pos[3] - 1
  local end_line, end_col = end_pos[2] - 1, end_pos[3]

  -- Handle line-wise visual mode (Shift+V)
  if end_col == 2147483647 then
    end_col = -1 -- Use -1 to represent the end of the line
  end

  -- Handle multi-line selections and selections ending at the start of a line
  if start_line ~= end_line or end_col == -1 then
    end_line = end_line + 1

    end_col = 0
  else
    end_col = end_col + 1
  end

  local lines = vim.api.nvim_buf_get_text(0, start_line, start_col, end_line, end_col, {})
  local text = table.concat(lines, '\n')

  -- Escape special regex characters
  local escaped_text = text:gsub('([()[%]{}.*+?^$|\\])', '\\%1')

  -- Put in the clipboard (both + and " registers)
  vim.fn.setreg('+', escaped_text)
  vim.fn.setreg('"', escaped_text)

  -- Exit visual mode
  local esc = vim.api.nvim_replace_termcodes('<esc>', true, false, true)
  vim.api.nvim_feedkeys(esc, 'x', false)

  print 'Regex-escaped text copied to clipboard'
end

-- open_commit_files: Open the files modified in a commit
function M.open_commit_files()
  local actions = require 'telescope.actions'
  local action_state = require 'telescope.actions.state'
  local previewers = require 'telescope.previewers'
  local files_previewer = previewers.new_buffer_previewer {
    title = 'Modified Files',
    define_preview = function(self, entry)
      local hash = entry.value
      local files = vim.fn.systemlist('git diff-tree --no-commit-id --name-only -r ' .. hash)
      local content = 'Modified files:\n\n' .. table.concat(files, '\n')
      vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, vim.split(content, '\n'))
    end,
  }

  require('telescope.builtin').git_commits {
    previewer = files_previewer,
    attach_mappings = function(_, map)
      map('i', '<CR>', function(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        local hash = selection.value
        actions.close(prompt_bufnr)
        local files = vim.fn.systemlist('git diff-tree --no-commit-id --name-only -r ' .. hash)
        for _, file in ipairs(files) do
          vim.cmd('edit ' .. file)
        end
      end)
      return true
    end,
  }
end

return M
