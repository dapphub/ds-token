/// token.sol -- ERC20 implementation with minting and burning

// Copyright (C) 2015, 2016, 2017  DappHub, LLC

// Licensed under the Apache License, Version 2.0 (the "License").
// You may not use this file except in compliance with the License.

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND (express or implied).

pragma solidity ^0.4.13;

import "ds-stop/stop.sol";

import "./base.sol";

contract DSToken is DSTokenBase(0), DSStop {

    mapping (address => mapping (address => bool)) _trusted;

    bytes32  public  symbol;
    uint256  public  decimals = 18; // standard token precision. override to customize

    function DSToken(bytes32 symbol_) {
        symbol = symbol_;
    }

    event Trust(address indexed src, address indexed guy, bool wat);
    event Mint(address indexed guy, uint wad);
    event Burn(address indexed guy, uint wad);

    function trusted(address src, address guy) returns (bool) {
        return _trusted[src][guy];
    }
    function trust(address guy, bool wat) stoppable {
        _trusted[msg.sender][guy] = wat;
        Trust(msg.sender, guy, wat);
    }

    function transfer(address dst, uint wad) stoppable returns (bool) {
        return super.transfer(dst, wad);
    }
    function transferFrom(address src, address dst, uint wad)
        stoppable
        returns (bool)
    {
        require(_balances[src] >= wad);

        if (!_trusted[src][msg.sender]) {
            require(_approvals[src][msg.sender] >= wad);
            _approvals[src][msg.sender] = sub(_approvals[src][msg.sender], wad);
        }

        _balances[src] = sub(_balances[src], wad);
        _balances[dst] = add(_balances[dst], wad);

        Transfer(src, dst, wad);

        return true;
    }
    function approve(address guy, uint wad) stoppable returns (bool) {
        return super.approve(guy, wad);
    }

    function push(address dst, uint wad) {
        transfer(dst, wad);
    }
    function pull(address src, uint wad) {
        transferFrom(src, msg.sender, wad);
    }
    function move(address src, address dst, uint wad) {
        transferFrom(src, dst, wad);
    }


    function mint(uint wad) {
        mint(msg.sender, wad);
    }
    function burn(uint wad) {
        burn(msg.sender, wad);
    }
    function mint(address guy, uint wad) auth stoppable {
        _balances[guy] = add(_balances[guy], wad);
        _supply = add(_supply, wad);
        Mint(guy, wad);
    }
    function burn(address guy, uint wad) auth stoppable {
        if (guy != msg.sender && !_trusted[guy][msg.sender]) {
            require(_approvals[guy][msg.sender] >= wad);
            _approvals[guy][msg.sender] = sub(_approvals[guy][msg.sender], wad);
        }

        _balances[guy] = sub(_balances[guy], wad);
        _supply = sub(_supply, wad);
        Burn(guy, wad);
    }

    // Optional token name

    bytes32   public  name = "";

    function setName(bytes32 name_) auth {
        name = name_;
    }

}
