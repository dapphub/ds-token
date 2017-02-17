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

contract DSTokenRules {
    function canTransfer(address caller, address from, address to, uint amount)
        constant returns (bool);
    function canApprove(address caller, address spender, uint amount)
        constant returns (bool);
}
