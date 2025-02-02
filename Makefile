KO_DOCKER_REPO ?= ko.local
GATEKEEPER ?= ./gatekeeper
GATEKEEPER_IMAGE ?= $(KO_DOCKER_REPO)/gatekeeper:latest

.EXPORT_ALL_VARIABLES:

.PHONY: build
build:
	go build -o gatekeeper gator.go

.PHONY: lint
lint:
	golangci-lint run -v  --timeout 10m

.PHONY: container
container:
	ko build --base-import-paths	

.PHONY: test-bin
test-bin:
	rm -rf _tmp _results
	kpt fn source examples | kpt fn eval --results-dir _results - --truncate-output=false --exec $(GATEKEEPER) | kpt fn sink _tmp
	make do-tests

.PHONY: test-container
test-container:
	rm -rf _tmp _results
	kpt fn source examples | kpt fn eval --results-dir _results - --image $(GATEKEEPER_IMAGE) | kpt fn sink _tmp
	make do-tests

.PHONY: do-tests
do-tests:
	grep -q 'Implied by expand-deployments] All pods must have an `owner` label violatedConstraint: must-have-owner' _results/results.yaml
