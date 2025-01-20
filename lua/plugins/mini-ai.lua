-- Better Around/Inside textobjects
--
-- Examples:
--  - va)  - [V]isually select [A]round [)]paren
--  - yinq - [Y]ank [I]nside [N]ext [Q]uote
--  - ci'  - [C]hange [I]nside [']quote
return {
	{
		"echasnovski/mini.ai",
		version = false,
		init = function()
			require("mini.ai").setup({ n_lines = 500 })
		end,
	},
}
