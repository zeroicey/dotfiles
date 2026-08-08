local M = {}

local paste_commands = {
	p = true,
	P = true,
	gp = true,
	gP = true,
}

local function resolve_bufnr(bufnr)
	if not bufnr or bufnr == 0 then
		return vim.api.nvim_get_current_buf()
	end

	return bufnr
end

local function normalize_range(bufnr, range)
	if not range then
		return nil
	end

	local start_line = range.start_line or (range.start and range.start[1])
	local end_line = range.end_line or (range["end"] and range["end"][1])
	if not start_line or not end_line then
		return nil
	end

	start_line = math.floor(start_line)
	end_line = math.floor(end_line)
	if start_line > end_line then
		start_line, end_line = end_line, start_line
	end

	local line_count = vim.api.nvim_buf_line_count(bufnr)
	start_line = math.max(1, math.min(start_line, line_count))
	end_line = math.max(1, math.min(end_line, line_count))

	return {
		start_line = start_line,
		end_line = end_line,
	}
end

function M.range_from_marks(bufnr)
	bufnr = resolve_bufnr(bufnr)

	if not vim.api.nvim_buf_is_valid(bufnr) then
		return nil
	end

	local start_mark = vim.api.nvim_buf_get_mark(bufnr, "[")
	local end_mark = vim.api.nvim_buf_get_mark(bufnr, "]")
	if start_mark[1] == 0 or end_mark[1] == 0 then
		return nil
	end

	return normalize_range(bufnr, {
		start_line = start_mark[1],
		end_line = end_mark[1],
	})
end

function M.to_conform_range(bufnr, range)
	bufnr = resolve_bufnr(bufnr)
	range = normalize_range(bufnr, range)
	if not range then
		return nil
	end

	local line = vim.api.nvim_buf_get_lines(bufnr, range.end_line - 1, range.end_line, true)[1] or ""
	return {
		start = { range.start_line, 0 },
		["end"] = { range.end_line, #line },
	}
end

function M.reindent_range(bufnr, range)
	bufnr = resolve_bufnr(bufnr)

	if not vim.api.nvim_buf_is_valid(bufnr) or vim.api.nvim_get_current_buf() ~= bufnr then
		return false
	end

	range = normalize_range(bufnr, range)
	if not range then
		return false
	end

	local view = vim.fn.winsaveview()
	pcall(vim.cmd, "silent! undojoin")

	local ok, err = pcall(vim.cmd, string.format("silent keepjumps %d,%dnormal! ==", range.start_line, range.end_line))
	vim.fn.winrestview(view)

	if not ok then
		vim.notify(err, vim.log.levels.WARN)
		return false
	end

	return true
end

function M.fix_range(bufnr, range)
	bufnr = resolve_bufnr(bufnr)

	if not vim.api.nvim_buf_is_valid(bufnr) or vim.bo[bufnr].readonly or not vim.bo[bufnr].modifiable then
		return false
	end

	range = normalize_range(bufnr, range)
	if not range then
		return false
	end

	local ok, conform = pcall(require, "conform")
	if not ok then
		return M.reindent_range(bufnr, range)
	end

	local changedtick = vim.b[bufnr].changedtick
	local did_fallback = false

	local function fallback_if_unchanged()
		if did_fallback then
			return false
		end

		did_fallback = true

		if not vim.api.nvim_buf_is_valid(bufnr) or vim.api.nvim_get_current_buf() ~= bufnr then
			return false
		end

		if vim.b[bufnr].changedtick ~= changedtick then
			return false
		end

		return M.reindent_range(bufnr, range)
	end

	local attempted = conform.format({
		bufnr = bufnr,
		async = true,
		quiet = true,
		undojoin = true,
		lsp_format = "fallback",
		range = M.to_conform_range(bufnr, range),
	}, function(err, _did_edit)
		if err then
			vim.schedule(fallback_if_unchanged)
		end
	end)

	if not attempted then
		return fallback_if_unchanged()
	end

	return true
end

local function paste_keys(command)
	local count = vim.v.count > 0 and tostring(vim.v.count) or ""
	local register = vim.v.register
	if register and register ~= "" and register ~= '"' then
		return count .. '"' .. register .. command
	end

	return count .. command
end

function M.paste_then_fix(command)
	if not paste_commands[command] then
		return false
	end

	vim.cmd.normal({ bang = true, args = { paste_keys(command) } })

	local bufnr = vim.api.nvim_get_current_buf()
	return M.fix_range(bufnr, M.range_from_marks(bufnr))
end

return M
