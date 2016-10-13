pragma solidity ^0.4.2;

contract DSTokenEventCallback {
    function emitTransfer( address from, address to, uint amount );
    function emitApproval( address holder, address spender, uint amount );
}
