local M = {}

---@class GitWorktreeConfig
local config = {

    -- command to change directory on your OS.
    --
    --- @type string
    change_directory_command = 'cd',

    -- ?????
    --
    --- @type boolean
    update_on_change = true,

    -- ????
    --
    --- @type string
    update_on_change_command = 'e .',

    -- clear jump list on change
    --
    --- @type boolean
    clearjumps_on_change = true,

    -- confirm telescope deletions
    --
    --- @type boolean
    confirm_telescope_deletions = true,

    -- ???? autopush worktree to origin
    --
    --- @type boolean
    autopush = false,
}

--- Get a configuration value
--- @param opt string
--- @return any
M.get = function()
    return config
end

--- Set user configurations
--- @param user_configs table
--- @return table
M.set = function(user_configs)
    vim.validate { user_configs = { user_configs, 'table' } }

    config = vim.tbl_deep_extend('force', config, user_configs)
    return config
end

return M
