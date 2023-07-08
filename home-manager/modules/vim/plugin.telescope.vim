lua <<END
local actions = require("telescope.actions")
local trouble = require("trouble.providers.telescope")

local telescope = require("telescope")

telescope.setup {
  defaults = {
    mappings = {
      i = { ["<c-t>"] = trouble.open_with_trouble },
      n = { ["<c-t>"] = trouble.open_with_trouble },
    },
  },
}
END

nnoremap <leader>fl <cmd>Telescope find_files<cr>
nnoremap <leader>ff <cmd>Telescope find_files<cr>
nnoremap <leader>fg <cmd>Telescope live_grep<cr>
nnoremap <leader>fb <cmd>Telescope buffers<cr>
nnoremap <leader>fr <cmd>Telescope buffers<cr>
nnoremap <leader>fc <cmd>Telescope commands<cr>
nnoremap <leader>fm <cmd>Telescope keymaps<cr>
nnoremap <leader>fk <cmd>Telescope marks<cr>
nnoremap <leader>ft <cmd>Telescope treesitter<cr>


nnoremap <leader>fs <cmd>Telescope lsp_document_symbols<cr>
nnoremap <leader>fS <cmd>Telescope lsp_dynamic_workspace_symbols<cr>
nnoremap <leader>fr <cmd>Telescope lsp_references<cr>
nnoremap <leader>fr <cmd>Telescope lsp_references<cr>

nnoremap <leader>fgs <cmd>Telescope git_status<cr>
nnoremap <leader>fgl <cmd>Telescope git_commits<cr>
nnoremap <leader>fgb <cmd>Telescope git_bcommits<cr>

nnoremap <leader>fol <cmd>Telescope oldfiles<cr>
nnoremap <leader>fqf <cmd>Telescope quickfix<cr>
