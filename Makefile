.PHONY: lint
lint:
	luacheck ./lua

# GIT_WORKTREE_NVIM_LOG=fatal
.PHONY: test
test:
	vusted --output=gtest ./lua
