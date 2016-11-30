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


// Attach to your balance DB to have a way for system contracts to print/burn
// tokens for themselves.

import 'ds-auth/auth.sol';
import './data/balance_db.sol';

contract DSTokenSupplyController is DSAuth
{
    DSBalanceDB _db;
    function DSTokenSupplyController( DSBalanceDB db )
    {
        setBalanceDB(db);
    }
    function setBalanceDB( DSBalanceDB db )
        auth
    {
        _db = db;
    }
    // ERC20 getters for convenience
    function balanceOf(address who) constant returns (uint amount) {
        return _db.getBalance(who);
    }
    function totalSupply() constant returns (uint amount) {
        return _db.getSupply();
    }
    function demand(address for_whom, uint amount)
        auth
    {
        _db.addBalance(for_whom, amount);
    }
    // Not intended to be used as an entrypoint!
    // User-accessible `destroy` entrypoint should use transfer then burn pattern
    function destroy(address from_whom, uint amount)
        auth
    {
        _db.subBalance(from_whom, amount);
    }
    function destroy()
    {
        _db.setBalance(this, 0);
    }
}
