return {
    "williamboman/mason.nvim",
    dependencies = {
        -- schema store for json and yaml
        "b0o/schemastore.nvim",

        -- autocomplete
        "hrsh7th/nvim-cmp",
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "hrsh7th/cmp-nvim-lua",

        -- formatter for autocomplete
        "onsails/lspkind.nvim",
    },
    config = function()
        local schemastore = require("schemastore")
        local mason = require('mason')

        mason.setup()

        vim.api.nvim_create_autocmd('LspAttach', {
            desc = 'LSP actions',
            callback = function(event)
                vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>', { desc = "Go to definition" })
                vim.keymap.set({ 'n', 'x' }, '<leader>f', function()
                    vim.lsp.buf.format({
                        async = false,
                        timeout_ms = 10000,
                        bufnr = vim.api.nvim_get_current_buf(),
                        desc = "[lsp] format"
                    })
                end, { buffer = event.buf, desc = "Format with LSP" })

                local client = vim.lsp.get_client_by_id(event.data.client_id)
                if client then
                    client.server_capabilities.semanticTokensProvider = nil
                end
            end
        })

        vim.lsp.config("*", {
            capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities())
        })

        vim.lsp.config['astro'] = {
            cmd = { 'astro-ls', '--stdio' },
            filetypes = { 'astro' },
            root_markers = {
                'package.json',
                'tsconfig.json',
                'jsconfig.json',
                '.git'
            },
            init_options = {
                typescript = {
                    tsdk = 'node_modules/typescript/lib'
                },
            },
        }

        vim.lsp.config['cssls'] = {
            cmd = { 'vscode-css-language-server', '--stdio' },
            filetypes = { 'css', 'scss', 'less' },
            init_options = { provideFormatter = true }, -- needed to enable formatting capabilities
            root_markers = { 'package.json', '.git' },
            settings = {
                css = { validate = true },
                scss = { validate = true },
                less = { validate = true },
            },
        }

        vim.lsp.config['eslint'] = {
            cmd = { 'vscode-eslint-language-server', '--stdio' },
            filetypes = {
                'javascript',
                'javascriptreact',
                'javascript.jsx',
                'typescript',
                'typescriptreact',
                'typescript.tsx',
                'vue',
                'svelte',
                'astro',
            },
            root_markers = { '.eslintrc.js', '.eslintrc.json', 'eslint.config.js' },
            -- Refer to https://github.com/Microsoft/vscode-eslint#settings-options for documentation.
            settings = {
                validate = 'on',
                packageManager = nil,
                useESLintClass = false,
                experimental = {
                    useFlatConfig = false,
                },
                codeActionOnSave = {
                    enable = false,
                    mode = 'all',
                },
                format = true,
                quiet = false,
                onIgnoredFiles = 'off',
                rulesCustomizations = {},
                run = 'onType',
                problems = {
                    shortenToSingleLine = false,
                },
                -- nodePath configures the directory in which the eslint server should start its node_modules resolution.
                -- This path is relative to the workspace folder (root dir) of the server instance.
                nodePath = '',
                -- use the workspace folder location or the file location (if no workspace folder is open) as the working directory
                workingDirectory = { mode = 'location' },
                codeAction = {
                    disableRuleComment = {
                        enable = true,
                        location = 'separateLine',
                    },
                    showDocumentation = {
                        enable = true,
                    },
                },
            },
            before_init = function(_, config)
                -- The "workspaceFolder" is a VSCode concept. It limits how far the
                -- server will traverse the file system when locating the ESLint config
                -- file (e.g., .eslintrc).
                local root_dir = config.root_dir

                if root_dir then
                    config.settings = config.settings or {}
                    config.settings.workspaceFolder = {
                        uri = root_dir,
                        name = vim.fn.fnamemodify(root_dir, ':t'),
                    }

                    -- Support flat config
                    local flat_config_files = {
                        'eslint.config.js',
                        'eslint.config.mjs',
                        'eslint.config.cjs',
                        'eslint.config.ts',
                        'eslint.config.mts',
                        'eslint.config.cts',
                    }

                    for _, file in ipairs(flat_config_files) do
                        if vim.fn.filereadable(root_dir .. '/' .. file) == 1 then
                            config.settings.experimental = config.settings.experimental or {}
                            config.settings.experimental.useFlatConfig = true
                            break
                        end
                    end

                    -- Support Yarn2 (PnP) projects
                    local pnp_cjs = root_dir .. '/.pnp.cjs'
                    local pnp_js = root_dir .. '/.pnp.js'
                    if vim.uv.fs_stat(pnp_cjs) or vim.uv.fs_stat(pnp_js) then
                        local cmd = config.cmd
                        config.cmd = vim.list_extend({ 'yarn', 'exec' }, cmd)
                    end
                end
            end,
            handlers = {
                ['eslint/openDoc'] = function(_, result)
                    if result then
                        vim.ui.open(result.url)
                    end
                    return {}
                end,
                ['eslint/confirmESLintExecution'] = function(_, result)
                    if not result then
                        return
                    end
                    return 4 -- approved
                end,
                ['eslint/probeFailed'] = function()
                    vim.notify('[lspconfig] ESLint probe failed.', vim.log.levels.WARN)
                    return {}
                end,
                ['eslint/noLibrary'] = function()
                    vim.notify('[lspconfig] Unable to find ESLint library.', vim.log.levels.WARN)
                    return {}
                end,
            },
            on_attach = function(client)
                -- turn on that eslint is a formatting provider for the appropriate
                -- file types
                client.server_capabilities.documentFormattingProvider = true
            end
        }

        vim.lsp.config['html'] = {
            cmd = { 'vscode-html-language-server', '--stdio' },
            filetypes = { 'html', 'templ' },
            root_markers = { 'package.json', '.git' },
            settings = {},
            init_options = {
                provideFormatter = false,
                embeddedLanguages = { css = true, javascript = true },
                configurationSection = { 'html', 'css', 'javascript' },
            },
        }

        vim.lsp.config['jsonls'] = {
            cmd = { 'vscode-json-language-server', '--stdio' },
            filetypes = { 'json', 'jsonc' },
            init_options = {
                provideFormatter = true,
            },
            root_markers = { 'package.json', '.git' },
            settings = {
                json = {
                    validate = {
                        enable = true
                    },
                    schemas = schemastore.json.schemas(),
                }
            }
        }

        vim.lsp.config['luals'] = {
            cmd = { 'lua-language-server' },
            filetypes = { 'lua' },
            root_markers = {
                '.luarc.json',
                '.luarc.jsonc',
                '.luacheckrc',
                '.stylua.toml',
                'stylua.toml',
                'selene.toml',
                'selene.yml',
                '.git',
            },
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
            },
            log_level = vim.lsp.protocol.MessageType.Warning,
        }

        vim.lsp.config['mdx_analyzer'] = {
            cmd = { 'mdx-language-server', '--stdio' },
            filetypes = { 'mdx' },
            root_markers = { 'package.json' },
            settings = {},
            init_options = {
                typescript = {},
            },
        }

        vim.lsp.config['pylsp'] = {
            cmd = { 'pylsp' },
            filetypes = { 'python' },
            root_markers = {
                'pyproject.toml',
                'setup.py',
                'setup.cfg',
                'requirements.txt',
                'Pipfile',
            },
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

        vim.lsp.config['ts_ls'] = {
            init_options = { hostInfo = 'neovim' },
            cmd = { 'typescript-language-server', '--stdio' },
            filetypes = {
                'javascript',
                'javascriptreact',
                'javascript.jsx',
                'typescript',
                'typescriptreact',
                'typescript.tsx',
            },
            root_markers = {
                'tsconfig.json', 'jsconfig.json', 'package.json', '.git'
            },
            on_attach = function(client)
                -- I use null-ls to format code, deactivate this
                client.server_capabilities.document_formatting = false
            end
        }

        vim.lsp.config['yamlls'] = {
            cmd = { 'yaml-language-server', '--stdio' },
            filetypes = { 'yaml', 'yaml.docker-compose', 'yaml.gitlab' },
            root_markers = {
                ".git"
            },
            settings = {
                -- https://github.com/redhat-developer/vscode-redhat-telemetry#how-to-disable-telemetry-reporting
                redhat = { telemetry = { enabled = false } },
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

        vim.lsp.enable({ 'astro', 'cssls', 'eslint', 'html', 'jsonls', 'luals', 'mdx_analyzer', 'pylsp', 'ts_ls',
            'yamlls' })

        -- autocomplete
        local cmp = require('cmp')
        cmp.setup({
            preselect = 'item',
            formatting = {
                format = require("lspkind").cmp_format({
                    mode = "symbol",
                    maxwidth = 50,
                    ellipsis_char = "..."
                })
            },
            mapping = cmp.mapping.preset.insert({
                ['<CR>'] = cmp.mapping.confirm({ select = true })
            }),
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
            }, {
                { name = "path" },
                { name = "buffer", keyword_length = 5 }
            }),
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
