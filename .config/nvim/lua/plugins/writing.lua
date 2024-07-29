vim.api.nvim_create_user_command("LiteratureMode", function()
    vim.cmd("ZenMode | set spell | GitGutterDisable")
end, {})

vim.api.nvim_create_user_command("CodeMode", function()
    vim.cmd("close | set nospell | GitGutterEnable")
end, {})

return {
    {
        "folke/zen-mode.nvim",
        opts = {
            window = {
                width = 85,
                options = {
                    relativenumber = false,
                    number = false
                }
            },
            plugins = {
                options = {
                    laststatus = 0
                },
            }
        }
    },
    {
        "iamcco/markdown-preview.nvim",
        cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
        build = "cd app && yarn install",
        init = function()
            vim.g.mkdp_filetypes = { "markdown" }
        end,
        ft = { "markdown" },
    }
}
