pragma solidity ^0.4.11;

import 'zeppelin-solidity/contracts/token/MintableToken.sol';

contract ProtexCoin is MintableToken {
  string public name = "Protex Coin";
  string public symbol = "PTX";
  uint256 public decimals = 10;
}