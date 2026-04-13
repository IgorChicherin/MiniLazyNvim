-- lspconfig + mason + lazydev
vim.api.nvim_create_autocmd("User", {
  pattern = "PackChanged",
  callback = function(ev)
    local name = ev.data.spec.name
    if name == "nvim-lspconfig" or name == "mason.nvim" then
      vim.cmd.packadd(name)
    end
  end,
})

vim.schedule(function()
  vim.pack.add({
    "https://github.com/neovim/nvim-lspconfig",
    "https://github.com/williamboman/mason.nvim",
    "https://github.com/williamboman/mason-lspconfig.nvim",
    "https://github.com/jay-babu/mason-nvim-dap.nvim",
    "https://github.com/stevearc/dressing.nvim",
    "https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim",
    "https://github.com/j-hui/fidget.nvim",
    "https://github.com/folke/lazydev.nvim",
    "https://github.com/folke/snacks.nvim",
  })

  require("mason").setup({})
  require("fidget").setup({})
  require("dressing").setup({})
  require("lazydev").setup({
    library = {
      { path = "${3rd}/luv/library", words = { "vim%.uv" } },
    },
  })

  -- LSP Attach
  vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("user-lsp-attach", { clear = true }),
    callback = function(event)
      local map = function(keys, func, desc, mode)
        mode = mode or "n"
        vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
      end

      map("<leader>cl", "<cmd>LspInfo<CR>", "LSP info")
      map("gd", function() vim.pack.add({ "https://github.com/folke/snacks.nvim" }); require("snacks").picker.lsp_definitions() end, "Goto definition")
      map("gD", vim.lsp.buf.declaration, "Goto declaration")
      map("gr", function() vim.pack.add({ "https://github.com/folke/snacks.nvim" }); require("snacks").picker.lsp_references() end, "Goto references")
      map("gI", function() vim.pack.add({ "https://github.com/folke/snacks.nvim" }); require("snacks").picker.lsp_implementations() end, "Goto implementation")
      map("gy", function() vim.pack.add({ "https://github.com/folke/snacks.nvim" }); require("snacks").picker.lsp_type_definitions() end, "Goto type definition")
      map("K", vim.lsp.buf.hover, "Hover")
      map("gx", vim.diagnostic.open_float, "Diagnostics")
      map("gK", vim.lsp.buf.signature_help, "Signature help")
      map("<c-k>", vim.lsp.buf.signature_help, "Signature help", "i")
      map("<leader>cs", function() vim.pack.add({ "https://github.com/folke/snacks.nvim" }); require("snacks").picker.lsp_symbols() end, "Symbols")
      map("<leader>cR", function() vim.pack.add({ "https://github.com/folke/snacks.nvim" }); require("snacks").rename.rename_file() end, "Rename file")
      map("<leader>cr", vim.lsp.buf.rename, "Rename")
      map("<leader>ca", vim.lsp.buf.code_action, "Code action", { "n", "x", "v" })
      map("]]", function() vim.pack.add({ "https://github.com/folke/snacks.nvim" }); require("snacks").words.jump(vim.v.count1) end, "Next reference", { "n", "x", "v" })
      map("[[", function() vim.pack.add({ "https://github.com/folke/snacks.nvim" }); require("snacks").words.jump(-vim.v.count1) end, "Prev reference", { "n", "x", "v" })
      map("a-n", function() vim.pack.add({ "https://github.com/folke/snacks.nvim" }); require("snacks").words.jump(vim.v.count1, true) end, "Next reference", { "n", "x", "v" })
      map("a-p", function() vim.pack.add({ "https://github.com/folke/snacks.nvim" }); require("snacks").words.jump(-vim.v.count1, true) end, "Prev reference", { "n", "x", "v" })

      local client = vim.lsp.get_client_by_id(event.data.client_id)
      if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
        local highlight_augroup = vim.api.nvim_create_augroup("user-lsp-highlight", { clear = false })
        vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
          buffer = event.buf,
          group = highlight_augroup,
          callback = vim.lsp.buf.document_highlight,
        })
        vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
          buffer = event.buf,
          group = highlight_augroup,
          callback = vim.lsp.buf.clear_references,
        })
        vim.api.nvim_create_autocmd("LspDetach", {
          group = vim.api.nvim_create_augroup("user-lsp-detach", { clear = true }),
          callback = function(event2)
            vim.lsp.buf.clear_references()
            vim.api.nvim_clear_autocmds({ group = "user-lsp-highlight", buffer = event2.buf })
          end,
        })
      end

      if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
        map("<leader>th", function()
          vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
        end, "Toggle inlay hints")
      end
    end,
  })

  -- Nerd font icons for diagnostics
  if vim.g.have_nerd_font then
    local signs = { ERROR = " ", WARN = " ", INFO = " ", HINT = " " }
    local diagnostic_signs = {}
    for type, icon in pairs(signs) do
      diagnostic_signs[vim.diagnostic.severity[type]] = icon
    end
    vim.diagnostic.config({ signs = { text = diagnostic_signs } })
  end

  -- LSP Servers
  local function get_python()
    local venv = os.getenv("VIRTUAL_ENV")
    if venv then
      if vim.fn.has("win32") == 1 then
        return venv .. "\\Scripts\\python.exe"
      end
      return venv .. "/bin/python"
    end
    return vim.fn.has("win32") == 1 and "python" or "python3"
  end

  local servers = {
    gopls = {},
    ruff = {},
    basedpyright = {
      settings = {
        python = {
          pythonPath = get_python(),
        },
      },
      basedpyright = {
        analysis = {
          autoSearchPaths = true,
          diagnosticMode = "workspace",
          useLibraryCodeForTypes = true,
        },
      },
    },
    lua_ls = {
      settings = {
        Lua = {
          completion = {
            callSnippet = "Replace",
          },
        },
      },
    },
    clangd = {
      keys = {
        { "<leader>ch", "<cmd>ClangdSwitchSourceHeader<cr>", desc = "Switch Source/Header (C/C++)" },
      },
      root_dir = function(fname)
        return require("lspconfig.util").root_pattern(
          "Makefile",
          "configure.ac",
          "configure.in",
          "config.h.in",
          "meson.build",
          "meson_options.txt",
          "build.ninja"
        )(fname) or require("lspconfig.util").root_pattern("compile_commands.json", "compile_flags.txt")(fname)
          or require("lspconfig.util").find_git_ancestor(fname)
      end,
      capabilities = {
        offsetEncoding = { "utf-16" },
      },
      cmd = {
        "clangd",
        "--background-index",
        "--clang-tidy",
        "--header-insertion=iwyu",
        "--completion-style=detailed",
        "--function-arg-placeholders",
        "--fallback-style=llvm",
      },
      init_options = {
        usePlaceholders = true,
        completeUnimported = true,
        clangdFileStatus = true,
      },
    },
  }

  local ensure_installed = vim.tbl_keys(servers)
  vim.list_extend(ensure_installed, { "stylua" })
  require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

  require("mason-lspconfig").setup({
    handlers = {
      function(server_name)
        local server = servers[server_name] or {}
        require("lspconfig")[server_name].setup(server)
      end,
    },
  })
end)
