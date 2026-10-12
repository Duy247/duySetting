return {
  {
    "iamcco/markdown-preview.nvim",
    build = function(plugin)
      local result = vim.system({ "cmd.exe", "/d", "/c", plugin.dir .. "/app/install.cmd" },
        { cwd = plugin.dir .. "/app", text = true }):wait()
      if result.code ~= 0 then error(result.stderr or "Markdown preview installation failed") end
    end,
  },
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      local drivers = {}
      for _, name in ipairs({ "g++", "gcc", "c++" }) do
        local path = vim.fn.exepath(name)
        if path ~= "" then table.insert(drivers, vim.fs.normalize(path)) end
      end
      if #drivers > 0 then
        table.insert(opts.servers.clangd.cmd, "--query-driver=" .. table.concat(drivers, ","))
      end
    end,
  },
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        "vtsls", "eslint-lsp", "prettier", "jdtls", "java-debug-adapter", "java-test",
        "basedpyright", "ruff", "debugpy", "clangd", "clang-format", "codelldb",
        "marksman", "markdownlint-cli2", "json-lsp", "cmake-language-server",
      },
    },
  },
}
