return {
  {
    "mikavilpas/yazi.nvim",
    version = "*",
    event = "VeryLazy",
    dependencies = { { "nvim-lua/plenary.nvim", lazy = true } },
    keys = {
      { "<leader>e", "<cmd>Yazi<cr>", mode = { "n", "v" }, desc = "Yazi (Current File)" },
      { "<leader>E", "<cmd>Yazi cwd<cr>", desc = "Yazi (cwd)" },
      { "<leader>fy", "<cmd>Yazi toggle<cr>", desc = "Resume Yazi" },
    },
    opts = {
      open_for_directories = true,
      change_neovim_cwd_on_close = false,
      keymaps = { show_help = "<f1>" },
      integrations = { resolve_relative_path_application = vim.env.DUY_REALPATH or "realpath" },
    },
    init = function() vim.g.loaded_netrwPlugin = 1 end,
  },
  {
    "folke/snacks.nvim",
    opts = { explorer = { enabled = false } },
    keys = {
      { "<leader>e", false },
      { "<leader>E", false },
      { "<leader>fe", false },
      { "<leader>fE", false },
    },
  },
}
