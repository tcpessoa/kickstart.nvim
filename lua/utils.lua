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
-- This function will open a Snacks picker with all the scripts found in the Makefile or package.json
-- It runs as a detached job in a new tmux split
function M.fzf_run()
  local makefile_exists = vim.fn.filereadable 'Makefile' == 1
  local package_json_exists = vim.fn.filereadable 'package.json' == 1

  local items = {}

  if makefile_exists then
    local makefile_targets = vim.fn.systemlist "awk -F: '/^[a-zA-Z0-9_-]+:/' Makefile | awk '{print $1}'"
    for _, target in ipairs(makefile_targets) do
      table.insert(items, { text = 'Make: ' .. target, type = 'make', target = target })
    end
  end

  if package_json_exists then
    local package_json_scripts = vim.fn.systemlist "jq -r '.scripts | keys[]' package.json"
    for _, script in ipairs(package_json_scripts) do
      table.insert(items, { text = 'NPM: ' .. script, type = 'npm', target = script })
    end
  end

  if #items == 0 then
    vim.notify('No Makefile or package.json scripts found', vim.log.levels.WARN)
    return
  end

  Snacks.picker {
    prompt = 'Select script',
    items = items,
    format = function(item)
      return { { item.text, 'Normal' } }
    end,
    confirm = function(picker, item)
      picker:close()
      if not item then
        return
      end

      local cmd
      if item.type == 'make' then
        cmd = 'tmux split-window -h "make ' .. item.target .. ' && read"'
      elseif item.type == 'npm' then
        cmd = 'tmux split-window -h "npm run ' .. item.target .. ' && read"'
      else
        vim.notify('Selected script not found in Makefile or package.json', vim.log.levels.ERROR)
        return
      end

      vim.fn.jobstart(cmd, { detach = true })
    end,
  }
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
  Snacks.picker.git_log {
    confirm = function(picker, item)
      picker:close()
      if not item then
        return
      end
      local hash = item.commit
      local files = vim.fn.systemlist('git diff-tree --no-commit-id --name-only -r ' .. hash)
      for _, file in ipairs(files) do
        if file ~= '' then
          vim.cmd('edit ' .. file)
        end
      end
    end,
  }
end

-- Fuzzy-search zsh history and drop the chosen command into the `:!` cmdline.
-- Nothing is executed: you land at `:!<cmd>` ready to edit (cmdline/`q:` motions)
-- and run with <CR>. No terminal spawn, so it's instant.
function M.shell_history_picker()
  -- Resolve the histfile: $HISTFILE if exported, else the usual locations.
  local candidates = { vim.env.HISTFILE, '~/.config/zsh/.zsh_history', '~/.zsh_history' }
  local histfile
  for _, path in ipairs(candidates) do
    if path then
      local expanded = vim.fn.expand(path)
      if vim.fn.filereadable(expanded) == 1 then
        histfile = expanded
        break
      end
    end
  end
  if not histfile then
    vim.notify('No zsh history file found', vim.log.levels.WARN)
    return
  end

  local lines = vim.fn.readfile(histfile)
  local seen = {}
  local items = {}
  -- Walk newest-first (histfile is appended chronologically) and dedup.
  for i = #lines, 1, -1 do
    -- Strip the extended-history metadata prefix ": <ts>:<dur>;" when present.
    local cmd = vim.trim((lines[i]:gsub('^:%s*%d+:%d+;', '')))
    if cmd ~= '' and not seen[cmd] then
      seen[cmd] = true
      table.insert(items, { text = cmd })
    end
  end

  -- Drop `line` into the `:!` cmdline (editable, not executed). Escapes the
  -- chars `:!` would otherwise expand: % (file), # (alt file), ! (prev cmd).
  local function to_cmdline(line)
    vim.schedule(function()
      vim.api.nvim_feedkeys(':!' .. line:gsub('[%%#!]', '\\%0'), 'n', false)
    end)
  end

  -- Single-quote for the shell, so the command lands intact inside `zsh -ic '...'`.
  local function squote(s)
    return "'" .. s:gsub("'", [['\'']]) .. "'"
  end

  Snacks.picker {
    -- Compact dropdown, no (empty) preview pane. Key hints live on the bottom
    -- border (a footer, not a pane — zero extra rows); `?` opens the full overlay.
    title = ' Shell history ',
    layout = {
      preset = 'select',
      layout = {
        footer = ' <CR> run (<C-f> vim edit) · <C-s> alias/fn · ? help ',
        footer_pos = 'center',
      },
    },
    items = items,
    -- Bash treesitter highlighting; cached per item and only run for visible
    -- rows, so it's free even across thousands of history entries.
    format = function(item)
      local ret = {}
      Snacks.picker.highlight.format(item, item.text, ret, { lang = 'bash' })
      return ret
    end,
    -- <CR>: plain `:!cmd` (fast, non-interactive shell).
    confirm = function(picker, item)
      picker:close()
      if not item then
        return
      end
      to_cmdline(item.text)
    end,
    actions = {
      -- <C-s>: wrap in `zsh -ic '...'` so aliases/functions (e.g. gsync) resolve.
      run_interactive = function(picker, item)
        item = item or picker:current()
        picker:close()
        if not item then
          return
        end
        -- `zsh -ic` loads aliases/functions; strip OMZ's harmless zle-init noise.
        to_cmdline('zsh -ic ' .. squote(item.text) .. [[ 2>&1 | grep -v "can't change option: zle"]])
      end,
    },
    win = {
      input = {
        keys = {
          ['<c-s>'] = { 'run_interactive', mode = { 'i', 'n' }, desc = 'Run via interactive zsh (aliases/functions)' },
        },
      },
    },
  }
end

function M.create_or_toggle_checkbox()
  local line = vim.api.nvim_get_current_line()
  if not line:match '- %[.?%]' then
    -- Line doesn't have a checkbox, create one
    vim.api.nvim_set_current_line('- [ ] ' .. line:gsub('^%s*-%s*', ''))
  else
    -- Toggle existing checkbox
    local new_line = line:gsub('%[.%]', function(match)
      return match == '[ ]' and '[x]' or '[ ]'
    end)
    vim.api.nvim_set_current_line(new_line)
  end
end

-- Nearest `node_modules` (walking up from `path`) that has a `typescript`
-- install; handles workspaces where subpackages have their own tsconfig roots
local function ts_install(path)
  if not path then
    return nil
  end
  local dirs = { vim.fs.normalize(path) }
  for dir in vim.fs.parents(dirs[1]) do
    table.insert(dirs, dir)
  end
  for _, dir in ipairs(dirs) do
    if vim.fn.isdirectory(vim.fs.joinpath(dir, 'node_modules', 'typescript')) == 1 then
      return vim.fs.joinpath(dir, 'node_modules')
    end
  end
  return nil
end

-- Major TypeScript version visible from `path` (buffer path or dir), or nil.
-- TS 7 is the native (Go) rewrite: no `tsserver` binary, LSP via `tsc --lsp --stdio`
function M.ts_major(path)
  local install = ts_install(path)
  if not install then
    return nil
  end
  local ok, lines = pcall(vim.fn.readfile, vim.fs.joinpath(install, 'typescript', 'package.json'))
  if not ok or #lines == 0 then
    return nil
  end
  local ok2, pkg = pcall(vim.json.decode, table.concat(lines, '\n'))
  if not ok2 or type(pkg) ~= 'table' or type(pkg.version) ~= 'string' then
    return nil
  end
  return tonumber(pkg.version:match '^(%d+)')
end

-- Start the TS 7 native language server on a buffer, using the nearest
-- `node_modules/.bin/tsc` so diagnostics match the project's toolchain
function M.start_tsgo(bufnr)
  bufnr = bufnr or 0
  local install = ts_install(vim.api.nvim_buf_get_name(bufnr))
  if not install then
    return
  end
  local tsc = vim.fs.joinpath(install, '.bin', 'tsc')
  if vim.fn.executable(tsc) ~= 1 then
    return
  end
  local root = vim.fs.root(bufnr, { 'tsconfig.json', 'package.json' }) or vim.fn.getcwd()
  local caps_ok, blink = pcall(require, 'blink.cmp')
  local capabilities = caps_ok and blink.get_lsp_capabilities() or nil
  vim.lsp.start({
    name = 'tsgo',
    cmd = { tsc, '--lsp', '--stdio' },
    root_dir = root,
    capabilities = capabilities,
  }, { bufnr = bufnr })
end

-- Parse tsc output and populate quickfix
local function parse_tsc_output(data)
  local items = {}
  for _, line in ipairs(data) do
    -- Match: path/file.ts(line,col): error TS1234: message
    local file, lnum, col, msg = line:match '^([^(]+)%((%d+),(%d+)%):%s*(.*)$'
    if file and lnum and col then
      table.insert(items, {
        filename = file,
        lnum = tonumber(lnum),
        col = tonumber(col),
        text = msg,
        type = msg:match '^error' and 'E' or 'W',
      })
    end
  end
  return items
end

-- TypeScript typecheck (project or file)
function M.typecheck(scope)
  scope = scope or 'project'
  local cmd = 'npx tsc --noEmit'
  if scope == 'file' then
    local file = vim.fn.expand '%'
    cmd = 'npx tsc --noEmit ' .. vim.fn.shellescape(file)
  end

  vim.fn.setqflist({}, 'r', { title = 'TypeScript (' .. scope .. ')' })
  vim.notify('Running tsc --noEmit (' .. scope .. ')...', vim.log.levels.INFO)

  local output = {}
  vim.fn.jobstart(cmd, {
    stdout_buffered = true,
    stderr_buffered = true,
    on_stdout = function(_, data)
      if data then
        vim.list_extend(output, data)
      end
    end,
    on_stderr = function(_, data)
      if data then
        vim.list_extend(output, data)
      end
    end,
    on_exit = function(_, code)
      local items = parse_tsc_output(output)
      vim.schedule(function()
        if #items > 0 then
          vim.fn.setqflist({}, 'r', { title = 'TypeScript (' .. scope .. ')', items = items })
          vim.cmd 'copen'
          vim.notify(string.format('TypeScript: %d error(s) found', #items), vim.log.levels.WARN)
        else
          vim.fn.setqflist({}, 'r', { title = 'TypeScript (' .. scope .. ')' })
          if code == 0 then
            vim.notify('TypeScript: No errors!', vim.log.levels.INFO)
          else
            vim.notify('TypeScript: tsc exited with code ' .. code, vim.log.levels.ERROR)
          end
        end
      end)
    end,
  })
end

-- Detect test runner based on project files
local function detect_test_runner()
  if vim.fn.filereadable 'vitest.config.ts' == 1 or vim.fn.filereadable 'vitest.config.js' == 1 then
    return 'vitest'
  elseif vim.fn.filereadable 'bun.lockb' == 1 or vim.fn.filereadable 'bunfig.toml' == 1 then
    return 'bun'
  elseif vim.fn.filereadable 'jest.config.js' == 1 or vim.fn.filereadable 'jest.config.ts' == 1 then
    return 'jest'
  end
  -- Check package.json for test script hints
  if vim.fn.filereadable 'package.json' == 1 then
    local content = vim.fn.readfile 'package.json'
    local json = table.concat(content, '\n')
    if json:match '"vitest"' then
      return 'vitest'
    elseif json:match '"bun test"' then
      return 'bun'
    elseif json:match '"jest"' then
      return 'jest'
    end
  end
  return 'vitest' -- default
end

-- Build test command based on runner and scope
local function build_test_cmd(runner, scope, file)
  local cmds = {
    vitest = {
      all = 'npx vitest run',
      file = 'npx vitest run ' .. (file or ''),
    },
    jest = {
      all = 'npx jest',
      file = 'npx jest ' .. (file or ''),
    },
    bun = {
      all = 'bun test',
      file = 'bun test ' .. (file or ''),
    },
  }
  return cmds[runner] and cmds[runner][scope] or cmds.vitest[scope]
end

-- Run tests (all or current file)
function M.run_tests(scope)
  scope = scope or 'all'
  local runner = detect_test_runner()
  local file = scope == 'file' and vim.fn.expand '%' or nil
  local cmd = build_test_cmd(runner, scope, file)

  vim.notify(string.format('Running %s (%s)...', runner, scope), vim.log.levels.INFO)

  -- Run in a terminal split
  vim.cmd('botright split | terminal ' .. cmd)
  vim.cmd 'startinsert'
end

-- Run tests with picker to choose runner
function M.run_tests_picker()
  local file = vim.fn.expand '%'
  local detected = detect_test_runner()

  local items = {
    { text = 'Vitest: All', runner = 'vitest', scope = 'all' },
    { text = 'Vitest: Current file', runner = 'vitest', scope = 'file', file = file },
    { text = 'Jest: All', runner = 'jest', scope = 'all' },
    { text = 'Jest: Current file', runner = 'jest', scope = 'file', file = file },
    { text = 'Bun: All', runner = 'bun', scope = 'all' },
    { text = 'Bun: Current file', runner = 'bun', scope = 'file', file = file },
  }

  -- Move detected runner to top
  table.sort(items, function(a, b)
    if a.runner == detected and b.runner ~= detected then
      return true
    elseif a.runner ~= detected and b.runner == detected then
      return false
    end
    return false
  end)

  Snacks.picker {
    prompt = 'Run tests (' .. detected .. ' detected)',
    items = items,
    format = function(item)
      local hl = item.runner == detected and 'String' or 'Normal'
      return { { item.text, hl } }
    end,
    confirm = function(picker, item)
      picker:close()
      if not item then
        return
      end
      local cmd = build_test_cmd(item.runner, item.scope, item.file)
      vim.cmd('botright split | terminal ' .. cmd)
      vim.cmd 'startinsert'
    end,
  }
end

return M
