pragma solidity ^0.4.11;

import 'zeppelin-solidity/contracts/token/SimpleToken.sol';

contract ProtexToken is SimpleToken {
  string public name = "Protex Token";
  string public symbol = "PTX";
  uint256 public decimals = 18;
  uint256 public INITIAL_SUPPLY = 1000000000000000000000000000;

}