vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
vim.keymap.set("n", "<leader>e", "<cmd>lua MiniFiles.open()<CR>", { desc = "Open file explorer" })
vim.keymap.set("n", "<leader><leader>", "<cmd>Pick files<CR>", { desc = "Find file" })
vim.keymap.set("n", "<leader>bw", "<cmd>:bd<CR>", { desc = "Buffer delete" })

-- quit
vim.keymap.set("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit All" })

-- Move to window using the <ctrl> hjkl keys
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Go to Left Window", remap = true })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Go to Lower Window", remap = true })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Go to Upper Window", remap = true })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Go to Right Window", remap = true })

-- Resize window using <ctrl> arrow keys
vim.keymap.set("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase Window Height" })
vim.keymap.set("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease Window Height" })
vim.keymap.set("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease Window Width" })
vim.keymap.set("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase Window Width" })

-- buffers
vim.keymap.set("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Prev Buffer" })
vim.keymap.set("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next Buffer" })
vim.keymap.set("n", "[b", "<cmd>bprevious<cr>", { desc = "Prev Buffer" })
vim.keymap.set("n", "]b", "<cmd>bnext<cr>", { desc = "Next Buffer" })
vim.keymap.set("n", "<leader>bb", "<cmd>e #<cr>", { desc = "Switch to Other Buffer" })
vim.keymap.set("n", "<leader>`", "<cmd>e #<cr>", { desc = "Switch to Other Buffer" })
vim.keymap.set("n", "<leader>bd", function()
	Snacks.bufdelete()
end, { desc = "Delete Buffer" })
vim.keymap.set("n", "<leader>bo", function()
	Snacks.bufdelete.other()
end, { desc = "Delete Other Buffers" })
vim.keymap.set("n", "<leader>bD", "<cmd>:bd<cr>", { desc = "Delete Buffer and Window" })

-- floating terminal
vim.keymap.set("n", "<c-/>", function()
	Snacks.terminal(nil, { cwd = vim.uv.cwd() })
end, { desc = "Terminal (Root Dir)" })
vim.keymap.set("n", "<c-_>", function()
	Snacks.terminal(nil, { cwd = vim.uv.cwd() })
end, { desc = "which_key_ignore" })

-- Terminal Mappings
vim.keymap.set("t", "<C-/>", "<cmd>close<cr>", { desc = "Hide Terminal" })
vim.keymap.set("t", "<c-_>", "<cmd>close<cr>", { desc = "which_key_ignore" })

-- lazygit
if vim.fn.executable("lazygit") == 1 then
	vim.keymap.set("n", "<leader>gg", function()
		Snacks.lazygit({ cwd = vim.uv.cwd() })
	end, { desc = "Lazygit (Root Dir)" })
	vim.keymap.set("n", "<leader>gG", function()
		Snacks.lazygit()
	end, { desc = "Lazygit (cwd)" })
	vim.keymap.set("n", "<leader>gf", function()
		Snacks.picker.git_log_file()
	end, { desc = "Git Current File History" })
	vim.keymap.set("n", "<leader>gl", function()
		Snacks.picker.git_log({ cwd = vim.uv.cwd() })
	end, { desc = "Git Log" })
	vim.keymap.set("n", "<leader>gL", function()
		Snacks.picker.git_log()
	end, { desc = "Git Log (cwd)" })
end

vim.keymap.set("n", "<leader>cl", "<cmd>LspInfo<cr>", { desc = "Lsp Info" })
vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Goto Definition"})
vim.keymap.set("n", "gr", vim.lsp.buf.references, { desc = "References", nowait = true })
vim.keymap.set("n", "gI", vim.lsp.buf.implementation, { desc = "Goto Implementation" })
vim.keymap.set("n", "gy", vim.lsp.buf.type_definition, { desc = "Goto T[y]pe Definition" })
vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { desc = "Goto Declaration" })
vim.keymap.set("n", "K", function()
	return vim.lsp.buf.hover()
end, { desc = "Hover" })
vim.keymap.set("n", "gK", function()
	return vim.lsp.buf.signature_help()
end, { desc = "Signature Help"})
vim.keymap.set("i", "<c-k>", function()
	return vim.lsp.buf.signature_help()
end, { desc = "Signature Help"} )
-- vim.keymap.set("n", "v", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code Action"})
-- vim.keymap.set("n", "v", "<leader>cc", vim.lsp.codelens.run, { desc = "Run Codelens"})
-- vim.keymap.set("n", "<leader>cC", vim.lsp.codelens.refresh, { desc = "Refresh & Display Codelens"})
-- vim.keymap.set("n", "<leader>cR", function()
-- 	Snacks.rename.rename_file()
-- end, { desc = "Rename File"})
-- vim.keymap.set("n", "<leader>cr", vim.lsp.buf.rename, { desc = "Rename" })
-- vim.keymap.set("n", "<leader>cA", vim.lsp.action.source, { desc = "Source Action"})
-- vim.keymap.set("n", "]]", function()
-- 	Snacks.words.jump(vim.v.count1)
-- end, {
-- 	desc = "Next Reference",
-- 	cond = function()
-- 		return Snacks.words.is_enabled()
-- 	end,
-- })
-- vim.keymap.set("n", "[[", function()
-- 	Snacks.words.jump(-vim.v.count1)
-- end, {
-- 	desc = "Prev Reference",
-- 	cond = function()
-- 		return Snacks.words.is_enabled()
-- 	end,
-- })
-- vim.keymap.set("n", "<a-n>", function()
-- 	Snacks.words.jump(vim.v.count1, true)
-- end, {
-- 	desc = "Next Reference",
-- 	cond = function()
-- 		return Snacks.words.is_enabled()
-- 	end,
-- })
-- vim.keymap.set("n", "<a-p>", function()
-- 	Snacks.words.jump(-vim.v.count1, true)
-- end, {
-- 	desc = "Prev Reference",
-- 	cond = function()
-- 		return Snacks.words.is_enabled()
-- 	end,
-- })
