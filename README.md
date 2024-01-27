# KRM function - gatekeeper

The `gatekeeper` KRM function runs [`gator
test`](https://open-policy-agent.github.io/gatekeeper/website/docs/gator#the-gator-test-subcommand).

This function is a re-implementation of the
['curated'](https://catalog.kpt.dev/gatekeeper/v0.2) function and this new version
support a newer variant of the Rego language and GateKeeper
[expansions](https://open-policy-agent.github.io/gatekeeper/website/docs/expansion).

Example:

```
kpt fn source test | kpt fn eval - --image ghcr.io/michaelvl/krm-gatekeeper:latest | kpt fn sink tmp
```

which will produce:

```
[RUNNING] "github.com/michaelvl/krm-gatekeeper:latest"
[PASS] "github.com/michaelvl/krm-gatekeeper:latest" in 800ms
  Results:
    [info]: gatekeeper
    [error] apps/v1/Deployment/foo: All pods must have an `owner` label violatedConstraint: must-have-owner
    [error] apps/v1/Deployment/foo: [Implied by expand-deployments] All pods must have an `owner` label violatedConstraint: must-have-owner
```
