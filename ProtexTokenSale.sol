/*
Smart contract for the Token Sale of Protex Tokens (PTX). 

Owned and developed by Protex, LLC.
*/

pragma solidity ^0.4.8;

//zeppelin safe math for security against potential attacks

contract SafeMath{
  function safeMul(uint a, uint b) internal returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function safeDiv(uint a, uint b) internal returns (uint) {
    assert(b > 0);
    uint c = a / b;
    assert(a == b * c + a % b);
    return c;
  }
	
	function safeSub(uint a, uint b) internal returns (uint) {
    	assert(b <= a);
    	return a - b;
  }

	function safeAdd(uint a, uint b) internal returns (uint) {
    	uint c = a + b;
    	assert(c >= a);
    	return c;
  }
	function assert(bool assertion) internal {
	    if (!assertion) {
	      revert();
	    }
	}
}

//erc20 token standard implementable

contract ERC20{

  //function totalSupply() constant returns (uint256 totalSupply) {}
	//function balanceOf(address _owner) constant returns (uint256 balance) {}
	//function transfer(address _recipient, uint256 _value) returns (bool success) {}
	//function transferFrom(address _from, address _recipient, uint256 _value) returns (bool success) {}
	//function approve(address _spender, uint256 _value) returns (bool success) {}
	//function allowance(address _owner, address _spender) constant returns (uint256 remaining) {}

	event Transfer(address indexed _from, address indexed _recipient, uint256 _value);
	event Approval(address indexed _owner, address indexed _spender, uint256 _value);

}


//the Protex token sale

contract ProtexSale is ERC20, SafeMath{


  string  public name = "Protex Token";
  string  public symbol = "PTX";
  uint  public decimals = 18;
  uint256 public INITIAL_SUPPLY = 1000000000000000000000000000; //1 billion circulating supply
  uint256 public PRIMARY_BONUS = 10; //10% bonus for contributors in the first week 
  uint256 public SECONDARY_BONUS = 5; //5% bonus for contributors in the second week
  uint256 public totalSupply; //total supply of PTX
  uint256 public TOKEN_SALE_PRICE = 4000000000000000000000; //1 ETH = 4000 PTX in the token sale
  uint256 public PRE_SALE_PRICE = 5000000000000000000000; //1 ETH = 5000 PTX in the pre sale
  uint256 public preSalePurchased; //counter for tokens purchased in pre sale
  uint256 public tokenSalePurchased; //counter for tokens puchsed in token sale
  uint256 public PRE_SALE_CAP = 200000000000000000000000000; //200,000,000 PTX available for pre-sale
  uint256 public TOKEN_SALE_CAP = 700000000000000000000000000; //700,000,000 PTX available for token sale
  uint256 public PRE_SALE_END_TIME = 4486055; //end of pre-sale
  uint256 public TOKEN_SALE_START_TIME = 4524221; //beginning of token sale (November 6th)
  uint256 public TOKEN_SALE_END_TIME = 4676729; //end of token sale (December 4th)
  uint256 public ONE_WEEK = 38117; //number of blocks in one week
  
  mapping(address => uint256) balances; //mapping of balances from addresses to amounts of PTX

/*
ERC 20 tokens
*/

  function balanceOf(address _owner) constant returns (uint256 balance) {
      return balances[_owner];
  }

  function transfer(address _to, uint256 _value) returns (bool success){
      balances[msg.sender] = safeSub(balances[msg.sender], _value);
      balances[_to] = safeAdd(balances[_to], _value);
      Transfer(msg.sender, _to, _value);
      return true;
  }

  mapping (address => mapping (address => uint256)) allowed;

  function transferFrom(address _from, address _to, uint256 _value) returns (bool success){
      var _allowance = allowed[_from][msg.sender];
      
      balances[_to] = safeAdd(balances[_to], _value);
      balances[_from] = safeSub(balances[_from], _value);
      allowed[_from][msg.sender] = safeSub(_allowance, _value);
      Transfer(_from, _to, _value);
      return true;
  }

  function approve(address _spender, uint256 _value) returns (bool success) {
      allowed[msg.sender][_spender] = _value;
      Approval(msg.sender, _spender, _value);
      return true;
  }

  function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
      return allowed[_owner][_spender];
  }

  //default function for handling contributions

  function () payable {

    if (msg.value == 0){ //empty contribution
      revert();
    }

    if (block.number <= PRE_SALE_END_TIME) { //presale contribution

      uint tokens = safeDiv(safeMul(msg.value, PRE_SALE_PRICE), 1 ether); //apply pre-sale rate

      if (preSalePurchased + tokens > PRE_SALE_CAP){ //enforce the cap of 200,000,000
        revert();
      }
      
      //perform PTX transfer
      preSalePurchased = safeAdd(preSalePurchased, tokens); //increment counter
      balances[msg.sender] = safeAdd(balances[msg.sender], tokens); //send PTX to contributor
      balances[owner] = safeSub(balances[owner], tokens); //decrease PTX of owner

    }

    else if (block.number <= TOKEN_SALE_END_TIME && block.number >= TOKEN_SALE_START_TIME ){ //token sale contribution

      tokens = safeDiv(safeMul(msg.value, TOKEN_SALE_PRICE), 1 ether); //apply token sale rate

      if (tokenSalePurchased + tokens < TOKEN_SALE_CAP){ //enforce the cap of 700,000,000

        if (block.number <= TOKEN_SALE_START_TIME + ONE_WEEK){ //within the first week
          tokens = safeAdd(tokens, safeDiv( safeMul(tokens, PRIMARY_BONUS), 100) ); //give 10% bonus
        }

        else if (block.number <= TOKEN_SALE_START_TIME + safeMul(ONE_WEEK, 2)){ //within second week
          tokens = safeAdd(tokens, safeDiv(safeMul(tokens, SECONDARY_BONUS), 100) ); //give 5% bonus
        }

        //perform PT transfer
        tokenSalePurchased = safeAdd(tokenSalePurchased, tokens); //increment counter
        balances[msg.sender] = safeAdd(balances[msg.sender], tokens); //send PTX
        balances[owner] = safeSub(balances[owner], tokens); //decrease PTX of owner

      }
      else{ //over the cap
        revert();
      }

    }
    else{ //not during an eligible period
      revert();
    }

    if (!owner.send(msg.value)){ //send the eth contribution to owner
      revert();
    }
  }

  address public owner; //the owner of the contract and beneficiary of the token sale

  function ProtexSale() { //constructor
    totalSupply = INITIAL_SUPPLY; //set total supply
    balances[msg.sender] = INITIAL_SUPPLY;  // Give all of the initial tokens to the contract deployer.
    owner   = msg.sender; //set owner to deployer
  
    //start counters at 0
    preSalePurchased = 0; 
    tokenSalePurchased = 0;

  }
}