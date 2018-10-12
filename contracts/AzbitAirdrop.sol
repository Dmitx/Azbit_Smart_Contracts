/**
 * @author https://github.com/Dmitx
 */

pragma solidity ^0.4.24;

import "./ownership/Ownable.sol";
import "./AzbitTokenInterface.sol";


/**
 * @title AzbitAirdrop
 * @dev Airdrop Smart Contract of Azbit project
 */
contract AzbitAirdrop is Ownable {

    // ** PUBLIC STATE VARIABLES **

    // Azbit token
    AzbitTokenInterface public azbitToken;

    
    // ** EVENTS **

    /**
     * Event for token address update logging
     * @param previousToken address of previous token
     * @param newToken address of new token
     */
    event TokenAddressUpdated(
        address indexed previousToken,
        address indexed newToken
    );


    // ** CONSTRUCTOR **

    /**
    * @dev Constructor of AzbitAirdrop Contract
    * @param tokenAddress address of AzbitToken
    */
    constructor(
        address tokenAddress
    ) 
        public 
    {
        _setToken(tokenAddress);
        emit TokenAddressUpdated(address(0), azbitToken);
    }


    // ** ONLY OWNER FUNCTIONS **

    // Set the address of Azbit Token
    function setToken(address tokenAddress) 
        external 
        onlyOwner 
    {
        emit TokenAddressUpdated(azbitToken, tokenAddress);
        _setToken(tokenAddress);
    }

    // Send tokens to beneficiary by owner
    function sendTokens(
        address beneficiary,
        uint256 amount
    )
        external
        onlyOwner
    {
        require(amount <= contractTokenBalance(), "not enough tokens on this contract");
        require(azbitToken.transfer(beneficiary, amount), "tokens are not transferred");
    }


    // ** PUBLIC VIEW FUNCTIONS **

    /**
    * @return total tokens of this contract.
    */
    function contractTokenBalance()
        public 
        view 
        returns(uint256) 
    {
        return azbitToken.balanceOf(this);
    }


    // ** PRIVATE HELPER FUNCTIONS **

    // Helper: Set the address of Azbit Token
    function _setToken(address tokenAddress) 
        internal 
    {
        azbitToken = AzbitTokenInterface(tokenAddress);
        require(contractTokenBalance() >= 0, "The token being added is not ERC20 token");
    }
}