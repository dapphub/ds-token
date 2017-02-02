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

import 'base.sol';

contract ERC20BaseFactory {
    function createERC20Base(uint initial_balance) returns (ERC20Base b) {
        b = new ERC20Base(initial_balance);
        b.transfer(msg.sender, initial_balance);
        return b;
    }
}
