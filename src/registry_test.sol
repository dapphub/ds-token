import 'dapple/test.sol';
import 'registry.sol';

contract TokenRegistryTest is Test {
    uint constant issuedAmount = 1000;

    address token;
    DSTokenRegistry registry;

    function setUp() {
        registry = new DSTokenRegistry();
        token = 0x1111111111111111111111111111111111111111;
    }

    function testGetToken() {
        bytes32 tokenName = "Kanye Coin";
        registry.set(tokenName, bytes32(address(token)));
        assertEq(registry.getToken(tokenName), token);
    }
    function testFailGetUnsetToken() {
        bytes32 tokenName = "Kanye Coin";
        assertEq(registry.getToken(tokenName), token);
    }
    function testTryGetToken() {
        bytes32 tokenName = "Kanye Coin";
        registry.set(tokenName, bytes32(address(token)));
        var (_token, ok) = registry.tryGetToken(tokenName);
        assertTrue(ok);
        assertEq(token, _token);
        (_token, ok) = registry.tryGetToken("NIL");
        assertFalse(ok);
    }
}
