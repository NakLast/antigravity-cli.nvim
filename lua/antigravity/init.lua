local M = {}

M.config = {
	cmd = "antigravity-cli",
	width_ratio = 0.8,
	height_ratio = 0.8,
	border = "rounded",
	style = "vsplit",
}

local state = {
	buf = -1,
	win = -1,
}

function M.setup(opts)
	opts = opts or {}
	M.config = vim.tbl_deep_extend("force", M.config, opts)
end

local function create_window()
	local buf = -1
	if vim.api.nvim_buf_is_valid(state.buf) then
		buf = state.buf
	else
		buf = vim.api.nvim_create_buf(false, true)
	end

	local win
	if M.config.style == "vsplit" then
		local width = math.floor(vim.o.columns * (M.config.width_ratio or 0.5))
		vim.cmd("topleft vsplit")
		win = vim.api.nvim_get_current_win()
		vim.api.nvim_win_set_buf(win, buf)
		vim.api.nvim_win_set_width(win, width)
	elseif M.config.style == "split" then
		local height = math.floor(vim.o.lines * (M.config.height_ratio or 0.3))
		vim.cmd("split")
		win = vim.api.nvim_get_current_win()
		vim.api.nvim_win_set_buf(win, buf)
		vim.api.nvim_win_set_height(win, height)
	else
		local width = math.floor(vim.o.columns * M.config.width_ratio)
		local height = math.floor(vim.o.lines * M.config.height_ratio)

		local col = math.floor((vim.o.columns - width) / 2)
		local row = math.floor((vim.o.lines - height) / 2)

		local win_opts = {
			style = "minimal",
			relative = "editor",
			width = width,
			height = height,
			row = row,
			col = col,
			border = M.config.border,
		}

		win = vim.api.nvim_open_win(buf, true, win_opts)
	end

	return { buf = buf, win = win }
end

function M.toggle()
	if vim.api.nvim_win_is_valid(state.win) then
		vim.api.nvim_win_hide(state.win)
		state.win = -1
	else
		local win_info = create_window()
		state.win = win_info.win
		state.buf = win_info.buf

		if vim.bo[state.buf].buftype ~= "terminal" then
			vim.cmd("term " .. M.config.cmd)
			vim.cmd("startinsert")
		else
			vim.cmd("startinsert")
		end
	end
end

function M.ask_selection()
	local mode = vim.fn.mode()
	local start_line, end_line
	if mode == "v" or mode == "V" or mode == "\22" then
		start_line = vim.fn.line("v")
		end_line = vim.fn.line(".")
		if start_line > end_line then
			start_line, end_line = end_line, start_line
		end
		-- Exit visual mode cleanly
		vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "x", true)
	else
		start_line = vim.fn.line("'<")
		end_line = vim.fn.line("'>")
		if start_line == 0 or end_line == 0 then
			start_line = vim.fn.line(".")
			end_line = start_line
		end
	end

	local bufname = vim.api.nvim_buf_get_name(0)
	local identifier = bufname ~= "" and vim.fn.fnamemodify(bufname, ":.") or "unnamed"

	local text
	if start_line == end_line then
		text = string.format("@%s lines:[%d]", identifier, start_line)
	else
		text = string.format("@%s lines:[%d-%d]", identifier, start_line, end_line)
	end

	if not vim.api.nvim_win_is_valid(state.win) then
		M.toggle()
	else
		vim.api.nvim_set_current_win(state.win)
	end

	local chan = vim.bo[state.buf].channel
	if chan ~= 0 then
		-- Send the selected file path and line range reference
		vim.api.nvim_chan_send(chan, text .. "\n")
	end
	vim.cmd("startinsert")
end

return M
