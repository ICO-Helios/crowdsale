pragma solidity ^0.4.20;
library SafeMath { //standard library for uint
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0 || b == 0){
        return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
  function pow(uint256 a, uint256 b) internal pure returns (uint256){ //power function
    if (b == 0){
      return 1;
    }
    uint256 c = a**b;
    assert (c >= a);
    return c;
  }
}

contract Ownable { //standart contract to identify owner
  address public owner;
  address public newOwner;

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }
  
  function Ownable() public {
    owner = msg.sender;
  }
  
  function transferOwnership(address _newOwner) public onlyOwner {
    require(_newOwner != address(0));
    newOwner = _newOwner;
  }
  
  function acceptOwnership() public {
    if (msg.sender == newOwner) {
      owner = newOwner;
    }
  }
}

contract HeliosToken is Ownable { //ERC - 20 token contract
  using SafeMath for uint;

  // Triggered when tokens are transferred.
  event Transfer(address indexed _from, address indexed _to, uint256 _value);

  event Approval(address indexed _owner, address indexed _spender, uint256 _value);


  string public constant symbol = "HLC";
  string public constant name = "Helios";

  uint8 public constant decimals = 2;
  uint256 _totalSupply = uint(5000000).mul(uint(10).pow(decimals));

  // Owner of this contract
  address public owner;
  // Balances for each account

  function HeliosToken () public {
    owner = msg.sender;
    balances[address(this)] = _totalSupply;
  }
  
  mapping(address => uint256) balances;

  // Owner of account approves the transfer of an amount to another account
  mapping(address => mapping (address => uint256)) allowed;

  function totalSupply() public view returns (uint256) { //standart ERC-20 function
    return _totalSupply;
  }

  function balanceOf(address _address) public view returns (uint256 balance) {//standart ERC-20 function
    return balances[_address];
  }

  //standart ERC-20 function
  function transfer(address _to, uint256 _amount) public returns (bool success) {
    require(address(this) != _to);
    balances[msg.sender] = balances[msg.sender].sub(_amount);
    balances[_to] = balances[_to].add(_amount);
    emit Transfer(msg.sender,_to,_amount);
    return true;
  }
  
  address public crowdsaleContract;

  //connect to crowdsaleContract, can be use once
  function setCrowdsaleContract (address _address) public{
    require(crowdsaleContract == address(0));
    crowdsaleContract = _address;
  }

  uint public crowdsaleTokens = uint(5000000).mul(uint(10).pow(decimals));

  function sendCrowdsaleTokens (address _address, uint _value) public {
    require (msg.sender == crowdsaleContract);
    crowdsaleTokens = crowdsaleTokens.sub(_value);
    balances[address(this)] = balances[address(this)].sub(_value);
    balances[_address] = balances[_address].add(_value);
    emit Transfer(address(this),_address,_value); 
  }
  

  function transferFrom(address _from, address _to, uint256 _amount) public returns(bool success){
    balances[_from] = balances[_from].sub(_amount);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_amount);
    balances[_to] = balances[_to].add(_amount);
    emit Transfer(_from,_to,_amount);
    return true;
  }

  //standart ERC-20 function
  function approve(address _spender, uint256 _amount)public returns (bool success) { 
    allowed[msg.sender][_spender] = _amount;
    emit Approval(msg.sender, _spender, _amount);
    return true;
  }

  //standart ERC-20 function
  function allowance(address _owner, address _spender)public constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }

  address public teamAddress;
  address public reserveAddress;
  address public bountyAddress;

  function endIco() public {  
    require (msg.sender == crowdsaleContract);
    uint tokensSold = uint(5000000).mul(uint(10).pow(decimals)).sub(crowdsaleTokens);

    balances[teamAddress] = balances[teamAddress].add(tokensSold/10);
    balances[reserveAddress] = balances[reserveAddress].add(tokensSold/20);
    balances[bountyAddress] = balances[bountyAddress].add(tokensSold.mul(3)/100);

    emit Transfer(address(this), teamAddress, tokensSold/10);
    emit Transfer(address(this), reserveAddress, tokensSold/20);
    emit Transfer(address(this), bountyAddress, tokensSold.mul(3)/100);

    uint buffer = (tokensSold/10).add(tokensSold/20).add(tokensSold.mul(3)/100);

    emit Transfer(address(this), 0, balances[address(this)].sub(buffer));
    balances[address(this)] = 0;

  }
}