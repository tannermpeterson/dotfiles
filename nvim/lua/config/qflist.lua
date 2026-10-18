vim.api.nvim_create_autocmd("FileType", {
  pattern = "qf",
  callback = function()
    -- Map 'dd' in normal mode to delete the current quickfix item
    vim.keymap.set("n", "D", function()
      local qf_list = vim.fn.getqflist()
      local current_line = vim.fn.line(".")

      if #qf_list > 0 then
        table.remove(qf_list, current_line)
        vim.fn.setqflist(qf_list, "r") -- Replace current list

        -- Restore cursor position safely
        local new_line = math.min(current_line, #qf_list)
        if new_line > 0 then
          vim.fn.cursor(new_line, 1)
        end
      end
    end, { buffer = true, desc = "Delete item from quickfix list" })
  end,
})

-- TODO make another cmd that allows deleting the highlighted line in the quickfix list without being in the quickfix list.
--     After adding that, see if the above cmd can be removed
-- TODO ? allow highlighting multiple lines in qf list and deleting all of them
-- TODO ? make it so that jk in quickfix list do cnext/cprev
-- TODO ? make the above work in visual mode as well
