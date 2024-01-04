.PHONY: lint
lint:
	luacheck ./lua

# GIT_WORKTREE_NVIM_LOG=fatal
.PHONY: test
test:
	vusted --output=gtest ./lua

.PHONY: wintest
wintest:
	vusted --output=gtest -m '.\plenary\lua\?.lua' -m '.\plenary\lua\?\?.lua' -m '.\plenary\lua\?\init.lua' ./lua
