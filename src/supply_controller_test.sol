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

pragma solidity ^0.4.4;

import 'dapple/test.sol';

import 'ds-auth/auth.sol';
import 'ds-auth/basic_authority.sol';
import './data/balance_db.sol';
import './supply_controller.sol';

contract DSTokenSupplyControllerTest is Test, DSAuthEvents {
    DSBalanceDB db;
    DSBasicAuthority authority;
    DSTokenSupplyController manager;
    function DSTokenSupplyControllerTest() {
        authority = new DSBasicAuthority();
    }

    function setUp() {
        db = new DSBalanceDB();
        manager = new DSTokenSupplyController(db);
        db.setAuthority(authority);
        authority.setCanCall(
          manager, db, bytes4(sha3('addBalance(address,uint256)')), true);
        authority.setCanCall(
          manager, db, bytes4(sha3('subBalance(address,uint256)')), true);

        manager.setAuthority(authority);
        authority.setCanCall(
          this, manager, bytes4(sha3('demand(address,uint256)')), true);
        authority.setCanCall(
          this, manager, bytes4(sha3('destroy(address,uint256)')), true);
    }

    function testDemand() {
      assertEq(db.getBalance(this), 0);
      manager.demand(this, 10);
      assertEq(db.getBalance(this), 10);
      assertEq(db.getSupply(), 10);
    }

    function testDestroy() {
      assertEq(db.getBalance(this), 0);
      assertEq(db.getBalance(manager), 0);
      assertEq(db.getSupply(), 0);

      manager.demand(this, 10);
      assertEq(db.getBalance(this), 10);
      assertEq(db.getBalance(manager), 0);
      assertEq(db.getSupply(), 10);

      manager.destroy(this, 9);
      assertEq(db.getBalance(this), 1);
      assertEq(db.getBalance(manager), 0);
      assertEq(db.getSupply(), 1);
    }
}
