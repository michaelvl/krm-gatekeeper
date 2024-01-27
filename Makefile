.PHONY: build
build:
	go build -o gatekeeper gator.go

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
