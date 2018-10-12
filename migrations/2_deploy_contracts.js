var AzbitToken = artifacts.require("./AzbitToken.sol");
var Bounty = artifacts.require("./AzbitBounty.sol");
var Airdrop = artifacts.require("./AzbitAirdrop.sol");

const initialSupply = 1e9;
const tokenName = "Azbit Token";
const tokenSymbol = "AZ";

module.exports = function(deployer) {
  deployer.deploy(AzbitToken,
    initialSupply, tokenName, tokenSymbol
  ).then(function() {
      return deployer.deploy(Bounty,
        AzbitToken.address);
  }).then(function() {
    return deployer.deploy(Airdrop,
      AzbitToken.address);
  })
};