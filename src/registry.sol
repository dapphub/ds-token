import 'ds-data/nullmap.sol';
import 'provider.sol';

// Simple registry implementing DSTokenProvider
contract DSTokenRegistry is DSTokenProvider, DSNullMap {
    // throws.
    function getToken(bytes32 symbol) returns (DSToken) {
        return DSToken(address(get(symbol)));
    }
    function tryGetToken(bytes32 symbol) returns (DSToken token, bool ok) {
        var (_token, _ok) = tryGet(symbol);
        return (DSToken(address(_token)), _ok);
    }
}

