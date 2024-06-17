// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.17;

interface IVault {
   
    function token() external view returns (address);
    
    function merkleRoot() external view returns (bytes32);
    
    function isWithdrawn(uint256 index) external view returns (bool);
   
    function withdraw(uint256 index, address account, uint256 amount, bytes32[] calldata merkleProof) external;

   
    event Withdrawn(uint256 index, address account, uint256 amount);
}