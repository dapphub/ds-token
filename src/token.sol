/*
   Copyright 2017 Nexus Development, LLC

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

pragma solidity ^0.4.8;

import 'base.sol';
import 'rules.sol';

contract DSToken is DSTokenBase {
    DSTokenRules _rules;
    function transfer( address to, uint value) returns (bool ok)
    {
        if (!_rules.canTransfer(msg.sender, msg,sender, to, value)) throw;
        super.transfer(to, value);
    }
    function transferFrom( address from, address to, uint value) returns (bool ok)
    {
        if (!_rules.canTransfer(msg.sender, from, to, value)) throw;
        super.transferFrom(from, to, value);
    }
    function approve(address spender, uint value) returns (bool ok)
    {
        if (!_rules.canApprove(msg.sender, spender, value)) throw;
        super.approve(spender, value);
    }

    function burn(address who, uint amount)
        auth
    {
        if( _balances[who] - amount > _balances[who] ) {
            throw;
        }
        _balances[who] -= amount;
    }
    function mint(address who, uint amount)
        auth
    {
        if( _balances[who] + amount < _balances[who] ) {
            throw;
        }
        _balances[who] += amount;
    }
}
