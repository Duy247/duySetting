-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Native Windows shell; projects and files remain owned by the normal user.
-- Store-installed pwsh is an execution alias, which Neovim jobstart cannot use.
-- Profiles supply the real executable; other launchers resolve the package once.
local shell = vim.env.NVIM_POWERSHELL
if not shell or vim.fn.executable(shell) ~= 1 then
  shell = vim.fn.exepath("pwsh")
  local portable = vim.env.LOCALAPPDATA .. "/Programs/PowerShell/7/pwsh.exe"
  if shell == "" and vim.fn.executable(portable) == 1 then shell = portable end
  if shell == "" then
    local package = vim.trim(vim.fn.system({ "powershell.exe", "-NoLogo", "-NoProfile", "-Command",
      "(Get-AppxPackage Microsoft.PowerShell | Select-Object -First 1).InstallLocation" }))
    local executable = package .. "/pwsh.exe"
    shell = vim.fn.executable(executable) == 1 and executable or "powershell.exe"
  end
end
vim.opt.shell = shell
vim.opt.shellcmdflag = "-NoLogo -NoProfile -Command"
vim.opt.shellquote = ""
vim.opt.shellxquote = ""
vim.opt.shellredir = "2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode"
vim.opt.shellpipe = "2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode"
vim.opt.clipboard = "unnamedplus"
vim.g.lazyvim_python_lsp = "basedpyright"
