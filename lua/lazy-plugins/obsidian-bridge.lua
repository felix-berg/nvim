return {
  "oflisback/obsidian-bridge.nvim",
  config = function()
    require("obsidian-bridge").setup({
      scroll_sync = false,
    })
  end,
  event = {
    "BufReadPre *.md",
    "BufNewFile *.md",
  },
  lazy = true,
  dependencies = {
    "nvim-telescope/telescope.nvim",
    "nvim-lua/plenary.nvim"
  },
}
