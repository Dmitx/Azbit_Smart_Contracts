/**
 * @author https://github.com/Dmitx
 */

pragma solidity ^0.4.24;

import "./ownership/Ownable.sol";
import "./AzbitTokenInterface.sol";
import "./math/SafeMath.sol";
import "./math/SafeMath128.sol";


/**
 * @title AzbitUSResidents
 * @dev Smart contracts for distribution tokens to US Azbit investors
 */
contract AzbitUSResidents is Ownable {
    using SafeMath for uint256;
    using SafeMath128 for uint128;


    // ** EVENTS **

    /**
     * Event for increase of investor's balance logging
     * @param investorAddress The address of investor
     * @param amount The token amount added to investor balance
     * @param investorBalance Updated balance of investor
     */
    event BalanceIncreased(
        address indexed investorAddress,
        uint256 amount,
        uint256 investorBalance
    );

    /**
     * Event for withdrawal tokens by investor logging
     * @param investorAddress The address of investor
     * @param amountWithdrawn The token amount withdrawn
     * @param investorBalance Updated balance of investor
     */
    event TokensWithdrawn(
        address indexed investorAddress,
        uint256 amountWithdrawn,
        uint256 investorBalance
    );


    // ** STRUCTS **

    struct InvestorInfo {
        // @dev The amount of tokens buy by the investor
        uint128 totalBuy;

        // @dev The amount of tokens withdrawn by the investor
        uint128 totalWithdrawn;

        // @dev Current number of withdrawal
        uint32 currentWithdrawal;

        // @dev The array of token amounts
        uint128[] tokenAmounts;

        // @dev The array of unlock times
        uint32[] unlockTimes;
    }


    // ** PUBLIC STATE VARIABLES **

    // Azbit token
    AzbitTokenInterface public azbitToken;

    // Investors info
    mapping(address => InvestorInfo) public investors;

    // Lockout period after token purchase
    uint256 public constant lockPeriod = 365 days; // 1 year


    // ** PRIVATE STATE VARIABLES **

    // Max purchase of tokens for one withdrawal (for not reaching gas limit)
    uint256 private constant MAX_WITHDRAWAL_LIMIT = 1000;

    
    // ** CONSTRUCTOR **

    /**
    * @dev Constructor of AzbitUSResidents Contract
    *
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
    * @dev Increase tokens balance of investor
    * @param beneficiary The address for tokens withdrawal
    * @param amount The token amount for increase
    */
    function increaseInvestorBalance(
        address beneficiary, 
        uint256 amount
    )
        external
        onlyOwner
    {
        _increaseBalance(beneficiary, amount);
    }

    /**
    * @dev Increase tokens the balance of the array of investors
    * @param beneficiaries The array of addresses for tokens withdrawal
    * @param amounts The array of tokens amount for increase
    */
    function increaseInvestorsBalancesArray(
        address[] beneficiaries, 
        uint256[] amounts
    )
        external
        onlyOwner
    {
        require(beneficiaries.length == amounts.length, "array lengths have to be equal");
        require(beneficiaries.length > 0, "array lengths have to be greater than zero");

        for (uint256 i = 0; i < beneficiaries.length; i++) {
            _increaseBalance(beneficiaries[i], amounts[i]);
        }
    }


    // ** EXTERNAL FUNCTIONS **

    // Withdrawal tokens from this contract
    // Available when the contract is not paused
    function withdrawTokens()
        external
    {
        (uint256 amount, uint256 count) = _getWithdrawalInfo(msg.sender);

        require(amount > 0, "no tokens for withdrawal");

        // update states
        investors[msg.sender].totalWithdrawn = investors[msg.sender].totalWithdrawn.add(uint128(amount));
        investors[msg.sender].currentWithdrawal += uint32(count);
        
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
        returns(uint256 amount) 
    {
        return azbitToken.balanceOf(this);
    }

    /**
    * @dev Gets the token balance of the specified address
    * @param beneficiary The address to query the balance of
    * @return An uint256 representing the amount owned by the passed address
    */
    function tokenBalanceOf(address beneficiary) 
        public 
        view 
        returns (uint256 amount) 
    {
        return investors[beneficiary].totalBuy.sub(investors[beneficiary].totalWithdrawn);
    }

    /**
    * @dev Calculates the amount that has already available but hasn't been withdrawn yet
    * @param beneficiary The address of investor
    * @return The amount of tokens
    */
    function releasableAmount(address beneficiary) 
        public 
        view 
        returns (uint256 amount)
    {
        // The address is not in the list of investors
        if (investors[beneficiary].tokenAmounts.length == 0) {
            return 0;
        }
        
        (amount, ) = _getWithdrawalInfo(beneficiary);
        return amount;
    }

    /**
    * @dev Gets current next unlock timestamp of investor
    * @param beneficiary The address of investor
    * @return Current next or latest (in the case of the last or all withdrawals) unlock timestamp
    */
    function currentUnlockTime(address beneficiary) 
        public 
        view 
        returns (uint256 ts)
    {
        // The address is not in the list of investors
        if (investors[beneficiary].tokenAmounts.length == 0) {
            return 0;
        }

        uint256 curWithdrawal = investors[beneficiary].currentWithdrawal;
        if (curWithdrawal < investors[beneficiary].unlockTimes.length) {
            return investors[beneficiary].unlockTimes[curWithdrawal];
        }

        // latest unlock time
        return latestUnlockTime(beneficiary);
    }

    /**
    * @dev Gets latest unlock timestamp of investor
    * @param beneficiary The address of investor
    * @return Latest unlock timestamp
    */
    function latestUnlockTime(address beneficiary) 
        public 
        view 
        returns (uint256 ts)
    {
        // The address is not in the list of investors
        if (investors[beneficiary].tokenAmounts.length == 0) {
            return 0;
        }

        return investors[beneficiary].unlockTimes[investors[beneficiary].unlockTimes.length - 1];
    }

    /**
    * @dev Gets the investor info of the specified address
    * @param beneficiary The address of investor
    * @return Investor info
    */
    function getInvestorInfo(address beneficiary) 
        public 
        view 
        returns (
            uint256 totalBuy,
            uint256 totalWithdrawn,
            uint32 currentWithdrawal,
            uint128[] tokenAmounts,
            uint32[] unlockTimes
        )
    {
        totalBuy = investors[beneficiary].totalBuy;
        totalWithdrawn = investors[beneficiary].totalWithdrawn;
        currentWithdrawal = investors[beneficiary].currentWithdrawal;
        tokenAmounts = investors[beneficiary].tokenAmounts;
        unlockTimes = investors[beneficiary].unlockTimes;
        return (totalBuy, totalWithdrawn, currentWithdrawal, tokenAmounts, unlockTimes);
    }


    // ** PRIVATE HELPER FUNCTIONS **

    // Helper: Find amount of tokens for withdrawal and number of withdrawals
    // Limits information about 100 buies of tokens
    function _getWithdrawalInfo(address beneficiary) 
        internal
        view
        returns(
            uint256 amount,
            uint256 number
        )
    {
        require(investors[beneficiary].tokenAmounts.length > 0, "The address is not in the list of investors");
        
        uint256 curWithdrawal = investors[beneficiary].currentWithdrawal;

        while (curWithdrawal < investors[beneficiary].tokenAmounts.length &&
                investors[beneficiary].unlockTimes[curWithdrawal] < now && number < MAX_WITHDRAWAL_LIMIT) {
            amount = amount.add(investors[beneficiary].tokenAmounts[curWithdrawal]);
            curWithdrawal++;
            number++;
        }

        return(amount, number);
    }

    // Helper: Set the address of azbitToken Token
    function _setToken(address tokenAddress) 
        internal 
    {
        azbitToken = AzbitTokenInterface(tokenAddress);
        require(contractTokenBalance() >= 0, "The token being added is not ERC20 token");
    }

    // Helper: increase balance of beneficiary
    function _increaseBalance(
        address beneficiary, 
        uint256 amount
    )
        internal
    {
        require(beneficiary != address(0), "Address cannot be 0x0");
        require(amount > 0, "Amount cannot be zero");
        require(amount == uint128(amount), "Too large amount");

        // update states
        investors[beneficiary].totalBuy = investors[beneficiary].totalBuy.add(uint128(amount));
        investors[beneficiary].tokenAmounts.push(uint128(amount));
        investors[beneficiary].unlockTimes.push(uint32(now + lockPeriod));

        emit BalanceIncreased(beneficiary, amount, tokenBalanceOf(beneficiary));
    }
}