/// base.t.sol -- test for base.sol

// Copyright (C) 2015, 2016, 2017  DappHub, LLC

// Licensed under the Apache License, Version 2.0 (the "License").
// You may not use this file except in compliance with the License.

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND (express or implied).

pragma solidity ^0.4.13;

import "ds-test/test.sol";

import "./base.sol";

contract TokenUser {
    ERC20  token;

    function TokenUser(ERC20 token_) public {
        token = token_;
    }

    function doTransferFrom(address from, address to, uint amount)
        public
        returns (bool)
    {
        return token.transferFrom(from, to, amount);
    }

    function doTransfer(address to, uint amount)
        public
        returns (bool)
    {
        return token.transfer(to, amount);
    }

    function doApprove(address recipient, uint amount)
        public
        returns (bool)
    {
        return token.approve(recipient, amount);
    }

    function doAllowance(address owner, address spender)
        public
        view
        returns (uint)
    {
        return token.allowance(owner, spender);
    }

    function doBalanceOf(address who) public view returns (uint) {
        return token.balanceOf(who);
    }
}

contract DSTokenBaseTest is DSTest {
    uint constant initialBalance = 1000;

    ERC20 token;
    TokenUser user1;
    TokenUser user2;

    function setUp() public {
        token = createToken();
        user1 = new TokenUser(token);
        user2 = new TokenUser(token);
    }

    function createToken() internal returns (ERC20) {
        return new DSTokenBase(initialBalance);
    }

    function testSetupPrecondition() public {
        assertEq(token.balanceOf(this), initialBalance);
    }

    function testTransferCost() public logs_gas() {
        token.transfer(address(0), 10);
    }

    function testAllowanceStartsAtZero() public logs_gas {
        assertEq(token.allowance(user1, user2), 0);
    }

    function testValidTransfers() public logs_gas {
        uint sentAmount = 250;
        log_named_address("token11111", token);
        token.transfer(user2, sentAmount);
        assertEq(token.balanceOf(user2), sentAmount);
        assertEq(token.balanceOf(this), initialBalance - sentAmount);
    }

    function testFailWrongAccountTransfers() public logs_gas {
        uint sentAmount = 250;
        token.transferFrom(user2, this, sentAmount);
    }

    function testFailInsufficientFundsTransfers() public logs_gas {
        uint sentAmount = 250;
        token.transfer(user1, initialBalance - sentAmount);
        token.transfer(user2, sentAmount+1);
    }


    function testApproveSetsAllowance() public logs_gas {
        log_named_address("Test", this);
        log_named_address("Token", token);
        log_named_address("Me", this);
        log_named_address("User 2", user2);
        token.approve(user2, 25);
        assertEq(token.allowance(this, user2), 25);
    }

    function testChargesAmountApproved() public logs_gas {
        uint amountApproved = 20;
        token.approve(user2, amountApproved);
        assertTrue(user2.doTransferFrom(this, user2, amountApproved));
        assertEq(token.balanceOf(this), initialBalance - amountApproved);
    }

    function testFailTransferWithoutApproval() public logs_gas {
        address self = this;
        token.transfer(user1, 50);
        token.transferFrom(user1, self, 1);
    }

    function testFailChargeMoreThanApproved() public logs_gas {
        address self = this;
        token.transfer(user1, 50);
        user1.doApprove(self, 20);
        token.transferFrom(user1, self, 21);
    }
}

