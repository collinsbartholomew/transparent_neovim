-- Motoko formatter and tooling setup
local M = {}

local function run_in_term(cmd, name)
  local term_ok, term = pcall(require, "toggleterm.terminal")
  if term_ok then
    local Terminal = term.Terminal
    local t = Terminal:new({
      cmd = table.concat(cmd, " "),
      direction = "float",
      close_on_exit = false,
      display_name = name or "Terminal",
    })
    t:toggle()
  else
    vim.cmd("belowright new | terminal " .. table.concat(cmd, " "))
  end
end

local function run_mops(subcommand, fargs, title, fallback)
  if vim.fn.executable("mops") == 0 then
    vim.notify("mops not found. Install from https://mops.one", vim.log.levels.WARN)
    return
  end
  local cmd = { "mops", subcommand }
  if fargs and #fargs > 0 then
    vim.list_extend(cmd, fargs)
  elseif fallback and #fallback > 0 then
    vim.list_extend(cmd, fallback)
  end
  run_in_term(cmd, title)
end

function M.setup()
  local conform_ok, conform = pcall(require, "conform")
  if conform_ok then
    conform.formatters.mo_fmt = {
      command = "mo-fmt",
      args = { "-" },
      stdin = true,
    }
    conform.formatters.motoko_prettier = {
      command = "prettier",
      args = { "--stdin-filepath", "$FILENAME", "--plugin", "prettier-plugin-motoko" },
      stdin = true,
    }
    conform.formatters_by_ft = vim.tbl_extend("force", conform.formatters_by_ft or {}, {
      motoko = { "mo_fmt", "motoko_prettier" },
    })
  end

  vim.api.nvim_create_user_command("MotokoFormat", function()
    local ok, conform = pcall(require, "conform")
    if ok then
      conform.format({ async = true, lsp_fallback = true })
      return
    end
    vim.lsp.buf.format({ async = true })
  end, { desc = "Format Motoko file" })

  vim.api.nvim_create_user_command("MopsBuild", function(opts)
    run_mops("build", opts.fargs, "[Mops Build]")
  end, { nargs = "*", desc = "Build with mops" })

  vim.api.nvim_create_user_command("MopsTest", function(opts)
    run_mops("test", opts.fargs, "[Mops Test]")
  end, { nargs = "*", desc = "Test with mops" })

  vim.api.nvim_create_user_command("MopsUpdate", function(opts)
    run_mops("update", opts.fargs, "[Mops Update]")
  end, { nargs = "*", desc = "Update dependencies or toolchain with mops" })

  vim.api.nvim_create_user_command("MopsFmt", function(opts)
    local fallback = { vim.fn.expand("%:p") }
    run_mops("fmt", opts.fargs, "[Mops Fmt]", fallback)
  end, { nargs = "*", desc = "Run mops fmt" })

  vim.api.nvim_create_user_command("MopsTree", function(opts)
    run_mops("tree", opts.fargs, "[Mops Tree]")
  end, { nargs = "*", desc = "Show dependency tree with mops" })

  vim.api.nvim_create_user_command("MopsInit", function(opts)
    local args = { "init" }
    if opts.fargs and #opts.fargs > 0 then
      vim.list_extend(args, opts.fargs)
    end
    run_mops("toolchain", args, "[Mops Toolchain Init]")
  end, { nargs = "*", desc = "Initialize mops toolchain" })

  vim.api.nvim_create_user_command("DfxDeploy", function(opts)
    local args = opts.args or ""
    run_in_term({ "dfx", "deploy", args }, "[DFX Deploy]")
  end, { nargs = "?", desc = "Deploy with dfx" })

  vim.api.nvim_create_user_command("DfxStart", function(opts)
    local args = opts.args or "--background"
    run_in_term({ "dfx", "start", args }, "[DFX Start]")
  end, { nargs = "?", desc = "Start dfx replica" })

  vim.api.nvim_create_user_command("DfxStop", function()
    run_in_term({ "dfx", "stop" }, "[DFX Stop]")
  end, { desc = "Stop dfx replica" })

  vim.api.nvim_create_user_command("DfxBuild", function(opts)
    local args = opts.args or ""
    run_in_term({ "dfx", "build", args }, "[DFX Build]")
  end, { nargs = "?", desc = "Build with dfx" })

  vim.api.nvim_create_user_command("DfxCanisterCall", function(opts)
    if opts.args == "" then
      vim.notify("Usage: DfxCanisterCall <canister> <method> [args]", vim.log.levels.WARN)
      return
    end
    run_in_term({ "dfx", "canister", "call", opts.args }, "[DFX Canister Call]")
  end, { nargs = "+", desc = "Call canister method" })

  vim.api.nvim_create_user_command("DfxCanisterStatus", function(opts)
    local args = opts.args or "--all"
    run_in_term({ "dfx", "canister", "status", args }, "[DFX Canister Status]")
  end, { nargs = "?", desc = "Check canister status" })

  vim.api.nvim_create_user_command("MotokoCheck", function()
    local file = vim.fn.expand("%:p")
    if vim.fn.executable("moc") == 1 then
      run_in_term({ "moc", "--check", file }, "[Motoko Check]")
    else
      vim.notify("moc compiler not found. Install dfx SDK", vim.log.levels.WARN)
    end
  end, { desc = "Type-check Motoko file" })
end

return M
