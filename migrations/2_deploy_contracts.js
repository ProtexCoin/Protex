//var ConvertLib = artifacts.require("./ConvertLib.sol");
//var MetaCoin = artifacts.require("./MetaCoin.sol");
var ProtexCoinCrowdsale = artifacts.require("./ProtexTokenCrowdsale.sol")


module.exports = function(deployer, network, accounts) {
	//TODO: set all of these variables properly, just place holders for now
  const startBlock = web3.eth.blockNumber + 2
  const endBlock = startBlock + 300
  const rate = new web3.BigNumber(1000)
  const wallet = web3.eth.accounts[0]

  deployer.deploy(ProtexTokenCrowdsale, startBlock, endBlock, rate, wallet);
};
