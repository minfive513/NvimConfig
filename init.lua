-- ==============================
--   Basis-Einstellungen
-- ==============================
vim.o.number = true
vim.o.relativenumber = true
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = true
vim.o.smartindent = true
vim.o.termguicolors = true
vim.g.mapleader = " "
vim.o.guifont = "CommitMono Nerd Font:h11:b"
vim.opt.cmdheight = 0


-- Set Bordercolor for Diagnostics popup
vim.cmd [[ 
  highlight NormalFloat guibg=#1e1e1e guifg=#404040
  highlight FloatBorder guibg=#1e1e1e guifg=#dddddd
]]

-- line wrapping
vim.o.wrap = true
vim.o.breakindent = true
vim.o.showbreak = string.rep(" ", 3) -- Make it so that long lines wrap smartly
vim.o.linebreak = true

-- ==============================
--   lazy.nvim installieren
-- ==============================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git", "clone", "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath
    })
end
vim.opt.rtp:prepend(lazypath)

-- Specify how the border looks like
local border = {
    { '┌', 'FloatBorder' },
    { '─', 'FloatBorder' },
    { '┐', 'FloatBorder' },
    { '│', 'FloatBorder' },
    { '┘', 'FloatBorder' },
    { '─', 'FloatBorder' },
    { '└', 'FloatBorder' },
    { '│', 'FloatBorder' },
}

-- Highlight for border
vim.cmd [[
  highlight NormalFloat guibg=#1e1e1e guifg=#404040
  highlight FloatBorder guibg=#1e1e1e guifg=#dddddd
]]

--Set XAML Filetype to xml
vim.api.nvim_create_autocmd({"BufNewFile", "BufRead"},{ pattern = {"*.xaml"}, command = "setf xml" })

vim.api.nvim_create_autocmd({"BufNewFile", "BufRead"},{ pattern = {"*.axaml"}, command = "setf xml" })

-- ==============================
--   Plugins
-- ==============================
require("lazy").setup({

    -- 🎨 VS Code Theme
    {
        priority = 1000,
        "Mofiqul/vscode.nvim",
        config = function()
            require("vscode").setup({
                italic_comments = true,
                transparent = false
            })
            require("vscode").load("dark")
        end
    },

    -- Statusleiste
    { "nvim-lualine/lualine.nvim", config = true },

    -- Syntax Highlighting
    { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },

    -- Dateibrowser
    { "nvim-tree/nvim-tree.lua", config = true },

    -- Fuzzy Finder
    { "nvim-telescope/telescope.nvim", dependencies = { "nvim-lua/plenary.nvim" } },

    -- Mason: Package Manager für LSP, DAP, Formatters usw.
    { "williamboman/mason.nvim", config = true },

    -- Mason-LSPConfig: verbindet Mason mit nvim-lspconfig
    { "williamboman/mason-lspconfig.nvim", config = true },


    -- LSP Support
    { "neovim/nvim-lspconfig",
      config = function()
        local capabilities = require("cmp_nvim_lsp").default_capabilities()

        -- Beispiel: TypeScript
        require("lspconfig").ts_ls.setup({
          capabilities = capabilities,
        })

        -- Beispiel: Rust
        require("lspconfig").rust_analyzer.setup({
          capabilities = capabilities,
        })

        -- C# lsp
        require("lspconfig").omnisharp.setup({
          capabilities = capabilities,
          cmd = { vim.fn.stdpath("data") .. "/mason/bin/OmniSharp" },
          enable_editorconfig_support = true,
          enable_ms_build_load_projects_on_demand = false,
          enable_roslyn_analyzers = true,
          organize_imports_on_format = true,
          enable_import_completion = true,
          sdk_include_prereleases = true,
          analyze_open_documents_only = false,
        })


      end,
    },

    -- Autocomplete
    {
        "hrsh7th/nvim-cmp",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path"
        }
    },

    { "rcarriga/nvim-dap-ui", dependencies = {"mfussenegger/nvim-dap", "nvim-neotest/nvim-nio"} },

    -- Debugger (DAP)
    {
        "mfussenegger/nvim-dap",
        dependencies = {
            "rcarriga/nvim-dap-ui",
        },
        config = function()
            local dap = require("dap")
            local dapui = require("dapui")

            -- UI Setup
            dapui.setup()

            -- Automatisch UI öffnen/schließen
            dap.listeners.after.event_initialized["dapui_config"] = function()
                dapui.open()
            end
            dap.listeners.before.event_terminated["dapui_config"] = function()
                dapui.close()
            end
            dap.listeners.before.event_exited["dapui_config"] = function()
                dapui.close()
            end
    -- Debugpy Adapter
    dap.adapters.python = {
        type = "executable",
        command = vim.fn.exepath("python3"), -- oder dein venv python
        args = { "-m", "debugpy.adapter" },
    }

    -- Remote Adapter
    dap.adapters.python = {
        type = "server",
        host = "192.168.178.71",
        port = 5678, -- dieser Port MUSS mit debugpy übereinstimmen
    }

    -- Debugpy Config
    dap.configurations.python = {
        {
            type = "python", -- muss genau so heißen wie oben
            request = "launch",
            name = "Launch file",
            program = "${file}", -- aktuelle Datei
            console = "integratedTerminal",
            pythonPath = function()
                local venv_path = os.getenv("VIRTUAL_ENV")
                if venv_path then
                    return venv_path .. "/bin/python"
                else
                    return vim.fn.exepath("python3")
                end
            end,
        },
        {
            type = "python",
            request = "attach",
            name = "Remote Attach to Raspberry",
            connect = {
                host = "192.168.178.71", -- IP of the remote pc
                port = 5678,          -- Port of debugpy-Server
            },
            justMyCode = false,
            cwd = vim.fn.getcwd(),
            pathMappings = {
            {
                localRoot = vim.fn.getcwd(),       -- dein Projektpfad in Neovim
                remoteRoot = "/home/minfive/Eternia/", -- Pfad auf dem Remote-PC
              },
            },
        },
    }

        end
    },

    -- Which Key
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        opts = {
            -- your configuration comes here
            -- or leave it empty to use the default settings
            -- refer to the configuration section below
        },
        keys = {
            {
            "<leader>?",
            function()
                require("which-key").show({ global = false })
            end,
            desc = "Buffer Local Keymaps (which-key)",
            },
        },
    },

    -- linting - nvim native, complementary to LSP
    {
        "mfussenegger/nvim-lint",
        event = { "BufWritePost", "BufReadPost", "InsertLeave" },
        config = function()
            local lint = require("lint")
            lint.linters_by_ft = {
                go = {"golangcilint"},
                sh = {"shellcheck"},
                proto = {"buf_lint"},
            }
            local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

            vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
                group = lint_augroup,
                callback = function()
                    lint.try_lint()
                end,
            })
            vim.keymap.set("n", "<leader>l", function()
                lint.try_lint()
            end, { desc = "Trigger linting for current file" })
        end,
    },
    {
      "ErichDonGubler/lsp_lines.nvim",
      event = "LspAttach",
      config = function()
        require("lsp_lines").setup()

        -- Optional: Toggle zwischen virtual_text und lsp_lines
        vim.diagnostic.config({
            virtual_text = {
                prefix = '■ ', -- Could be '●', '▎', 'x', '■', , 
            },
            float = { border = border },
        })
        vim.keymap.set(
          "",
          "<leader>l",
          require("lsp_lines").toggle,
          { desc = "Toggle lsp_lines" }
        )



        -- Add the border on hover and on signature help popup window
        local handlers = {
            ['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, { border = border }),
            ['textDocument/signatureHelp'] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = border }),
        }

        -- Add the border (handlers) to the lua language server
        lspconfig = require("lspconfig")

        lspconfig.lua_ls.setup({
            handlers = handlers,
            -- The rest of the server configuration
        })

        -- Add the border (handlers) to the pyright server
        lspconfig.pyright.setup({
            handlers = handlers,
            capabilities = require("cmp_nvim_lsp").default_capabilities() -- Wichtig für Autocomplete!
        })

      end,
    },

    {
      "hrsh7th/nvim-cmp",
      dependencies = {
        "hrsh7th/cmp-nvim-lsp", -- verbindet LSP mit cmp
        "L3MON4D3/LuaSnip",     -- Snippets
        "saadparwaiz1/cmp_luasnip",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
      },
      config = function()
        local cmp = require("cmp")
        cmp.setup({
          snippet = {
            expand = function(args)
              require("luasnip").lsp_expand(args.body)
            end,
          },
          window = {
                completion = cmp.config.window.bordered(),
                documentation = cmp.config.window.bordered(),
                },
          mapping = cmp.mapping.preset.insert({
            ["<C-Space>"] = cmp.mapping.complete(),
            ["<CR>"] = cmp.mapping.confirm({ select = true }),
          }),
          sources = cmp.config.sources({
            { name = "nvim_lsp" },
            { name = "luasnip" },
          }, {
            { name = "buffer" },
            { name = "path" },
          }),
        })
      end,
    },
})


-- ==============================
--   Treesitter Setup
-- ==============================
require("nvim-treesitter.configs").setup({
    ensure_installed = { "python", "lua", "bash", "json", "yaml", "c_sharp", "xml" },
    highlight = { enable = true },
    indent = { enable = true },
})


-- ==============================
--   LSP + nvim-cmp Setup
-- ==============================
--local lspconfig = require("lspconfig")
local cmp = require("cmp")
--local capabilities = require("cmp_nvim_lsp").default_capabilities()
 

-- Python Language Server (Pyright)
--lspconfig.pyright.setup({
--    capabilities = capabilities,
--})


-- ==============================
--   LSP Semantic Highlighting
-- ==============================
vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if client and client.server_capabilities.semanticTokensProvider then
            vim.cmd("hi link @lsp.type.class Type")
            vim.cmd("hi link @lsp.type.variable Identifier")
            vim.cmd("hi link @lsp.type.function Function")
        end
    end,
})

-- =============================
-- Ensure symbols and color are set correctly
-- =============================
require("lualine").setup({
    options = { icons_enabled = true },
})

vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
        vim.o.termguicolors = true
    end,
})


-- ==============================
-- Auto cmd 
-- ==============================
vim.api.nvim_create_autocmd("CursorHold", {
    callback = function()
        vim.diagnostic.open_float(nil, { focus = false })
    end,
})


-- ==============================
--   Keybindings
-- ==============================
vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { desc = "Dateibrowser" })
vim.keymap.set("n", "<leader>f", ":Telescope find_files<CR>", { desc = "Dateien suchen" })

-- DAP Keymaps
local dap = require("dap")
vim.keymap.set("n", "<F5>", dap.continue, { desc = "Debugger: Start/Continue" })
vim.keymap.set("n", "<F10>", dap.step_over, { desc = "Debugger: Step Over" })
vim.keymap.set("n", "<F11>", dap.step_into, { desc = "Debugger: Step Into" })
vim.keymap.set("n", "<F12>", dap.step_out, { desc = "Debugger: Step Out" })
vim.keymap.set("n", "<leader>b", dap.toggle_breakpoint, { desc = "Debugger: Toggle Breakpoint" })
vim.keymap.set("n", "<leader>B", function()
    dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
end, { desc = "Debugger: Conditional Breakpoint" })
vim.keymap.set("n", "<leader>dr", dap.repl.open, { desc = "Debugger: REPL" })
vim.keymap.set("n", "<leader>dl", dap.run_last, { desc = "Debugger: Run Last" })
-- Remote Debuuger keymap
 vim.keymap.set("n", "<F7>", function()
    require("dap").continue()
end, { desc = "Debugger: Continue/Connect Remote" })

vim.keymap.set("n", "<F6>", function()
    require("dap").run(dap.configurations.python[2])
end, { desc = "Debugger: Attach to Remote" })


-- Telescope (Suche) Keymap
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })


-- naviagtion Shortcuts
-- Gehe zu Definition F12
vim.keymap.set("n", "<F12>", vim.lsp.buf.definition, { desc = "Gehe zur Definition" })
-- Show all Diagnostics (wie in VSCode mit F11)
vim.keymap.set("n", "<leader>j", "<cmd>Telescope diagnostics<CR>", { desc = "Show all diagnostics" })
-- Show Diagnostics for current line F10
-- Diagnostics Popup unter Cursor öffnen
vim.keymap.set("n", "<leader>h", vim.diagnostic.open_float, { desc = "Show diagnostics popup" })



-- navigate between files with mouse buttons
vim.keymap.set('', '<X1Mouse>', ':bprevious<CR>', { noremap = true, silent = true })
vim.keymap.set('', '<X2Mouse>', ':bnext<CR>', { noremap = true, silent = true })


-- to select all intented code after one intentadtion
vim.keymap.set("x", "<", "<gv", { noremap = true, silent = true })
vim.keymap.set("x", ">", ">gv", { noremap = true, silent = true })

-- Ident remapping from < > to Tab Shift-Tab
vim.keymap.set("n", "<TAB>", ">gv");
vim.keymap.set("v", "<TAB>", ">gv");
vim.keymap.set("n", "<S-TAB>", "<gv");
vim.keymap.set("v", "<S-TAB>", "<gv");

-- Jump Forwards/Backwards
vim.keymap.set("n", "<leader>o", "<C-o>", { desc = "Jump backward" })
vim.keymap.set("n", "<leader>i", "<C-i>", { desc = "Jump forward" })

