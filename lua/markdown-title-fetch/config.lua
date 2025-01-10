local M = {}

M.defaults = {
  register = "*",
}

M.options = {}

--- Merge defaults with user opts
---
---@param user_opts? table<string, string>
M.setup = function(user_opts)
  M.options = vim.tbl_deep_extend("force", M.defaults, user_opts or {})
end

return M
