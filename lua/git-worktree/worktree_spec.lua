local git_harness = require('git-worktree.test.git_util')
local git_worktree = require('git-worktree')
local Path = require('plenary.path')
-- local Status = require('git-worktree.status')

-- local status = Status:new()

local cwd = vim.fn.getcwd()

-- luacheck: globals repo_dir
describe('[Worktree]', function()
    local completed_create = false
    local completed_switch = false
    -- local completed_delete = false

    local reset_variables = function()
        completed_create = false
        completed_switch = false
        -- completed_delete = false
    end

    before_each(function()
        reset_variables()
        git_worktree = require('git-worktree')
        git_worktree:setup {}
        git_worktree:hooks {
            CREATE = function()
                print('called create')
                completed_create = true
            end,
            -- DELETE = function()
            --     completed_delete = true
            -- end,
            SWITCH = function()
                completed_switch = true
            end,
        }
    end)

    after_each(function()
        -- git_worktree.reset()
        vim.api.nvim_command('cd ' .. cwd)
    end)

    -- luacheck: globals working_dir master_dir
    describe('[Switch]', function()
        describe('[bare repo]', function()
            before_each(function()
                working_dir, master_dir = git_harness.prepare_repo_bare_worktree(2)
            end)
            it('able to switch to worktree (relative path)', function()
                local wt = 'featB'
                local path = '../' .. wt
                git_worktree:switch_worktree(path)
                --
                vim.fn.wait(10000, function()
                    return completed_switch
                end, 1000)
                --
                --     -- Check to make sure directory was switched
                assert.is_true(completed_switch)
                assert.are.same(working_dir .. Path.path.sep .. wt, vim.loop.cwd())
            end)
        end)
        describe('[normal repo]', function()
            before_each(function()
                working_dir, master_dir = git_harness.prepare_repo_normal_worktree(1)
            end)
            it('able to switch to worktree (relative path)', function()
                local wt = 'featB'
                local path = '../' .. wt
                git_worktree:switch_worktree(path)
                --
                vim.fn.wait(10000, function()
                    return completed_switch
                end, 1000)
                --
                --     -- Check to make sure directory was switched
                assert.is_true(completed_switch)
                assert.are.same(working_dir .. Path.path.sep .. wt, vim.loop.cwd())
            end)
        end)
    end)
    -- luacheck: globals working_dir master_dir
    describe('[CREATE]', function()
        describe('[bare repo]', function()
            before_each(function()
                working_dir, master_dir = git_harness.prepare_repo_bare_worktree(1)
            end)
            it('able to create a worktree (relative path)', function()
                local wt = 'featB'
                local path = '../' .. wt
                git_worktree:create_worktree(path, wt)
                --
                vim.fn.wait(10000, function()
                    -- need to wait for final switch
                    return completed_switch
                end, 1000)
                --
                --     -- Check to make sure directory was switched
                assert.is_true(completed_create)
                assert.is_true(completed_switch)
                assert.are.same(working_dir .. Path.path.sep .. wt, vim.loop.cwd())
            end)
        end)
        describe('[normal repo]', function()
            before_each(function()
                working_dir, master_dir = git_harness.prepare_repo_normal_worktree(0)
            end)
            it('able to create a worktree (relative path)', function()
                local wt = 'featB'
                local path = '../' .. wt
                git_worktree:create_worktree(path, wt)
                --
                vim.fn.wait(10000, function()
                    return completed_switch
                end, 1000)
                --
                --     -- Check to make sure directory was switched
                assert.is_true(completed_create)
                assert.is_true(completed_switch)
                assert.are.same(working_dir .. Path.path.sep .. wt, vim.loop.cwd())
            end)
        end)
    end)
end)
