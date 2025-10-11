-- <leader>
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- swap colon and semicolon for commands
vim.keymap.set({ "n", "v" }, ";", ":")
vim.keymap.set({ "n", "v" }, ":", ";")

vim.keymap.set("n", "<leader>al", "<cmd>Lazy<cr>", { desc = "Open Lazy" })
vim.keymap.set("n", "<leader>as", function()
    vim.cmd("se spell!")
    if vim.opt.spell._value then
        ---@diagnostic disable-next-line: param-type-mismatch
        vim.notify("enabled spell check", "info", {
            id = "spell_status"
        })
    else
        ---@diagnostic disable-next-line: param-type-mismatch
        vim.notify("disabled spell check", "info", {
            id = "spell_status"
        })
    end
end, { desc = "Toggle spelling" })

-- auto center
vim.keymap.set("n", "<C-d>", "<C-d>zz", { noremap = true })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { noremap = true })
vim.keymap.set("n", "n", "nzz", { noremap = true })
vim.keymap.set("n", "N", "Nzz", { noremap = true })

-- clipboard
vim.keymap.set({ "n", "v" }, "<leader>y", "\"+y", { desc = "Yank to system clipboard" })
vim.keymap.set({ "n", "v" }, "<leader>p", "\"+p", { desc = "Paste from system clipboard" })
vim.keymap.set({ "n", "v" }, "<leader>d", "\"+d", { desc = "Delete to system clipboard" })

-- buffer stuff
vim.keymap.set("n", "<leader>bk", "<cmd>b#<cr>", { desc = "Goto last accessed buffer" })
vim.keymap.set("n", "<leader>bh", vim.cmd.bprevious, { desc = "Goto previous buffer" })
vim.keymap.set("n", "<leader>bl", vim.cmd.bnext, { desc = "Goto previous buffer" })
vim.keymap.set("n", "<leader>bd", vim.cmd.bdelete, { desc = "Delete buffer" })
vim.keymap.set("n", "<leader>bc", ":CleanOldBuffers<cr>", { desc = "Clean old buffers" })

-- window management
vim.keymap.set("n", "<M-S-l>", "5<C-w>>")
vim.keymap.set("n", "<M-S-h>", "5<C-w><")
vim.keymap.set("n", "<M-S-k>", "2<C-w>+")
vim.keymap.set("n", "<M-S-j>", "2<C-w>-")
vim.keymap.set("n", "<M-v>", "<C-w>v")
vim.keymap.set("n", "<M-s>", "<C-w>s")
vim.keymap.set("n", "<M-c>", "<C-w>c")
vim.keymap.set("n", "<M-o>", "<C-w>o")
vim.keymap.set("n", "<M-=>", "<C-w>=")

-- tabs
vim.keymap.set("n", "<leader>tc", "<cmd>tabclose<cr>", { desc = "Close tab" })
vim.keymap.set("n", "<leader>tl", "<cmd>tabnext<cr>", { desc = "Next tab" })
vim.keymap.set("n", "<leader>th", "<cmd>tabprevious<cr>", { desc = "Previous tab" })
vim.keymap.set("n", "<leader>tt", "<cmd>tabnew<cr>", { desc = "Add tab" })

-- markdown tasks
vim.keymap.set("n", "<leader>mc", function()
    local ls = require("luasnip")
    local bufnr = 0
    local last = vim.api.nvim_buf_line_count(bufnr)

    -- insert a new line at EOF containing the trigger "fn"
    vim.api.nvim_buf_set_lines(bufnr, last, last, true, { "- new task" })

    -- move cursor right after the "fn" we just inserted
    -- (vim.win_set_cursor uses 1-based row, 0-based col)
    vim.api.nvim_win_set_cursor(0, { last + 1, 0 })

    -- enter insert mode, then schedule the expansion so it runs after mode change
    vim.cmd("startinsert!")
    vim.schedule(function()
        if ls.expand_or_jumpable() then
            ls.expand_or_jump()
        end
    end)
end, { desc = "Create task" })
vim.keymap.set("n", "<leader>mx", function()
    local bufnr = 0
    local row = vim.api.nvim_win_get_cursor(0)[1]

    vim.api.nvim_win_set_cursor(0, { row, 3 })
    vim.cmd("norm rx")
    vim.api.nvim_win_set_cursor(0, { row, 12 })
    local date = os.date("%Y-%m-%d")
    vim.cmd("norm i " .. date)

    local line = vim.api.nvim_buf_get_lines(bufnr, row - 1, row, false)[1]
    local new_line = vim.fn.substitute(line, "(\\(\\d\\d\\d\\d-\\d\\d-\\d\\d\\)) ", "", "")

    local dest_path = os.getenv("HOME") .. "/notes/done.md"
    local f, err = io.open(dest_path, "a")
    if not f then
        vim.notify("Failed to open " .. dest_path .. ": " .. tostring(err),
            vim.log.levels.ERROR)
        return
    end
    f:write(new_line .. "\n")
    f:close()

    vim.api.nvim_buf_set_lines(0, row - 1, row, false, {})

    vim.cmd("w")
end, { desc = "Complete task" })

-- file preview
vim.keymap.set("n", "<leader>lp", "<cmd>TogglePreviewFile<cr>", { desc = "Toggle preview current file" })

vim.keymap.set("i", "<C-h>", "<C-w>")

vim.keymap.set("n", "<leader>/", function()
    ---@diagnostic disable-next-line: undefined-field
    if vim.opt.hlsearch._value then
        vim.opt.hlsearch = false
    else
        vim.opt.hlsearch = true
    end
end, { desc = "Toggle search highlight" })
