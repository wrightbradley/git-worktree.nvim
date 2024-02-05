if not vim.g.did_gitworktree_initialize then
    vim.api.nvim_create_user_command('GitWorktreeSwitch', function(args)
        local path = args['args']
        require('git-worktree').switch_worktree(path)
    end, { desc = 'Switch to worktree', nargs = 1 })
end

vim.g.did_gitworktree_initialize = true
