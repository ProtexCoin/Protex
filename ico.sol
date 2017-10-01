/*
Smart contract for the Token Sale of Protex Tokens (PTX). 




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
  uint256 public INITIAL_SUPPLY = 1000000000000000000000000000;
  uint256 public PRIMARY_BONUS = 10;
  uint256 public SECONDARY_BONUS = 5;
  //uint256  totalSupply;
  uint256 public TOKEN_SALE_PRICE = 4000000000000000000000; //change back to 4
  uint256 public PRE_SALE_PRICE = 5000000000000000000000;
  uint256 public preSalePurchased;
  uint256 public tokenSalePurchased;
  uint256 public PRE_SALE_CAP = 200000000000000000000000000;
  uint256 public TOKEN_SALE_CAP = 700000000000000000000000000;
  uint256 public PRE_SALE_END_TIME = 4502763;
  uint256 public TOKEN_SALE_START_TIME = 4540880;
  uint256 public TOKEN_SALE_END_TIME = 4693348;
  uint256 public ONE_WEEK = 38117;

  
  mapping(address => uint256) balances;

  uint256 public totalSupply;


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

  function () payable {

    if (msg.value == 0){ //empty contribution
      revert();
    }

    if (block.number <= PRE_SALE_END_TIME) {

      //do pre-sale stuff
      uint tokens = safeDiv(safeMul(msg.value, PRE_SALE_PRICE), 1 ether);


      if (preSalePurchased + tokens > PRE_SALE_CAP){ //enforce the cap
        revert();
      }
      

      preSalePurchased = safeAdd(preSalePurchased, tokens);
      balances[msg.sender] = safeAdd(balances[msg.sender], tokens);
      balances[owner] = safeSub(balances[owner], tokens);

    }
    else if (block.number <= TOKEN_SALE_END_TIME && block.number >= TOKEN_SALE_START_TIME ){
      //do token-sale stuff

      tokens = safeDiv(safeMul(msg.value, TOKEN_SALE_PRICE), 1 ether);

      if (tokenSalePurchased + tokens < TOKEN_SALE_CAP){
        if (block.number <= TOKEN_SALE_START_TIME + ONE_WEEK){
          tokens = safeAdd(tokens, safeDiv( safeMul(tokens, PRIMARY_BONUS), 100) );
        }
        else if (block.number <= TOKEN_SALE_START_TIME + safeMul(ONE_WEEK, 2)){
          tokens = safeAdd(tokens, safeDiv(safeMul(tokens, SECONDARY_BONUS), 100) );
        }

        tokenSalePurchased = safeAdd(tokenSalePurchased, tokens);
        balances[msg.sender] = safeAdd(balances[msg.sender], tokens);
        balances[owner] = safeSub(balances[owner], tokens);

      }
      else{
        revert();
      }


    }
    else{ //not during an eligible period
      revert();
    }

    
    //sendTokens(msg.sender);

    if (!owner.send(msg.value)){ //send the eth
      revert();
    }
  }


  address public owner;
 // uint256 public endTime;

  function ProtexSale() {
    totalSupply = INITIAL_SUPPLY;
    balances[msg.sender] = INITIAL_SUPPLY;  // Give all of the initial tokens to the contract deployer.
    owner   = msg.sender;
  

    preSalePurchased = 0;
    tokenSalePurchased = 0;

  }

}
