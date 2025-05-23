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
                exclude = { "markdown" }
            })
        end
    },

    -- statusline plugin
    {
        "nvim-lualine/lualine.nvim",
        config = function()
            require("lualine").setup({
                options = {
                    globalstatus = true
                },
                sections = {
                    lualine_c = {
                        'filename',
                        {
                            'lsp_status',
                            icon = '', -- f013
                            symbols = {
                                -- Standard unicode symbols to cycle through for LSP progress:
                                spinner = { '⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏' },
                                -- Standard unicode symbol for when LSP is done:
                                done = '✓',
                                -- Delimiter inserted between LSP names:
                                separator = ', ',
                            },
                            -- List of LSP names to ignore (e.g., `null-ls`):
                            ignore_lsp = { "null-ls" },
                        }
                    }
                },
                extensions = { 'oil', 'lazy', 'fugitive' }
            })
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
        config = function()
            -- I just want prettier
            local null_ls = require("null-ls")
            null_ls.setup({
                sources = null_ls.builtins.formatting.prettierd
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
}
