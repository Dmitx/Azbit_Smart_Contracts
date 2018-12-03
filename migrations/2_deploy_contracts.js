var AzbitToken = artifacts.require("./AzbitToken.sol");
var Bounty = artifacts.require("./AzbitBounty.sol");
var Airdrop = artifacts.require("./AzbitAirdrop.sol");
var Advisors = artifacts.require("./AzbitAdvisors.sol");
var USResidents = artifacts.require("./AzbitUSResidents.sol");
var TeamTokenLock = artifacts.require("./AzbitTeamTokenLock.sol");
var ReservedTokenLock = artifacts.require("./AzbitReservedTokenLock.sol");

const initialETH = 1e17; // initial balance for Oraclize update
const initialSupply = 1e9;
const tokenName = "Azbit Token";
const tokenSymbol = "AZ";
const initialTokenPrice = 120000; // price in USD * 1e9
const teamAddress = "0x627306090abaB3A6e1400e9345bC60c78a8BEf57";
const reservedAddress = "0x627306090abaB3A6e1400e9345bC60c78a8BEf57";

module.exports = function(deployer) {
  deployer.deploy(AzbitToken,
    initialSupply, tokenName, tokenSymbol
  ).then(function() {
      return deployer.deploy(Bounty,
        AzbitToken.address);
  }).then(function() {
    return deployer.deploy(Airdrop,
      AzbitToken.address);
  }).then(function() {
    return deployer.deploy(Advisors,
      AzbitToken.address);
  }).then(function() {
    return deployer.deploy(USResidents,
      AzbitToken.address);
  }).then(function() {
    return deployer.deploy(TeamTokenLock,
      AzbitToken.address, initialTokenPrice, teamAddress,
      {value: initialETH});  // send eth
  }).then(function() {
    return deployer.deploy(ReservedTokenLock,
      AzbitToken.address, initialTokenPrice, reservedAddress,
      {value: initialETH});  // send eth
  })
};