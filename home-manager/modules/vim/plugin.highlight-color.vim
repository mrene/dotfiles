lua <<END
local highlight_colors = require('nvim-highlight-colors');
highlight_colors.setup {
    enable_named_colors = false,
}
highlight_colors.turnOn()
END