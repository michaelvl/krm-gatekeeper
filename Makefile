.PHONY: build
build:
	go build -o gatekeeper gator.go

.PHONY: lint
lint:
	docker run --rm -v $$(pwd):/app -w /app golangci/golangci-lint:v1.55.2 golangci-lint run -v  --timeout 10m

.PHONY: container
container:
	docker build -t github.com/michaelvl/krm-gatekeeper:latest .

.PHONY: test-bin
test-bin:
	rm -rf _tmp
	kpt fn source test | ./gatekeeper

.PHONY: test-container
test-container:
	rm -rf _tmp
	kpt fn source test | kpt fn eval - --image github.com/michaelvl/krm-gatekeeper:latest | kpt fn sink _tmp
