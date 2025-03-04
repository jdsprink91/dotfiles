return {
    "neovim/nvim-lspconfig",
    dependencies = {
        -- LSP Support
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
        local lspconfig = require("lspconfig")
        local schemastore = require("schemastore")

        vim.keymap.set('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<cr>')
        vim.keymap.set('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<cr>')

        vim.api.nvim_create_autocmd('LspAttach', {
            desc = 'LSP actions',
            callback = function(event)
                local opts = { buffer = event.buf }

                -- these will be buffer-local keybindings
                -- because they only work if you have an active language server

                vim.keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>', opts)
                vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>', opts)
                vim.keymap.set('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>', opts)
                vim.keymap.set('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>', opts)
                vim.keymap.set('n', 'go', '<cmd>lua vim.lsp.buf.type_definition()<cr>', opts)
                vim.keymap.set('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>', opts)
                vim.keymap.set('n', 'gs', '<cmd>lua vim.lsp.buf.signature_help()<cr>', opts)
                vim.keymap.set('n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<cr>', opts)
                vim.keymap.set('n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<cr>', opts)
                vim.keymap.set({ 'n', 'x' }, '<leader>pf', function()
                    vim.lsp.buf.format({
                        async = false,
                        timeout_ms = 10000,
                        bufnr = vim.api.nvim_get_current_buf(),
                        desc = "[lsp] format"
                    })
                end, opts)
                local client = vim.lsp.get_client_by_id(event.data.client_id)
                client.server_capabilities.semanticTokensProvider = nil
            end
        })

        local capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities())
        capabilities.textDocument.completion.completionItem.snippetSupport = true
        local default_setup = function(server)
            lspconfig[server].setup({
                capabilities = capabilities,
            })
        end

        require("mason").setup {}
        require("mason-lspconfig").setup {
            ensure_installed = { "astro", "cssls", "html", "eslint", "jsonls", "lua_ls", "pylsp",
                "ts_ls", "yamlls", "mdx_analyzer" },
            handlers = {
                default_setup,
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
                lua_ls = function()
                    lspconfig.lua_ls.setup {
                        settings = {
                            Lua = {
                                runtime = {
                                    version = "LuaJIT"
                                },
                                diagnostics = {
                                    globals = {
                                        "vim",
                                        "require"
                                    }
                                },
                                workspace = {
                                    library = vim.api.nvim_get_runtime_file("", true)
                                },
                                telemetry = {
                                    enable = false
                                }
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
                ts_ls = function()
                    lspconfig.ts_ls.setup {
                        capabilities = capabilities,
                        on_attach = function(client)
                            -- I use null-ls to format code, deactivate this
                            client.server_capabilities.document_formatting = false
                        end
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

        -- autocomplete
        require("luasnip.loaders.from_vscode").lazy_load()
        local t = function(str)
            return vim.api.nvim_replace_termcodes(str, true, true, true)
        end

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
                ['<C-n>'] = cmp.mapping({
                    c = function()
                        if cmp.visible() then
                            cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
                        else
                            vim.api.nvim_feedkeys(t('<Down>'), 'n', true)
                        end
                    end,
                    i = function(fallback)
                        if cmp.visible() then
                            cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
                        else
                            fallback()
                        end
                    end
                }),
                ['<C-p>'] = cmp.mapping({
                    c = function()
                        if cmp.visible() then
                            cmp.select_prev_item({ behavior = cmp.SelectBehavior.Select })
                        else
                            vim.api.nvim_feedkeys(t('<Up>'), 'n', true)
                        end
                    end,
                    i = function(fallback)
                        if cmp.visible() then
                            cmp.select_prev_item({ behavior = cmp.SelectBehavior.Select })
                        else
                            fallback()
                        end
                    end
                }),
                ["<C-e>"] = cmp.mapping.abort(),
                ["<C-y>"] = cmp.mapping.confirm({ select = false })
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
        cmp.setup.filetype("markdown.mdx", { enabled = false })
        cmp.setup.filetype("gitcommit", { enabled = false })
        cmp.setup.filetype("oil", { enabled = false })
    end
}
