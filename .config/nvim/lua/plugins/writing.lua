vim.api.nvim_create_user_command("WriterMode", function()
    vim.cmd("ZenMode | SoftPencil | set spell")
end, {})

vim.api.nvim_create_user_command("CodeMode", function()
    vim.cmd("close | HardPencil | set nospell")
end, {})

return {
    -- 4. pandoc for converting files
    "folke/zen-mode.nvim",
    "preservim/vim-pencil",
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
