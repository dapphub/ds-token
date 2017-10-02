/// token.t.sol -- test for token.sol

// Copyright (C) 2015, 2016, 2017  DappHub, LLC

// Licensed under the Apache License, Version 2.0 (the "License").
// You may not use this file except in compliance with the License.

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND (express or implied).

pragma solidity ^0.4.13;

import "ds-test/test.sol";

import "./token.sol";

contract TokenUser {
    DSToken  token;

    function TokenUser(DSToken token_) public {
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

    function doSetName(bytes32 name) public {
        token.setName(name);
    }

    function doPush(address who, uint amount) public {
        token.push(who, amount);
    }
    function doPull(address who, uint amount) public {
        token.pull(who, amount);
    }
    function doMove(address src, address dst, uint amount) public {
        token.move(src, dst, amount);
    }
    function doTrust(address guy, bool wat) public {
        token.trust(guy, wat);
    }
    function doMint(uint wad) public {
        token.mint(wad);
    }
    function doBurn(uint wad) public {
        token.burn(wad);
    }
    function doMint(address guy, uint wad) public {
        token.mint(guy, wad);
    }
    function doBurn(address guy, uint wad) public {
        token.burn(guy, wad);
    }

}

contract DSTokenTest is DSTest {
    uint constant initialBalance = 1000;

    DSToken token;
    TokenUser user1;
    TokenUser user2;

    function setUp() public {
        token = createToken();
        token.mint(initialBalance);
        user1 = new TokenUser(token);
        user2 = new TokenUser(token);
    }

    function createToken() internal returns (DSToken) {
        return new DSToken("TST");
    }

    function testSetupPrecondition() public {
        assertEq(token.balanceOf(this), initialBalance);
    }

    function testTransferCost() public logs_gas {
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
        token.transfer(user2, sentAmount + 1);
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
    function testTransferFromSelf() public {
        // you always trust yourself
        assertTrue(!token.trusted(this, this));
        token.transferFrom(this, user1, 50);
        assertEq(token.balanceOf(user1), 50);
    }

    function testMint() public {
        uint mintAmount = 10;
        token.mint(mintAmount);
        assertEq(token.totalSupply(), initialBalance + mintAmount);
    }
    function testMintThis() public {
        uint mintAmount = 10;
        token.mint(mintAmount);
        assertEq(token.balanceOf(this), initialBalance + mintAmount);
    }
    function testMintGuy() public {
        uint mintAmount = 10;
        token.mint(user1, mintAmount);
        assertEq(token.balanceOf(user1), mintAmount);
    }
    function testFailMintNoAuth() public {
        user1.doMint(10);
    }
    function testMintAuth() public {
        token.setOwner(user1);
        user1.doMint(10);
    }
    function testFailMintGuyNoAuth() public {
        user1.doMint(user2, 10);
    }
    function testMintGuyAuth() public {
        token.setOwner(user1);
        user1.doMint(user2, 10);
    }

    function testBurn() public {
        uint burnAmount = 10;
        token.burn(burnAmount);
        assertEq(token.totalSupply(), initialBalance - burnAmount);
    }
    function testBurnThis() public {
        uint burnAmount = 10;
        token.burn(burnAmount);
        assertEq(token.balanceOf(this), initialBalance - burnAmount);
    }
    function testFailBurnGuyWithoutTrust() public {
        uint burnAmount = 10;
        token.push(user1, burnAmount);
        token.burn(user1, burnAmount);
    }
    function testBurnGuyWithTrust() public {
        uint burnAmount = 10;
        token.push(user1, burnAmount);
        assertEq(token.balanceOf(user1), burnAmount);

        user1.doTrust(this, true);
        token.burn(user1, burnAmount);
        assertEq(token.balanceOf(user1), 0);
    }
    function testFailBurnNoAuth() public {
        token.transfer(user1, 10);
        user1.doBurn(10);
    }
    function testBurnAuth() public {
        token.transfer(user1, 10);
        token.setOwner(user1);
        user1.doBurn(10);
    }
    function testFailBurnGuyNoAuth() public {
        token.transfer(user2, 10);
        user2.doTrust(user1, true);
        user1.doBurn(user2, 10);
    }
    function testBurnGuyAuth() public {
        token.transfer(user2, 10);
        token.setOwner(user1);
        user2.doTrust(user1, true);
        user1.doBurn(user2, 10);
    }


    function testFailTransferWhenStopped() public {
        token.stop();
        token.transfer(user1, 10);
    }
    function testFailTransferFromWhenStopped() public {
        token.stop();
        user1.doTransferFrom(this, user2, 10);
    }
    function testFailPushWhenStopped() public {
        token.stop();
        token.push(user1, 10);
    }
    function testFailPullWhenStopped() public {
        token.trust(user1, true);
        token.stop();
        user1.doPull(this, 10);
    }
    function testFailMoveWhenStopped() public {
        token.trust(user1, true);
        token.stop();
        token.move(this, user2, 10);
    }
    function testFailMintWhenStopped() public {
        token.stop();
        token.mint(10);
    }
    function testFailMintGuyWhenStopped() public {
        token.stop();
        token.mint(user1, 10);
    }
    function testFailBurnWhenStopped() public {
        token.stop();
        token.burn(10);
    }
    function testFailTrustWhenStopped() public {
        token.stop();
        token.trust(user1, true);
    }


    function testSetName() public logs_gas {
        assertEq(token.name(), "");
        token.setName("Test");
        assertEq(token.name(), "Test");
    }

    function testFailSetName() public logs_gas {
        user1.doSetName("Test");
    }

    function testFailUntrustedTransferFrom() public {
        assertTrue(!token.trusted(this, user2));
        user1.doTransferFrom(this, user2, 200);
    }
    function testTrusting() public {
        assertTrue(!token.trusted(this, user2));
        token.trust(user2, true);
        assertTrue(token.trusted(this, user2));
        token.trust(user2, false);
        assertTrue(!token.trusted(this, user2));
    }
    function testTrustedTransferFrom() public {
        token.trust(user1, true);
        user1.doTransferFrom(this, user2, 200);
        assertEq(token.balanceOf(user2), 200);
    }

    function testPush() public {
        assertEq(token.balanceOf(this), 1000);
        assertEq(token.balanceOf(user1), 0);
        token.push(user1, 1000);
        assertEq(token.balanceOf(this), 0);
        assertEq(token.balanceOf(user1), 1000);
        user1.doPush(user2, 200);
        assertEq(token.balanceOf(this), 0);
        assertEq(token.balanceOf(user1), 800);
        assertEq(token.balanceOf(user2), 200);
    }
    function testFailPullWithoutTrust() public {
        user1.doPull(this, 1000);
    }
    function testPullWithTrust() public {
        token.trust(user1, true);
        user1.doPull(this, 1000);
    }
    function testFailMoveWithoutTrust() public {
        user1.doMove(this, user2, 1000);
    }
    function testMoveWithTrust() public {
        token.trust(user1, true);
        user1.doMove(this, user2, 1000);
    }
}

