-- Global diagnostic configuration initialized at startup
vim.diagnostic.config({
  virtual_text = false,
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "\u{ea87} ", -- 󰅚
      [vim.diagnostic.severity.WARN] = "\u{ea6c} ",  -- 󰀪
      [vim.diagnostic.severity.INFO] = "\u{ea74} ",  -- 󰋽
      [vim.diagnostic.severity.HINT] = "\u{eb58} ",  -- 󰌵
    },
  },
  underline = true,
  severity_sort = true,
  float = {
    border = "rounded",
    source = true,
  },
})
