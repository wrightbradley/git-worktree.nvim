local Path = require('plenary.path')

local Config = require('git-worktree.config')
local Git = require('git-worktree.git')
local Hooks = require('git-worktree.hooks')
local Log = require('git-worktree.logger')

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

local function get_absolute_path(path)
    if Path:new(path):is_absolute() then
        return path
    else
        return Path:new(vim.loop.cwd(), path):absolute()
    end
end

local function change_dirs(path)
    Log.info('changing dirs:  %s ', path)
    local worktree_path = get_absolute_path(path)
    local previous_worktree = vim.loop.cwd()

    -- vim.loop.chdir(worktree_path)
    if Path:new(worktree_path):exists() then
        local cmd = string.format('%s %s', current.config.change_directory_command, worktree_path)
        Log.debug('Changing to directory  %s', worktree_path)
        vim.cmd(cmd)
    else
        Log.error('Could not chang to directory: %s', worktree_path)
    end

    if current.config.clearjumps_on_change then
        Log.debug('Clearing jumps')
        vim.cmd('clearjumps')
    end

    return previous_worktree
end

---@param hook GitWorkTreeHook
function M:hooks(hook)
    self._hooks:add_listener(hook)
end

--Switch the current worktree
---@param path string
function M:switch_worktree(path)
    -- status:reset(2)
    -- status:status(path)
    local cur_hooks = self._hooks
    Git.has_worktree(path, function(found)
        if not found then
            Log.error('worktree does not exists, please create it first %s ', path)
        end

        vim.schedule(function()
            local prev_path = change_dirs(path)
            -- change_dirs(path)
            Log.info('emiting hooks')
            print(vim.inspect(current._hooks))
            cur_hooks:emit(Hooks.hook_event_names.SWITCH, path, prev_path)
        end)
    end)
end
--
-- local function create_worktree_job(path, branch, found_branch)
--     local worktree_add_cmd = "git"
--     local worktree_add_args = { "worktree", "add" }
--
--     if not found_branch then
--         table.insert(worktree_add_args, "-b")
--         table.insert(worktree_add_args, branch)
--         table.insert(worktree_add_args, path)
--     else
--         table.insert(worktree_add_args, path)
--         table.insert(worktree_add_args, branch)
--     end
--
--     return Job:new({
--         command = worktree_add_cmd,
--         args = worktree_add_args,
--         cwd = git_worktree_root,
--         on_start = function()
--             status:next_status(worktree_add_cmd .. " " .. table.concat(worktree_add_args, " "))
--         end,
--     })
-- end
--
--
-- local function failure(from, cmd, path, soft_error)
--     return function(e)
--         local error_message = string.format(
--             "%s Failed: PATH %s CMD %s RES %s, ERR %s",
--             from,
--             path,
--             vim.inspect(cmd),
--             vim.inspect(e:result()),
--             vim.inspect(e:stderr_result())
--         )
--
--         if soft_error then
--             status:status(error_message)
--         else
--             status:error(error_message)
--         end
--     end
-- end
--
-- local function create_worktree(path, branch, upstream, found_branch)
--     local create = create_worktree_job(path, branch, found_branch)
--
--     local worktree_path
--     if Path:new(path):is_absolute() then
--         worktree_path = path
--     else
--         worktree_path = Path:new(git_worktree_root, path):absolute()
--     end
--
--     local fetch = Job:new({
--         "git",
--         "fetch",
--         "--all",
--         cwd = worktree_path,
--         on_start = function()
--             status:next_status("git fetch --all (This may take a moment)")
--         end,
--     })
--
--     local set_branch_cmd = "git"
--     local set_branch_args = { "branch", string.format("--set-upstream-to=%s/%s", upstream, branch) }
--     local set_branch = Job:new({
--         command = set_branch_cmd,
--         args = set_branch_args,
--         cwd = worktree_path,
--         on_start = function()
--             status:next_status(set_branch_cmd .. " " .. table.concat(set_branch_args, " "))
--         end,
--     })
--
--     -- TODO: How to configure origin???  Should upstream ever be the push
--     -- destination?
--     local set_push_cmd = "git"
--     local set_push_args = { "push", "--set-upstream", upstream, branch, path }
--     local set_push = Job:new({
--         command = set_push_cmd,
--         args = set_push_args,
--         cwd = worktree_path,
--         on_start = function()
--             status:next_status(set_push_cmd .. " " .. table.concat(set_push_args, " "))
--         end,
--     })
--
--     local rebase = Job:new({
--         "git",
--         "rebase",
--         cwd = worktree_path,
--         on_start = function()
--             status:next_status("git rebase")
--         end,
--     })
--
--     if upstream ~= nil then
--         create:and_then_on_success(fetch)
--         fetch:and_then_on_success(set_branch)
--
--         if M._config.autopush then
--             -- These are "optional" operations.
--             -- We have to figure out how we want to handle these...
--             set_branch:and_then(set_push)
--             set_push:and_then(rebase)
--             set_push:after_failure(failure("create_worktree", set_branch.args, worktree_path, true))
--         else
--             set_branch:and_then(rebase)
--         end
--
--         create:after_failure(failure("create_worktree", create.args, git_worktree_root))
--         fetch:after_failure(failure("create_worktree", fetch.args, worktree_path))
--
--         set_branch:after_failure(failure("create_worktree", set_branch.args, worktree_path, true))
--
--         rebase:after(function()
--             if rebase.code ~= 0 then
--                 status:status("Rebase failed, but that's ok.")
--             end
--
--             vim.schedule(function()
--                 Hooks.emit_on_change(Enum.Operations.Create, { path = path, branch = branch, upstream = upstream })
--                 M.switch_worktree(path)
--             end)
--         end)
--     else
--         create:after(function()
--             vim.schedule(function()
--                 Hooks.emit_on_change(Enum.Operations.Create, { path = path, branch = branch, upstream = upstream })
--                 M.switch_worktree(path)
--             end)
--         end)
--     end
--
--     create:start()
-- end
--
-- M.create_worktree = function(path, branch, upstream)
--     status:reset(8)
--
--     if upstream == nil then
--         if Git.has_origin() then
--             upstream = "origin"
--         end
--     end
--
--     M.setup_git_info()
--
--     has_worktree(path, function(found)
--         if found then
--             status:error("worktree already exists")
--         end
--
--         Git.has_branch(branch, function(found_branch)
--             create_worktree(path, branch, upstream, found_branch)
--         end)
--     end)
-- end
--

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
--
-- M.set_worktree_root = function(wd)
--     git_worktree_root = wd
-- end
--
-- M.set_current_worktree_path = function(wd)
--     current_worktree_path = wd
-- end
--
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
--
--
-- M.reset = function()
--     on_change_callbacks = {}
-- end
--
-- M.get_root = function()
--     return git_worktree_root
-- end
--
-- M.get_current_worktree_path = function()
--     return current_worktree_path
-- end
--
--
-- M.setup = function(config)
--     config = config or {}
--     M._config = vim.tbl_deep_extend("force", {
--         change_directory_command = "cd",
--         update_on_change = true,
--         update_on_change_command = "e .",
--         clearjumps_on_change = true,
--         -- default to false to avoid breaking the previous default behavior
--         confirm_telescope_deletions = false,
--         -- should this default to true or false?
--         autopush = false,
--     }, config)
-- end
--
-- M.setup()
-- --M.Operations = Enum.Operations

return current
