return {
  "oflisback/obsidian-bridge.nvim",
  dependencies = { "nvim-telescope/telescope.nvim" },
  config = function()
    require("obsidian-bridge").setup({
      scroll_sync = true,
    })
  end,
  event = {
    "BufReadPre *.md",
    "BufNewFile *.md",
  },
  lazy = true,
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
}
