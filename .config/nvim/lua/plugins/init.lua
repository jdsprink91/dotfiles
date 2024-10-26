return {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    {
        "oxfist/night-owl.nvim",
        lazy = false,    -- make sure we load this during startup if it is your main colorscheme
        priority = 1000, -- make sure to load this before all the other start plugins
        config = function()
            require('night-owl').setup({
                italics = false
            })
            vim.cmd.colorscheme("night-owl")
            vim.api.nvim_set_hl(0, "IndentLine", { link = "@nowl.indentChar" })
            vim.api.nvim_set_hl(0, "IndentLineCurrent", { link = "@nowl.indentChar.active" })
        end,
    },

    -- git plugins
    {
        "tpope/vim-fugitive",
        lazy = false,
        keys = {
            { "<leader>gs", vim.cmd.Git }
        }
    },

    "airblade/vim-gitgutter",

    -- visual help with tabs and spaces
    {
        "nvimdev/indentmini.nvim",
        config = function()
            require("indentmini").setup({
                char = "¦",
            })
        end
    },

    -- statusline plugin
    {
        "nvim-lualine/lualine.nvim",
        dependencies = {
            "f-person/git-blame.nvim",
        },
        config = function()
            vim.g.gitblame_display_virtual_text = 0 -- Disable virtual text
            local lualine = require("lualine")
            local gitblame = require("gitblame")
            lualine.setup {
                options = {
                    globalstatus = true
                },
                sections = {
                    lualine_x = {
                        {
                            gitblame.get_current_blame_text,
                            cond = gitblame.is_blame_text_available,
                            fmt = function(str)
                                return str:sub(1, 75)
                            end
                        },
                        'encoding', 'fileformat', 'filetype'
                    }
                },
                extensions = { 'oil', 'lazy', 'fugitive' }
            }
        end
    },

    -- that sweet sweet surround plugin
    {
        "tpope/vim-surround",
        config = function()
            vim.g.surround_115 = "**\r**"  -- 115 is the ASCII code for 's'
            vim.g.surround_47 = "/* \r */" -- 47 is /
        end
    },

    { "windwp/nvim-autopairs", config = true },

    -- session management
    {
        "Shatur/neovim-session-manager",
        config = function()
            local config = require('session_manager.config')

            -- don't automatically load up previous session
            -- Define what to do when Neovim is started without arguments. Possible values: Disabled, CurrentDir, LastSession
            require('session_manager').setup({
                autoload_mode = config.AutoloadMode.Disabled,
            })
        end
    },


    -- helps with repeating thing
    "tpope/vim-repeat",

    -- taking a beeg leap here
    {
        "ggandor/leap.nvim",
        -- one two three repeater!
        dependencies = { "tpope/vim-repeat" },
        config = function()
            local leap = require('leap')
            leap.add_default_mappings()
            leap.opts.highlight_unlabeled_phase_one_targets = true
        end
    },

    -- autodetecting of tab widths and such
    "tpope/vim-sleuth",

    {
        "nvimtools/none-ls.nvim",
        dependencies = {
            "MunifTanjim/prettier.nvim"
        },
        config = function()
            -- I just want prettier
            local null_ls = require("null-ls")
            local prettier = require("prettier")
            null_ls.setup()
            prettier.setup({
                bin = "prettierd"
            })
        end
    },

    -- oil, not vinegar
    {
        "stevearc/oil.nvim",
        config = function()
            require('oil').setup({
                view_options = {
                    show_hidden = true
                }
            })
            vim.keymap.set("n", "-", "<cmd>Oil<cr>", { desc = "Open parent directory" })
        end
    },
    dev = {
        path = "~/code"
    }
}
