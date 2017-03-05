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

contract DSToken is DSTokenBase(0), DSAuth {
    bool public _stopped;

    function assert(bool x) internal {
        if (!x) throw;
    }

    modifier stoppable {
        if (_stopped) throw;
        _;
    }

    function stop() auth {
        _stopped = true;
    }

    function start() auth {
        _stopped = false;
    }

    function transfer( address to, uint value) stoppable returns (bool ok) {
        return super.transfer(to, value);
    }

    function transferFrom( address from, address to, uint value) stoppable returns (bool ok) {
        return super.transferFrom(from, to, value);
    }

    function approve( address spender, uint value ) stoppable returns (bool ok) {
        return super.approve(spender, value);
    }

    function burn(uint x) auth stoppable {
        assert(_balances[msg.sender] - x <= _balances[msg.sender]);
        _balances[msg.sender] -= x;
        _supply -= x;
    }
    function mint(uint x) auth stoppable {
        assert(_balances[msg.sender] + x >= _balances[msg.sender]);
        _balances[msg.sender] += x;
        _supply += x;
    }
}
