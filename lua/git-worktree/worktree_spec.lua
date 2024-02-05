local git_harness = require('git-worktree.test.git_util')
local Path = require('plenary.path')
local stub = require('luassert.stub')

local cwd = vim.fn.getcwd()

-- luacheck: globals repo_dir config git_worktree
describe('[Worktree]', function()
    local Hooks = require('git-worktree.hooks').hooks
    stub(Hooks, 'emit')

    before_each(function()
        git_worktree = require('git-worktree')
        git_worktree.setup {}
    end)
    after_each(function()
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
                local input_path = '../' .. wt
                local expected_path = working_dir .. Path.path.sep .. wt
                local prev_path = working_dir .. Path.path.sep .. 'master'
                require('git-worktree').switch_worktree(input_path)

                local co = coroutine.running()
                vim.defer_fn(function()
                    coroutine.resume(co)
                end, 1000)
                --The test will reach here immediately.
                coroutine.yield()

                -- Check to make sure directory was switched
                assert.stub(Hooks.emit).was_called_with(Hooks, 'SWITCH', input_path, prev_path)
                assert.are.same(expected_path, vim.loop.cwd())
            end)
        end)

        describe('[normal repo]', function()
            before_each(function()
                working_dir, master_dir = git_harness.prepare_repo_normal_worktree(1)
            end)
            it('able to switch to worktree (relative path)', function()
                local wt = 'featB'
                local input_path = '../' .. wt
                local expected_path = working_dir .. Path.path.sep .. wt
                local prev_path = working_dir .. Path.path.sep .. 'master'
                require('git-worktree').switch_worktree(input_path)

                local co = coroutine.running()
                vim.defer_fn(function()
                    coroutine.resume(co)
                end, 1000)
                --The test will reach here immediately.
                coroutine.yield()

                -- Check to make sure directory was switched
                assert.stub(Hooks.emit).was_called_with(Hooks, 'SWITCH', input_path, prev_path)
                assert.are.same(expected_path, vim.loop.cwd())
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
                local input_path = '../' .. wt
                local expected_path = working_dir .. Path.path.sep .. wt
                local prev_path = working_dir .. Path.path.sep .. 'master'
                require('git-worktree').create_worktree(input_path, wt)

                local co = coroutine.running()
                vim.defer_fn(function()
                    coroutine.resume(co)
                end, 1000)
                --The test will reach here immediately.
                coroutine.yield()

                -- Check to make sure directory was switched
                assert.stub(Hooks.emit).was_called_with(Hooks, 'CREATE', input_path, wt, nil)
                assert.stub(Hooks.emit).was_called_with(Hooks, 'SWITCH', input_path, prev_path)
                assert.are.same(expected_path, vim.loop.cwd())
            end)
        end)
        describe('[normal repo]', function()
            before_each(function()
                working_dir, master_dir = git_harness.prepare_repo_normal_worktree(0)
            end)
            it('able to create a worktree (relative path)', function()
                local wt = 'featB'
                local input_path = '../' .. wt
                local expected_path = working_dir .. Path.path.sep .. wt
                local prev_path = working_dir .. Path.path.sep .. 'master'
                require('git-worktree').create_worktree(input_path, wt)

                local co = coroutine.running()
                vim.defer_fn(function()
                    coroutine.resume(co)
                end, 1000)
                --The test will reach here immediately.
                coroutine.yield()

                -- Check to make sure directory was switched
                assert.stub(Hooks.emit).was_called_with(Hooks, 'CREATE', input_path, wt, nil)
                assert.stub(Hooks.emit).was_called_with(Hooks, 'SWITCH', input_path, prev_path)
                assert.are.same(expected_path, vim.loop.cwd())
            end)
        end)
    end)

    -- luacheck: globals working_dir master_dir
    describe('[DELETE]', function()
        describe('[bare repo]', function()
            before_each(function()
                working_dir, master_dir = git_harness.prepare_repo_bare_worktree(2)
            end)
            it('able to create a worktree (relative path)', function()
                local wt = 'featB'
                local input_path = '../' .. wt
                require('git-worktree').delete_worktree(input_path, true)

                local co = coroutine.running()
                vim.defer_fn(function()
                    coroutine.resume(co)
                end, 1000)
                --The test will reach here immediately.
                coroutine.yield()

                -- Check to make sure directory was switched
                assert.stub(Hooks.emit).was_called_with(Hooks, 'DELETE', input_path)
                assert.are.same(master_dir, vim.loop.cwd())
            end)
        end)
        describe('[normal repo]', function()
            before_each(function()
                working_dir, master_dir = git_harness.prepare_repo_normal_worktree(1)
            end)
            it('able to create a worktree (relative path)', function()
                local wt = 'featB'
                local input_path = '../' .. wt
                require('git-worktree').delete_worktree(input_path, wt)

                local co = coroutine.running()
                vim.defer_fn(function()
                    coroutine.resume(co)
                end, 1000)
                --The test will reach here immediately.
                coroutine.yield()

                -- Check to make sure directory was switched
                assert.stub(Hooks.emit).was_called_with(Hooks, 'DELETE', input_path)
                assert.are.same(master_dir, vim.loop.cwd())
            end)
        end)
    end)
end)
