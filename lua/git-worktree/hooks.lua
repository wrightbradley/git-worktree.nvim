local Path = require('plenary.path')

--- @class GitWorkTreeHook
--- @field SWITCH? fun(...): nil
--- @field CREATE? fun(...): nil
--- @field DELETE? fun(...): nil

local M = {}

local Hooks = {}

Hooks.__index = Hooks

function Hooks:new()
    return setmetatable({
        hooks = {},
    }, self)
end

---@param hook GitWorktreeHook
function Hooks:add_listener(hook)
    table.insert(self.hooks, hook)
end

function M:clear_listeners()
    self.hooks = {}
end

---@param type string
---@param ... any
function Hooks:emit(type, ...)
    print('emitting')
    for _, cb in ipairs(self.hooks) do
        print(type)
        if cb[type] then
            print(vim.inspect(cb))
            cb[type](...)
        end
    end
end

local builtins = {}

builtins.update_current_buffer_on_switch = function(_, prev_path)
    if prev_path == nil then
        local config = require('git-worktree.config').get()
        vim.cmd(config.update_on_change_command)
    end

    local cwd = vim.loop.cwd()
    local current_buf_name = vim.api.nvim_buf_get_name(0)
    if not current_buf_name or current_buf_name == '' then
        local config = require('git-worktree.config').get()
        vim.cmd(config.update_on_change_command)
    end

    local name = Path:new(current_buf_name):absolute()
    local start1, _ = string.find(name, cwd .. Path.path.sep, 1, true)
    if start1 ~= nil then
        return
    end

    local start, fin = string.find(name, prev_path, 1, true)
    if start == nil then
        local config = require('git-worktree.config').get()
        vim.cmd(config.update_on_change_command)
    end

    local local_name = name:sub(fin + 2)

    local final_path = Path:new({ cwd, local_name }):absolute()

    if not Path:new(final_path):exists() then
        local config = require('git-worktree.config').get()
        vim.cmd(config.update_on_change_command)
    end

    local bufnr = vim.fn.bufnr(final_path, true)
    vim.api.nvim_set_current_buf(bufnr)
end

M.hooks = Hooks:new()

M.builtins = builtins

M.hook_event_names = {
    CREATE = 'CREATE',
    DELETE = 'DELETE',
    SWITCH = 'SWITCH',
}

return M
