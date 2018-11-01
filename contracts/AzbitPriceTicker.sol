/**
 * @author https://github.com/Dmitx
 */

pragma solidity ^0.4.24;

import "./ownership/Ownable.sol";
import "./oraclize/oraclizeAPI_0.4.25.sol";


/**
 * @title AzbitPriceTicker
 * @dev Smart contract for check token price
 */
contract AzbitPriceTicker is Ownable, usingOraclize {


    // ** EVENTS **

    // Event for new oraclize query logging
    event NewOraclizeQuery(string description);

    // Event for new AzbitToken price ticker logging
    event NewPriceTicker(bytes32 myid, string price, bytes proof);

    // Event for new gas limit logging
    event SetNewGasLimit(uint256 newGasLimit);

    // Event for new gas price logging
    event SetNewGasPrice(uint256 newGasPrice);

    // Event for set oraclize proof logging
    event SetProof(string proofType);


    // ** PUBLIC STATE VARIABLES **

    // Initial price of AzbitToken in USD cents
    uint256 public initialPrice;

    // Oraclize query gas limit
    uint256 public oraclizeGasLimit;

    // Oraclize query gas price
    uint256 public oraclizeGasPrice;

    // Oraclize time of price update
    uint256 public constant updateTime = 6 hours; // each 6 hours

    
    // ** INTERNAL STATE VARIABLES **

    // Number of measurements – x2 (+100%)
    uint256 internal _x2Count = 1;

    // Number of measurements – x3 (+200%)
    uint256 internal _x3Count = 1;

    // Number of measurements – x4 (+300%)
    uint256 internal _x4Count = 1;

    // Number of measurements – x5 (+400%)
    uint256 internal _x5Count = 1;

    // Number of enought measurements
    uint256 internal constant _count = 30 * 4; // 30 days

    
    // ** PRIVATE STATE VARIABLES **

    // Used for validating Query IDs
    mapping(bytes32 => bool) private _validIds;

    // last update timestamp
    uint256 private _lastUpdateTime = 1;


    // ** CONSTRUCTOR **

    /**
    * @dev Constructor of AzbitPriceTicker Contract
    * @param tokenPrice initial price of AzbitToken in USD cents
    */
    constructor(
        uint256 tokenPrice
    ) 
        public 
        payable
    {
        require(tokenPrice > 0, "Price of AzbitToken cannot be zero");
        initialPrice = tokenPrice;

        // set oraclize query gas limit
        oraclizeGasLimit = 200000;

        // set oraclize gas price
        oraclizeGasPrice = 10000000000 wei;
        oraclize_setCustomGasPrice(oraclizeGasPrice);

        // set oraclize proof - NONE
        oraclize_setProof(proofType_NONE);

        _update();
    }

    
    // ** EXTERNAL PAYABLE FUNCTIONS **

    function() external payable {}


    // ** ONLY OWNER FUNCTIONS **

    /**
    * @dev Start updating of price
    */
    function startUpdatingPrice() 
        external 
        payable
        onlyOwner
    {
        if (now - 2 * updateTime > _lastUpdateTime) {
            _update();
        }
    }

    /**
    * @dev Set new gas limit for oraclize query
    */
    function setGasLimit(uint256 gasLimit) 
        external
        onlyOwner
    {
        require(gasLimit > 0, "gasLimit cannot be zero");
        oraclizeGasLimit = gasLimit;
        emit SetNewGasLimit(gasLimit);
    }

    /**
    * @dev Set new gas price for oraclize query
    */
    function setGasPrice(uint256 gasPrice) 
        external
        onlyOwner
    {
        require(gasPrice > 0, "gasPrice cannot be zero");
        oraclize_setCustomGasPrice(gasPrice);
        emit SetNewGasPrice(gasPrice);
    }

    /**
    * @dev Enable oraclize proof
    * Increase of query cost
    */
    function enableProof()
        external
        onlyOwner
    {
        oraclize_setProof(proofType_TLSNotary | proofStorage_IPFS);
        emit SetProof("TLSNotary and IPFS");
    }

    /**
    * @dev Disable oraclize proof
    * Decrease of query cost
    */
    function disableProof()
        external
        onlyOwner
    {
        oraclize_setProof(proofType_NONE);
        emit SetProof("NONE");
    }

    /**
    * @dev Withdrawal eth from contract
    * @param wallet for withdrawal
    * @param amount eth
    */
    function withdrawEth(address wallet, uint256 amount) 
        external 
        onlyOwner
    {
        require(amount <= address(this).balance, "Not enough funds");
        wallet.transfer(amount);
    }


    // ** PUBLIC VIEW FUNCTIONS **

    /**
    * @dev Gets number of price satisfactory measurements 
    * @return number of measurements
    */
    function getCurrentCount()
        public
        view
        returns(
            uint256 x2Count,
            uint256 x3Count,
            uint256 x4Count,
            uint256 x5Count
        )
    {
        return (_x2Count, _x3Count, _x4Count, _x5Count);
    }

    /**
    * @dev Gets number of price satisfactory days 
    * @return number of days
    */
    function getCurrentDays()
        public
        view
        returns(
            uint256 x2Days,
            uint256 x3Days,
            uint256 x4Days,
            uint256 x5Days
        )
    {
        return (_x2Count / 4, _x3Count / 4, _x4Count / 4, _x5Count / 4);
    }


    // ** ORACLIZE CALLBACKS **

    function __callback(
        bytes32 myId,
        string result
    )
        public 
    {
        require(msg.sender == oraclize_cbAddress(), "Sender is not Oraclize address");
        _oraclizeCallback(myId, result, "NONE");
    }

    function __callback(
        bytes32 myId,
        string result,
        bytes proof
    )
        public 
    {
        require(msg.sender == oraclize_cbAddress(), "Sender is not Oraclize address");
        _oraclizeCallback(myId, result, proof);
    }


    // ** PRIVATE HELPER FUNCTIONS **

    // Helper: oraclize query
    function _update() 
        internal 
    {   
        if (oraclize_getPrice("URL", oraclizeGasLimit) > address(this).balance) {
            emit NewOraclizeQuery("Oraclize query was NOT sent, please add some ETH to cover for the query fee");
        } else {
            emit NewOraclizeQuery("Oraclize query was sent, standing by for the answer..");
            bytes32 queryId = oraclize_query(updateTime, "URL", "json(https://api.azbit.com/api/v1/data).az", oraclizeGasLimit);
            
            // add query ID to mapping
            _validIds[queryId] = true;
        }
    }

    //Helper: oraclize callback
    function _oraclizeCallback(
        bytes32 queryId,
        string result,
        bytes proof
    )
        internal
    {
        // validate the ID 
        require(_validIds[queryId]);
        
        // reset mapping of this ID to false
        // this ensures the callback for a given queryID never called twice
        _validIds[queryId] = false;

        uint256 price = parseInt(result, 2); // in USD cent
        uint256 initPrice = initialPrice; // gas optimization

        // update states
        if (price >= 5 * initPrice) {
            _x2Count++;
            _x3Count++;
            _x4Count++;
            _x5Count++;
        } else if (price >= 4 * initPrice) {
            _x2Count++;
            _x3Count++;
            _x4Count++;
            _x5Count = 1;
        } else if (price >= 3 * initPrice) {
            _x2Count++;
            _x3Count++;
            _x4Count = 1;
            _x5Count = 1;
        } else if (price >= 2 * initPrice) {
            _x2Count++;
            _x3Count = 1;
            _x4Count = 1;
            _x5Count = 1;
        } else {
            _x2Count = 1;
            _x3Count = 1;
            _x4Count = 1;
            _x5Count = 1;
        }

        _lastUpdateTime = now;

        emit NewPriceTicker(queryId, result, proof);
        
        // update price after an updateTime
        _update();
    }
}