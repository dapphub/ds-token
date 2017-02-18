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

import "ds-auth/auth.sol";

import "./base.sol";
import "./rules.sol";

contract DSToken is DSTokenBase, DSAuth {
    DSTokenRules _rules;

    function assert(bool x) {
        if (!x) throw;
    }

    function transfer(address dst, uint x) returns (bool) {
        assert(_rules.canTransfer(msg.sender, msg.sender, dst, x));
        super.transfer(dst, x);
    }

    function transferFrom(address src, address dst, uint x) returns (bool) {
        assert(_rules.canTransfer(msg.sender, src, dst, x));
        super.transferFrom(src, dst, x);
    }

    function approve(address spender, uint x) returns (bool) {
        assert(_rules.canApprove(msg.sender, spender, x));
        super.approve(spender, x);
    }

    function burn(uint x) auth {
        assert(_balances[msg.sender] - x <= _balances[msg.sender]);
        _balances[msg.sender] -= x;
    }

    function mint(uint x) auth {
        assert(_balances[msg.sender] + x >= _balances[msg.sender]);
        _balances[msg.sender] += x;
    }
}
