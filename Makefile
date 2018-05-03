REPO_ROOT=$(shell git rev-parse --show-toplevel)

test: docker
	@docker build -q --rm -t valptid -f $(REPO_ROOT)/test/Dockerfile $(REPO_ROOT)
	@docker run -t --mount type=bind,source=$(REPO_ROOT),target=/app valptid \
		nyc mocha \
			-r /app/valptid \
			-r chai/register-should \
			-r coffeescript/register \
			"test/*.coffee"

test_with_codecov: test docker
	@docker run -t --mount type=bind,source=$(REPO_ROOT),target=/app valptid \
		nyc report --reporter=text-lcov \> coverage.lcov \&\& codecov

docker:
ifeq (, $(shell which docker))
	$(error you need docker to test: https://www.docker.com)
endif

.PHONY: test test_with_codecov docker
