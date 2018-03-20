var Crowdsale = artifacts.require("Crowdsale");
var Token = artifacts.require("HeliosToken");

var TokenName = "Helios";
var Symbol = "HLC";
var TokenSupply = 5000000;
var Decimals = 2;
var TokenPrice = 1000000000000000;

var TokenBuffer = 0;

expect = require("chai").expect;

var totalSupply;

contract("Token contract", function(accounts){
  describe("Check SC instance", function(){
    it("catch an instance of tokenContract", function(){
      return Token.deployed().then(function(instance){
        TokenInstance = instance;
        console.log("tokenContract = " + TokenInstance.address);
      });
    });
    it("Saving totalSupply", function(){
      return TokenInstance.totalSupply().then(function(res){
        console.log("totalSupply = " + res.toString());
        totalSupply = res.toString();
        expect(parseInt(res.toString())).to.be.equal(TokenSupply*(Math.pow(10,parseInt(Decimals))));
      });
    });
  });
  describe ("Check Contract balance", function(){
    it ("contract balance must be equals totalSupply", function(){
      return TokenInstance.balanceOf(TokenInstance.address).then(function(res){
        console.log(res.toString());
        // console.log(totalSupply);
        expect(res.toString()).to.be.equal(totalSupply);
      });
    });
    // SimpleStorage.deployed().then(function(instance){return instance.get.call();}).then(function(value){return value.toNumber()});
    it ("Check Token name", function(){
      return TokenInstance.name.call().then(function(res){
        console.log("Token name = " + res.toString());
        expect(res.toString()).to.be.equal(TokenName);
      })
    })
    it ("Check Token Symbol", function(){
      return TokenInstance.symbol.call().then(function(res){
        console.log("Token Symbol = " + res.toString());
        expect(res.toString()).to.be.equal(Symbol);
      })
    })
    it ("check Token Decimals", function(){
      return TokenInstance.decimals.call().then(function(res){
        console.log("Token decimals = " + res.toString());
        expect(parseInt(res.toString())).to.be.equal(Decimals);
      })
    })
  });


  contract ("Deploy Crowdsale contract", function(accounts){
    describe("Check Crowdsale instance", function(){
      it("catch an instance of Crowdsale", function(){
        return Crowdsale.deployed().then(function(instance){
          CrowdsaleInstance = instance;
          console.log("CrowdsaleContract = " + CrowdsaleInstance.address);
        })
      })
    })
    describe ("Check contract connections", function(){
      it("Check contract connections", function(){
        return TokenInstance.crowdsaleContract().then(function(res){
          console.log(res.toString());
          expect(res.toString()).to.be.equal(CrowdsaleInstance.address);
        })
      })
    })
    describe ("sendEther", function(){
      it("sendEther 0.5 from acc0", function(){
        return CrowdsaleInstance.send(web3.toWei(0.5, "ether")).then(function(res){
          expect (res.toString()).to.not.be.an("error");
        })
      })
      it("Check user 1 balance", function(){
        return TokenInstance.balanceOf(accounts[0]).then(function(res){
          TokenBuffer += parseInt(res.toString());
          console.log(res.toString());
        })
      })
      it("anotherUserSendEther (0,6 eth)", function(){
        return web3.eth.sendTransaction({from: accounts[1], to: CrowdsaleInstance.address, value: 600000000000000000})
      })
      it("check his balance ",function(){
        return TokenInstance.balanceOf(accounts[1]).then(function(res){
          TokenBuffer += parseInt(res.toString());
          console.log(res.toString());
        })
      })
      it("check tokenContract balance now", function(){
        return TokenInstance.balanceOf(TokenInstance.address).then(function(res){
          console.log(res.toString());
          expect(parseInt(res.toString())).to.be.equal(TokenSupply*Math.pow(10,Decimals)-TokenBuffer);
        })
      })
    })
    describe ("Checking amount bonus",function(){
      it("send 1 Ether", function(){
        return web3.eth.sendTransaction({from: accounts[2], to: CrowdsaleInstance.address, value: 1000000000000000000})
      })
      it("check his balance", function(){
        return TokenInstance.balanceOf(accounts[2]).then(function(res){
          console.log(res.toString());
          expect(parseInt(res.toString())).to.not.be.equal(0);
        })
      })
      it("send 2,999 ether", function(){
        return web3.eth.sendTransaction({from:accounts[3], to: CrowdsaleInstance.address, value: 2990000000000000000})
      })
      it("check his balance", function(){
        return TokenInstance.balanceOf(accounts[3]).then(function(res){
          console.log(res.toString());
          expect(parseInt(res.toString())).to.not.be.equal(0);
        })
      })
      it("send 3 ether", function(){
        return web3.eth.sendTransaction({from:accounts[4], to: CrowdsaleInstance.address, value: 3000000000000000000})
      })
      it("check his balance", function(){
        return TokenInstance.balanceOf(accounts[4]).then(function(res){
          console.log(res.toString());
          expect(parseInt(res.toString())).to.not.be.equal(0);
        })
      })
      it("send 4,999 ether", function(){
        return web3.eth.sendTransaction({from:accounts[5], to: CrowdsaleInstance.address, value: 4990000000000000000})
      })
      it("check his balance", function(){
        return TokenInstance.balanceOf(accounts[5]).then(function(res){
          console.log(res.toString());
          expect(parseInt(res.toString())).to.not.be.equal(0);
        })
      })
      it("send 5 ether", function(){
        return web3.eth.sendTransaction({from:accounts[6], to: CrowdsaleInstance.address, value: 5000000000000000000})
      })
      it("check his balance", function(){
        return TokenInstance.balanceOf(accounts[6]).then(function(res){
          console.log(res.toString());
          expect(parseInt(res.toString())).to.not.be.equal(0);
        })
      })
      it("send 8 ether", function(){
        return web3.eth.sendTransaction({from:accounts[7], to: CrowdsaleInstance.address, value: 8000000000000000000})
      })
      // it("check his balance", function(){
      //   return TokenInstance.balanceOf(accounts[7]).then(function(res){
      //     console.log(res.toString());
      //     var buffer = 8000000000000000000/TokenPrice;
      //     buffer += buffer*140/100;
      //     console.log(buffer);
      //     expect(parseInt(res.toString())).to.be.equal(buffer);
      //   })
      // })



    })
  })
})
