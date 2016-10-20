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

import 'ds-auth/auth.sol';

contract DSApprovalDBEvents {
    event Approval( address indexed owner, address indexed spender, uint value );
}

// Spending approval for standard token pattern (see `token/EIP20.sol`)
contract DSApprovalDB is DSAuth, DSApprovalDBEvents {
    mapping(address => mapping( address=>uint)) _approvals;

    function setApproval( address holder, address spender, uint amount )
             auth()
    {
        _approvals[holder][spender] = amount;
        Approval( holder, spender, amount );
    }
    function getApproval( address holder, address spender )
             returns (uint amount )
    {
        return _approvals[holder][spender];
    }
}
