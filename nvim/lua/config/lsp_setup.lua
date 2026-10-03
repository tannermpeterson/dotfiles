vim.api.nvim_create_autocmd("FileType", {
  pattern = { "c", "cpp" }, -- Only triggers for these file types
  callback = function(args)
  
    local caps = vim.lsp.protocol.make_client_capabilities()
    caps.textDocument.completion.completionItem.snippetSupport = true
    caps.textDocument.completion.completionItem.resolveSupport = {
        properties = {
            'documentation',
            'detail',
            'additionalTextEdits',
        }
    }

    vim.lsp.start({
        capabilities = caps,
        cmd = { 
            "clangd",
            -- "-std=c++20",  -- TODO .clangd file
            "--completion-style=detailed"
        },
        filetypes = { "c", "cpp" },
        root_markers = { ".git" }
        -- TODO compile_commands.json
    })
  end,
})

-- Create an autocommand that runs whenever an LSP client attaches to a buffer
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(event)
    -- Helper function to make mapping shorter
    local map = function(keys, func, desc)
      vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
    end

    local client = assert(
        vim.lsp.get_client_by_id(event.data.client_id),
        "Client ID invalid"
    )

    -- enable LSP completion
    if client and client:supports_method("textDocument/completion", event.buf) then
        vim.lsp.completion.enable(true, client.id, event.buf, { autotrigger = true })
    end

    -- TODO make this work the way I want it (toggle with remap)
    -- if client:supports_method("textDocument/inlayHint", event.buf) then
    --     -- FIX: figure out how to wait for the language server to be ready
    --     vim.lsp.inlay_hint.enable(true, { bufnr = event.buf })
    --     vim.api.nvim_buf_create_user_command(event.buf, "ToggleHints", function()
    --         local inlay_hints_enabled =
    --         vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf })
    --         vim.lsp.inlay_hint.enable(
    --             not inlay_hints_enabled,
    --             { bufnr = event.buf }
    --         )
    --     end, { desc = "toggle inlay hints" })
    -- end

    -- Navigation
    map('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
    map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
    map('gi', vim.lsp.buf.implementation, '[G]oto [I]mplementation')

    -- Documentation & Actions
    map('K',  vim.lsp.buf.hover, 'Hover Documentation')
    map('<leader>rr', vim.lsp.buf.references, 'Symbol [R]eferences')
    map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame Variable')
    map('<leader>ra', vim.lsp.buf.code_action, '[R]un Code [A]ction')

    -- Diagnostics (Errors/Warnings)
    map('[d', function() vim.diagnostic.jump({ count = -1, float = true }) end, 'Go to previous [d]iagnostic')
    map(']d', function() vim.diagnostic.jump({ count = 1, float = true }) end, 'Go to next [d]iagnostic')
    map('<leader>e', vim.diagnostic.open_float, 'Show diagnostic [e]rror messages')
  end,
})

vim.lsp.enable('clangd')
