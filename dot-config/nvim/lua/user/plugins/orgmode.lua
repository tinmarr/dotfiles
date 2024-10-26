return {
    "nvim-orgmode/orgmode",
    event = "VeryLazy",
    ft = { "org" },
    opts = {
        org_agenda_files = "~/notes/**/*",
        org_default_notes_file = "~/notes/refile.org",
        org_highlight_latex_and_related = "entities",
    }
}
