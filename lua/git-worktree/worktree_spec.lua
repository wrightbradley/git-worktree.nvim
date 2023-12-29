local git_harness = require('git-worktree.test.git_util')
local git_worktree = require('git-worktree')
local Path = require('plenary.path')
-- local Status = require('git-worktree.status')

-- local status = Status:new()

-- luacheck: globals repo_dir
describe('git-worktree', function()
    -- local completed_create = false
    local completed_switch = false
    -- local completed_delete = false

    local reset_variables = function()
        -- completed_create = false
        completed_switch = false
        -- completed_delete = false
    end

    before_each(function()
        reset_variables()
        git_worktree = require('git-worktree')
        git_worktree:hooks {
            -- CREATE = function()
            --     completed_create = true
            -- end,
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
    end)

    -- luacheck: globals repo_dir worktree_dir
    describe('Switch', function()
        describe('bare repo', function()
            before_each(function()
                repo_dir, worktree_dir = git_harness.prepare_repo_worktree()
            end)
            it('from a bare repo with one worktree, able to switch to worktree (relative path)', function()
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
                assert.are.same(vim.loop.cwd(), repo_dir .. Path.path.sep .. wt)
            end)
        end)
    end)
end)
