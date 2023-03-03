local lsp = require('lsp-zero')

lsp.preset('recommended')

lsp.nvim_workspace()

ToggleHighlight = function ()
  local highlight = vim.highlight
  local protocol = require('vim.lsp.protocol')

  --@class DiagnosticSeverity
  local DiagnosticSeverity = protocol.DiagnosticSeverity

  local diagnostic_severities = {
    [DiagnosticSeverity.Error]       = { guifg = "Red" };
    [DiagnosticSeverity.Warning]     = { guifg = "Orange" };
    [DiagnosticSeverity.Information] = { guifg = "LightBlue" };
    [DiagnosticSeverity.Hint]        = { guifg = "LightGrey" };
  }

  -- Make a map from DiagnosticSeverity -> Highlight Name
  local make_highlight_map = function(base_name)
    local result = {}
    for k, _ in pairs(diagnostic_severities) do
      result[k] = "LspDiagnostics" .. base_name .. DiagnosticSeverity[k]
    end

    return result
  end

  local underline_highlight_map = make_highlight_map("Underline")

    -- Initialize Underline highlights
  for severity, underline_highlight_name in pairs(underline_highlight_map) do
    highlight.create(underline_highlight_name, {
      cterm = 'underline',
      gui   = 'underline',
      guisp = diagnostic_severities[severity].guifg,
    }, true)

  end
end

vim.cmd([[ autocmd ColorScheme * :lua require('vim.lsp.diagnostic')._define_default_signs_and_highlights() ]])

lsp.setup()

