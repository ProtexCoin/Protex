pragma solidity ^0.4.8;

//zeppelin safe math for attack prevention

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

  uint256 public preSaleEndTime;
  uint256 public tokenSaleEndTime;
  uint256 public tokenSaleStartTime;

  modifier during_offering_time(){
    if (now >= endTime){
      revert();
    }else{
      _;
    }
  }

  function () payable during_offering_time {
    createTokens(msg.sender);
  }

  function createTokens(address recipient) payable {
    if (msg.value == 0) {
      revert();
    }

    uint tokens = safeDiv(safeMul(msg.value, price), 1 ether);

    totalSupply = safeAdd(totalSupply, tokens);

    balances[recipient] = safeAdd(balances[recipient], tokens);

    if (!owner.send(msg.value)) {
      revert();
    }
  }

  string  public name = "Protex Token";
  string  public symbol = "PTX";
  uint  public decimals = 18;
  uint256 public INITIAL_SUPPLY = 1000000000000000000000000000;
  //uint256  totalSupply;
  uint256 public tokenSalePrice;
  uint256 public preSalePrice;
  uint256 public tier1Bonus;
  uint256 public tier2Bonus;
  uint256 public tier3Bonus;

  address public owner;
 // uint256 public endTime;

  function ProtexSale() {
    totalSupply = INITIAL_SUPPLY;
    balances[msg.sender] = INITIAL_SUPPLY;  // Give all of the initial tokens to the contract deployer.
    endTime = now + 1 weeks;
    owner   = msg.sender;
    tokenSalePrice   = 4000;
    preSalePrice = 5000;

    tier1Bonus = 10;
    tier2Bonus = 5;

    preSaleEndTime = 4502763;
    tokenSaleStartTime = 4540880;
    tokenSaleEndTime = 4693348; 



  }

}
