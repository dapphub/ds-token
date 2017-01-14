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

pragma solidity ^0.4.6;

// An implementation of ERC20 with updateable databases contracts and a frontend
// interface.
import 'ds-auth/auth.sol';
import 'erc20/erc20.sol';

import 'data/approval_db.sol';
import 'data/balance_db.sol';
import 'event_callback.sol';
import 'frontend.sol';
import 'token.sol';

import 'util/safety.sol';

// Does NOT implement ERC20, but does happen implement the constant getters
// The frontend contract passes the msg.sender through as caller for some functions.
// This controller calls back into the frontend to fire events.
contract DSTokenControllerType is ERC20Constant
                                , DSSafeAddSub
{
    // ERC20Stateful proxies
    function transfer( address _caller, address to, uint value) returns (bool ok);
    function transferFrom( address _caller, address from, address to, uint value) returns (bool ok);
    function approve( address _caller, address spender, uint value) returns (bool ok);

    // Administrative functions
    function getFrontend() constant returns (DSTokenFrontend);
    function setFrontend( DSTokenFrontend frontend );
    function setBalanceDB( DSBalanceDB new_db );
    function getBalanceDB() constant returns (DSBalanceDB);
    function setApprovalDB( DSApprovalDB new_db );
    function getApprovalDB() constant returns (DSApprovalDB);

}

contract DSTokenController is DSTokenControllerType
                            , DSAuth
{
    // Swappable database contracts
    DSBalanceDB                _balances;
    DSApprovalDB               _approvals;
    // Trust calls from this address and report events here.
    DSTokenFrontend            _frontend;

    // Setup and admin functions
    function DSTokenController( DSTokenFrontend frontend, DSBalanceDB baldb, DSApprovalDB apprdb ) {
        _frontend = frontend;
        _balances = baldb;
        _approvals = apprdb;
    }
    function getFrontend() constant returns (DSTokenFrontend) {
        return _frontend;
    }
    function getApprovalDB() constant returns (DSApprovalDB) {
        return _approvals;
    }
    function getBalanceDB() constant returns (DSBalanceDB) {
        return _balances;
    }
    function setFrontend( DSTokenFrontend frontend )
             auth()
    {
        _frontend = frontend;
    }
    function setBalanceDB( DSBalanceDB new_db )
             auth()
    {
        _balances = new_db;
    }
    function setApprovalDB( DSApprovalDB new_db )
             auth()
    {
        _approvals = new_db;
    }


    // Stateless ERC20 functions. Doesn't need to know who the sender is.
    function totalSupply() constant returns (uint supply) {
        return _balances.getSupply();
    }
    function balanceOf( address who ) constant returns (uint amount) {
        return _balances.getBalance( who );
    }
    function allowance(address owner, address spender) constant returns (uint _allowance) {
        return _approvals.getApproval(owner, spender);
    }


    // Each stateful ERC20 function signature has an parallel function
    // which takes a `msg.sender` as the first argument. Each such "implementation"
    // function needs to report any events back to the "frontend" contract.

    // Only trust calls from the frontend contract.
    function transfer(address _caller, address to, uint value)
             auth()
             returns (bool ok)
    {
        if( _balances.getBalance(_caller) < value ) {
            throw;
        }
        if( !safeToAdd(_balances.getBalance(to), value) ) {
            throw;
        }
        _balances.moveBalance(_caller, to, value);
        _frontend.emitTransfer( _caller, to, value );
        return true;
    }
    function transferFrom(address _caller, address from, address to, uint value)
             auth()
             returns (bool)
    {
        // if you don't have enough balance, throw
        if( _balances.getBalance(from) < value ) {
            throw;
        }

        // if you don't have approval, throw
        var allowance = _approvals.getApproval( from, _caller );
        if( allowance < value ) {
            throw;
        }

        if( !safeToAdd(_balances.getBalance(to), value) ) {
            throw;
        }
        _approvals.setApproval( from, _caller, allowance - value );
        _balances.moveBalance( from, to, value);
        _frontend.emitTransfer( from, to, value );
        return true;
    }
    function approve( address _caller, address spender, uint value)
             auth()
             returns (bool)
    {
        _approvals.setApproval( _caller, spender, value );
        _frontend.emitApproval( _caller, spender, value);
        return true;
    }
}
