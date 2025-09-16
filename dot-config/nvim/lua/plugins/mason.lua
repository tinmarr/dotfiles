local lsps = {
    "lua_ls",
    "gopls",
    "yamlls",
    "ts_ls",
    "jsonls",
    "pyright",
    "taplo",
    "tinymist",
    "golangci_lint_ls",
    "bashls",
    "marksman",
    "arduino_language_server",
    "clangd",
}
local pkgs = {
    -- debuggers
    "delve",
    "js-debug-adapter",
    -- linters
    "golangci-lint",
    -- formatters
    "isort",
    "black",
    "prettier",
    "gofumpt",
}
local function ensure_installed()
    local registry = require("mason-registry")
    local lsp = require("mason-lspconfig")
    local mappings = lsp.get_mappings().lspconfig_to_package

    for _, value in ipairs(lsps) do
        table.insert(pkgs, mappings[value])
    end

    registry.update(
        function(success, _)
            if not success then
                return
            end

            for _, value in ipairs(pkgs) do
                local pkg = registry.get_package(value)
                local is_latest = pkg:get_installed_version() == pkg:get_latest_version()
                if not pkg:is_installed() or not is_latest then
                    pkg:install()
                end
            end
        end
    )
end

return {
    {
        "mason-org/mason.nvim",
        cmd = "Mason",
        lazy = false,
        keys = {
            { "<leader>am", "<cmd>Mason<cr>", desc = "Open Mason" }
        },
        opts = {},
        config = function(_, opts)
            require("mason").setup(opts)

            ensure_installed()
        end
    },
    {
        "mason-org/mason-lspconfig.nvim",
        dependencies = {
            "mason-org/mason.nvim",
        },
        opts = {}
    },
}
