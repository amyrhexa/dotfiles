local M = {}

-- 1.5 MB threshold for disabling expensive editor operations
M.MAX_FILE_SIZE = 1.5 * 1024 * 1024

---Check if a buffer contains a file exceeding the maximum size limit
---@param bufnr number|nil
---@return boolean
function M.is_large_file(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local file = vim.api.nvim_buf_get_name(bufnr)
  if file == "" then
    return false
  end
  local ok, stats = pcall(vim.uv.fs_stat, file)
  if ok and stats and stats.size > M.MAX_FILE_SIZE then
    return true
  end
  return false
end

return M
