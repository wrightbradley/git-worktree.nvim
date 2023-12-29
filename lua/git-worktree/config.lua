local M = {}

---@class GitWorktreeConfig
local defaults = {

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

--- @return GitWorktreeConfig
M._get_defaults = function()
    return defaults
end

---@param opts? GitWorktreeConfig
function M.setup(opts)
    local config = vim.tbl_deep_extend('force', vim.deepcopy(defaults), opts or {})
    return config
end

return M
