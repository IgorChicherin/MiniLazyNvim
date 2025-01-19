return {
	"neovim/nvim-lspconfig",
	dependencies = {
		{
			"williamboman/mason.nvim",
			keys = { { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" } },
			dependencies = { "stevearc/dressing.nvim", opts = {}, event = "VeryLazy" },
			opts = {
				ensure_installed = {
					"stylua",
					"shellcheck",
					"shfmt",
					"flake8",
				},
			},
			config = function()
				-- import mason
				local mason = require("mason")

				-- enable mason and configure icons
				mason.setup({
					ui = {
						icons = {
							package_installed = "✓",
							package_pending = "➜",
							package_uninstalled = "✗",
						},
					},
				})
			end,
		},
		{ "williamboman/mason-lspconfig.nvim", config = function() end },
	},
}
