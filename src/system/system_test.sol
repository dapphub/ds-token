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

import 'ds-auth/basic_authority.sol';

import 'erc20/erc20.sol';
import 'erc20/base_test.sol';

import 'factory.sol';
import 'token.sol';

contract DSTokenBasicSystemTest is ERC20Test
                                 , ERC20Events
                                 , DSAuthEvents
{
    DSTokenFactory factory;
    DSBasicAuthority auth;

    DSBalanceDB balanceDB;
    DSApprovalDB approvalDB;
    DSTokenController controller;
    DSTokenFrontend frontend;

    function createToken() internal returns (ERC20) {
        factory = new DSTokenFactory();
        auth = new DSBasicAuthority();
        auth.setOwner(address(factory));
        frontend = factory.installDSTokenBasicSystem(auth);
        return ERC20(frontend);
    }

    function setUp() {
        // Save system sub-pieces
        controller = DSTokenFrontend(token).getController();
        balanceDB = controller.getBalanceDB();
        approvalDB = controller.getApprovalDB();

        // satisfy the precondition
        var sig = bytes4(sha3("setBalance(address,uint256)"));
        auth.setCanCall(this, balanceDB, sig, true);
        balanceDB.setBalance(this, initialBalance);
        auth.setCanCall(this, balanceDB, sig, false);

        // Additionally, let the test harness call the controller directly,
        // as if the tester were the frontend.
        auth.setCanCall(this, controller, "transfer(address,address,uint256)", true);
        auth.setCanCall(this, controller, "transferFrom(address,address,address,uint256)", true);
        auth.setCanCall(this, controller, "approve(address,address,uint256)", true);
    }
    function testBalanceAuth() {
        assertTrue( balanceDB.authority() == address(auth));
    }
    function testTestHarnessAuth() {
        assertTrue( auth.owner() == address(this) );
    }

    function testGetController() {
        assertEq(frontend.getController(), controller);
    }

    function testSetController() {
        var newController = new DSTokenController(frontend, balanceDB, approvalDB);
        auth.setCanCall(this, frontend, "setController(address)", true);
        frontend.setController(newController);
        assertEq(frontend.getController(), newController);
    }

    function testGetFrontend() {
        assertEq(address(controller.getFrontend()), address(frontend));
    }

    function testSetFrontend() {
        var newFrontend = new DSTokenFrontend();
        auth.setCanCall(this, controller, "setFrontend(address)", true);
        controller.setFrontend(newFrontend);
        assertEq(address(controller.getFrontend()), address(newFrontend));
    }

    function testGetApprovalDb() {
        var _approvalDB = controller.getApprovalDB();
        assertEq(address(_approvalDB), address(_approvalDB));
    }

    function testSetApprovalDb() {
        var newApprovalDB = new DSApprovalDB();
        auth.setCanCall(address(this), controller, "setApprovalDB(address)", true);
        controller.setApprovalDB(newApprovalDB);
        assertEq(controller.getApprovalDB(), newApprovalDB, "db not set");
    }

    function testGetBalanceDb() {
        var _balanceDB = controller.getBalanceDB();
        assertEq(address(_balanceDB), address(_balanceDB));
    }

    function testSetBalanceDb() {
        var newBalanceDB = new DSBalanceDB();
        auth.setCanCall(address(this), controller, "setBalanceDB(address)", true);
        controller.setBalanceDB(newBalanceDB);
        assertEq(controller.getBalanceDB(), newBalanceDB, "db not set");
    }


    // Functionality directly on the controller
    function testAllowanceStartsAtZero() {
        assertEq(controller.allowance(user1, user2), 0);
    }

    function testBalanceOfStartsAtZero() {
        assertEq(controller.balanceOf(user1), 0);
    }

    function testBalanceOfReflectsTransfer() {
        uint sentAmount = 250;
        controller.transfer(this, user1, sentAmount);
        assertEq(controller.balanceOf(user1), sentAmount);
    }

    function testTotalSupply() {
        assertEq(controller.totalSupply(), initialBalance);
    }

    function testControllerValidTransfers() {
        uint sentAmount = 250;
        controller.transfer(this, user1, sentAmount);
        controller.transfer(user1, user2, sentAmount);
        assertEq(controller.balanceOf(user2), sentAmount);
        assertEq(controller.balanceOf(user1), 0);
        assertEq(controller.balanceOf(this), initialBalance - sentAmount);
    }

    function testControllerValidTransferFrom() {
        uint sentAmount = 250;
        controller.transfer(this, user1, sentAmount);
        controller.approve(user1, this, sentAmount);
        controller.transferFrom(this, user1, user2, sentAmount);
        assertEq(controller.balanceOf(user2), sentAmount);
        assertEq(controller.balanceOf(user1), 0);
    }

    function testControllerTransferTriggersEvent() {
        uint sentAmount = 250;
        expectEventsExact(frontend);
        Transfer(this, user1, sentAmount);
        controller.transfer(this, user1, sentAmount);
    }

    function testControllerApproveTriggersEvent() {
        uint sentAmount = 250;
        expectEventsExact(frontend);
        Approval(this, user1, sentAmount);
        controller.approve(this, user1, sentAmount);
    }

    function testFailControllerUnapprovedTransferFrom() {
        uint sentAmount = 250;
        controller.transfer(this, user1, sentAmount);
        controller.transferFrom(this, user1, user2, sentAmount);
    }

    function testFailControllerInsufficientFundsTransfer() {
        uint sentAmount = 250;
        controller.transfer(this, user1, initialBalance);
        controller.transfer(user1, user2, initialBalance+1);
    }

    function testFailControllerInsufficientFundsTransferFrom() {
        uint sentAmount = 250;
        controller.transfer(this, user1, sentAmount);
        controller.approve(user1, user2, sentAmount + 1);
        controller.transferFrom(user2, user1, user2, sentAmount + 1);
    }

    function testControllerApproveSetsAllowance() {
        controller.approve(user1, user2, 25);
        assertEq(controller.allowance(user1, user2), 25,
                 "wrong allowance");
    }

    function testFailControllerTransferFromWithoutApproval() {
        controller.transfer(this, user1, 50);
        controller.transferFrom(this, user1, user2, 1);
    }

    function testFailControllerChargeMoreThanApproved() {
        controller.transfer(this, user1, 50);
        controller.approve(user1, this, 20);
        controller.transferFrom(this, user1, user2, 21);
    }




}
