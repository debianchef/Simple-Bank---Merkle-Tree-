// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "src/Vault.sol";
import "openzeppelin-contracts/contracts/utils/cryptography/MerkleProof.sol";
import {Ownable} from "openzeppelin-contracts/contracts/access/Ownable.sol";
import {IERC20, SafeERC20} from "openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import "murky/src/Merkle.sol";

contract Bank is Vault {
    using SafeERC20 for IERC20;

    uint256 public immutable endTime;
    mapping(address => uint256) private balances;
    Merkle public merkle;
    bytes32[] private leaves;

    constructor(address token_, bytes32 merkleRoot_, uint256 endTime_) Vault(token_, merkleRoot_) {
        if (endTime_ <= block.timestamp) revert EndTimeInPast();
        endTime = endTime_;
        merkle = new Merkle();
    }

    function deposit(uint256 amount) external {
        require(amount > 0, "Amount must be greater than 0");
        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);
        balances[msg.sender] += amount;

        bytes32 newLeaf = keccak256(abi.encodePacked(leaves.length, msg.sender, balances[msg.sender]));
        leaves.push(newLeaf);

        if (leaves.length >= 4) {
            merkleRoot = merkle.getRoot(leaves);
        }
    }

    function withdraw(uint256 index, address account, uint256 amount, bytes32[] calldata merkleProof) public override {
        if (block.timestamp > endTime) revert WithdrawWindowFinished();
        super.withdraw(index, account, amount, merkleProof);
    }

    function updateMerkleRoot(bytes32 newRoot) external {
        merkleRoot = newRoot;
    }



    function getBalance(address account) external view returns (uint256) {
        return balances[account];
    }

    error EndTimeInPast();
    error WithdrawWindowFinished();
}
