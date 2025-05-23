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
        local themes = require("telescope.themes")

        -- doing this b/c linux mint has an issue with filenames being too long in the
        -- encrypted home directory: https://github.com/neovim/neovim/issues/25008#issuecomment-1715415068
        vim.loader.enable(false)
        local lga_actions = require("telescope-live-grep-args.actions")
        local live_grep_args_shortcuts = require("telescope-live-grep-args.shortcuts")
        vim.loader.enable(true)

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
                path_display = function(_, path)
                    local tail = vim.fs.basename(path)
                    local parent = vim.fs.dirname(path)
                    if parent == "." then
                        return tail
                    end

                    return string.format("%s\t\t%s", tail, parent)
                end
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
        vim.keymap.set('n', '<leader>ff', function() builtin.find_files(dropdown_theme_no_previewer) end,
            { desc = "Telescope Find Files" })
        vim.keymap.set('n', '<leader>gf', function() builtin.git_files(dropdown_theme_no_previewer) end,
            { desc = "Telescope Git Files" })
        vim.keymap.set('n', '<leader>fb', function() builtin.buffers(dropdown_theme_no_previewer) end,
            { desc = "Telescope Find Buffers" })

        -- greps
        vim.keymap.set('n', '<leader>lg', function()
            telescope.extensions.live_grep_args.live_grep_args()
        end, { desc = "Telescope Live Grep" })
        vim.keymap.set("n", "<leader>gw", live_grep_args_shortcuts.grep_word_under_cursor,
            { desc = "Telescope Live Grep Word Under Cursor" })
    end
}
