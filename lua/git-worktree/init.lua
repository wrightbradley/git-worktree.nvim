local Config = require('git-worktree.config')
local Hooks = require('git-worktree.hooks')
local Worktree = require('git-worktree.worktree')

--- @class GitWorktree
--- @field config GitWorktreeConfig
--- @field _hooks GitWorktreeHooks

local M = {}
M.__index = M

function M:new()
    local config = Config._get_defaults()
    local obj = setmetatable({
        config = config,
        _hooks = Hooks.hooks,
    }, self)
    return obj
end

local current = M:new()

---@param self GitWorktree
--- @param opts table<string, any>
function M.setup(self, opts)
    if self ~= current then
        self = current
    end
    self.config = Config.setup(opts)
    return self
end

---@param hook GitWorkTreeHook
function M:hooks(hook)
    self._hooks:add_listener(hook)
end

--Switch the current worktree
---@param path string
-- luacheck:ignore self
function M:switch_worktree(path)
    Worktree.switch(path)
end

--Create a worktree
---@param path string
---@param branch string
---@param upstream? string
-- luacheck:ignore self
function M:create_worktree(path, branch, upstream)
    Worktree.create(path, branch, upstream)
end

--Delete a worktree
---@param path string
---@param force boolean
---@param opts any
function M:delete_worktree(path, force, opts)
    Worktree.delete(path, force, opts)
end

return current
