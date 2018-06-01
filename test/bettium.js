var Bettium = artifacts.require("Bettium");
var Crowdsale = artifacts.require("CrowdSale")

contract('CrowdSale', function(accounts) {
  it("deploy contract crowdsale in test network", function() {
    return CrowdSale.deployed().then(function(instance) {
      return instance.getBalance.call(accounts[1]);
    }).then(function(balance) {
      assert.equal(balance.valueOf(), 10000, "10000 wasn't in the first account");
    });
  });
  });
