local M = {}

local function construct_window_opts(surrounding_window_id)
    local surrounding_width = vim.api.nvim_win_get_width(surrounding_window_id)
    local surrounding_height = vim.api.nvim_win_get_height(surrounding_window_id)
    local surrounding_top, surrounding_left = unpack(vim.api.nvim_win_get_position(surrounding_window_id))

    local width = (surrounding_width > 20) and (surrounding_width - 6) or surrounding_width
    local height = (surrounding_height > 10) and (surrounding_height - 4) or surrounding_height

    local top = surrounding_top + math.floor((surrounding_height - height) / 2)
    local left = surrounding_left + math.floor((surrounding_width - width) / 2)

    return {
        relative = "editor",
        row = top,
        col = left,
        width = width,
        height = height,
        border = "rounded",
    }
end

local function float(bufnr)
    local surrounding_window_id = vim.api.nvim_get_current_win()
    local window_opts = construct_window_opts(0)
    local window_id = vim.api.nvim_open_win(bufnr, true, window_opts)
    local augroup_id = vim.api.nvim_create_augroup("detour-"..window_id, {})
    vim.api.nvim_create_autocmd({"WinResized"}, {
        group = augroup_id,
        callback = function (e)
            for x, _ in ipairs(vim.v.event.windows) do
                if vim.fn.win_getid(x) == surrounding_window_id then
                    local new_window_opts = construct_window_opts(surrounding_window_id)
                    vim.api.nvim_win_set_config(window_id, new_window_opts)
                end
            end
        end
    })
    vim.api.nvim_create_autocmd({"WinClosed"}, {
        group = augroup_id,
        pattern = "" .. surrounding_window_id .. "," .. window_id,
        callback = function (e)
            vim.api.nvim_del_augroup_by_id(augroup_id)
            vim.api.nvim_win_close(window_id, false)
        end
    })
end

M.FloatWin = function ()
    float(vim.api.nvim_get_current_buf())
end

return M