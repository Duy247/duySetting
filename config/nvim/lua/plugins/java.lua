return {
  {
    "mfussenegger/nvim-jdtls",
    opts = {
      -- Projects with the same folder name need separate Eclipse workspaces.
      project_name = function(root)
        return root and (vim.fs.basename(root) .. "-" .. vim.fn.sha256(root):sub(1, 12))
      end,
      jdtls = function(config)
        -- Runner/coverage jars are launched by the test adapter, not OSGi.
        -- Mason exposes both a versioned test plugin and an alias; load once.
        local seen = {}
        config.init_options.bundles = vim.tbl_filter(function(path)
          local name = vim.fs.basename(path)
          -- Reinjecting ASM already shipped with JDTLS forces an invalid
          -- refresh of the language server's own dependency closure.
          local bundled = vim.fn.stdpath("data") .. "/mason/packages/jdtls/plugins/" .. name
          if vim.uv.fs_stat(bundled) then return false end
          if name == "com.microsoft.java.test.runner-jar-with-dependencies.jar"
            or name == "jacocoagent.jar"
            or name == "com.microsoft.java.test.plugin.jar" then return false end
          local real = vim.uv.fs_realpath(path) or path
          if seen[real] then return false end
          seen[real] = true
          return true
        end, config.init_options.bundles or {})
        return config
      end,
    },
  },
}
