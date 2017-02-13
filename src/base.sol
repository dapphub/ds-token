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

pragma solidity ^0.4.9;

// Good old ERC20 implementation
// You probably want `DSToken` which has some `auth`ed backdoors for giving it extra functionality
// Everything throws instead of returning false on failure.

import 'erc20/erc20.sol';

contract DSTokenBase is ERC20
{
    mapping( address => uint ) _balances;
    mapping( address => mapping( address => uint ) ) _approvals;
    uint _supply;
    function DSTokenBase( uint initial_balance ) {
        _balances[msg.sender] = initial_balance;
        _supply = initial_balance;
    }
    function totalSupply() constant returns (uint supply) {
        return _supply;
    }
    function balanceOf( address who ) constant returns (uint value) {
        return _balances[who];
    }
    function transfer( address to, uint value) returns (bool ok) {
        if( _balances[msg.sender] < value ) {
            throw;
        }
        if( !safeToAdd(_balances[to], value) ) {
            throw;
        }
        _balances[msg.sender] -= value;
        _balances[to] += value;
        Transfer( msg.sender, to, value );
        return true;
    }
    function transferFrom( address from, address to, uint value) returns (bool ok) {
        // if you don't have enough balance, throw
        if( _balances[from] < value ) {
            throw;
        }
        // if you don't have approval, throw
        if( _approvals[from][msg.sender] < value ) {
            throw;
        }
        if( !safeToAdd(_balances[to], value) ) {
            throw;
        }
        // transfer and return true
        _approvals[from][msg.sender] -= value;
        _balances[from] -= value;
        _balances[to] += value;
        Transfer( from, to, value );
        return true;
    }
    function approve(address spender, uint value) returns (bool ok) {
        _approvals[msg.sender][spender] = value;
        Approval( msg.sender, spender, value );
        return true;
    }
    function allowance(address owner, address spender) constant returns (uint _allowance) {
        return _approvals[owner][spender];
    }
    function safeToAdd(uint a, uint b) internal returns (bool) {
        return (a + b >= a);
    }
}
