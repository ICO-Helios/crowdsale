var Token = artifacts.require("./HeliosToken.sol");
var Crowdsale = artifacts.require("./Crowdsale.sol");

//var address = web3.eth.accounts[0];
module.exports = function(deployer) {
  deployer.deploy(Token).then(function(){
  	return deployer.deploy(Crowdsale,Token.address,"0x8C0F5211A006bB28D4c694dC76632901664230f9");
  });
}
