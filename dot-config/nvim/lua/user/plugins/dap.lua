-- https://github.com/mfussenegger/nvim-dap/wiki/Debug-Adapter-installation
return {
    {
        "mfussenegger/nvim-dap",
        keys = {
            { "<leader>dd", "<cmd>lua require('dap').continue()<cr>",          desc = "Continue or start debugging" },
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
        end
    },
    {
        "rcarriga/nvim-dap-ui",
        dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
        keys = {
            { "<leader>dt", "<cmd>lua require('dapui').toggle()<cr>", desc = "Toggle UI" },
        },
        opts = {},
    },
    -- DAP configuration packages
    {
        "leoluz/nvim-dap-go",
        ft = { "go" },
        dependencies = {
            "mfussenegger/nvim-dap",
        },
        opts = {},
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
