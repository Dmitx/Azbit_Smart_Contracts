# Smart Contracts for [Azbit](https://azbit.com/)

<p align="center">
  <img width="500" height ="500"  alt="Azbit logo" src = "./assets/logo-azbit.JPG">
</p>

# Dependencies 
[![truffle](https://img.shields.io/badge/truffle-docs-orange.svg)](https://truffleframework.com/docs)
[![solidity](https://img.shields.io/badge/solidity-docs-red.svg)](https://solidity.readthedocs.io/en/develop/)

# Smart contracts


## [Azbit Token](https://github.com/Dmitx/Azbit_Smart_Contracts/blob/master/contracts/AzbitToken.sol)
ERC20 standard token of Azbit project.



## [AzbitBounty Contract](https://github.com/Dmitx/Azbit_Smart_Contracts/blob/master/contracts/AzbitBounty.sol)
Bounty Smart Contract of Azbit project.


### List of owner functions:

Function | Params | Description
------------ | ------------- | -------------
**constructor** | (address) **tokenAddress** | Constructor of AzbitBounty Contract.
**sendTokens** | (address) **beneficiary**<br> (uint256) **amount** | Send tokens to beneficiary by owner.
**sendTokensArray** | (address[]) **beneficiaries**<br> (uint256[]) **amounts** | Send tokens to the array of beneficiaries  by owner.


### List of public view functions:

Function | Params | Description
------------ | ------------- | -------------
**azbitToken** | –– | Azbit token address.
**contractTokenBalance** | –– | Total tokens of this contract.



## [AzbitAirdrop Contract](https://github.com/Dmitx/Azbit_Smart_Contracts/blob/master/contracts/AzbitAirdrop.sol)
Airdrop Smart Contract of Azbit project.


### List of owner functions:

Function | Params | Description
------------ | ------------- | -------------
**constructor** | (address) **tokenAddress** | Constructor of AzbitAirdrop Contract.
**sendTokens** | (address) **beneficiary**<br> (uint256) **amount** | Send tokens to beneficiary by owner.
**sendTokensArray** | (address[]) **beneficiaries**<br> (uint256[]) **amounts** | Send tokens to the array of beneficiaries  by owner.


### List of public view functions:

Function | Params | Description
------------ | ------------- | -------------
**azbitToken** | –– | Azbit token address.
**contractTokenBalance** | –– | Total tokens of this contract.



## [AzbitAdvisors Contract](https://github.com/Dmitx/Azbit_Smart_Contracts/blob/master/contracts/AzbitAdvisors.sol)
Smart contract for distribution tokens to Azbit advisors.


### List of events:

Event | Params | Description
------------ | ------------- | -------------
**AdvisorAdded** | (address) **advisorAddress**<br> (TokenLockState) **advisorLockState**<br> (uint256) **advisorAmount** | Event for adding advisor logging.
**TokensWithdrawn** | (address) **advisorAddress**<br> (uint256) **amountWithdrawn**<br> (uint256) **amountOnContract**| Event for withdrawal tokens by advisor logging.


### List of enums:

Enum | States | Description
------------ | ------------- | -------------
**TokenLockState** | **NotAdvisor** (0)<br> **WithoutLock** (1)<br> **SixMonthLock** (2)<br> **OneYearLock** (3)| Token Lock State of advisors.


### List of structs:

Struct | Params | Description
------------ | ------------- | -------------
**AdvisorInfo** | (TokenLockState) **lockState**<br> (uint256) **tokensAmount**<br> (uint256) **withdrawnTokens**| Information about advisors.


### List of owner functions:

Function | Params | Description
------------ | ------------- | -------------
**constructor** | (address) **tokenAddress** | Constructor of AzbitAdvisors Contract.
**addAdvisor** | (address) **advisorAddr**<br> (TokenLockState) **advisorLockState**<br> (uint256) **advisorAmount** | Add advisor in advisors list.
**addAdvisorsArray** | (address[]) **advisorAddr**<br> (TokenLockState[]) **advisorLockState**<br> (uint256[]) **advisorAmount** | Add array of advisors in advisors list.


### List of external functions:

Function | Params | Description
------------ | ------------- | -------------
**withdrawTokens** | –– | Withdrawal tokens from this contract by advisors.


### List of public view functions:

Function | Params | Description
------------ | ------------- | -------------
**azbitToken** | –– | Azbit token address.
**advisors** | (address) **advisorAddr** | Gets the advisor info of the specified address.
**contractTokenBalance** | –– | Total tokens of this contract.
**tokenBalanceOf** | (address) **advisorAddr** | Gets the token balance of the specified address.
**getAdvisorInfo** | (address) **advisorAddr** | Gets the advisor info of the specified address.
**getStagesDates** | –– | Gets dates of release stages.
**getCurrentStage** | –– | Gets current stage of release.<br> Return stage number from 0 to 4.
**timeUntilNextUnlock** | –– | Time until the next unlock of tokens.
**releasableAmount** | (address) **advisorAddr** | Calculates the amount that has already available but hasn't been withdrawn yet.



## [AzbitUSResidents Contract](https://github.com/Dmitx/Azbit_Smart_Contracts/blob/master/contracts/AzbitUSResidents.sol)
Smart contract for distribution tokens to US Azbit investors.


### List of events:

Event | Params | Description
------------ | ------------- | -------------
**BalanceIncreased** | (address) **investorAddress**<br> (uint256) **amount**<br> (uint256) **investorBalance** | Event for increase of investor's balance logging.
**TokensWithdrawn** | (address) **investorAddress**<br> (uint256) **amountWithdrawn**<br> (uint256) **investorBalance**| Event for withdrawal tokens by investor logging.


### List of structs:

Struct | Params | Description
------------ | ------------- | -------------
**InvestorInfo** | (uint128) **totalBuy**<br> (uint128) **totalWithdrawn**<br> (uint32) **currentWithdrawal**<br> (uint128[]) **tokenAmounts**<br> (uint32[]) **unlockTimes**| Information about investors.


### List of owner functions:

Function | Params | Description
------------ | ------------- | -------------
**constructor** | (address) **tokenAddress** | Constructor of AzbitUSResidents Contract.
**increaseInvestorBalance** | (address) **beneficiary**<br> (uint256) **amount** | Increase tokens balance of investor.
**increaseInvestorsBalancesArray** | (address[]) **beneficiaries**<br> (uint256[]) **amounts** | Increase tokens the balance of the array of investors.


### List of external functions:

Function | Params | Description
------------ | ------------- | -------------
**withdrawTokens** | –– | Withdrawal tokens from this contract by investors.


### List of public view functions:

Function | Params | Description
------------ | ------------- | -------------
**azbitToken** | –– | Azbit token address.
**investors** | (address) **beneficiary** | Gets the investor info of the specified address.
**lockPeriod** | –– | Lockout period after token purchase –– 365 days.
**contractTokenBalance** | –– | Total tokens of this contract.
**tokenBalanceOf** | (address) **beneficiary** | Gets the token balance of the specified address.
**releasableAmount** | (address) **beneficiary** | Calculates the amount that has already available but hasn't been withdrawn yet.
**currentUnlockTime** | (address) **beneficiary** | Gets current next unlock timestamp of investor.
**latestUnlockTime** | (address) **beneficiary** | Gets latest unlock timestamp of investor.
**getInvestorInfo** | (address) **beneficiary** | Gets the investor info of the specified address.



## [Helper: AzbitPriceTicker Contract](https://github.com/Dmitx/Azbit_Smart_Contracts/blob/master/contracts/AzbitPriceTicker.sol)
Smart contract for check token price.


### List of events:

Event | Params | Description
------------ | ------------- | -------------
**NewOraclizeQuery** | (string) **description** | Event for new oraclize query logging.
**NewPriceTicker** | (bytes32) **myid**<br> (string) **price**<br> (bytes) **proof**| Event for new AzbitToken price ticker logging.
**SetNewGasLimit** | (uint256) **newGasLimit**| Event for new gas limit logging.
**SetNewGasPrice** | (uint256) **newGasPrice** | Event for new gas price logging.
**SetProof** | (string) **proofType** | Event for set oraclize proof logging.


### List of owner functions:

Function | Params | Description
------------ | ------------- | -------------
**constructor** | (uint256) **tokenPrice** | Constructor of AzbitPriceTicker Contract.<br> Initial price of AzbitToken in USD cents.<br> * payable
**startUpdatingPrice** | –– | Start updating of price.<br> * payable
**setGasLimit** | (uint256) **gasLimit** | Set new gas limit for oraclize query.
**setGasPrice** | (uint256) **gasPrice** | Set new gas price for oraclize query.
**enableProof** | –– | Enable oraclize proof.
**disableProof** | –– | Disable oraclize proof.
**withdrawEth** | (address) **wallet**<br> (uint256) amount | Withdrawal eth from contract.


### List of external functions:

Function | Params | Description
------------ | ------------- | -------------
**fallback** | –– | Payable.


### List of public view functions:

Function | Params | Description
------------ | ------------- | -------------
**initialPrice** | –– | Initial price of AzbitToken in USD cents.
**oraclizeGasLimit** | –– | Oraclize query gas limit.
**oraclizeGasPrice** | –– | Oraclize query gas price.
**updateTime** | –– | Oraclize time of price update.<br> Each 6 hours.
**getCurrentCount** | (uint256) **x2Count**<br> (uint256) **x3Count**<br> (uint256) **x4Count**<br> (uint256) **x5Count** | Gets number of price satisfactory measurements.
**getCurrentDays** | (uint256) **x2Days**<br> (uint256) **x3Days**<br> (uint256) **4Days**<br> (uint256) **x5Days** | Gets number of price satisfactory days.



## [AzbitTeamTokenLock Contract](https://github.com/Dmitx/Azbit_Smart_Contracts/blob/master/contracts/AzbitTeamTokenLock.sol)
Smart contract for lock tokens of founders and team.


### List of owner functions:

Function | Params | Description
------------ | ------------- | -------------
**constructor** | (address) **tokenAddress**<br> (uint256) **tokenPrice**<br> (address) **beneficiary** | Constructor of AzbitTeamTokenLock Contract.<br> * payable


### List of external functions:

Function | Params | Description
------------ | ------------- | -------------
**withdrawTokens** | –– | Withdrawal tokens from this contract to founders and team.


### List of public view functions:

Function | Params | Description
------------ | ------------- | -------------
**azbitToken** | –– | Azbit token.
**teamAddress** | –– | Address of founders and team.
**withdrawnTokens** | –– | Number of withdrawn tokens.
**lockPeriod** | –– | Lockout period after token purchase.<br> 2 years.
**contractTokenBalance** | –– | Total tokens of this contract.
**getReleaseDates** | –– | Gets dates of release stages (each stage – 25%).<br> Timestamps of stages.
**getCurrentStage** | –– | Gets current stage of release.<br> Stage number from 0 to 4.
**getUnlockedPercent** | –– | Gets unlocked percent of tokens.
**releasableAmount** | –– | Calculates the amount that has already available but hasn't been withdrawn yet.



## [AzbitReservedTokenLock Contract](https://github.com/Dmitx/Azbit_Smart_Contracts/blob/master/contracts/AzbitReservedTokenLock.sol)
Smart contract for reserved tokens.


### List of owner functions:

Function | Params | Description
------------ | ------------- | -------------
**constructor** | (address) **tokenAddress**<br> (uint256) **tokenPrice**<br> (address) **beneficiary** | Constructor of AzbitReservedTokenLock Contract.<br> * payable


### List of external functions:

Function | Params | Description
------------ | ------------- | -------------
**withdrawTokens** | –– | Withdrawal tokens from this contract to founders and team.


### List of public view functions:

Function | Params | Description
------------ | ------------- | -------------
**azbitToken** | –– | Azbit token.
**withdrawalAddress** | –– | Address for tokens withdrawal.
**withdrawnTokens** | –– | Number of withdrawn tokens.
**lockPeriod** | –– | Lockout period after token purchase.<br> 5 years.
**contractTokenBalance** | –– | Total tokens of this contract.
**getUnlockedPercent** | –– | Gets unlocked percent of tokens.
**releasableAmount** | –– | Calculates the amount that has already available but hasn't been withdrawn yet.



# Created by
[![Dmitx](https://img.shields.io/badge/github-Dmitx-green.svg?longCache=true&style=for-the-badge)](https://github.com/Dmitx)