local M = {}

M.palette = {
  base = "#232831",
  raised = "#2a303b",
  sel = "#353d4b",
  border = "#444d5e",
  fg = "#e5e9f0",
  bright = "#eceff4",
  dim = "#aeb8c8",
  muted = "#8b97b0",
  accent = "#88c0d0",
  blue = "#81a1c1",
  teal = "#8fbcbb",
  green = "#a3be8c",
  yellow = "#ebcb8b",
  orange = "#d08770",
  red = "#da7a84",
  magenta = "#b48ead",
}

function M.setup()
  vim.cmd("highlight clear")
  if vim.fn.exists("syntax_on") == 1 then
    vim.cmd("syntax reset")
  end

  vim.o.termguicolors = true
  vim.o.background = "dark"
  vim.g.colors_name = "nord-dark"

  local p = M.palette
  local transparent = true

  local function hl(group, spec)
    vim.api.nvim_set_hl(0, group, spec)
  end

  -- Terminal ANSI colors matching Kitty configuration
  local ansi = {
    "#3b4252",
    "#da7a84",
    "#a3be8c",
    "#ebcb8b",
    "#81a1c1",
    "#b48ead",
    "#88c0d0",
    "#d8dee9",
    "#8490a8",
    "#e58a93",
    "#b4cf9d",
    "#f1d8a0",
    "#93b4d4",
    "#c6a1bf",
    "#9bd0df",
    "#eceff4",
  }
  for i, c in ipairs(ansi) do
    vim.g["terminal_color_" .. (i - 1)] = c
  end

  -- UI Chrome
  hl("Normal", { fg = p.fg, bg = transparent and "NONE" or p.base })
  hl("NormalNC", { link = "Normal" })
  hl("NormalFloat", { fg = p.fg, bg = p.raised })
  hl("FloatBorder", { fg = p.border, bg = p.raised })
  hl("FloatTitle", { fg = p.accent, bg = p.raised, bold = true })
  hl("Cursor", { fg = p.base, bg = p.accent })
  hl("CursorLine", { bg = p.raised })
  hl("CursorLineNr", { fg = p.accent, bold = true })
  hl("LineNr", { fg = p.muted })
  hl("SignColumn", { bg = "NONE" })
  hl("ColorColumn", { bg = p.raised })
  hl("Visual", { bg = p.sel })
  hl("Search", { fg = p.base, bg = p.yellow })
  hl("IncSearch", { fg = p.base, bg = p.accent })
  hl("CurSearch", { link = "IncSearch" })
  hl("MatchParen", { fg = p.accent, bold = true, underline = true })
  hl("Pmenu", { fg = p.fg, bg = p.raised })
  hl("PmenuSel", { fg = p.bright, bg = p.sel, bold = true })
  hl("PmenuSbar", { bg = p.raised })
  hl("PmenuThumb", { bg = p.border })
  hl("StatusLine", { fg = p.fg, bg = p.raised })
  hl("StatusLineNC", { fg = p.muted, bg = p.raised })
  hl("WinSeparator", { fg = p.border })
  hl("TabLine", { fg = p.dim, bg = p.raised })
  hl("TabLineSel", { fg = p.base, bg = p.accent, bold = true })
  hl("TabLineFill", { bg = p.raised })
  hl("Folded", { fg = p.muted, bg = p.raised })
  hl("NonText", { fg = p.border })
  hl("Whitespace", { fg = p.border })
  hl("EndOfBuffer", { fg = p.base })
  hl("Conceal", { fg = p.muted })
  hl("Directory", { fg = p.blue })
  hl("Title", { fg = p.accent, bold = true })
  hl("ErrorMsg", { fg = p.red, bold = true })
  hl("WarningMsg", { fg = p.yellow })
  hl("ModeMsg", { fg = p.accent })
  hl("MoreMsg", { fg = p.green })
  hl("Question", { fg = p.green })

  -- Syntax Highlighting
  hl("Comment", { fg = p.muted, italic = true })
  hl("Constant", { fg = p.magenta })
  hl("String", { fg = p.green })
  hl("Character", { link = "String" })
  hl("Number", { fg = p.magenta })
  hl("Boolean", { fg = p.magenta })
  hl("Float", { link = "Number" })
  hl("Identifier", { fg = p.fg })
  hl("Function", { fg = p.accent })
  hl("Statement", { fg = p.blue })
  hl("Operator", { fg = p.blue })
  hl("PreProc", { fg = p.blue })
  hl("Type", { fg = p.teal })
  hl("Special", { fg = p.yellow })
  hl("Delimiter", { fg = p.dim })
  hl("Underlined", { underline = true })
  hl("Error", { fg = p.red })
  hl("Todo", { fg = p.base, bg = p.yellow, bold = true })

  -- Treesitter Captures
  hl("@variable", { fg = p.fg })
  hl("@variable.builtin", { fg = p.blue })
  hl("@function.builtin", { fg = p.accent })
  hl("@type.builtin", { fg = p.teal })
  hl("@punctuation", { fg = p.dim })
  hl("@tag", { fg = p.blue })
  hl("@tag.attribute", { fg = p.teal })
  hl("@markup.heading", { fg = p.accent, bold = true })
  hl("@markup.link.url", { fg = p.accent, underline = true })
  hl("@markup.raw", { fg = p.green })

  -- Diagnostics
  local diag = { Error = p.red, Warn = p.yellow, Info = p.blue, Hint = p.teal, Ok = p.green }
  for name, color in pairs(diag) do
    hl("Diagnostic" .. name, { fg = color })
    hl("DiagnosticVirtualText" .. name, { fg = color })
    hl("DiagnosticUnderline" .. name, { undercurl = true, sp = color })
  end

  -- Spelling
  hl("SpellBad", { undercurl = true, sp = p.red })
  hl("SpellCap", { undercurl = true, sp = p.yellow })
  hl("SpellLocal", { undercurl = true, sp = p.blue })
  hl("SpellRare", { undercurl = true, sp = p.magenta })

  -- Diff & Git
  hl("DiffAdd", { bg = "#2b3a33" })
  hl("DiffChange", { bg = "#2b3547" })
  hl("DiffDelete", { fg = p.red, bg = "#3d2c33" })
  hl("DiffText", { bg = "#36445c" })
  hl("Added", { fg = p.green })
  hl("Changed", { fg = p.yellow })
  hl("Removed", { fg = p.red })
end

-- Lualine Theme matching the Nord palette
M.lualine_theme = {
  normal = {
    a = { fg = M.palette.base, bg = M.palette.accent, gui = "bold" },
    b = { fg = M.palette.fg, bg = M.palette.sel },
    c = { fg = M.palette.dim, bg = M.palette.raised },
  },
  insert = {
    a = { fg = M.palette.base, bg = M.palette.green, gui = "bold" },
    b = { fg = M.palette.fg, bg = M.palette.sel },
    c = { fg = M.palette.dim, bg = M.palette.raised },
  },
  visual = {
    a = { fg = M.palette.base, bg = M.palette.magenta, gui = "bold" },
    b = { fg = M.palette.fg, bg = M.palette.sel },
    c = { fg = M.palette.dim, bg = M.palette.raised },
  },
  replace = {
    a = { fg = M.palette.base, bg = M.palette.red, gui = "bold" },
    b = { fg = M.palette.fg, bg = M.palette.sel },
    c = { fg = M.palette.dim, bg = M.palette.raised },
  },
  command = {
    a = { fg = M.palette.base, bg = M.palette.yellow, gui = "bold" },
    b = { fg = M.palette.fg, bg = M.palette.sel },
    c = { fg = M.palette.dim, bg = M.palette.raised },
  },
  inactive = {
    a = { fg = M.palette.muted, bg = M.palette.raised, gui = "bold" },
    b = { fg = M.palette.muted, bg = M.palette.raised },
    c = { fg = M.palette.muted, bg = M.palette.raised },
  },
}

return M
