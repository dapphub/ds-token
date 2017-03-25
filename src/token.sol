/// token.sol -- ERC20 implementation with minting and burning

// Copyright (C) 2015, 2016, 2017  Nexus Development, LLC

// Licensed under the Apache License, Version 2.0 (the "License").
// You may not use this file except in compliance with the License.

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND (express or implied).

pragma solidity ^0.4.8;

import "ds-auth/auth.sol";

import "./base.sol";

contract DSToken is DSTokenBase(0), DSAuth {
    string   public  name;
    string   public  symbol;
    uint256  public  decimals;
    bool     public  stopped;

    function DSToken(string name_, string symbol_, uint decimals_) {
        name = name_;
        symbol = symbol_;
        decimals = decimals_;
    }

    modifier stoppable {
        assert (!stopped);
        _;
    }
    function stop() auth {
        stopped = true;
    }
    function start() auth {
        stopped = false;
    }

    function transfer(address dst, uint wad) stoppable returns (bool) {
        return super.transfer(dst, wad);
    }
    function transferFrom(
        address src, address dst, uint wad
    ) stoppable returns (bool) {
        return super.transferFrom(src, dst, wad);
    }
    function approve(address guy, uint wad) stoppable returns (bool) {
        return super.approve(guy, wad);
    }

    function push(address dst, uint128 wad) returns (bool) {
        return transfer(dst, wad);
    }
    function pull(address src, uint128 wad) returns (bool) {
        return transferFrom(src, msg.sender, wad);
    }

    function mint(uint128 wad) auth stoppable {
        assert(_balances[msg.sender] + wad >= _balances[msg.sender]);
        _balances[msg.sender] += wad;
        _supply += wad;
    }
    function burn(uint128 wad) auth stoppable {
        assert(_balances[msg.sender] - wad <= _balances[msg.sender]);
        _balances[msg.sender] -= wad;
        _supply -= wad;
    }    
}
