-- System clipboard over SSH: OSC 52 for writing, local cache for reading.
--
-- Why this file exists (measured on hpcore, 2026-10-13):
-- NvChad sets `clipboard = unnamedplus`, so yanks go to the "+" register. On a
-- headless host there is no local clipboard tool (no pbcopy/xclip/wl-copy), so
-- Nvim finds no provider at all and every yank errors with
-- "clipboard: No provider. Try ":checkhealth"".
--
-- Nvim bundles an OSC 52 provider that works over SSH (the terminal writes to
-- the real clipboard), but its auto-detection only runs when 'clipboard' is
-- empty -- runtime/autoload/provider/clipboard.vim: `... && &clipboard ==# ''`
-- -- which `unnamedplus` turns off. So we opt in explicitly.
--
-- The *read* direction is a dead end here: Nvim's bundled OSC 52 paste sends
-- `OSC 52 ; c ; ?` and blocks 10s for an answer. Measured through this host's
-- stack (ssh -> herdr 0.8.2 -> Ghostty on macOS) the answer never arrives (raw
-- query on the pane's tty: 12s timeout, 0 bytes, twice), so every `"+p` / fresh
-- `p` froze for 10s and then pasted a stale value. So: copy goes out via OSC 52,
-- paste reads the last yank/delete Nvim itself sent (same content the built-in
-- cache would have produced, minus the 10s wait). Pastes *from* the host
-- clipboard use the terminal's own paste (Cmd+V).
--
-- Hosts with a real clipboard tool, and tmux (whose provider is synchronous in
-- both directions), keep Nvim's own detection and never reach this code.

if vim.g.clipboard ~= nil or vim.fn.has "nvim-0.11" ~= 1 then
  return
end

local env, exe = vim.env, vim.fn.executable
local has_local_tool = vim.fn.has "mac" == 1
  or ((env.WAYLAND_DISPLAY or "") ~= "" and exe "wl-copy" == 1)
  or ((env.DISPLAY or "") ~= "" and (exe "xclip" == 1 or exe "xsel" == 1))
  or exe "lemonade" == 1
  or exe "doitclient" == 1
  or exe "win32yank.exe" == 1
  or (exe "putclip" == 1 and exe "getclip" == 1)
  or (exe "clip" == 1 and exe "powershell" == 1)
  or exe "termux-clipboard-set" == 1
  or ((env.TMUX or "") ~= "" and exe "tmux" == 1)

if has_local_tool then
  return
end

-- Mirror of the last yank/delete/change, i.e. what the unnamed register holds.
-- TextYankPost fires for `y`, `d` and `c`, so this tracks `p` after `dd` too.
local last = { {}, "v" }
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    local ev = vim.v.event
    if type(ev.regcontents) == "table" and #ev.regcontents > 0 then
      last = { ev.regcontents, (ev.regtype ~= "" and ev.regtype) or "v" }
    end
  end,
})

local osc52 = require "vim.ui.clipboard.osc52"

vim.g.clipboard = {
  name = "OSC 52 (copy) + local paste",
  copy = { ["+"] = osc52.copy "+", ["*"] = osc52.copy "*" },
  paste = {
    ["+"] = function()
      return { last[1], last[2] }
    end,
    ["*"] = function()
      return { last[1], last[2] }
    end,
  },
}
