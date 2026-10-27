---------------------------------
-- PACKAGES ---------------------
---------------------------------

-- :lua vim.pack.update(nil, { force = true })
-- :checkhealth vim.pack
vim.pack.add({
  { src = 'https://github.com/folke/tokyonight.nvim', version = '545d72c' },
  { src = 'https://github.com/neovim/nvim-lspconfig', version = 'f6738ef' },
  { src = 'https://github.com/ibhagwan/fzf-lua', version = '6995a3f' },  -- TODO check out pickers?
  { src = 'https://github.com/junegunn/fzf', version = 'f7ae439' },
  { src = 'https://github.com/SmiteshP/nvim-navic', version = '455808f' },
  { src = 'https://github.com/christoomey/vim-tmux-navigator', version = 'e41c431' }
})


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
vim.o.complete = '.,o,w,b,'
vim.o.completeopt = 'menu,noselect,fuzzy,popup,preview'
vim.o.autocomplete = true
vim.o.autocompletedelay = 200
vim.o.winborder = "rounded"
vim.o.pummaxwidth = 70
vim.o.pumheight = 7

vim.api.nvim_create_autocmd(
	{ "FileChangedShellPost" },
	{ command = 'echohl WarningMsg | echo "File changed on disk. Buffer reloaded." | echohl None', pattern = { "*" } }
)

vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter", "TermOpen" }, {
  callback = function()
    -- this will only filter out qflist when entering it, not opening it
    if vim.bo.buftype == "terminal" or vim.bo.buftype == "quickfix" then
      vim.opt_local.winbar = ""
    else
      vim.opt_local.winbar = "%{%v:lua.require'nvim-navic'.get_location()%}"
    end
  end,
})

-- reset the winbar when opening qflist
vim.api.nvim_create_autocmd("FileType", {
  pattern = "qf",
  callback = function()
      vim.opt_local.winbar = ""
  end,
})

vim.api.nvim_create_autocmd({ "TermOpen", "BufEnter" }, {
  pattern = { "*" },
  callback = function()
    if vim.opt.buftype:get() == "terminal" then
      vim.cmd(":startinsert")
    end
  end,
})

---------------------------------
-- REMAPS -----------------------
---------------------------------

-- NOTE: some remaps are in files under lua/config/

-- TODO see how this feels
-- vim.keymap.set("i", "<S-tab>", "<Esc>")
-- vim.keymap.set("v", "<S-tab>", "<Esc>")

vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-j>", "<C-w>j")
vim.keymap.set("n", "<C-k>", "<C-w>k")
vim.keymap.set("n", "<C-l>", "<C-w>l")

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
-- vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz")
-- vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz")

vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])

vim.keymap.set("i", "<C-h>", vim.lsp.buf.signature_help)
-- Winterm has issues with pasting large amounts of text, so paste straight from clipboard
vim.keymap.set("i", "<C-v>", "<C-r>+")

vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], { desc = "Exit terminal mode" })
vim.keymap.set("t", "<C-h>", [[<C-\><C-n><C-w>h]])
vim.keymap.set("t", "<C-j>", [[<C-\><C-n><C-w>j]])
vim.keymap.set("t", "<C-k>", [[<C-\><C-n><C-w>k]])
vim.keymap.set("t", "<C-l>", [[<C-\><C-n><C-w>l]])

---------------------------------
-- CONFIG -----------------------
---------------------------------

require('config.fzf')
require('config.lsp_setup')
require('config.netrw')
require('config.qflist')
require('config.statusline')
