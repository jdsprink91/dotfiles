return {
    "mfussenegger/nvim-dap",
    dependencies = {
        "rcarriga/nvim-dap-ui",
        "theHamsta/nvim-dap-virtual-text",
        "mfussenegger/nvim-dap-python",
        { "mxsdev/nvim-dap-vscode-js", tag = "v1.1.0" },
        {
            "microsoft/vscode-js-debug",
            tag = "v1.74.1",
            build = "npm ci --legacy-peer-deps && npx gulp vsDebugServerBundle && mv dist out"
        },
    },
    config = function()
        local dap = require('dap')
        local dapPython = require("dap-python")

        dapPython.setup("python")

        -- here, we are inserting a new selectable configuration into our debugging option table
        -- this includes the information on how to look at things in a djangoproject FROM
        -- the djangoproject folder
        table.insert(dap.configurations.python, {
            type = "python",
            request = "attach",
            connect = {
                port = 8765,
                host = "localhost",
            },
            mode = "remote",
            name = "Python: Remote Django",
            cwd = vim.fn.getcwd(),
            pathMappings = {
                {
                    localRoot = vim.fn.getcwd(),
                    remoteRoot = "/opt/app"
                },
            },
            django = true
        })

        -- javascript dap
        -- https://github.com/mxsdev/nvim-dap-vscode-js/issues/42#issuecomment-1519068066
        -- shout out to this dude who get things setup with lazy vim
        require('dap-vscode-js').setup({
            debugger_path = vim.fn.stdpath('data') .. '/lazy/vscode-js-debug',
            adapters = { 'pwa-node', 'pwa-chrome', 'pwa-msedge', 'node-terminal', 'pwa-extensionHost' },
        })
        for _, language in ipairs({ 'typescript', 'javascript' }) do
            dap.configurations[language] = {
                {
                    type = "pwa-node",
                    request = "launch",
                    name = "Debug Jest Tests",
                    -- trace = true, -- include debugger info
                    runtimeExecutable = "node",
                    runtimeArgs = function()
                        local args_string = vim.fn.input("Arguments: ")
                        local baseArgs = {
                            "./node_modules/jest/bin/jest.js",
                            "--runInBand",
                            args_string
                        }

                        return baseArgs
                    end,
                    rootPath = "${workspaceFolder}",
                    cwd = "${workspaceFolder}",
                    console = "integratedTerminal",
                    internalConsoleOptions = "neverOpen",
                }
            }
        end

        vim.keymap.set('n', '<F5>', function() dap.continue() end)
        vim.keymap.set('n', '<F6>', function() dap.disconnect() end)
        vim.keymap.set('n', '<F10>', function() dap.step_over() end)
        vim.keymap.set('n', '<F11>', function() dap.step_into() end)
        vim.keymap.set('n', '<F12>', function() dap.step_out() end)
        vim.keymap.set('n', '<Leader>tb', function() dap.toggle_breakpoint() end)
        vim.keymap.set('n', '<Leader>sb', function() dap.set_breakpoint() end)
        vim.keymap.set('n', '<Leader>lp',
            function() dap.set_breakpoint(nil, nil, vim.fn.input('Log point message: ')) end)

        -- dap virtual text
        local dapVirtualText = require("nvim-dap-virtual-text")
        dapVirtualText.setup()

        -- dap ui
        local dapui = require("dapui")
        dapui.setup()
        vim.keymap.set('n', '<leader>do', function() dapui.open() end)
        vim.keymap.set('n', '<leader>dc', function() dapui.close() end)
    end
}
