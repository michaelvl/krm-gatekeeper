.PHONY: build
build:
	go build -o gatekeeper gator.go

.PHONY: lint
lint:
	docker run --rm -v $$(pwd):/app -w /app golangci/golangci-lint:v1.60.3 golangci-lint run -v  --timeout 10m

.PHONY: container
container:
	docker build -t ghcr.io/krm-functions/gatekeeper:latest .

.PHONY: test-bin
test-bin:
	rm -rf _tmp _results && mkdir _results
	kpt fn source test | ./gatekeeper | tee _results/results.yaml
	make do-tests

.PHONY: test-container
test-container:
	rm -rf _tmp _results
	kpt fn source test | kpt fn eval --results-dir _results - --image ghcr.io/krm-functions/gatekeeper:latest | kpt fn sink _tmp
	make do-tests

.PHONY: do-tests
do-tests:
	grep -q 'Implied by expand-deployments] All pods must have an `owner` label violatedConstraint: must-have-owner' _results/results.yaml
