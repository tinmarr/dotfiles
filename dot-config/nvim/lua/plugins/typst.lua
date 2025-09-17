return {
    "chomosuke/typst-preview.nvim",
    ft = "typst",
    version = "1.*",
    cmd = "TypstPreviewToggle",
    opts = {
        dependencies_bin = { ["tinymist"] = "tinymist" },
        open_cmd = "zen-browser --new-window %s -P preview",
    },
}
