local M = {}

function M.formatPaste()
  local pasteRegister = vim.fn.getreg("*")

  local isUrl = string.match(pasteRegister, "^[a-z]*://[^ >,;]*$")

  if not isUrl then
    return pasteRegister
  end

  local curl = require("plenary.curl")
  local res = curl.request({
    url = pasteRegister,
    method = "get",
    accept = "application/json",
  })

  local title = string.match(res.body, "<title>(.-)</title>")

  if title == nil then
    title = "Error: Unable to fetch link title"
  end

  return string.format("[%s](%s)", title, pasteRegister)
end

function M.paste()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  vim.api.nvim_buf_set_text(0, row - 1, col, row - 1, col, { M.formatPaste() })
end

function M.setup()
  vim.api.nvim_create_user_command("MarkdownLinkPaste", function()
    pcall(function()
      M.paste()
    end)
  end, {})
end

return M
