-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Mouse navigation uses the clicked symbol, including clicks in another split.
vim.opt.mouse = "a"
local function mouse_definition()
  local pos = vim.fn.getmousepos()
  if pos.winid == 0 or pos.line < 1 or not vim.api.nvim_win_is_valid(pos.winid) then return end
  vim.cmd.stopinsert()
  vim.api.nvim_set_current_win(pos.winid)
  local line = math.min(pos.line, vim.api.nvim_buf_line_count(0))
  local text = vim.api.nvim_buf_get_lines(0, line - 1, line, false)[1] or ""
  vim.api.nvim_win_set_cursor(0, { line, math.min(math.max(pos.column - 1, 0), #text) })
  if #vim.lsp.get_clients({ bufnr = 0, method = "textDocument/definition" }) == 0 then
    vim.notify("The language server is still starting, or this file has no definition provider.", vim.log.levels.INFO)
    return
  end
  vim.lsp.buf.definition()
end
vim.keymap.set({ "n", "i" }, "<C-LeftMouse>", mouse_definition, { desc = "Go to clicked definition" })
vim.keymap.set("n", "g<LeftMouse>", mouse_definition, { desc = "Go to clicked definition" })
vim.keymap.set("n", "<C-RightMouse>", "<C-o>", { desc = "Back from definition" })
-- Neovim's native gx opens URLs, document links, and files using the default application.
