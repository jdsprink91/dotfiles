return {
    "nvim-treesitter/nvim-treesitter",
    build = ':TSUpdate',
    dependencies = {
        "nvim-treesitter/nvim-treesitter-textobjects",
        "nvim-treesitter/nvim-treesitter-context",
    },
    opts = {
        -- Automatically install missing parsers when entering buffer
        -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
        auto_install = true,
        -- A list of parser names, or "all" (the four listed parsers should always be installed)
        ensure_installed = { "astro", "css", "html", "htmldjango", "javascript",
            "jsdoc", "json", "lua", "markdown", "python", "typescript", "toml", "tsx", "vim", "yaml" },

        highlight = {
            enable = true,

            -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
            -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
            -- Using this option may slow down your editor, and you may see some duplicate highlights.
            -- Instead of true it can also be a list of languages
            additional_vim_regex_highlighting = false,
        },
        incremental_selection = {
            enable = true,
            keymaps = {
                init_selection = "<Leader>ss",     -- set to `false` to disable one of the mappings
                node_incremental = "<Leader>si",
                scope_incremental = "<Leader>sc",
                node_decremental = "<Leader>sd",
            },
        },
        -- Install parsers synchronously (only applied to `ensure_installed`)
        sync_install = false,
        textobjects = {
            -- NOTE: select only works in visual mode
            -- see more at https://github.com/nvim-treesitter/nvim-treesitter-textobjects
            select = {
                enable = true,
                lookahead = true,
                keymaps = {
                    ["af"] = {
                        query = "@function.outer",
                        desc =
                        "Select function including the function definition"
                    },
                    ["if"] = { query = "@function.inner", desc = "Select the inner part of a function" },
                    ["ac"] = { query = "@class.outer", desc = "Select class including class definition" },
                    ["ic"] = { query = "@class.inner", desc = "Select the inner part of a class" },
                    ["as"] = { query = "@scope", query_group = "locals", desc = "Select language scope" },
                }
            }
        }
    },
    config = function(_, opts)
        require("nvim-treesitter.configs").setup(opts)
    end
}
