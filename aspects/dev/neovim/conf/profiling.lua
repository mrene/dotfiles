require("which-key").add({
	{ "<leader>P", group = "Profiler" },
})

local Snacks = require("snacks")
Snacks.toggle.profiler():map("<leader>Pt") -- toggle profiler
Snacks.toggle.profiler_highlights():map("<leader>Ph") -- toggle highlights
