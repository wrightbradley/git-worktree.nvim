local Job = require('plenary').job
local Path = require('plenary.path')
-- local Status = require('git-worktree.status')
--
-- local status = Status:new()
--
---@class GitWorktreeGitOps
local M = {}

-- A lot of this could be cleaned up if there was better job -> job -> function
-- communication.  That should be doable here in the near future
---
---@param path_str string path to the worktree to check. if relative, then path from the git root dir
---@param cb any
function M.has_worktree(path_str, cb)
    local found = false
    local path = Path:new(path_str)
    local git_worktree_root = M.gitroot_dir()

    if path_str == '.' then
        path_str = vim.loop.cwd()
        path = Path:new(path_str)
    end

    local job = Job:new {
        'git',
        'worktree',
        'list',
        on_stdout = function(_, data)
            local list_data = {}
            for section in data:gmatch('%S+') do
                table.insert(list_data, section)
            end
            print(vim.inspect(list_data))

            data = list_data[1]

            local start
            if path:is_absolute() then
                start = data == path_str
            else
                local worktree_path =
                    Path:new(string.format('%s' .. Path.path.sep .. '%s', git_worktree_root, path_str))
                worktree_path = worktree_path:absolute()
                start = data == worktree_path
            end

            -- TODO: This is clearly a hack (do not think we need this anymore?)
            --local start_with_head = string.find(data, string.format('[heads/%s]', path), 1, true)
            found = found or start
        end,
        cwd = vim.loop.cwd(),
    }

    job:after(function()
        cb(found)
    end)

    -- TODO: I really don't want status's spread everywhere... seems bad
    --status:next_status('Checking for worktree ' .. path)
    job:start()
end

-- --- @return boolean
-- function M.is_bare_repo()
--     local inside_worktree_job = Job:new({
--         "git",
--         "rev-parse",
--         "--is-bare-repository",
--         cwd = vim.loop.cwd(),
--     })
--
--     local stdout, code = inside_worktree_job:sync()
--     if code ~= 0 then
--         status:log().error("Error in determining if we are in a worktree")
--         return false
--     end
--
--     stdout = table.concat(stdout, "")
--
--     if stdout == "true" then
--         return true
--     else
--         return false
--     end
-- end
--
-- --- @return boolean
-- function M.is_worktree()
--     local inside_worktree_job = Job:new({
--         "git",
--         "rev-parse",
--         "--is-inside-work-tree",
--         cwd = vim.loop.cwd(),
--     })
--
--     local stdout, code = inside_worktree_job:sync()
--     if code ~= 0 then
--         status:log().error("Error in determining if we are in a worktree")
--         return false
--     end
--
--     stdout = table.concat(stdout, "")
--
--     if stdout == "true" then
--         return true
--     else
--         return false
--     end
-- end

--- @return string|nil
function M.gitroot_dir()
    local job = Job:new {
        'git',
        'rev-parse',
        '--path-format=absolute',
        '--git-common-dir',
        cwd = vim.loop.cwd(),
        -- on_stderr = function(_, data)
        --     status:log().info('ERROR: ' .. data)
        -- end,
    }

    local stdout, code = job:sync()
    if code ~= 0 then
        -- status:log().error(
        --     'Error in determining the git root dir: code:'
        --         .. tostring(code)
        --         .. ' out: '
        --         .. table.concat(stdout, '')
        --         .. '.'
        -- )
        return nil
    end

    return table.concat(stdout, '')
end

-- @param is_worktree boolean
--- @return string|nil
function M.toplevel_dir()
    local job = Job:new {
        'git',
        'rev-parse',
        '--path-format=absolute',
        '--show-toplevel',
        cwd = vim.loop.cwd(),
        -- on_stderr = function(_, data)
        --     status:log().info('ERROR: ' .. data)
        -- end,
    }

    local stdout, code = job:sync()
    if code ~= 0 then
        -- status:log().error(
        --     'Error in determining the git root dir: code:'
        --         .. tostring(code)
        --         .. ' out: '
        --         .. table.concat(stdout, '')
        --         .. '.'
        -- )
        return nil
    end

    return table.concat(stdout, '')
end

-- --- @return string|nil
-- function M.find_git_toplevel()
--     local find_toplevel_job = Job:new({
--         "git",
--         "rev-parse",
--         "--show-toplevel",
--         cwd = vim.loop.cwd(),
--     })
--     local stdout, code = find_toplevel_job:sync()
--     if code == 0 then
--         stdout = table.concat(stdout, "")
--         return stdout
--     else
--         return nil
--     end
-- end
--
-- function M.has_branch(branch, cb)
--     local found = false
--     local job = Job:new({
--         "git",
--         "branch",
--         on_stdout = function(_, data)
--             -- remove  markere on current branch
--             data = data:gsub("*", "")
--             data = vim.trim(data)
--             found = found or data == branch
--         end,
--         cwd = vim.loop.cwd(),
--     })
--
--     -- TODO: I really don't want status's spread everywhere... seems bad
--     status:next_status(string.format("Checking for branch %s", branch))
--     job:after(function()
--         status:status("found branch: " .. tostring(found))
--         cb(found)
--     end):start()
-- end
--
-- function M.has_origin()
--     local found = false
--     local job = Job:new({
--         "git",
--         "remote",
--         "show",
--         on_stdout = function(_, data)
--             data = vim.trim(data)
--             found = found or data == "origin"
--         end,
--         cwd = vim.loop.cwd(),
--     })
--
--     -- TODO: I really don't want status's spread everywhere... seems bad
--     job:after(function()
--         status:status("found origin: " .. tostring(found))
--     end):sync()
--
--     return found
-- end
--
return M
