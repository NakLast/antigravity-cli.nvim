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
    local save_v = vim.fn.getreg('v')
    local save_v_type = vim.fn.getregtype('v')
    vim.cmd('normal! "vy')
    local text = vim.fn.getreg('v')
    vim.fn.setreg('v', save_v, save_v_type)
    
    if not vim.api.nvim_win_is_valid(state.win) then
        M.toggle()
    else
        vim.api.nvim_set_current_win(state.win)
    end
    
    local chan = vim.bo[state.buf].channel
    if chan ~= 0 then
        -- Send the selected text to the CLI input
        vim.api.nvim_chan_send(chan, text .. "\n")
    end
    vim.cmd("startinsert")
end

return M
