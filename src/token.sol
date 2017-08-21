/// token.sol -- dappsys-flavored ERC20

// Copyright (C) 2015, 2016, 2017  DappHub, LLC

// Licensed under the Apache License, Version 2.0 (the "License").
// You may not use this file except in compliance with the License.

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND (express or implied).

import 'ds-thing/thing.sol';

pragma solidity ^0.4.15;

contract DSToken is DSThing
{
    uint128                                   public size;
    mapping(address=>uint128)                 public bals;
    mapping(address=>mapping(address=>bool))  public deps;  // hodler->spender->ok

    function move(address src, address dst, uint128 wad)
    {
        require(src == msg.sender || deps[src][msg.sender]);
        bals[src] = wsub(bals[src], wad);
        bals[dst] = wadd(bals[src], wad);
    }

    function push(address dst, uint128 wad)
    {
        move(msg.sender, dst, wad);
    }

    function pull(address src, uint128 wad)
    {
        move(src, msg.sender, wad);
    }

    function mint(uint128 wad)
        auth
    {
        bals[msg.sender] = wadd(bals[msg.sender], wad);
        size = wadd(size, wad);
    }

    function burn(uint128 wad)
        auth
    {
        bals[msg.sender] = wsub(bals[msg.sender], wad);
        size = wsub(size, wad);
    }
}
