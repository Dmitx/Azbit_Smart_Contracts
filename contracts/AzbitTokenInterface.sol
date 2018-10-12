/**
 * @author https://github.com/Dmitx
 */

pragma solidity ^0.4.24;

import "./token/ERC20/IERC20.sol";


/**
 * @title AzbitTokenInterface
 * @dev ERC20 Token Interface for Azbit project
 */
contract AzbitTokenInterface is IERC20 {

    function releaseDate() external view returns (uint256);

}