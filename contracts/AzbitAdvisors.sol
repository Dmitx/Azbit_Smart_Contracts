/**
 * @author https://github.com/Dmitx
 */

pragma solidity ^0.4.24;

import "./ownership/Ownable.sol";
import "./AzbitTokenInterface.sol";
import "./math/SafeMath.sol";


/**
 * @title AzbitAdvisors
 * @dev Smart contracts for distribution tokens to Azbit advisors
 */
contract AzbitAdvisors is Ownable {
    using SafeMath for uint256;

    // ** EVENTS **

    /**
     * Event for adding advisor logging
     * @param advisorAddress The address of advisor
     * @param advisorLockState The TokenLockState of current advisor
     * @param advisorAmount The token amount of current advisor
     */
    event AdvisorAdded(
        address indexed advisorAddress,
        TokenLockState advisorLockState,
        uint256 advisorAmount
    );

    /**
     * Event for withdrawal tokens by advisor logging
     * @param advisorAddress The address of advisor
     * @param amountWithdrawn The token amount withdrawn
     * @param amountOnContract The token amount remaining on contract
     */
    event TokensWithdrawn(
        address indexed advisorAddress,
        uint256 amountWithdrawn,
        uint256 amountOnContract
    );


    // ** ENUMS **

    /**
    * @dev Token Lock State of advisors 
    */
    enum TokenLockState {
        // @dev Not advisor
        NotAdvisor, // 0

        // @dev Without Token Lock
        WithoutLock, // 1

        // @dev 6 month Token Lock with 50% unlocking after 3 months
        SixMonthLock, // 2

        // @dev 1 year Token Lock with 25% unlocking each 3 months
        OneYearLock // 3
    }


    // ** STRUCTS **

    struct AdvisorInfo {
        TokenLockState lockState;
        uint256 tokensAmount;
        uint256 withdrawnTokens;
    }


    // ** PUBLIC STATE VARIABLES **

    // Azbit token
    AzbitTokenInterface public azbitToken;

    // Set of Advisors
    mapping(address => AdvisorInfo) public advisors;

    
    // ** CONSTRUCTOR **

    /**
    * @dev Constructor of AzbitAdvisors Contract
    * @param tokenAddress address of AzbitToken
    */
    constructor(
        address tokenAddress
    ) 
        public 
    {
        _setToken(tokenAddress);
    }


    // ** ONLY OWNER FUNCTIONS **

    /**
    * @dev Add advisor in advisors list
    * @param advisorAddr The address of advisor
    * @param advisorLockState The TokenLockState of current advisor
    * @param advisorAmount The token amount of current advisor
    */
    function addAdvisor(
        address advisorAddr,
        TokenLockState advisorLockState,
        uint256 advisorAmount
    )
        external
        onlyOwner
    {
        _addAdvisor(advisorAddr, advisorLockState, advisorAmount);
    }

    /**
    * @dev Add array of advisors in advisors list
    * @param advisorsAddr The array of addresses for tokens withdrawal
    * @param advisorsLockState The array of TokenLockStates of current advisors
    * @param advisorsAmount The array of token amount of current advisors
    */
    function addAdvisorsArray(
        address[] advisorsAddr,
        TokenLockState[] advisorsLockState,
        uint256[] advisorsAmount
    )
        external
        onlyOwner
    {
        require(advisorsAddr.length == advisorsLockState.length, "array lengths have to be equal");
        require(advisorsAddr.length == advisorsAmount.length, "array lengths have to be equal");
        require(advisorsAddr.length > 0, "array lengths have to be greater than zero");

        for (uint256 i = 0; i < advisorsAddr.length; i++) {
            _addAdvisor(advisorsAddr[i], advisorsLockState[i], advisorsAmount[i]);
        }
    }


    // ** EXTERNAL FUNCTIONS **

    // Withdrawal tokens from this contract by advisors
    function withdrawTokens()
        external
    {
        // amount for withdrawal
        uint256 amount = _getAmountForWithdrawal(msg.sender);

        require(amount > 0, "no tokens for withdrawal");

        // update states
        advisors[msg.sender].withdrawnTokens = advisors[msg.sender].withdrawnTokens.add(amount);

        require(azbitToken.transfer(msg.sender, amount), "tokens are not transferred");

        emit TokensWithdrawn(msg.sender, amount, tokenBalanceOf(msg.sender));
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

    /**
    * @dev Gets the token balance of the specified address
    * @param advisorAddr The address to query the balance of
    * @return An uint256 representing the amount owned by the passed address
    */
    function tokenBalanceOf(address advisorAddr) 
        public 
        view 
        returns (uint256) 
    {
        return advisors[advisorAddr].tokensAmount.sub(advisors[advisorAddr].withdrawnTokens);
    }

    /**
    * @dev Gets the advisor info of the specified address
    * @param advisorAddr address of advisor 
    * @return Token lock state and tokens amount of current advisor
    */
    function getAdvisorInfo(address advisorAddr) 
        public 
        view 
        returns (
            TokenLockState lockState,
            uint256 tokensAmount,
            uint256 withdrawnTokens
        )
    {
        lockState = advisors[advisorAddr].lockState;
        tokensAmount = advisors[advisorAddr].tokensAmount;
        withdrawnTokens = advisors[advisorAddr].withdrawnTokens;
        return (lockState, tokensAmount, withdrawnTokens);
    }

    function getCurrentStage()
        public
        view
        returns(uint256 stage)
    {
        uint256 releaseDate = azbitToken.releaseDate();

        if (now > releaseDate + 1 years) {
            return 4;
        } else if (now > releaseDate + 270 days) {
            return 3;
        } else if (now > releaseDate + 180 days) {
            return 2;
        } else if (now > releaseDate + 90 days) {
            return 1;
        }

        return 0;
    }


    // ** PRIVATE HELPER FUNCTIONS **

    // Helper: get current tokens for withdrawal by advisor
    function _getAmountForWithdrawal(address advisorAddr)
        internal
        view
        returns (uint256 amount)
    {
        uint256 currentStage = getCurrentStage();

        if (advisors[advisorAddr].lockState == TokenLockState.WithoutLock) {
            // 100% of advisor's tokens
            return advisors[advisorAddr].tokensAmount.sub(advisors[advisorAddr].withdrawnTokens);
        } else if (advisors[advisorAddr].lockState == TokenLockState.SixMonthLock &&
                   currentStage > 0) {
            if (currentStage >= 2) {
                // 100% of advisor's tokens
                return advisors[advisorAddr].tokensAmount.sub(advisors[advisorAddr].withdrawnTokens);
            }
            // 50% of advisor's tokens
            return advisors[advisorAddr].tokensAmount.div(2).sub(advisors[advisorAddr].withdrawnTokens);
        } else if (advisors[advisorAddr].lockState == TokenLockState.OneYearLock &&
                   currentStage > 0) {
            // 25% of advisor's tokens each 3 months
            return advisors[advisorAddr].tokensAmount.mul(currentStage).div(4).sub(advisors[advisorAddr].withdrawnTokens);
        }

        return 0;
    }
    
    // Helper: Set the address of Azbit Token
    function _setToken(address tokenAddress) 
        internal 
    {
        azbitToken = AzbitTokenInterface(tokenAddress);
        require(contractTokenBalance() >= 0, "The token being added is not ERC20 token");
    }

    // Helper: add advisor in advisors list
    function _addAdvisor(
        address advisorAddr,
        TokenLockState advisorLockState,
        uint256 advisorAmount
    )
        internal
    {
        require(advisorAddr != address(0), "Address cannot be 0x0");
        require(advisors[advisorAddr].lockState == TokenLockState.NotAdvisor, "Address already added");
        require(advisorLockState != TokenLockState.NotAdvisor, "Invalid Token Lock State");
        require(advisorAmount > 0, "Amount cannot be zero");

         // update state
        advisors[advisorAddr] = AdvisorInfo(advisorLockState, advisorAmount, 0);

        emit AdvisorAdded(advisorAddr, advisorLockState, advisorAmount);
    }
}