-- line number config
vim.opt.nu = true
vim.opt.relativenumber = true

-- where to open up a new window
vim.opt.splitbelow = true
vim.opt.splitright = true

-- tabs
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true

vim.opt.wrap = false

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.termguicolors = true

vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")

vim.opt.updatetime = 50

vim.opt.hidden = true

-- which python host
vim.g.python3_host_prog = '/Users/jasonsprinkle/.pyenv/versions/py3nvim/bin/python'

-- folds
vim.opt.foldmethod = "indent"
vim.opt.foldenable = false

-- some keymaps
vim.keymap.set("n", "[w", "<C-w>W")
vim.keymap.set("n", "]w", "<C-w>w")
vim.keymap.set("n", "[q", ":cprev<cr>")
vim.keymap.set("n", "]q", ":cnext<cr>")

-- if we're in a django project, always set these html files to be htmldjango
vim.api.nvim_create_autocmd({
    "BufNewFile",
    "BufRead"
}, {
    pattern = { "*.html" },
    callback = function()
        local buf = vim.api.nvim_get_current_buf()
        -- if this is an html file in a django project, then we should
        -- automatically set the filetype to such
        if vim.api.nvim_buf_get_name(buf):match("djangoproject") then
            vim.api.nvim_buf_set_option(buf, "filetype", "htmldjango")
        end
    end
})

vim.g.mapleader = " "

-- make it really easy to yank things into the clipboard
vim.keymap.set("n", "<leader>y", "\"+y")

-- get me a word count
vim.keymap.set("n", "<leader>wc", "g<C-g>")

-- load last session
vim.keymap.set("n", "<leader>ls", ":SessionManager load_last_session<cr>")

vim.filetype.add({
    extension = {
        mdx = 'markdown.mdx'
    }
})

-- add wrapping for markdown files
-- autocmds
vim.api.nvim_create_autocmd('BufWinEnter', {
    pattern = { '*.md', '*.mdx' },
    callback = function()
        vim.opt.textwidth = 80
    end,
})

vim.api.nvim_create_autocmd({ 'BufWinLeave' }, {
    pattern = { '*.md', '*.mdx' },
    callback = function()
        vim.opt.textwidth = 0
    end,
})

vim.treesitter.language.register("bash", "zsh")

local function get_icon()
    local path = vim.fn.bufname()

    if vim.bo.filetype == "" then
        return "", "Default"
    end

    if vim.fn.isdirectory(path) > 0 then
        return "", "Default"
    end

    local devicons = require("nvim-web-devicons")
    local filename = vim.fn.expand("%:t")

    local icon, highlight_name = devicons.get_icon(filename, vim.fn.expand("%:e:e"))

    if not icon then
        icon, highlight_name = devicons.get_icon(filename, vim.fn.expand("%:e"))

        if not icon then
            return "", "Default"
        end
    end

    return icon, highlight_name
end

local function register_winbar()
    vim.api.nvim_create_autocmd({ "VimEnter", "BufEnter", "WinEnter", "WinLeave" }, {
        group    = vim.api.nvim_create_augroup("winbar_winbar", { clear = true }),
        callback = function(args)
            local win_number = vim.api.nvim_get_current_win()
            local win_config = vim.api.nvim_win_get_config(win_number)

            if win_config.relative == "" then
                local icon, hl = get_icon()
                if args.event == "WinLeave" then
                    hl = "WinbarNC"
                    vim.opt_local.winbar = " " .. "%*" .. " %#" .. hl .. "#" .. icon .. " %t%*"
                else
                    vim.opt_local.winbar = " " .. "%*" .. " %#" .. hl .. "#" .. icon .. " %#Type#%t%*"
                end
            else
                vim.opt_local.winbar = nil
            end
        end
    })
end

register_winbar()

vim.api.nvim_create_user_command('LspHealth', function()
    vim.cmd(':checkhealth vim.lsp')
end, { desc = 'Shortcut for :checkhealth vim.lsp' })

vim.api.nvim_create_user_command('LspLog', function()
    vim.cmd('split' .. vim.lsp.get_log_path())
end, { desc = 'Opens the LSP client log' })

-- set mah diagnostics
vim.diagnostic.config({
    jump = {
        float = true
    },
    update_in_insert = false
})
