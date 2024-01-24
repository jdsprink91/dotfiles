return {
    "nvim-telescope/telescope.nvim",
    tag = '0.1.2',
    config = function()
        local telescope = require('telescope')
        local builtin = require('telescope.builtin')
        telescope.setup {
            defaults = {
                file_ignore_patterns = { "node_modules/", ".git/" },
            },
            pickers = {
                find_files = {
                    hidden = true,
                },
                git_files = {
                    hidden = true
                },
                oldfiles = {
                    hidden = true
                },
            }
        }

        -- finding files with no previewer
        local dropdown_theme_no_previewer = require('telescope.themes').get_dropdown({ previewer = false })
        vim.keymap.set('n', '<leader>ff', function() builtin.find_files(dropdown_theme_no_previewer) end, {})
        vim.keymap.set('n', '<leader>gf', function() builtin.git_files(dropdown_theme_no_previewer) end, {})

        -- these things should get a previewer
        local dropdown_theme = require('telescope.themes').get_dropdown()
        vim.keymap.set('n', '<leader>lg', function() builtin.live_grep(dropdown_theme) end, {})
        vim.keymap.set('n', '<leader>fr', function() builtin.lsp_references(dropdown_theme) end, {})
        vim.keymap.set('n', '<leader>km', function() builtin.keymaps(dropdown_theme) end, {})
    end
}
