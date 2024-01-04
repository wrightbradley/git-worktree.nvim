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

local M = {}

M.hooks = GitWorktreeHooks:new()

M.hook_event_names = {
    CREATE = 'CREATE',
    DELETE = 'DELETE',
    SWITCH = 'SWITCH',
}

return M
