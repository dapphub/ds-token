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

import 'erc20/base.sol';
import 'ds-auth/auth.sol';

contract DSIFreezableToken is ERC20 {
    function freeze();
}

contract DSFreezableToken is ERC20Base, DSAuth {
    bool public frozen;
    function freeze() auth {
        frozen = true;
    }
    modifier freezable() {
        if( frozen ) throw;
        _;
    }
    function transfer( address to, uint value)
        freezable returns (bool ok)
    {
        super.transfer(to, value);
    }
    function transferFrom( address from, address to, uint value)
        freezable returns (bool ok)
    {
        super.transferFrom(from, to, value);
    }
    function approve(address spender, uint value)
        freezable returns (bool ok)
    {
        super.approve(spender, value);
    }
}
