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

contract DSIDemandableToken is ERC20 {
    function demand(address who, uint amount);
}

contract DSDemandableToken is ERC20Base, DSAuth {
    function demand(address who, uint amount)
        auth {
        if( _balances[who] + amount < _balances[who] ) {
            throw;
        }
        _balances[who] += amount;
    }
}
