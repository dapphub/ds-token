ds-token
===

An opinionated ERC20 (standard Ethereum token) extension.

ERC20 functions check a `canTransfer` and `canApprove` on a `DSTokenRules` contract.

Two new `auth`enticated functions, `mint` (create) `burn` (destroy).

This design is a tradeoff between flexibility of token logic and ensuring ERC20 compatability on behalf of the consumer.

The main insight into why this tradeoff is reasonable is that we have observed almost all custom token logic can and
inevitably will be repackaged into "simple" tokens with a "smart" converter/redeemer contract.

The old "ds-token" repository was an example of using frontend/controller/datastore contracts for upgradeability. This can be found at [`ds-token-system`](https://github.com/dapphub/ds-token-system).
