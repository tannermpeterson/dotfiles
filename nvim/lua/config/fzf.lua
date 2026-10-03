-- NOTES: 
-- * type a single quote to do an exact match (i.e. 'keymap)
-- * 'rg' requires ripgrep installation
-- TODO
-- * customize window size
-- * add syntax highlighting to preview window?


vim.env.FZF_DEFAULT_OPTS = '--color=hl:#00ffff:bold,hl+:#00ffff:bold,fg:#777777,fg+:#aaaaaa --bind ctrl-a:select-all,tab:toggle+up,btab:toggle+down,ctrl-q:accept,enter:deselect-all+accept'

function fzf_with_filename_toggle(include_paths_initially, query)
    if query == nil then
        return
    end

    if query == true then
        -- get query input
        query = vim.fn.input("Grep > ")
        if not query or query == "" then 
            print("Skipping search: empty query")
            return 
        end
    end

    local base_cmd = "rg --column --line-number --no-heading --color=always --smart-case " .. vim.fn.shellescape(query) .. " || true"


    local header_paths_excluded = 'Matching file contents only (Ctrl-F to toggle)'
    local header_paths_included = 'Matching file names and contents (Ctrl-F to toggle)'
    if query ~= "" then
        header_paths_excluded = "|\27[31m" .. query ..  "\27[0m| :: " .. header_paths_excluded
        header_paths_included = "|\27[31m" .. query ..  "\27[0m| :: " .. header_paths_included
    end

    local default_header = header_paths_excluded
    if include_paths_initially then
        default_header = header_paths_included
    end

    local state_file = vim.fn.tempname()
    local f = io.open(state_file, "w")
    if f then f:write((include_paths_initially and '1\n' or '0\n')) f:close() end

    local fzf_options = vim.fn['fzf#vim#with_preview']({
        options = { 
            '--delimiter', ':', 
            '--nth', include_paths_initially and '1..' or '4..',
            '--header', default_header,
            -- Use transform to dynamically inspect fzf's active prompt headers directly
            '--bind', 'ctrl-f:transform: ' ..
            'if [ $(cat ' .. vim.fn.shellescape(state_file) .. ') -eq 0 ]; then ' ..
            '  echo "1" > ' .. vim.fn.shellescape(state_file) .. '; ' ..
            '  echo "change-header(' .. header_paths_included .. ')+change-nth(1..)"; ' ..
            'else ' ..
            '  echo "0" > ' .. vim.fn.shellescape(state_file) .. '; ' ..
            '  echo "change-header(' .. header_paths_excluded .. ')+change-nth(4..)"; ' ..
           'fi'
        }
    })

    -- The 0 at the end prevents it from opening full-screen (use 1 for full-screen)
    vim.fn['fzf#vim#grep'](base_cmd, 1, fzf_options, 0)
end

local function get_selection_simple()
    -- Yank the current visual selection into register 'z'
    -- 'normal!' ensures user custom keymaps don't break it
    vim.cmd('normal! "zy') 

    -- Access the text from register 'z' inside Lua
    local text = vim.fn.getreg('z')

    if text.find(text, "\n") ~= nil then
        print("Skipping search: selection spans multiple lines")
        return nil
    end

    return text
end


vim.keymap.set('n', '<leader>ff', ':GFiles<CR>', { desc = 'Find git files in current dir + subdirs' })
vim.keymap.set('n', '<leader>fF', ':Files<CR>', { desc = 'Find all files in current dir + subdirs' })
vim.keymap.set('n', '<leader>fl', 
    function() fzf_with_filename_toggle(false, "") end, 
    { desc = "Live grep across filenames and lines of files in current dir + subdirs (live does not match filenames initially)" }
)
vim.keymap.set('n', '<leader>fL',
    function() fzf_with_filename_toggle(true, "") end, 
    { desc = 'Live grep across filenames and lines of files in current dir + subdirs (live matches filenames initially)' }
)    
vim.keymap.set('n', '<leader>fs', 
    function() fzf_with_filename_toggle(false, true) end,
    { desc = 'Live grep w/ query across filenames and lines of files in current dir + subdirs (live does not match filenames initially)' }
)
vim.keymap.set('n', '<leader>fS', 
    function() fzf_with_filename_toggle(true, true) end,
    { desc = 'Live grep w/ query across filenames and lines of files in current dir + subdirs (live matches filenames initially)' }
)
vim.keymap.set('n', '<leader>fw', 
    function() fzf_with_filename_toggle(true, vim.fn.expand("<cword>")) end,
    { desc = 'Live grep w/ query (word under cursor) across filenames and lines of files in current dir + subdirs (live matches filenames initially)' }
)
vim.keymap.set('v', '<leader>fw', 
    function() fzf_with_filename_toggle(true, get_selection_simple()) end,
    { desc = 'Live grep w/ query (visual selection) across filenames and lines of files in current dir + subdirs (live matches filenames initially)' }
)
vim.keymap.set('n', '<leader>fb', ':BLines<CR>', { desc = 'Search lines in current file' })

