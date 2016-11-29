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

import "./supply_controller.sol";

// The supply manager frontend interacts with tokens in an assymetric way:
// * `print` takes an argument and credits the caller, when successful
// * `burn` takes no argument and destroys *the frontend's* balance

contract DSTokenSupplyFrontend is DSAuth {
    DSTokenSupplyController _controller;
    function DSTokenController( DSTokenSupplyController controller ) {
        setSupplyController(controller);
    }
    function setSupplyController(DSTokenSupplyController controller)
        auth
    {
        _controller = controller;
    }
    event LogPrint(address indexed caller, uint amount);
    event LogBurn(address indexed caller, uint amount);
    // TODO use `emit` pattern?
    function print(uint amount)
    {
        _controller.demand(msg.sender, amount);
        LogPrint(msg.sender, amount);
    }
    function burn()
    {
        var amount = _controller.balanceOf(this);
        _controller.destroy(this, amount);
        LogBurn(msg.sender, amount);
    }
}
