pragma solidity ^0.4.11;

import './ProtexToken.sol';
import 'zeppelin-solidity/contracts/crowdsale/CappedCrowdsale.sol';


contract ProtexTokenCrowdsale is CappedCrowdsale {

  function ProtexCoinCrowdsale(uint256 _startBlock, uint256 _endBlock, uint256 _rate, address _wallet, uint256 cap) CappedCrowdsale(cap) Crowdsale(_startBlock, _endBlock, _rate, _wallet) {
  }

  // creates the token to be sold.
  // override this method to have crowdsale of a specific MintableToken token.
  function createTokenContract() internal returns (SimpleToken) {
    return new ProtexToken();
  }

}