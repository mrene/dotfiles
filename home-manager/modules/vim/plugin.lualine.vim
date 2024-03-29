lua << END

local navic = require("nvim-navic")

local function navic_get_location()
    if navic.is_available() == true then
      return navic.get_location()
    end

    return ""
end

require('lualine').setup {
  options = {
    icons_enabled = true,
    theme = 'auto',
    component_separators = { left = '', right = ''},
    section_separators = { left = '', right = ''},
    disabled_filetypes = {
      statusline = {},
      winbar = {},
    },
    ignore_focus = {},
    always_divide_middle = true,
    globalstatus = false,
    refresh = {
      statusline = 1000,
      tabline = 1000,
      winbar = 1000,
    }
  },
  sections = {
    lualine_a = {'mode'},
    lualine_b = {'branch', 'diff', 'diagnostics'},
    lualine_c = {'filename', 'lsp_progress'}, 
    lualine_x = {'encoding', 'fileformat', 'filetype'},
    lualine_y = {'progress'},
    lualine_z = {'location'}
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = {'filename'},
    lualine_x = {'location'},
    lualine_y = {},
    lualine_z = {}
  },
  tabline = {
    lualine_a = {'buffers'},
  },
  winbar = {
    lualine_c = {
      { navic_get_location },
    },
    lualine_x = {
      {'filename', path = 3, icon_only = true, shortening_target = 0, file_status = false },
    },
  },
  inactive_winbar = {
    lualine_c = {
      { navic_get_location },
    },
    lualine_x = {
      {'filename', path = 3, icon_only = true, shortening_target = 0, file_status = false },
    },
  },
  extensions = { 'nerdtree', 'fugitive', 'fzf' }
}
END
