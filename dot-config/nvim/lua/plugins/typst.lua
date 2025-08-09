return {
    "chomosuke/typst-preview.nvim",
    ft = "typst",
    version = "1.*",
    cmd = "TypstPreviewToggle",
    keys = {
        { "<localleader>pt", "<cmd>TypstPreviewToggle<cr>", desc = "Toggle typst preview" }
    },
    opts = {
        dependencies_bin = { ["tinymist"] = "tinymist" }
    },
}
