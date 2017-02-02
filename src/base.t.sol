/*
   Copyright 2016 Nexus Development, LLC

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
*/

pragma solidity ^0.4.2;

import 'dapple/test.sol';
import 'dapple/debug.sol';
import 'base.sol';

// Supporting classes

contract ERC20Tester is Tester, Debug {
    function doTransferFrom(address from, address to, uint amount)
        returns (bool)
    {
        return ERC20(_t).transferFrom(from, to, amount);
    }

    function doTransfer(address to, uint amount)
        returns (bool)
    {
        return ERC20(_t).transfer(to, amount);
    }

    function doApprove(address recipient, uint amount)
        returns (bool)
    {
        return ERC20(_t).approve(recipient, amount);
    }

    function doAllowance(address owner, address spender)
        constant returns (uint)
    {
        return ERC20(_t).allowance(owner, spender);
    }

    function doBalanceOf(address who) constant returns (uint) {
        return ERC20(_t).balanceOf(who);
    }
}

// Tests that should work for all Tokens
contract ERC20Test is Test {
    uint constant initialBalance = 1000;

    ERC20 token;
    ERC20Tester user1;
    ERC20Tester user2;

    function ERC20Test() {
        token = createToken();
        user1 = new ERC20Tester();
        user2 = new ERC20Tester();
        user1._target(address(token));
        user2._target(address(token));
    }

    function createToken() internal returns (ERC20) {
        return new ERC20Base(initialBalance);
    }

    function testSetupPrecondition() {
        assertEq(token.balanceOf(this), initialBalance);
    }

    function testTransferCost() logs_gas() {
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
        assertEq(token.balanceOf(me), initialBalance - sentAmount);
    }

    function testFailWrongAccountTransfers() logs_gas {
        uint sentAmount = 250;
        token.transferFrom(user2, me, sentAmount);
    }

    function testFailInsufficientFundsTransfers() logs_gas {
        uint sentAmount = 250;
        token.transfer(user1, initialBalance - sentAmount);
        token.transfer(user2, sentAmount+1);
    }


    function testApproveSetsAllowance() logs_gas {
        log_named_address("Test", this);
        log_named_address("Token", token);
        log_named_address("Me", me);
        log_named_address("User 2", user2);
        token.approve(user2, 25);
        assertEq(token.allowance(me, user2), 25,
                 "wrong allowance");
    }

    function testChargesAmountApproved() logs_gas {
        uint amountApproved = 20;
        token.approve(user2, amountApproved);
        assertTrue(user2.doTransferFrom(
            me, user2, amountApproved),
            "couldn't transferFrom");
        assertEq(token.balanceOf(me), initialBalance - amountApproved,
                 "wrong balance after transferFrom");
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
}

