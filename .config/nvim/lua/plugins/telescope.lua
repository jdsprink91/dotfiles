return {
    "nvim-telescope/telescope.nvim",
    branch = '0.1.x',
    dependencies = {
        {
            "nvim-telescope/telescope-live-grep-args.nvim",
            version = "^1.0.0"
        }
    },
    config = function()
        local telescope = require('telescope')
        local builtin = require('telescope.builtin')
        local lga_actions = require("telescope-live-grep-args.actions")
        local themes = require("telescope.themes")
        local live_grep_args_shortcuts = require("telescope-live-grep-args.shortcuts")

        local layout_config = {
            width = 0.5
        }

        local dropdown_theme_no_previewer = themes.get_dropdown({
            previewer = false,
            layout_config = layout_config
        })

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
            },
            extensions = {
                live_grep_args = {
                    auto_quoting = true,
                    mappings = {
                        i = {
                            ["<C-f>"] = lga_actions.quote_prompt({ postfix = " -g " })
                        }
                    },
                    theme = "dropdown"
                }
            }
        }

        telescope.load_extension("live_grep_args")

        -- finding files with no previewer
        vim.keymap.set('n', '<leader>ff', function() builtin.find_files(dropdown_theme_no_previewer) end, {})
        vim.keymap.set('n', '<leader>gf', function() builtin.git_files(dropdown_theme_no_previewer) end, {})

        -- greps
        vim.keymap.set('n', '<leader>lg', function()
            telescope.extensions.live_grep_args.live_grep_args()
        end, {})
        vim.keymap.set("n", "<leader>gw", live_grep_args_shortcuts.grep_word_under_cursor)
    end
}
