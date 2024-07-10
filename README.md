# `gatekeeper`

The `gatekeeper` KRM function runs [`gator
test`](https://open-policy-agent.github.io/gatekeeper/website/docs/gator#the-gator-test-subcommand).

This function support the newer variants of the Rego language and GateKeeper
[expansions](https://open-policy-agent.github.io/gatekeeper/website/docs/expansion).

Example:

```
kpt fn source test | kpt fn eval - --image ghcr.io/krm-functions/gatekeeper@sha256:01b927c641d14f2d6c0b5b4335e7a01596ed2cd1f3169bae4e025b9bfaa802ba
```

which will produce:

```
[RUNNING] "github.com/krm-functions/gatekeeper:latest"
[PASS] "github.com/krm-functions/gatekeeper:latest" in 800ms
  Results:
    [info]: gatekeeper
    [error] apps/v1/Deployment/foo: All pods must have an `owner` label violatedConstraint: must-have-owner
    [error] apps/v1/Deployment/foo: [Implied by expand-deployments] All pods must have an `owner` label violatedConstraint: must-have-owner
```
