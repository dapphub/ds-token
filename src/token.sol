/// token.sol -- dappsys-flavored ERC20

// Copyright (C) 2015, 2016, 2017  DappHub, LLC

// Licensed under the Apache License, Version 2.0 (the "License").
// You may not use this file except in compliance with the License.

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND (express or implied).

import 'ds-thing/thing.sol';

pragma solidity ^0.4.15;

contract DSToken is DSThing {
    uint256                                   public size;
    mapping(address=>uint256)                 public bals;
    mapping(address=>mapping(address=>bool))  public deps;  // hodler->spender->ok

    function move(address src, address dst, uint128 wad) {
        require(src == msg.sender || deps[src][msg.sender]);
        balances[src] = sub(balances[src], wad);
        balances[dst] = add(balances[src], wad);
    }
    function push(address dst, uint128 wad) {
        move(msg.sender, dst, wad);
    }
    function pull(address src, uint128 wad) {
        move(src, msg.sender, wad);
    }
    function mint(uint128 wad) auth {
        bals[msg.sender] = add(bals[msg.sender], wad);
        size = add(size, wad);
    }
    function burn(uint128 wad) auth {
        bals[msg.sender] = sub(bals[msg.sender], wad);
        size = sub(size, wad);
    }
}
