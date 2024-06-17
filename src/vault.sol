// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "src/interface/IVault.sol";
import "openzeppelin-contracts/contracts/utils/cryptography/MerkleProof.sol";
import {IERC20, SafeERC20} from "openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";

contract Vault is IVault {
    using SafeERC20 for IERC20;

    address public immutable override token;
    bytes32 public  override merkleRoot;

    // This is a packed array of booleans.
    mapping(uint256 => uint256) private withdrawnBitMap;

    constructor(address token_, bytes32 merkleRoot_) {
        token = token_;
        merkleRoot = merkleRoot_;
    }

    function isWithdrawn(uint256 index) public view  returns (bool) {
        uint256 withdrawnWordIndex = index / 256;
        uint256 withdrawnBitIndex = index % 256;
        uint256 withdrawnWord = withdrawnBitMap[withdrawnWordIndex];
        uint256 mask = (1 << withdrawnBitIndex);
        return withdrawnWord & mask == mask;
    }

    function _setWithdrawn(uint256 index) private {
        uint256 withdrawnWordIndex = index / 256;
        uint256 withdrawnBitIndex = index % 256;
        withdrawnBitMap[withdrawnWordIndex] = withdrawnBitMap[withdrawnWordIndex] | (1 << withdrawnBitIndex);
    }

    function withdraw(uint256 index, address account, uint256 amount, bytes32[] calldata merkleProof)
        public
        virtual

    {
        if (isWithdrawn(index)) revert AlreadyWithdrawn();

        // Verify the merkle proof.
        bytes32 node = keccak256(abi.encodePacked(index, account, amount));
        if (!MerkleProof.verify(merkleProof, merkleRoot, node)) revert InvalidProof();

        // Mark it withdrawn and send the token.
        _setWithdrawn(index);
        IERC20(token).safeTransfer(account, amount);

       emit Withdrawn(index, account, amount);
    }

    error AlreadyWithdrawn();
    error InvalidProof();
}
