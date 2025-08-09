-- https://github.com/mfussenegger/nvim-dap/wiki/Debug-Adapter-installation
return {
    {
        "mfussenegger/nvim-dap",
        dependencies = {
            "mason-org/mason.nvim",
            "nvim-telescope/telescope.nvim",
        },
        keys = {
            { "<leader>dd", "<cmd>lua require('dap').continue()<cr>",          desc = "Continue or start debugging" },
            { "<leader>dl", "<cmd>lua require('dap').run_last()<cr>",          desc = "Continue or start debugging" },
            { "<leader>dr", "<cmd>lua require('dap').restart()<cr>",           desc = "Restart debugging session" },
            { "<leader>dq", "<cmd>lua require('dap').terminate()<cr>",         desc = "Terminate debugging session" },
            { "<leader>db", "<cmd>lua require('dap').toggle_breakpoint()<cr>", desc = "Toggle breakpoint" },
            { "<leader>di", "<cmd>lua require('dap').step_into()<cr>",         desc = "Step into" },
            { "<leader>do", "<cmd>lua require('dap').step_over()<cr>",         desc = "Step over" },
            { "<leader>du", "<cmd>lua require('dap').step_out()<cr>",          desc = "Step out" },
        },
        config = function(_, _)
            local dap = require("dap")
            dap.adapters.gdb = {
                type = "executable",
                command = "gdb",
                args = { "--interpreter=dap", "--eval-command", "set print pretty on" }
            }
            dap.configurations.c = {
                {
                    name = "Launch",
                    type = "gdb",
                    request = "launch",
                    program = function()
                        return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
                    end,
                    cwd = "${workspaceFolder}",
                    stopAtBeginningOfMainSubprogram = false,
                    continueOnFork = true,
                },
            }

            dap.adapters["pwa-node"] = {
                type = "server",
                host = "localhost",
                port = "${port}",
                executable = {
                    command = "node",
                    args = { vim.fn.stdpath("data") .. "/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js", "${port}" },
                }
            }
            dap.adapters["node"] = function(cb, config)
                if config.type == "node" then
                    config.type = "pwa-node"
                end
                local nativeAdapter = dap.adapters["pwa-node"]
                if type(nativeAdapter) == "function" then
                    nativeAdapter(cb, config)
                else
                    cb(nativeAdapter)
                end
            end

            vim.api.nvim_set_hl(0, "DapStoppedLine", { default = true, link = "Visual" })
            local vscode = require("dap.ext.vscode")
            local json = require("plenary.json")
            ---@diagnostic disable-next-line: duplicate-set-field
            vscode.json_decode = function(str)
                return vim.json.decode(json.json_strip_comments(str))
            end
        end
    },
    {
        "rcarriga/nvim-dap-ui",
        dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
        keys = {
            { "<leader>dt", "<cmd>lua require('dapui').toggle()<cr>", desc = "Toggle UI" },
        },
        opts = {
            render = {
                max_type_length = 0,
            },
        },
    },
    -- DAP configuration packages
    {
        "leoluz/nvim-dap-go",
        ft = { "go" },
        dependencies = {
            "mfussenegger/nvim-dap",
        },
        keys = {
            { "<leader>dgt", "<cmd>lua require('dap-go').debug_test()<cr>",      desc = "Debug current test" },
            { "<leader>dgl", "<cmd>lua require('dap-go').debug_last_test()<cr>", desc = "Debug last test" }
        },
        opts = {},
        config = function(_, opts)
            opts["dap_configurations"] = {
                {
                    type = "go",
                    name = "Debug main.go (with args)",
                    request = "launch",
                    program = "main.go",
                    args = require("dap-go").get_arguments,
                },
            }
            require("dap-go").setup(opts)
        end
    },
    {
        "mfussenegger/nvim-dap-python",
        ft = { "python" },
        dependencies = {
            "mfussenegger/nvim-dap",
        },
        config = function(_, _)
            require("dap-python").setup("python")
        end
    },
}
