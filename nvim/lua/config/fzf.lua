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


-- TODO wrap the fzf functions in something that checks if any buffers have edits not written to disk and warn before launching with y/n opt to continue

-- Keymaps
vim.keymap.set('n', '<leader>ff', fzf.git_files, { desc = 'Find git files in current dir tree' })
vim.keymap.set('n', '<leader>fF', fzf.files, { desc = 'Find all files in current dir tree' })

-- Live grep
vim.keymap.set('n', '<leader>fl', fzf.live_grep, { desc = 'Live grep across lines of files' })  -- TODO try live_grep_native?
vim.keymap.set('n', '<leader>fs', function()
  vim.ui.input({ prompt = 'Grep > ' }, function(input)
    if input and input ~= "" then
      fzf.live_grep({ search = input })
    end
  end)
end, { desc = 'Prompt for query then live grep' })

-- Grep word under cursor or visual selection
vim.keymap.set('n', '<leader>fw', fzf.grep_cword, { desc = 'Search word under cursor' })
vim.keymap.set('n', '<leader>fW', fzf.grep_cWORD, { desc = 'Search WORD under cursor' })
vim.keymap.set('v', '<leader>fw', fzf.grep_visual, { desc = 'Search visual selection' })
vim.keymap.set('v', '<leader>fW', fzf.grep_visual, { desc = 'Search visual selection' })
-- vim.keymap.set('n', '<leader>fp', fzf.grep_project, { desc = 'Search project' })
vim.keymap.set('n', '<leader>fr', fzf.lsp_references, { desc = 'Search LSP references' })

-- Search lines in current file
vim.keymap.set('n', '<leader>fb', fzf.blines, { desc = 'Search lines in current file' })
