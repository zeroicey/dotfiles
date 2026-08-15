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

-- auto-reload files changed on disk (e.g. by external AI tools)
vim.o.autoread = true
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
  callback = function()
    pcall(vim.cmd.checktime)
  end,
})

local check_timer = vim.uv.new_timer()
check_timer:start(1000, 1500, vim.schedule_wrap(function()
  pcall(vim.cmd.checktime)
end))
