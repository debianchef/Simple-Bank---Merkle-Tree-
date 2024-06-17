// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "src/Bank.sol";
import "src/MockERC20.sol";
import "murky/src/Merkle.sol";

contract BankTest is Test {
    Vault vault;
    Bank bank;
    MockERC20 token;
    Merkle merkle;

    function setUp() public {
        token = new MockERC20();
        merkle = new Merkle();

        vault = new Vault(address(token), bytes32(0));
        bank = new Bank(address(token), bytes32(0), block.timestamp + 1 days);

        // Mint tokens to the test account
        token.mint(address(this), 2000);
        // Approve bank contract to spend tokens
        token.approve(address(bank), 1000);
    }

    function testTokenAddress() public {
        assertEq(vault.token(), address(token));
        assertEq(bank.token(), address(token));
    }

    function testMerkleRoot() public {
        assertEq(vault.merkleRoot(), bytes32(0));
        assertEq(bank.merkleRoot(), bytes32(0));
    }

    function testDeposit() public {
        uint256 depositAmount = 1000;
        uint256 initialBalance = token.balanceOf(address(this));

        // Deposit tokens
        bank.deposit(depositAmount);

        // Check balances after deposit
        assertEq(bank.getBalance(address(this)), depositAmount);
        assertEq(token.balanceOf(address(this)), initialBalance - depositAmount);
    }


}
