pragma solidity ^0.4.20;

library SafeMath { //standart library for uint
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

//standart contract to identify owner
contract Ownable {

  address public owner;

  address public newOwner;

  address public techSupport;

  address public newTechSupport;

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  modifier onlyTechSupport() {
    require(msg.sender == techSupport);
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

  function transferTechSupport (address _newSupport) public{
    require (msg.sender == owner || msg.sender == techSupport);
    newTechSupport = _newSupport;
  }

  function acceptSupport() public{
    if(msg.sender == newTechSupport){
      techSupport = newTechSupport;
    }
  }

}

//Abstract Token contract
contract HeliosToken{
  function setCrowdsaleContract (address) public;
  function sendCrowdsaleTokens(address, uint256) public;
  function endIco() public;
//   function getOwner()public view returns(address);
}

//Crowdsale contract
contract Crowdsale is Ownable{

  using SafeMath for uint;

  uint decimals = 2;
  // Token contract address
  HeliosToken public token;

  // Constructor
  function Crowdsale(address _tokenAddress, address _techSupport) public{
    token = HeliosToken(_tokenAddress);
    techSupport = _techSupport;

    // test parameter
    // techSupport = 0x8C0F5211A006bB28D4c694dC76632901664230f9;

    token.setCrowdsaleContract(address(this));
    owner = msg.sender;
  }

   //Crowdsale variables
  uint public tokensSold = 0;
  uint public ethCollected = 0;


  uint tokenPrice = 0.001 ether;

  //preIco constants
  uint public constant preIcoStart = 1521470307; //1525168800
  uint public constant preIcoFinish = 1527847200;
  uint public constant preIcoMinInvest = 50*(uint(10).pow(decimals)); //50 Tokens

  // Ico constants
  uint public constant icoStart = 1530439200; 
  uint public constant icoFinish = 1538388000; 
  uint public constant icoMinInvest = 10*(uint(10).pow(decimals)); //10 Tokens

  uint public constant minCap = 1000000 * uint(10).pow(decimals);

  function isPreIco (uint _time) public pure returns(bool) {
    if((preIcoStart <= _time) && (_time < preIcoFinish)){
      return true;
    }
  }
  
  //check is now ICO
  function isIco(uint _time) public pure returns (bool){
    if((icoStart <= _time) && (_time < icoFinish)){
      return true;
    }
    return false;
  }

  function timeBasedBonus(uint _time) public pure returns(uint) {
    if(isPreIco(_time)){
      if(preIcoStart + 1 weeks > _time){
        return 20;
      }
      if(preIcoStart + 2 weeks > _time){
        return 15;
      }
      if(preIcoStart + 3 weeks > _time){
        return 10;
      }
    }
    if(isIco(_time)){
      if(icoStart + 1 weeks > _time){
        return 20;
      }
      if(icoStart + 2 weeks > _time){
        return 15;
      }
      if(icoStart + 3 weeks > _time){
        return 10;
      }
    }
    return 0;
  }
  
  //fallback function (when investor send ether to contract)
  function() public payable{
    require(isPreIco(now) || isIco(now));
    require(buy(msg.sender,msg.value, now)); //redirect to func buy
  }

  //function buy Tokens
  function buy(address _address, uint _value, uint _time) internal returns (bool){
    
    uint tokensToSend = etherToTokens(_value,_time);

    if (isPreIco(_time)){
      require (tokensToSend >= preIcoMinInvest);
      token.sendCrowdsaleTokens(_address,tokensToSend);

      tokensSold = tokensSold.add(tokensToSend);
      distributeEther();


    }else{
      require (tokensToSend >= icoMinInvest);
      token.sendCrowdsaleTokens(_address,tokensToSend);

      tokensSold = tokensSold.add(tokensToSend);

      if (tokensSold >= minCap){
        distributeEther();
      }
    }

    ethCollected = ethCollected.add(_value);

    return true;
  }

  address public distribution = 0xBBBBaAeDaa53EACF57213b95cc023f668eDbA361; //0x6efa045215A477d9e015Af0b5507C7b3c8bA9EBb;
  // address public distribution2;
  function distributeEther() internal {
    // distribution1.transfer(address(this).balance/2);
    distribution.transfer(address(this).balance);
  }
  

  function manualSendTokens (address _address, uint _tokens) public onlyTechSupport {
    token.sendCrowdsaleTokens(_address, _tokens);
    tokensSold = tokensSold.add(_tokens);
  }
  

  //convert ether to tokens (without decimals)
  function etherToTokens(uint _value, uint _time) public view returns(uint res) {
    res = _value.mul((uint)(10).pow(decimals))/tokenPrice;
    uint bonus = timeBasedBonus(_time);
    res = res.add(res.mul(bonus)/100);
  }


  function endIco () public {
    require(msg.sender == owner || msg.sender == techSupport);
    require(now > icoFinish + 5 days);
    token.endIco();
  }
  
}