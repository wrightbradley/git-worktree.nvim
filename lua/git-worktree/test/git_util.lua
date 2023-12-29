local system = require('git-worktree.test.system_util')

-- local change_dir = function(dir)
--     vim.api.nvim_set_current_dir(dir)
-- end

local create_worktree = function(folder_path, commitish)
    system.run('git worktree add ' .. folder_path .. ' ' .. commitish)
end

local project_dir = vim.api.nvim_exec('pwd', true)
local reset_cwd = function()
    vim.cmd('cd ' .. project_dir)
    vim.api.nvim_set_current_dir(project_dir)
end

local M = {}

local origin_repo_path = nil

function M.setup_origin_repo()
    if origin_repo_path ~= nil then
        return origin_repo_path
    end

    local workspace_dir = system.create_temp_dir('workspace-dir')
    vim.api.nvim_set_current_dir(vim.fn.getcwd())
    system.run('cp -r test/fixtures/.repo ' .. workspace_dir)
    vim.api.nvim_set_current_dir(workspace_dir)
    system.run([[
        mv .repo/.git-orig ./.git
        mv .repo/* .
        git config user.email "test@test.test"
        git config user.name "Test User"
    ]])

    origin_repo_path = system.create_temp_dir('origin-repo')
    system.run(string.format('git clone --bare %s %s', workspace_dir, origin_repo_path))

    return origin_repo_path
end

function M.prepare_repo()
    M.setup_origin_repo()

    local working_dir = system.create_temp_dir('working-dir')
    vim.api.nvim_set_current_dir(working_dir)
    system.run(string.format('git clone %s %s', origin_repo_path, working_dir))
    system.run([[
        git config remote.origin.url git@github.com:test/test.git
        git config user.email "test@test.test"
        git config user.name "Test User"
    ]])
    return working_dir
end

function M.prepare_repo_bare()
    M.setup_origin_repo()

    local working_dir = system.create_temp_dir('working-bare-dir')
    vim.api.nvim_set_current_dir(working_dir)
    system.run(string.format('git clone --bare %s %s', origin_repo_path, working_dir))
    return working_dir
end

function M.prepare_repo_worktree()
    reset_cwd()
    M.setup_origin_repo()

    local working_dir = system.create_temp_dir('working-worktree-dir')
    vim.api.nvim_set_current_dir(working_dir)
    system.run(string.format('git clone --bare %s %s', origin_repo_path, working_dir))
    create_worktree('master', 'master')
    create_worktree('featB', 'featB')
    local worktree_dir = working_dir .. '/master'
    vim.api.nvim_set_current_dir(worktree_dir)
    return working_dir, worktree_dir
end

return M
