---@mod git-worktree.config

---@brief [[

--- The plugin configuration.
--- Merges the default config with `vim.g.git_worktree`.

---@brief ]]

---@class GitWorktreeConfig
---@field change_directory_command string command to change directory on your OS
---@field update_on_change boolean ????
---@field update_on_change_command string ?????
---@field clearjumps_on_change boolean
---@field confirm_telescope_deletions boolean
---@field autopush boolean

---@type (fun():GitWorktreeConfig) | GitWorktreeConfig | nil
vim.g.haskell_tools = vim.g.haskell_tools

local GitWorktreeDefaultConfig = {

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

local git_worktree = vim.g.git_worktree or {}
---@type GitWorktreeConfig
local opts = type(git_worktree) == 'function' and git_worktree() or git_worktree

local GitWorktreeConfig = vim.tbl_deep_extend('force', {}, GitWorktreeDefaultConfig, opts)

return GitWorktreeConfig
