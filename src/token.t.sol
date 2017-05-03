/// token.t.sol -- test for token.sol

// Copyright (C) 2015, 2016, 2017  DappHub, LLC

// Licensed under the Apache License, Version 2.0 (the "License").
// You may not use this file except in compliance with the License.

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND (express or implied).

pragma solidity ^0.4.10;

import "ds-test/test.sol";

import "./token.sol";

contract TokenUser {
    DSToken  token;

    function TokenUser(DSToken token_) {
        token = token_;
    }

    function doTransferFrom(address from, address to, uint amount)
        returns (bool)
    {
        return token.transferFrom(from, to, amount);
    }

    function doTransfer(address to, uint amount)
        returns (bool)
    {
        return token.transfer(to, amount);
    }

    function doApprove(address recipient, uint amount)
        returns (bool)
    {
        return token.approve(recipient, amount);
    }

    function doAllowance(address owner, address spender)
        constant returns (uint)
    {
        return token.allowance(owner, spender);
    }

    function doBalanceOf(address who) constant returns (uint) {
        return token.balanceOf(who);
    }

    function doSetName(bytes32 name) constant {
        token.setName(name);
    }

    function doSetDecimals(uint256 decimals) constant {
        token.setDecimals(decimals);
    }
}

contract DSTokenTest is DSTest {
    uint128 constant initialBalance = 1000;

    DSToken token;
    TokenUser user1;
    TokenUser user2;

    function setUp() {
        token = createToken();
        token.mint(initialBalance);
        user1 = new TokenUser(token);
        user2 = new TokenUser(token);
    }

    function createToken() internal returns (DSToken) {
        return new DSToken("TST");
    }

    function testSetupPrecondition() {
        assertEq(token.balanceOf(this), initialBalance);
    }

    function testTransferCost() logs_gas {
        token.transfer(address(0), 10);
    }

    function testAllowanceStartsAtZero() logs_gas {
        assertEq(token.allowance(user1, user2), 0);
    }

    function testValidTransfers() logs_gas {
        uint sentAmount = 250;
        log_named_address("token11111", token);
        token.transfer(user2, sentAmount);
        assertEq(token.balanceOf(user2), sentAmount);
        assertEq(token.balanceOf(this), initialBalance - sentAmount);
    }

    function testFailWrongAccountTransfers() logs_gas {
        uint sentAmount = 250;
        token.transferFrom(user2, this, sentAmount);
    }

    function testFailInsufficientFundsTransfers() logs_gas {
        uint sentAmount = 250;
        token.transfer(user1, initialBalance - sentAmount);
        token.transfer(user2, sentAmount + 1);
    }

    function testApproveSetsAllowance() logs_gas {
        log_named_address("Test", this);
        log_named_address("Token", token);
        log_named_address("Me", this);
        log_named_address("User 2", user2);
        token.approve(user2, 25);
        assertEq(token.allowance(this, user2), 25);
    }

    function testChargesAmountApproved() logs_gas {
        uint amountApproved = 20;
        token.approve(user2, amountApproved);
        assert(user2.doTransferFrom(this, user2, amountApproved));
        assertEq(token.balanceOf(this), initialBalance - amountApproved);
    }

    function testFailTransferWithoutApproval() logs_gas {
        address self = this;
        token.transfer(user1, 50);
        token.transferFrom(user1, self, 1);
    }

    function testFailChargeMoreThanApproved() logs_gas {
        address self = this;
        token.transfer(user1, 50);
        user1.doApprove(self, 20);
        token.transferFrom(user1, self, 21);
    }

    function testMint() logs_gas {
        uint128 mintAmount = 10;
        token.mint(mintAmount);
        assertEq(token.totalSupply(), initialBalance + mintAmount);
    }

    function testBurn() logs_gas {
        uint128 burnAmount = 10;
        token.burn(burnAmount);
        assertEq(token.totalSupply(), initialBalance - burnAmount);
    }

    function testFailTransferWhenStopped() logs_gas {
        token.stop();
        token.transfer(user1, 10);
    }

    function testSetName() logs_gas {
        assertEq(token.name(), "");
        token.setName("Test");
        assertEq(token.name(), "Test");
    }

    function testSetDecimals() logs_gas {
        assertEq(token.decimals(), 18);
        token.setDecimals(1);
        assertEq(token.decimals(), 1);
    }

    function testFailSetName() logs_gas {
        user1.doSetName("Test");
    }

    function testFailSetDecimals() logs_gas {
        user1.doSetDecimals(1);
    }
}

