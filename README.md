<h2>DSToken
  <small class="text-muted">
    <a href="https://github.com/dapphub/ds-token"><span class="fa fa-github"></span></a>
  </small>
</h2>

_An ERC20 Token with wholesome memes_

Provides a standard [ERC20](https://theethereum.wiki/w/index.php/ERC20_Token_Standard)
token interface plus [DSAuth](https://dapp.tools/dappsys/ds-auth)-protected 
`mint` and `burn` functions; `trust` binary approval; as well as  `push`, `pull`
and `move` aliases for `transferFrom` operations.

### Custom Actions

#### `trust`
similar to `approve` but with a boolean argument for permitting or forbidding 
transfers of any amount by a third party (requires auth)

#### `mint`
credit tokens at an address whilst simultaniously increasing `totalSupply` 
(requires auth)

#### `burn`
debit tokens at an address whilst simultaniously decreasing `totalSupply` 
(requires auth)

### Aliases

#### `push`
transfer an amount from `msg.sender` to a given address (requires trust or 
approval)

#### `pull`
transfer an amount from a given address to `msg.sender` (requires trust or 
approval)

#### `move`
transfer an amount from a given `src` address to a given `dst` address (requires
trust or approval)
