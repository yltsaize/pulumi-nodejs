SHELL := /bin/sh

# One worker at the time
MAKEFLAGS = --jobs=1

.PHONY: check
check: ## show some info
	pulumi version
	@echo
	pulumi plugin ls
	@echo

# Absolutely awesome: http://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.DEFAULT_GOAL := help
