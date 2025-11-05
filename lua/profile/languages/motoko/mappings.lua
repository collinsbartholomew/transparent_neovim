-- Motoko key mappings
local M = {}

function M.setup()
  local wk_ok, wk = pcall(require, "which-key")
  if not wk_ok then
    return
  end

  -- Add Motoko specific key mappings under the language prefix
  wk.add({
    { "<leader>lm", group = "Motoko" },
    { "<leader>lmd", "<cmd>lua vim.lsp.buf.definition()<cr>", desc = "Go to Definition" },
    { "<leader>lmt", "<cmd>lua vim.lsp.buf.type_definition()<cr>", desc = "Type Definition" },
    { "<leader>lmr", "<cmd>lua vim.lsp.buf.rename()<cr>", desc = "Rename" },
    { "<leader>lmi", "<cmd>lua vim.lsp.buf.implementation()<cr>", desc = "Implementation" },
    { "<leader>lmf", "<cmd>lua vim.lsp.buf.format { async = true }<cr>", desc = "Format" },
    { "<leader>lmc", "<cmd>lua vim.lsp.buf.code_action()<cr>", desc = "Code Action" },
    { "<leader>lms", "<cmd>lua vim.lsp.buf.signature_help()<cr>", desc = "Signature Help" },
    { "<leader>lmh", "<cmd>lua vim.lsp.buf.hover()<cr>", desc = "Hover" },
    { "<leader>lmo", "<cmd>lua vim.diagnostic.open_float()<cr>", desc = "Diagnostics" },
  })
end

return M