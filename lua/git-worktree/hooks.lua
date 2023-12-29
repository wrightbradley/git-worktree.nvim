-- local Enum = require("git-worktree.enum")
-- local Status = require("git-worktree.status")
-- local status = Status:new()

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
    SWITCH = 'SWITCH',
}

-- function M.on_tree_change_handler(op, metadata)
--     if M._config.update_on_change then
--         if op == Enum.Operations.Switch then
--             local changed = M.update_current_buffer(metadata["prev_path"])
--             if not changed then
--                 status
--                     :log()
--                     .debug("Could not change to the file in the new worktree,
--                          running the `update_on_change_command`")
--                 vim.cmd(M._config.update_on_change_command)
--             end
--         end
--     end
-- end

-- function M.emit_on_change(op, metadata)
--     -- TODO: We don't have a way to async update what is running
--     status:next_status(string.format("Running post %s callbacks", op))
--     print(metadata)
--     -- on_tree_change_handler(op, metadata)
--     -- for idx = 1, #on_change_callbacks do
--     --     on_change_callbacks[idx](op, metadata)
--     -- end
-- end

return M
