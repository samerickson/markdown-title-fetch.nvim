local M = {}

--- Fetch tile for webpage using curl
---@param url string - url fetch title of
---@param callback function - to call with result of fetching title
local function fetch_title(url, callback)
  vim.system({ "curl", "-s", url }, { text = true }, function(result)
    if result.code ~= 0 then
      vim.notify("Failed to fetch URL: " .. url, vim.log.levels.ERROR)
      return
    end

    -- Extract title from HTML
    local title = result.stdout:match("<title>(.-)</title>")
    if title then
      title = title:gsub("\n", " "):gsub("^%s*(.-)%s*$", "%1") -- Trim whitespace
      callback(title)
    else
      vim.notify("No title found for URL: " .. url, vim.log.levels.WARN)
    end
  end)
end

--- Formats a URL in a way that can be string replaced with gsub()
---@param str string string to escape patterns on
---@return string
---@return integer count
local function escape_pattern(str)
  return str:gsub("([%.%-%+%*%?%[%]%^%$%(%)%{%,%}])", "%%%1")
end

--- Formats links in clipboard register "+" as a markdown link if contents
--- are a link to an html page that contains a <title></title>
local function on_paste()
  print("here")

  -- If we are not in a markdown file then do nothing
  if vim.bo.filetype ~= "markdown" then
    return
  end

  vim.schedule(function()
    -- Get cursor position
    local bufnr = vim.api.nvim_get_current_buf()
    local row, col = unpack(vim.api.nvim_win_get_cursor(0))

    -- TODO: make this overridable via config. You might want to use *
    local line = vim.fn.getreg("+")

    -- Extract URL (basic regex)
    local url = line:match("(http[s]?://[%w%._~:/?#@!$&'()*+,;=-]+)")

    if url then
      print("is url")
      local escaped_url = escape_pattern(url)
      local placeholder = "%%__PLACEHOLDER__%%"
      local new_placeholder_line = line:gsub(escaped_url, "[" .. placeholder .. "](" .. line .. ")")
      -- __AUTO_GENERATED_PRINT_VAR_START__
      print([==[on_paste#(anon)#if new_placeholder_line:]==], vim.inspect(new_placeholder_line)) -- __AUTO_GENERATED_PRINT_VAR_END__
      vim.api.nvim_buf_set_lines(bufnr, row - 1, row, false, { new_placeholder_line })
      vim.api.nvim_win_set_cursor(0, { row, col + #new_placeholder_line })
      print("done")

      fetch_title(url, function(title)
        -- Replace the URL with a Markdown-formatted link
        vim.schedule(function()
          local current_line = vim.api.nvim_buf_get_lines(bufnr, row - 1, row, false)[1]
          local new_line = current_line:gsub(placeholder, title)
          -- __AUTO_GENERATED_PRINT_VAR_START__
          print([==[on_paste#(anon)#if#(anon)#(anon) new_line:]==], vim.inspect(new_line)) -- __AUTO_GENERATED_PRINT_VAR_END__

          vim.api.nvim_buf_set_lines(bufnr, row - 1, row, false, { new_line })

          -- If the request took a while and the user is on a new line, then we want to
          -- update the old line, then return the users cursor to the old line
          local new_row, new_col = unpack(vim.api.nvim_win_get_cursor(0))
          vim.api.nvim_win_set_cursor(0, { new_row, new_col + #new_line })
        end)
      end)
    else
      vim.api.nvim_buf_set_lines(bufnr, row - 1, row, false, { line })
      vim.api.nvim_win_set_cursor(0, { row, col + #line })
    end
  end)
end

---Sets up the plugin by loading 'MarkdownLinkPaste' as a command.
function M.setup()
  vim.api.nvim_create_user_command("MarkdownLinkPaste", function()
    pcall(function()
      on_paste()
    end)
  end, {})
end

return M
