vim.api.nvim_create_user_command("CleanOldBuffers", function()
    -- Get all listed buffers
    local bufs = vim.fn.getbufinfo({ buflisted = 1 })
    -- If less than 5 buffers, return early
    if #bufs < 5 then
        return
    end
    -- Sort by last used time (ascending)
    table.sort(bufs, function(a, b)
        return (a.lastused or 0) < (b.lastused or 0)
    end)
    -- Close until we're at 5 buffers
    for i = 1, #bufs - 5 do
        vim.api.nvim_buf_delete(bufs[i].bufnr, { force = false })
    end
end, {})

vim.api.nvim_create_user_command("TogglePreviewFile", function()
    local ft = vim.bo.filetype

    if ft == "markdown" then
        vim.cmd("Lazy load peek.nvim")
        vim.cmd("PeekToggle")
    elseif ft == "typst" then
        vim.cmd("Lazy load typst-preview.nvim")
        vim.cmd("TypstPreviewToggle")
    else
        print("no file preview configured")
    end
end, {})
