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

// Balance database contract for Tokens and token-like contracts.

import 'ds-auth/auth.sol';
import 'util/safety.sol';

contract DSBalanceDBEvents {
    event BalanceUpdate( address indexed who, uint new_amount );
}

contract DSBalanceDB is DSAuth
                      , DSSafeAddSub
                      , DSBalanceDBEvents
{
    uint _supply;
    mapping( address => uint )  _balances;

    function getSupply()
             constant
             returns (uint)
    {
        return _supply;
    }
    function getBalance( address who )
             constant
             returns (uint)
    {
        return _balances[who];
    }
    function setBalance( address who, uint new_balance )
             auth()
    {
        var old_balance = _balances[who];
        if( new_balance <= old_balance ) {
            _supply = safeSub( _supply, old_balance - new_balance );
        } else {
            _supply = safeAdd( _supply, new_balance - old_balance );
        }
        _balances[who] = new_balance;
        BalanceUpdate( who, new_balance );
    }
    function addBalance( address to, uint amount )
             auth()
    {
        _supply = safeAdd( _supply, amount );
        _balances[to] = safeAdd( _balances[to], amount );
        BalanceUpdate( to, _balances[to] );
    }
    function subBalance( address from, uint amount )
             auth()
    {
        _supply = safeSub( _supply, amount );
        _balances[from] = safeSub( _balances[from], amount );
        BalanceUpdate( from, _balances[from] );
    }
    function moveBalance( address from, address to, uint amount )
             auth()
    {
        _balances[from] = safeSub( _balances[from], amount );
        _balances[to] = safeAdd( _balances[to], amount );
        BalanceUpdate( from, _balances[from] );
        BalanceUpdate( to, _balances[to] );
    }

}
