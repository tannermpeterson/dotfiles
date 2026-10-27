local fzf = require('fzf-lua')
local actions = require('fzf-lua').actions

fzf.setup({
  keymap = {
    fzf = {
      ['ctrl-a'] = 'select-all',
      ['ctrl-d'] = 'deselect-all',
    },
  },
  actions = {
    files = {
      ['enter'] = { fn = actions.file_edit, prefix = "deselect-all" },
      ['ctrl-s'] = actions.file_sel_to_qf,
      ["ctrl-q"] = { fn = actions.file_sel_to_qf, prefix = "select-all" },
    },
  },
})


local function has_unsaved_changes()
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(bufnr) and vim.api.nvim_get_option_value("modified", { buf = bufnr }) then
      return true
    end
  end
  return false
end

-- wrap functions called in keymaps to check if unsaved changes before calling
local function check_unsaved(fn)
  return function()
    if has_unsaved_changes() then
      local res = vim.fn.input("Unsaved files! Search anyway? ([s]ave/[y]es/[n]o): ")
      if res == 's' then
        vim.cmd("wa")
      elseif res == 'y' then
        -- do nothing
      else
        print("Search cancelled")
        return
      end
    end
    fn()
  end
end

-- Keymaps
vim.keymap.set('n', '<leader>ff', check_unsaved(fzf.git_files), { desc = 'Find git files in current dir tree' })
vim.keymap.set('n', '<leader>fF', check_unsaved(fzf.files), { desc = 'Find all files in current dir tree' })

-- Live grep
vim.keymap.set('n', '<leader>fl', check_unsaved(fzf.live_grep), { desc = 'Live grep across lines of files' })  -- TODO try live_grep_native?
vim.keymap.set('n', '<leader>fs', check_unsaved(function()
  vim.ui.input({ prompt = 'Grep > ' }, function(input)
    if input and input ~= "" then
      fzf.live_grep({ search = input })
    end
  end)
end), { desc = 'Prompt for query then live grep' })

-- Grep word under cursor or visual selection
vim.keymap.set('n', '<leader>fw', check_unsaved(fzf.grep_cword), { desc = 'Search word under cursor' })
vim.keymap.set('n', '<leader>fW', check_unsaved(fzf.grep_cWORD), { desc = 'Search WORD under cursor' })
vim.keymap.set('v', '<leader>fw', check_unsaved(fzf.grep_visual), { desc = 'Search visual selection' })
vim.keymap.set('v', '<leader>fW', check_unsaved(fzf.grep_visual), { desc = 'Search visual selection' })
-- vim.keymap.set('n', '<leader>fp', fzf.grep_project, { desc = 'Search project' })

vim.keymap.set('n', '<leader>fr', check_unsaved(fzf.lsp_references), { desc = 'Search LSP references' })

local fzf_dw = function(sb) return function() fzf.diagnostics_workspace({ severity_limit = sb }) end end
vim.keymap.set('n', '<leader>fde', check_unsaved(fzf_dw(vim.diagnostic.severity.ERROR)), { desc = 'Search workspace error diagnostics' })
vim.keymap.set('n', '<leader>fdw', check_unsaved(fzf_dw(vim.diagnostic.severity.WARN)), { desc = 'Search workspace diagnostics >= warning' })
vim.keymap.set('n', '<leader>fda', check_unsaved(fzf_dw(vim.diagnostic.severity.HINT)), { desc = 'Search all workspace diagnostics' })

-- Search lines in current file
vim.keymap.set('n', '<leader>fb', fzf.blines, { desc = 'Search lines in current file' })
