// This factory contains several useful token system install patterns.
// You may want to create your own.

// Copyright 2016  Nexus Development, LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// A copy of the License may be obtained at the following URL:
//
//    https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

pragma solidity ^0.4.6;

import 'ds-auth/basic_authority.sol';
import 'data/balance_db.sol';
import 'data/approval_db.sol';
import 'data/composite_db.sol';
import 'frontend.sol';
import 'controller.sol';

contract DSTokenFactory {
    function buildDSTokenDB()
        external
        returns (DSTokenDB)
    {
        var db = new DSTokenDB();
        db.setOwner( msg.sender );
        return db;
    }
    function buildDSBalanceDB()
        external
        returns (DSBalanceDB) 
    {
        var bdb = new DSBalanceDB();
		bdb.setOwner( msg.sender );
        return bdb;
    }
    function buildDSApprovalDB()
        external
        returns (DSApprovalDB)
    {
        var adb = new DSApprovalDB();
        adb.setOwner( msg.sender );
        return adb;
    }
    function buildDSTokenController( DSTokenFrontend frontend
                                   , DSBalanceDB bal_db
                                   , DSApprovalDB appr_db )
             external
             returns (DSTokenController)
    {
        var controller = new DSTokenController( frontend, bal_db, appr_db );
 		controller.setOwner( msg.sender );
        return controller;
    }
    function buildBlankTokenSystem() returns (DSTokenFrontend frontend)
    {
        frontend = this.buildDSTokenFrontend();
        var db = this.buildDSTokenDB();
        var controller = this.buildDSTokenController( frontend, db, db );

        db.setOwner(msg.sender);
        controller.setOwner(msg.sender);
        frontend.setOwner(msg.sender);

        return frontend;
    }

    function buildDSTokenFrontend()
             external
             returns (DSTokenFrontend)
    {
        var frontend = new DSTokenFrontend();
		frontend.setOwner(msg.sender);
        return frontend;
    }
    function installDSTokenBasicSystem( DSBasicAuthority authority )
             returns( DSTokenFrontend frontend )
    {
        frontend = this.buildDSTokenFrontend();
        var balance_db = this.buildDSBalanceDB();
        var approval_db = this.buildDSApprovalDB();
        var controller = this.buildDSTokenController( frontend, balance_db, approval_db );

        frontend.setController( controller );
		
		balance_db.setAuthority(authority);
		approval_db.setAuthority(authority);
		controller.setAuthority(authority);
		frontend.setAuthority(authority);

        // The only data ops the controller does is `move` balances and `set` approvals.
        authority.setCanCall( controller, balance_db,
                             bytes4(sha3("moveBalance(address,address,uint256)")), true );
        authority.setCanCall( controller, approval_db,
                             bytes4(sha3("setApproval(address,address,uint256)")), true );

        // The controller calls back to the forntend for the 2 events.
        authority.setCanCall( controller, frontend,
                             bytes4(sha3("emitTransfer(address,address,uint256)")), true );
        authority.setCanCall( controller, frontend,
                             bytes4(sha3("emitApproval(address,address,uint256)")), true );

        // The frontend can call the proxy functions.
        authority.setCanCall( frontend, controller,
                             bytes4(sha3("transfer(address,address,uint256)")), true );
        authority.setCanCall( frontend, controller,
                             bytes4(sha3("transferFrom(address,address,address,uint256)")),
                             true );

        authority.setCanCall( frontend, controller,
                             bytes4(sha3("approve(address,address,uint256)")), true );

		authority.setOwner(msg.sender);
        return frontend;
    }
}
