require "nvchad.autocmds"

-- auto-open file tree when nvim is launched with a directory argument
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    local args = vim.fn.argv()
    if #args > 0 and vim.fn.isdirectory(args[1]) == 1 then
      vim.schedule(function()
        require("nvim-tree.api").tree.open()
      end)
    end
  end,
})
