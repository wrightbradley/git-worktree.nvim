local Path = require('plenary.path')

--- @class GitWorkTreeHook
--- @field SWITCH? fun(...): nil

--- @class GitWorktreeHooks
--- @field hooks GitWorktreeHook[]
local GitWorktreeHooks = {}

GitWorktreeHooks.__index = GitWorktreeHooks

function GitWorktreeHooks:new()
    return setmetatable({
        hooks = {},
    }, self)
end

---@param hook GitWorktreeHook
function GitWorktreeHooks:add_listener(hook)
    table.insert(self.hooks, hook)
end

function GitWorktreeHooks:clear_listener()
    self.hooks = {}
end

---@param type string
---@param ... any
function GitWorktreeHooks:emit(type, ...)
    for _, cb in ipairs(self.hooks) do
        print(type)
        if cb[type] then
            cb[type](...)
        end
    end
end

local builtins = {}

builtins.update_current_buffer_on_switch = function(_, prev_path)
    if prev_path == nil then
        local gwt = require('git-worktree')
        vim.cmd(gwt.config.update_on_change_command)
    end

    local cwd = vim.loop.cwd()
    local current_buf_name = vim.api.nvim_buf_get_name(0)
    if not current_buf_name or current_buf_name == '' then
        local gwt = require('git-worktree')
        vim.cmd(gwt.config.update_on_change_command)
    end

    local name = Path:new(current_buf_name):absolute()
    local start1, _ = string.find(name, cwd .. Path.path.sep, 1, true)
    if start1 ~= nil then
        return
    end

    local start, fin = string.find(name, prev_path, 1, true)
    if start == nil then
        local gwt = require('git-worktree')
        vim.cmd(gwt.config.update_on_change_command)
    end

    local local_name = name:sub(fin + 2)

    local final_path = Path:new({ cwd, local_name }):absolute()

    if not Path:new(final_path):exists() then
        local gwt = require('git-worktree')
        vim.cmd(gwt.config.update_on_change_command)
    end

    local bufnr = vim.fn.bufnr(final_path, true)
    vim.api.nvim_set_current_buf(bufnr)
end

local M = {}

M.builtins = builtins

M.hooks = GitWorktreeHooks:new()

M.hook_event_names = {
    CREATE = 'CREATE',
    DELETE = 'DELETE',
    SWITCH = 'SWITCH',
}

return M
