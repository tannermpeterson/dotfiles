---------------------------------
-- PACKAGES ---------------------
---------------------------------

-- :lua vim.pack.update(nil, { force = true })
-- :checkhealth vim.pack
vim.pack.add({
  { src = 'https://github.com/folke/tokyonight.nvim', version = '545d72c' },
  { src = 'https://github.com/neovim/nvim-lspconfig', version = 'f6738ef' },
  { src = 'https://github.com/junegunn/fzf.vim', version = 'd2a59a9' },
  { src = 'https://github.com/junegunn/fzf', version = 'f7ae439' },
  { src = 'https://github.com/christoomey/vim-tmux-navigator', version = 'e41c431' }
})
-- TODO use any of this?
--use("nvim-treesitter/nvim-treesitter", { run = ":TSUpdate" })
--use("mbbill/undotree")
--use("tpope/vim-fugitive")
--use({
--	"nvim-neo-tree/neo-tree.nvim",
--	branch = "v3.x",
--	requires = {
--		{ "nvim-lua/plenary.nvim" },
--		{ "nvim-tree/nvim-web-devicons" }, -- not strictly required, but recommended
--		{ "MunifTanjim/nui.nvim" },
--		-- "3rd/image.nvim", -- Optional image support in preview window: See `# Preview Mode` for more information
--	},
--})


---------------------------------
-- SETS -------------------------
---------------------------------

vim.opt.nu = true
vim.opt.relativenumber = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.smartindent = true

vim.opt.wrap = false

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

vim.opt.hlsearch = true
vim.opt.incsearch = true

vim.opt.termguicolors = true

vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"

vim.opt.isfname:append("@-@")

vim.opt.updatetime = 50

vim.opt.colorcolumn = "110"

vim.opt.cindent = false
vim.cmd('filetype indent off')

vim.g.mapleader = " "

-- TODO learn how to use the autocomplete better (i.e. ctrl-x options)
vim.o.autoread = true
vim.o.complete = '.,w,b,o'
vim.o.completeopt = 'menu,noselect,fuzzy,popup,preview'
vim.o.autocomplete = true
vim.o.autocompletedelay = 200
vim.o.winborder = "rounded"
vim.o.pummaxwidth = 70
vim.o.pumheight = 7

vim.diagnostic.config({
  virtual_text = {
    spacing = 4, -- Distance from the end of the line text
    prefix = '■', -- The symbol shown before the error message
  },
  severity_sort = true, -- Sort diagnostics by severity (Errors first)
})


-- TODO is any of this needed? Is neo-tree needed? If so move this auto cmd
-- This auto command reloads neo tree anytime that neovim gains focus so that new files will show up
vim.api.nvim_create_autocmd({
	-- "BufEnter",
	-- "CursorHold",
	-- "CursorHoldI",
	"FocusGained",
}, {
	callback = function(ev)
		if vim.api.nvim_get_mode() ~= "c" then
			vim.cmd("checktime")
		end

		local find_buffer_by_type = function(type)
			for _, buf in ipairs(vim.api.nvim_list_bufs()) do
				local ft = vim.api.nvim_buf_get_option(buf, "filetype")
				if ft == type then
					return buf
				end
			end
			return -1
		end
		if find_buffer_by_type("neo-tree") > 0 then
			vim.cmd("Neotree show ")
		end
	end,
	pattern = { "*" },
})
vim.api.nvim_create_autocmd(
	{ "FileChangedShellPost" },
	{ command = 'echohl WarningMsg | echo "File changed on disk. Buffer reloaded." | echohl None', pattern = { "*" } }
)


---------------------------------
-- REMAPS -----------------------
---------------------------------

-- NOTE: some remaps are in files under lua/config/

-- TODO see how this feels
vim.keymap.set("i", "<C-enter>", "<Esc>")
vim.keymap.set("v", "<C-enter>", "<Esc>")

-- move highlighted lines up and down
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")
-- shift highlighted lines left and right
vim.keymap.set("v", "<", "<gv")
vim.keymap.set("v", ">", ">gv")

vim.keymap.set("n", "J", "mzJ`z")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

vim.keymap.set("x", "<leader>p", '"_dP')

vim.keymap.set("n", "<leader>y", '"+y')
vim.keymap.set("v", "<leader>y", '"+y')
vim.keymap.set("n", "<leader>Y", '"+y$')

vim.keymap.set("n", "<leader>d", '"+d')
vim.keymap.set("v", "<leader>d", '"+d')

vim.keymap.set("n", "Q", "<nop>")

vim.keymap.set("n", "<C-n>", "<cmd>cnext<CR>zz")
vim.keymap.set("n", "<C-p>", "<cmd>cprev<CR>zz")
-- TODO are these needed?
-- vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz")
-- vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz")

vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])

vim.keymap.set("n", "<leader>c", function()
	local qf_exists = false
	for _, win in pairs(vim.fn.getwininfo()) do
		if win["quickfix"] == 1 then
			qf_exists = true
            break
		end
	end
	if qf_exists == true then
		vim.cmd("cclose")
	elseif not vim.tbl_isempty(vim.fn.getqflist()) then
		vim.cmd("copen")
	else
        print("No quickfix list found")
    end
end)

vim.keymap.set("i", "<C-h>", vim.lsp.buf.signature_help)


---------------------------------
-- CONFIG -----------------------
---------------------------------

require('config.fzf')
require('config.lsp_setup')
