return {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim", "nvim-telescope/telescope.nvim" },
    keys = {
        { "<leader>hm", function() require("harpoon"):list():add() end,                                    desc = "Create new harpoon mark" },
        { "<leader>hl", function() require("harpoon").ui:toggle_quick_menu(require("harpoon"):list()) end, desc = "Toggle harpoon menu" },
        { "<leader>ha", function() require("harpoon"):list():select(1) end,                                desc = "Goto harpoon mark 1" },
        { "<leader>hs", function() require("harpoon"):list():select(2) end,                                desc = "Goto harpoon mark 2" },
        { "<leader>hd", function() require("harpoon"):list():select(3) end,                                desc = "Goto harpoon mark 3" },
        { "<leader>hf", function() require("harpoon"):list():select(4) end,                                desc = "Goto harpoon mark 4" },
        { "<leader>hg", function() require("harpoon"):list():select(5) end,                                desc = "Goto harpoon mark 5" },
    },
    opts = {
        settings = {
            save_on_toggle = true,
        }
    },
}
