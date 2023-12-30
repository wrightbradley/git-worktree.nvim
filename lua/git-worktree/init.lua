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

--Create a  worktree
---@param path string
---@param branch string
---@param upstream? string
-- luacheck:ignore self
function M:create_worktree(path, branch, upstream)
    Worktree.create(path, branch, upstream)
end

--
-- M.delete_worktree = function(path, force, opts)
--     if not opts then
--         opts = {}
--     end
--
--     status:reset(2)
--     M.setup_git_info()
--     has_worktree(path, function(found)
--         if not found then
--             status:error(string.format("Worktree %s does not exist", path))
--         end
--
--         local cmd = {
--             "git",
--             "worktree",
--             "remove",
--             path,
--         }
--
--         if force then
--             table.insert(cmd, "--force")
--         end
--
--         local delete = Job:new(cmd)
--         delete:after_success(vim.schedule_wrap(function()
--             Hooks.emit_on_change(Enum.Operations.Delete, { path = path })
--             if opts.on_success then
--                 opts.on_success()
--             end
--         end))
--
--         delete:after_failure(function(e)
--             -- callback has to be called before failure() because failure()
--             -- halts code execution
--             if opts.on_failure then
--                 opts.on_failure(e)
--             end
--
--             failure(cmd, vim.loop.cwd())(e)
--         end)
--         delete:start()
--     end)
-- end

-- M.update_current_buffer = function(prev_path)
--     if prev_path == nil then
--         return false
--     end
--
--     local cwd = vim.loop.cwd()
--     local current_buf_name = vim.api.nvim_buf_get_name(0)
--     if not current_buf_name or current_buf_name == "" then
--         return false
--     end
--
--     local name = Path:new(current_buf_name):absolute()
--     local start1, _ = string.find(name, cwd .. Path.path.sep, 1, true)
--     if start1 ~= nil then
--         return true
--     end
--
--     local start, fin = string.find(name, prev_path, 1, true)
--     if start == nil then
--         return false
--     end
--
--     local local_name = name:sub(fin + 2)
--
--     local final_path = Path:new({ cwd, local_name }):absolute()
--
--     if not Path:new(final_path):exists() then
--         return false
--     end
--
--     local bufnr = vim.fn.bufnr(final_path, true)
--     vim.api.nvim_set_current_buf(bufnr)
--     return true
-- end

return current
