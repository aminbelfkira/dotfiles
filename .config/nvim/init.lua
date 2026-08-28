vim.g.mapleader = " "
vim.g.maplocalleader = " "

local opt = vim.opt

-- Interface
opt.number = true
opt.relativenumber = true
opt.cursorline = true
opt.signcolumn = "yes"
opt.termguicolors = true
opt.scrolloff = 5

-- Édition
opt.expandtab = true
opt.shiftwidth = 4
opt.tabstop = 4
opt.smartindent = true
opt.wrap = false

-- Recherche
opt.ignorecase = true
opt.smartcase = true
opt.incsearch = true

-- Fenêtres
opt.splitright = true
opt.splitbelow = true

-- Fichiers
opt.undofile = true

-- Confort
opt.mouse = "a"
opt.updatetime = 250

local map = vim.keymap.set

map("n", "<leader>w", "<cmd>write<cr>", {
    desc = "Enregistrer",
})

map("n", "<leader>q", "<cmd>quit<cr>", {
    desc = "Quitter",
})

map("n", "<Esc>", "<cmd>nohlsearch<cr>", {
    desc = "Effacer le surlignage de recherche",
})
-- Yazi remplace l'explorateur de fichiers natif netrw
vim.g.loaded_netrwPlugin = 1
-- Plugins gérés nativement par Neovim
vim.pack.add({
    "https://github.com/folke/tokyonight.nvim",
    "https://github.com/ibhagwan/fzf-lua",
    "https://github.com/folke/which-key.nvim",
    "https://github.com/neovim/nvim-lspconfig",
    "https://github.com/saghen/blink.lib",
    {
        src = "https://github.com/saghen/blink.cmp",
        version = vim.version.range("1"),
    },
    "https://github.com/stevearc/conform.nvim",
    "https://github.com/lewis6991/gitsigns.nvim",
    "https://github.com/folke/trouble.nvim",
    {
        src = "https://github.com/nvim-mini/mini.nvim",
        version = "stable",
    },
    "https://github.com/nvim-lualine/lualine.nvim",
    "https://github.com/mrjones2014/smart-splits.nvim",
    { src = "https://github.com/nvim-lua/plenary.nvim" },
    { src = "https://github.com/mikavilpas/yazi.nvim" },
})
-- Gestionnaire de fichiers Yazi
require("yazi").setup({
    open_for_directories = true,
    floating_window_scaling_factor = 0.9,
    yazi_floating_window_border = "rounded",
})

map({ "n", "v" }, "<leader>e", "<cmd>Yazi<cr>", {
    desc = "Ouvrir Yazi",
})
-- Thème
require("tokyonight").setup({
    style = "night",
})

vim.cmd.colorscheme("tokyonight")

-- Recherche de fichiers et de texte
local fzf = require("fzf-lua")

fzf.setup({
    "max-perf",
})

map("n", "<leader>ff", fzf.files, {
    desc = "Rechercher des fichiers",
})

map("n", "<leader>fg", fzf.live_grep, {
    desc = "Rechercher du texte",
})

map("n", "<leader>fb", fzf.buffers, {
    desc = "Afficher les buffers",
})

map("n", "<leader>fr", fzf.oldfiles, {
    desc = "Fichiers récents",
})
-- Aide interactive pour les raccourcis
require("which-key").setup({
    delay = 300,

    icons = {
        mappings = false,
    },

    spec = {
        {
            "<leader>f",
            group = "Recherche",
        },
        {
            "<leader>c",
            group = "Code",
        },
        {
            "<leader>g",
            group = "Git"
        },
        {
            "<leader>x",
            group = "Diagnostics",
        },
        {
            "<leader>b",
            group = "Buffers"
        },
        {
            "<leader>s",
            group = "Fenêtres",
        },
    },
})
-- LSP pour la configuration Neovim en Lua
vim.lsp.config("lua_ls", {
    settings = {
        Lua = {
            runtime = {
                version = "LuaJIT",
            },

            workspace = {
                checkThirdParty = false,
                library = {
                    vim.env.VIMRUNTIME,
                },
            },

            telemetry = {
                enable = false,
            },
        },
    },
})
-- Serveurs de langage Python
vim.lsp.enable({
    "basedpyright",
    "ruff",
    "lua_ls",
})
vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup(
        "disable_ruff_hover",
        { clear = true }
    ),

    callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)

        if client and client.name == "ruff" then
            client.server_capabilities.hoverProvider = false
        end
    end,
})
vim.diagnostic.config({
    signs = true,
    underline = true,
    virtual_text = false,

    virtual_lines = {
        current_line = true,
    },

    update_in_insert = false,
    severity_sort = true,
})
map("n", "gd", vim.lsp.buf.definition, {
    desc = "Aller à la définition",
})

map("n", "<leader>ca", vim.lsp.buf.code_action, {
    desc = "Action de code",
})

map("n", "<leader>cr", vim.lsp.buf.rename, {
    desc = "Renommer le symbole",
})

map("n", "<leader>cd", vim.diagnostic.open_float, {
    desc = "Détail du diagnostic",
})

map("n", "]d", function()
    vim.diagnostic.jump({ count = 1 })
end, {
    desc = "Diagnostic suivant",
})

map("n", "[d", function()
    vim.diagnostic.jump({ count = -1 })
end, {
    desc = "Diagnostic précédent",
})
-- Autocomplétion
local cmp = require("blink.cmp")


cmp.setup({
    keymap = {
        preset = "none",

        ["<C-Space>"] = {
            "show",
            "show_documentation",
            "hide_documentation",
        },

        ["<C-n>"] = { "select_next", "fallback" },
        ["<C-p>"] = { "select_prev", "fallback" },
        ["<CR>"] = { "accept", "fallback" },
        ["<C-e>"] = { "hide", "fallback" },
    },

    completion = {
        documentation = {
            auto_show = true,
        },

        list = {
            selection = {
                preselect = false,
                auto_insert = false,
            },
        },
    },

    sources = {
        default = { "lsp", "path", "snippets", "buffer" },
    },

    fuzzy = {
        implementation = "prefer_rust_with_warning",
    },
})
-- Formatage du code
local conform = require("conform")

conform.setup({
    formatters_by_ft = {
        python = { "ruff_format" },
        lua = { "stylua" },
    },

    default_format_opts = {
        lsp_format = "fallback",
    },

    format_on_save = {
        timeout_ms = 1000,
    },
})

map("n", "<leader>cf", function()
    conform.format({
        timeout_ms = 1000,
    })
end, {
    desc = "Formater le fichier",
})
-- Modifications Git dans la marge
require("gitsigns").setup({
    on_attach = function(bufnr)
        local git = require("gitsigns")

        local function gitmap(mode, keys, action, description)
            map(mode, keys, action, {
                buffer = bufnr,
                desc = description,
            })
        end

        gitmap("n", "]h", function()
            git.nav_hunk("next")
        end, "Modification Git suivante")

        gitmap("n", "[h", function()
            git.nav_hunk("prev")
        end, "Modification Git précédente")

        gitmap("n", "<leader>gp", git.preview_hunk, "Prévisualiser la modification")
        gitmap("n", "<leader>gs", git.stage_hunk, "Ajouter la modification au stage")
        gitmap("n", "<leader>gr", git.reset_hunk, "Annuler la modification")

        gitmap("n", "<leader>gb", function()
            git.blame_line({ full = true })
        end, "Historique de la ligne")
    end,
})
-- Liste structurée des diagnostics
require("trouble").setup({
    focus = true,
})

map("n", "<leader>xx", function()
    require("trouble").toggle("diagnostics")
end, {
    desc = "Tous les diagnostics",
})

map("n", "<leader>xd", function()
    require("trouble").toggle({
        mode = "diagnostics",
        filter = { buf = 0 },
    })
end, {
    desc = "Diagnostics du fichier",
})
-- Paires automatiques : (), [], {}, "", ''
require("mini.pairs").setup()

-- Ajouter, supprimer ou remplacer des entourages
require("mini.surround").setup()
-- Barre d’état minimale
require("lualine").setup({
    options = {
        theme = "tokyonight",
        icons_enabled = false,
        globalstatus = true,

        section_separators = {
            left = "",
            right = "",
        },

        component_separators = {
            left = "│",
            right = "│",
        },
    },

    sections = {
        lualine_a = {
            "mode",
        },

        lualine_b = {
            "branch",
        },

        lualine_c = {
            {
                "filename",
                path = 1,
                symbols = {
                    modified = " [+]",
                    readonly = " [RO]",
                    unnamed = "[Sans nom]",
                    newfile = " [Nouveau]",
                },
            },
        },

        lualine_x = {
            {
                "diagnostics",
                sources = { "nvim_diagnostic" },
                sections = { "error", "warn" },
                symbols = {
                    error = "E",
                    warn = "W",
                },
            },
            "filetype",
        },

        lualine_y = {},

        lualine_z = {
            "location",
        },
    },

    inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = {},
        lualine_x = {},
        lualine_y = {},
        lualine_z = {},
    },

    tabline = {},
    winbar = {},
})
-- Navigation transparente entre Neovim et tmux
local splits = require("smart-splits")

splits.setup()

map("n", "<C-h>", splits.move_cursor_left, {
    desc = "Fenêtre de gauche",
})

map("n", "<C-j>", splits.move_cursor_down, {
    desc = "Fenêtre du bas",
})

map("n", "<C-k>", splits.move_cursor_up, {
    desc = "Fenêtre du haut",
})

map("n", "<C-l>", splits.move_cursor_right, {
    desc = "Fenêtre de droite",
})
-- Ouvrir LazyGit dans une nouvelle fenêtre tmux
map("n", "<leader>gg", function()
    local root = vim.fs.root(0, ".git") or vim.fn.getcwd()

    if vim.env.TMUX then
        vim.system({
            "tmux",
            "new-window",
            "-c",
            root,
            "lazygit",
        })
    else
        vim.notify(
            "Ouvre Neovim dans tmux pour utiliser Espace g g",
            vim.log.levels.WARN
        )
    end
end, {
    desc = "Ouvrir LazyGit",
})
-- Navigation entre les fichiers ouverts
map("n", "[b", "<cmd>bprevious<cr>", {
    desc = "Buffer précédent",
})

map("n", "]b", "<cmd>bnext<cr>", {
    desc = "Buffer suivant",
})

map("n", "<leader>bd", "<cmd>bdelete<cr>", {
    desc = "Fermer le buffer",
})
-- Gestion des fenêtres divisées
map("n", "<leader>sv", "<cmd>vsplit<cr>", {
    desc = "Séparation verticale",
})

map("n", "<leader>sh", "<cmd>split<cr>", {
    desc = "Séparation horizontale",
})

map("n", "<leader>se", "<C-w>=", {
    desc = "Égaliser les fenêtres",
})

map("n", "<leader>sc", "<cmd>close<cr>", {
    desc = "Fermer la fenêtre",
})
