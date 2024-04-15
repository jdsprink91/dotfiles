return {
    "VonHeikemen/lsp-zero.nvim",
    branch = "v3.x",
    dependencies = {
        -- LSP Support
        "neovim/nvim-lspconfig",
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",

        -- schema store for json and yaml
        "b0o/schemastore.nvim",

        -- autocomplete
        "hrsh7th/nvim-cmp",
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "saadparwaiz1/cmp_luasnip",
        "hrsh7th/cmp-nvim-lua",

        -- autocomplete snippets
        {
            "L3MON4D3/LuaSnip",
            dependencies = {
                "rafamadriz/friendly-snippets",
            }
        },

        -- formatter for autocomplete
        "onsails/lspkind.nvim",
    },
    config = function()
        local lsp_zero = require("lsp-zero")
        local lspconfig = require("lspconfig")
        local capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities())
        capabilities.textDocument.completion.completionItem.snippetSupport = true
        local schemastore = require("schemastore")

        lsp_zero.on_attach(function(_, bufnr)
            local opts = { buffer = bufnr }
            lsp_zero.default_keymaps({ buffer = bufnr, omit = { "gs" } })
            vim.keymap.set("n", "<leader>vrn", function() vim.lsp.buf.rename() end, opts)
            vim.keymap.set("n", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)

            vim.keymap.set({ 'n', 'x' }, '<leader>pf', function()
                vim.lsp.buf.format({ async = false, timeout_ms = 10000 })
            end, opts)
        end)

        require("mason").setup {}
        require("mason-lspconfig").setup {
            ensure_installed = { "astro", "cssls", "html", "eslint", "jsonls", "lua_ls", "pylsp", "tailwindcss",
                "tsserver", "yamlls" },
            handlers = {
                lsp_zero.default_setup,
                -- we need to set these up special for special reasons
                html = function()
                    lspconfig.html.setup {
                        capabilities = capabilities,
                        filetypes = { "html", "htmldjango" },
                        init_options = {
                            provideFormatter = false
                        }
                    }
                end,
                eslint = function()
                    lspconfig.eslint.setup {
                        capabilities = capabilities,
                        on_attach = function(client)
                            -- turn on that eslint is a formatting provider for the appropriate
                            -- file types
                            client.server_capabilities.documentFormattingProvider = true
                        end
                    }
                end,
                jsonls = function()
                    lspconfig.jsonls.setup {
                        capabilities = capabilities,
                        settings = {
                            json = {
                                validate = {
                                    enable = true
                                },
                                schemas = schemastore.json.schemas(),
                            }
                        }
                    }
                end,
                pylsp = function()
                    lspconfig.pylsp.setup {
                        settings = {
                            pylsp = {
                                configurationSources = { 'flake8' },
                                plugins = {
                                    -- we don't care about these, we use flake8
                                    pycodestyle = { enabled = false },
                                    mccabe = { enabled = false },
                                    pyflakes = { enabled = false },

                                    -- literati related config
                                    flake8 = {
                                        enabled = true,
                                    },
                                    isort = {
                                        enabled = true,
                                    },
                                    black = {
                                        enabled = true
                                    },
                                    pylsp_mypy = {
                                        enabled = false,
                                    }
                                }
                            }
                        }
                    }
                end,
                tailwindcss = function()
                    lspconfig.tailwindcss.setup {
                        init_options = {
                            userLanguages = {
                                htmldjango = "html"
                            },
                        }
                    }
                end,
                yamlls = function()
                    lspconfig.yamlls.setup {
                        capabilities = capabilities,
                        settings = {
                            yaml = {
                                format = {
                                    enable = true,
                                },
                                validate = true,
                                hover = true,
                                completion = true,
                                schemaStore = {
                                    url = "",
                                    enable = false,
                                },
                                schemas = schemastore.yaml.schemas(),
                            },
                        },
                    }
                end
            }

        }

        -- HERE BE THE AUTOCOMPLETE SETUP
        require("luasnip.loaders.from_vscode").lazy_load()

        local cmp = require('cmp')
        cmp.setup({
            preselect = 'item',
            completion = {
                completeopt = 'menu,menuone,noinsert'
            },
            formatting = {
                format = require("lspkind").cmp_format({
                    mode = "symbol",
                    maxwidth = 50,
                    ellipsis_char = "..."
                })
            },
            mapping = {
                ["<C-j>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
                ["<C-k>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
                ["<C-e>"] = cmp.mapping.abort(),
                ["<C-y>"] = cmp.mapping.confirm({ select = true })
            },
            enabled = function()
                -- it was getting annoying to see cmp work inside comments, this disables that
                local in_prompt = vim.api.nvim_buf_get_option(0, 'buftype') == 'prompt'
                if in_prompt then -- this will disable cmp in the Telescope window (taken from the default config)
                    return false
                end
                local context = require("cmp.config.context")
                return not (context.in_treesitter_capture("comment") == true or context.in_syntax_group("Comment"))
            end,
            sources = cmp.config.sources({
                { name = "nvim_lua" },
                { name = "nvim_lsp" },
                { name = "luasnip" },
            }, {
                { name = "path" },
                { name = "buffer", keyword_length = 5 }
            }),
            snippet = {
                expand = function(args)
                    require 'luasnip'.lsp_expand(args.body)
                end
            },
            experimental = {
                ghost_text = true
            }
        })

        -- filetypes that should disable completion
        cmp.setup.filetype("markdown", { enabled = false })
        cmp.setup.filetype("gitcommit", { enabled = false })
        cmp.setup.filetype("oil", { enabled = false })
    end
}
