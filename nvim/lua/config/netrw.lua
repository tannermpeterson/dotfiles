vim.g.netrw_liststyle = 3 -- tree view
vim.g.netrw_banner = 0 -- hide the top banner
vim.g.netrw_winsize = 25 -- fix the left split width
vim.g.netrw_browse_split = 0 -- open files in the previous window
vim.g.netrw_altfile = 1 -- keep the alternate file correct

vim.keymap.set("n", "<leader>fe", ":Lexplore<cr>", { silent = true })

-- TODO learn all netrw commands
-- TODO is it possible to show diagnostics in netrw?
-- TODO add a keymap that open file explorer at file location (if this doesn't already exist)
-- TODO see if netrw auto-reloads and picks up new files, if not figure out how to do that

-- netrw's built-in `%` opens new files in the netrw window instead of
-- respecting `netrw_browse_split`. Override it to open in the previous window.
vim.api.nvim_create_autocmd("FileType", {
	pattern = "netrw",
	callback = function()
		vim.keymap.set("n", "%", function()
			local fname = vim.fn.input("Enter filename: ")
			if fname == "" then
				return
			end

			local dir = vim.b.netrw_curdir or vim.fn.getcwd()
			local path = dir .. "/" .. fname

			if vim.fn.filereadable(path) == 1 or vim.fn.isdirectory(path) == 1 then
				vim.notify("Already exists: " .. fname, vim.log.levels.WARN)
				return
			end

			if fname:match("/$") then
				vim.fn.mkdir(path, "p")
				vim.cmd("edit")
			else
				local f = io.open(path, "w")
				if not f then
					vim.notify("Failed to create: " .. fname, vim.log.levels.ERROR)
					return
				end
				f:close()

				local escaped = vim.fn.fnameescape(path)
				if vim.fn.winnr("#") == 0 then
					vim.cmd("edit " .. escaped)
				else
					vim.cmd("wincmd p")
					vim.cmd("edit " .. escaped)
				end
			end
		end, { buffer = true, silent = true, noremap = true, desc = "Create file in previous window" })
	end,
})

-- TODO make this work for netrw
-- This auto command reloads neo tree anytime that neovim gains focus so that new files will show up
-- vim.api.nvim_create_autocmd({
-- 	-- "BufEnter",
-- 	-- "CursorHold",
-- 	-- "CursorHoldI",
-- 	"FocusGained",
-- }, {
-- 	callback = function(ev)
-- 		if vim.api.nvim_get_mode() ~= "c" then
-- 			vim.cmd("checktime")
-- 		end
--
-- 		local find_buffer_by_type = function(type)
-- 			for _, buf in ipairs(vim.api.nvim_list_bufs()) do
-- 				local ft = vim.api.nvim_buf_get_option(buf, "filetype")
-- 				if ft == type then
-- 					return buf
-- 				end
-- 			end
-- 			return -1
-- 		end
-- 		if find_buffer_by_type("neo-tree") > 0 then
-- 			vim.cmd("Neotree show ")
-- 		end
-- 	end,
-- 	pattern = { "*" },
-- })
