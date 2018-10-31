/**
 * @author https://github.com/Dmitx
 */

pragma solidity ^0.4.24;

import "./AzbitTokenInterface.sol";
import "./math/SafeMath.sol";
import "./AzbitPriceTicker.sol";


/**
 * @title AzbitTeamTokenLock
 * @dev Smart contracts for lock tokens of founders and team
 */
contract AzbitTeamTokenLock is AzbitPriceTicker {
    using SafeMath for uint256;


    // ** PUBLIC STATE VARIABLES **

    // Azbit token
    AzbitTokenInterface public azbitToken;

    // Address of founders and team
    address public teamAddress;

    // Number of withdrawn tokens
    uint256 public withdrawnTokens;

    // Lockout period after token purchase
    uint256 public constant lockPeriod = 2 * 365 days; // 2 years


    // ** CONSTRUCTOR **

    /**
    * @dev Constructor of AzbitTeamTokenLock Contract
    *
    * @param tokenAddress address of AzbitToken
    * @param tokenPrice initial price of AzbitToken in USD cents
    * @param beneficiary address of founders and team for tokens withdrawal
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
        teamAddress = beneficiary;
    }


    // ** EXTERNAL FUNCTIONS **

    // Withdrawal tokens from this contract to founders and team
    function withdrawTokens()
        external
    {
        // amount for withdrawal
        uint256 amount = releasableAmount();

        require(amount > 0, "no tokens for withdrawal");

        // update state
        withdrawnTokens = withdrawnTokens.add(amount);

        // withdrawal to founders and team 
        require(azbitToken.transfer(teamAddress, amount), "tokens are not transferred");
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
    * @dev Gets dates of release stages (each stage – 25%)
    * @return timestamps of stages
    */
    function getReleaseDates()
        public
        view
        returns(
            uint256 stage1,
            uint256 stage2,
            uint256 stage3,
            uint256 stage4
        )
    {
        uint256 releaseDate = azbitToken.releaseDate();
        uint256 stagePeriod = lockPeriod / 4;

        return (
            releaseDate + stagePeriod,
            releaseDate + 2 * stagePeriod,
            releaseDate + 3 * stagePeriod,
            releaseDate + 4 * stagePeriod
        );
    }

    /**
    * @dev Gets current stage of release
    * @return Stage number from 0 to 4
    */
    function getCurrentStage()
        public
        view
        returns(uint256 stage)
    {
        (uint256 stage1, uint256 stage2, uint256 stage3, uint256 stage4) = getReleaseDates();

        if (now > stage4) {
            return 4;
        } else if (now > stage3) {
            return 3;
        } else if (now > stage2) {
            return 2;
        } else if (now > stage1) {
            return 1;
        }

        return 0;
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
        percentage = _rateUnlockedPercent() + _timeUnlockedPercent();

        if (percentage > 100) {
            return 100;
        }

        return percentage;
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

    // Helper: Get percent of tokens unlocked with an increased time
    function _timeUnlockedPercent()
        internal
        view
        returns(uint256 percentage)
    {
        // return percentage
        return 25 * getCurrentStage();
    }

    // Helper: Set the address of azbitToken Token
    function _setToken(address tokenAddress) 
        internal 
    {
        azbitToken = AzbitTokenInterface(tokenAddress);
        require(contractTokenBalance() >= 0, "The token being added is not ERC20 token");
    }
}