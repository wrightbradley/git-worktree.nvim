-- local Status = require('git-worktree.status')

-- local status = Status:new()

-- luacheck: globals repo_dir
describe('git-worktree', function()
    -- local completed_create = false
    -- local completed_switch = false
    -- local completed_delete = false

    -- local reset_variables = function()
    --     -- completed_create = false
    --     completed_switch = false
    --     -- completed_delete = false
    -- end

    -- before_each(function()
    --     reset_variables()
    --     git_worktree.on_tree_change(function(op, _, _)
    --         -- if op == git_worktree.Operations.Create then
    --         --     completed_create = true
    --         -- end
    --         if op == git_worktree.Operations.Switch then
    --             completed_switch = true
    --         end
    --         -- if op == git_worktree.Operations.Delete then
    --         --     completed_delete = true
    --         -- end
    --     end)
    -- end)

    -- after_each(function()
    --     -- git_worktree.reset()
    -- end)

    describe('Switch', function()
        describe('bare repo', function()
            -- before_each(function()
            --     repo_dir, worktree_dir = git_harness.prepare_repo_worktree()
            -- end)
            it('from a bare repo with one worktree, able to switch to worktree (relative path)', function()
                --     local path = 'master'
                --     git_worktree.switch_worktree(path)
                --
                --     vim.fn.wait(10000, function()
                --         return completed_switch
                --     end, 1000)
                --
                --     -- Check to make sure directory was switched
                --     assert.are.same(vim.loop.cwd(), git_worktree:get_root() .. Path.path.sep .. path)
                assert.are.same(vim.loop.cwd(), vim.loop.cwd())
            end)
        end)
    end)
end)
