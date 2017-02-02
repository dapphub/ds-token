pragma solidity ^0.4.2;

// deprecated?
import 'token.sol';

contract DSTokenProvider {
    function getToken(bytes32 symbol) returns (DSToken);
    function tryGetToken(bytes32 symbol) returns (DSToken, bool ok);
}

