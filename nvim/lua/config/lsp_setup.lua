vim.diagnostic.config({
  virtual_text = {
    spacing = 4, -- Distance from the end of the line text
    prefix = '■', -- The symbol shown before the error message
  },
  severity_sort = true, -- Sort diagnostics by severity (Errors first)
})

local caps = vim.lsp.protocol.make_client_capabilities()
caps.textDocument.completion.completionItem.snippetSupport = true
caps.textDocument.completion.completionItem.resolveSupport = {
    properties = {
        'documentation',
        'detail',
        'additionalTextEdits'
    }
}

vim.lsp.config("clangd", {
    capabilities = caps,
    cmd = {
        "clangd",
        "--completion-style=detailed"
    },
    filetypes = { "c", "cpp" },
    root_markers = { ".clangd", "compile_commands.json", ".git" }
    -- Other opts set in .clangd file
})


-- Create an autocommand that runs whenever an LSP client attaches to a buffer
vim.api.nvim_create_autocmd('LspAttach', {
    callback = function(event)
        -- Helper function to make mapping shorter
        local map = function(keys, func, desc)
            vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
        end

        local client = assert(vim.lsp.get_client_by_id(event.data.client_id), "Client ID invalid")

        -- enable LSP completion
        if client and client:supports_method("textDocument/completion", event.buf) then
            vim.lsp.completion.enable(true, client.id, event.buf, {
                autotrigger = true,
                convert = function(item)
                    -- Remove leading misc chars for abbr name,
                    -- and cap field to 25 chars
                    --local abbr = item.label
                    --abbr = abbr:match("[%w_.]+.*") or abbr
                    --abbr = #abbr > 25 and abbr:sub(1, 24) .. "…" or abbr
                    --
                    -- Remove return value
                    --local menu = ""

                    -- Only show abbr name, remove leading misc chars (bullets etc.),
                    -- and cap field to 15 chars
                    local abbr = item.label
                    abbr = abbr:gsub("%b()", ""):gsub("%b{}", "")
                    abbr = abbr:match("[%w_.]+.*") or abbr
                    abbr = #abbr > 25 and abbr:sub(1, 24) .. "…" or abbr

                    -- Cap return value field to 15 chars
                    local menu = item.detail or ""
                    menu = #menu > 25 and menu:sub(1, 24) .. "…" or menu

                    return { abbr = abbr, menu = menu }
                end
            })
        end

        -- Navigation
        map('gd', vim.lsp.buf.definition, '[G]o to [D]efinition')
        map('gD', vim.lsp.buf.declaration, '[G]o to [D]eclaration')
        map('gi', vim.lsp.buf.implementation, '[G]o to [I]mplementation')

        -- Documentation & Actions
        map('K',  vim.lsp.buf.hover, 'Hover Documentation')
        map('<leader>rr', vim.lsp.buf.references, 'Symbol [R]eferences')
        map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame Variable')
        map('<leader>ra', vim.lsp.buf.code_action, '[R]un Code [A]ction')

        -- Diagnostics (Errors/Warnings)
        map('[d', function() vim.diagnostic.jump({ count = -1, float = true }) end, 'Go to previous [d]iagnostic')
        map(']d', function() vim.diagnostic.jump({ count = 1, float = true }) end, 'Go to next [d]iagnostic')
        map('<leader>e', vim.diagnostic.open_float, 'Show diagnostic [e]rror messages')

        vim.keymap.set('n', '<leader>h', function()
            local bufnr = vim.api.nvim_get_current_buf()
            local is_enabled = not vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr })
            print("Inlay hints " .. (is_enabled and "enabled" or "disabled"))
            vim.lsp.inlay_hint.enable(is_enabled, { bufnr = bufnr })
        end, { desc = 'Toggle Buffer Inlay [H]ints' })
    end
})

vim.lsp.enable('clangd')
vim.lsp.enable('lua_ls')
