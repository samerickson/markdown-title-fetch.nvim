local Config = require("markdown-title-fetch.config")

local M = {}

---Gets contents of '*' register and formats it as a markdown link if the contents are a link
---fetching the title of the webpage automatically. If the webpage title cannot be found,
---then the domain name will be used.
---@private
---@return string formatted url if contents of * are a url, and contents of * as is otherwise
function M.formatPaste()
  local pasteRegister = vim.fn.getreg(Config.options.register)

  local isUrl = string.match(pasteRegister, "^[a-z]*://[^ >,;]*$")

  if not isUrl then
    return pasteRegister
  end

  local curl = require("plenary.curl")
  local res = curl.request({
    url = pasteRegister,
    method = "get",
  })

  local title = res.body:match("<title>(.-)</title>")

  if title == nil then
    title = pasteRegister:match("^%w+://([^/]+)")
  end

  return string.format("[%s](%s)", title, pasteRegister)
end

---Pastes the contents of the register after formatting
---@private
function M.paste()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  vim.api.nvim_buf_set_text(0, row - 1, col, row - 1, col, { M.formatPaste() })
end

---Sets up the plugin by loading 'MarkdownLinkPaste' as a command.
function M.setup(user_opts)
  Config.setup(user_opts)

  vim.api.nvim_create_user_command("MarkdownLinkPaste", function()
    pcall(function()
      M.paste()
    end)
  end, {})
end

return M
