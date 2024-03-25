vim.api.nvim_create_user_command("LiteratureMode", function()
    vim.cmd("ZenMode | SoftPencil | set spell | GitGutterDisable")
end, {})

vim.api.nvim_create_user_command("CodeMode", function()
    vim.cmd("close | NoPencil | set nospell | GitGutterEnable")
end, {})

return {
    -- 4. pandoc for converting files
    "preservim/vim-pencil",
    {
        "folke/zen-mode.nvim",
        opts = {
            window = {
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
