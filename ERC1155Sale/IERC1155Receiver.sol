// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

interface IERC1155Receiver {
    function onERC1155Received(
        address operator,
        address from,
        address to,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);


}