local root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h")
package.path = root .. "/lua/?.lua;" .. root .. "/lua/?/init.lua;" .. package.path

local function assert_equal(actual, expected, message)
	if not vim.deep_equal(actual, expected) then
		error(string.format("%s\nexpected: %s\nactual:   %s", message, vim.inspect(expected), vim.inspect(actual)))
	end
end

local function assert_lines(expected, message)
	local actual = vim.api.nvim_buf_get_lines(0, 0, -1, false)
	assert_equal(actual, expected, message)
end

local function new_buffer(lines)
	local bufnr = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_set_current_buf(bufnr)
	vim.bo[bufnr].expandtab = true
	vim.bo[bufnr].shiftwidth = 4
	vim.bo[bufnr].indentexpr = "v:lua.PasteFixIndentExpr()"
	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
	return bufnr
end

function _G.PasteFixIndentExpr()
	if vim.v.lnum == 1 then
		return 0
	end

	return 4
end

package.loaded.conform = {
	format = function(_, _)
		return false
	end,
}

local paste = require("core.paste")

new_buffer({
	"root",
	"child",
	"  grandchild",
})

local fixed = paste.fix_range(0, {
	start_line = 2,
	end_line = 3,
})

assert_equal(fixed, true, "fix_range should report that native indent fallback ran")
assert_lines({
	"root",
	"    child",
	"    grandchild",
}, "fix_range should reindent the requested pasted range when Conform does not run")

new_buffer({
	"root",
	"tail",
})

vim.fn.setreg('"', "child\n  grandchild\n", "l")
vim.api.nvim_win_set_cursor(0, { 1, 0 })

local pasted = paste.paste_then_fix("p")

assert_equal(pasted, true, "paste_then_fix should report that the pasted range was handled")
assert_lines({
	"root",
	"    child",
	"    grandchild",
	"tail",
}, "paste_then_fix should reindent the lines inserted by p")

package.loaded.conform = {
	format = function(_, callback)
		callback("formatter failed", false)
		return true
	end,
}

new_buffer({
	"root",
	"child",
	"  grandchild",
})

local attempted = paste.fix_range(0, {
	start_line = 2,
	end_line = 3,
})

assert_equal(attempted, true, "fix_range should report that Conform was attempted before fallback")

local fallback_ran = vim.wait(100, function()
	local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
	return vim.deep_equal(lines, {
		"root",
		"    child",
		"    grandchild",
	})
end)

assert_equal(fallback_ran, true, "fix_range should reindent when Conform returns an error")

print("paste_fix_spec: ok")
