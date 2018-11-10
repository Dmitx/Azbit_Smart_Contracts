/**
 * @author https://github.com/Dmitx
 */

pragma solidity ^0.4.24;

import "./AzbitTokenInterface.sol";
import "./math/SafeMath.sol";
import "./AzbitPriceTicker.sol";


/**
 * @title AzbitReservedTokenLock
 * @dev Smart contract for reserved tokens
 */
contract AzbitReservedTokenLock is AzbitPriceTicker {
    using SafeMath for uint256;


    // ** EVENTS **

    // Event for token withdrawal logging
    event TokenWithdrawn(address indexed to, uint256 value);


    // ** PUBLIC STATE VARIABLES **

    // Azbit token
    AzbitTokenInterface public azbitToken;

    // Address for tokens withdrawal
    address public withdrawalAddress;

    // Number of withdrawn tokens
    uint256 public withdrawnTokens;

    // Lockout period after token purchase
    uint256 public constant lockPeriod = 5 * 365 days; // 5 years


    // ** CONSTRUCTOR **

    /**
    * @dev Constructor of AzbitReservedTokenLock Contract
    *
    * @param tokenAddress address of AzbitToken
    * @param tokenPrice initial price of AzbitToken in USD cents
    * @param beneficiary address for tokens withdrawal
    */
    constructor(
        address tokenAddress,
        uint256 tokenPrice,
        address beneficiary
    ) 
        public
        payable
        AzbitPriceTicker(tokenPrice)
    {
        require(beneficiary != address(0), "Address cannot be 0x0");

        _setToken(tokenAddress);
        withdrawalAddress = beneficiary;
    }


    // ** EXTERNAL FUNCTIONS **

    // Withdrawal tokens from this contract to withdrawalAddress
    function withdrawTokens()
        external
    {
        // amount for withdrawal
        uint256 amount = releasableAmount();

        require(amount > 0, "no tokens for withdrawal");

        // update state
        withdrawnTokens = withdrawnTokens.add(amount);

        // withdrawal to withdrawalAddress
        require(azbitToken.transfer(withdrawalAddress, amount), "tokens are not transferred");

        emit TokenWithdrawn(withdrawalAddress, amount);
    }

    
    // ** PUBLIC VIEW FUNCTIONS **

    /**
    * @return total tokens of this contract.
    */
    function contractTokenBalance()
        public 
        view 
        returns(uint256 amount) 
    {
        return azbitToken.balanceOf(this);
    }

    /**
    * @dev Gets unlocked percent of tokens
    * @return percentage of unlocked tokens
    */
    function getUnlockedPercent()
        public
        view
        returns(uint256 percentage)
    {
        return _rateUnlockedPercent();
    }

    /**
    * @dev Calculates the amount that has already available but hasn't been withdrawn yet
    * @return The amount of tokens
    */
    function releasableAmount() 
        public 
        view 
        returns (uint256 amount)
    {
        return contractTokenBalance().add(withdrawnTokens)
        .mul(getUnlockedPercent()).div(100)
        .sub(withdrawnTokens);
    }


    // ** PRIVATE HELPER FUNCTIONS **

    // Helper: Get percent of tokens unlocked with an increased rate
    function _rateUnlockedPercent()
        internal
        view
        returns(uint256 percentage)
    {
        if (_x5Count > _count) {
            return 100;
        } else if (_x4Count > _count) {
            return 75;
        } else if (_x3Count > _count) {
            return 50;
        } else if (_x2Count > _count) {
            return 25;
        }

        return 0;
    }

    // Helper: Set the address of azbitToken Token
    function _setToken(address tokenAddress) 
        internal 
    {
        azbitToken = AzbitTokenInterface(tokenAddress);
        require(contractTokenBalance() >= 0, "The token being added is not ERC20 token");
    }
}