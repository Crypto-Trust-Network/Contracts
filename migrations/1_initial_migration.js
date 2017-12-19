var Migrations = artifacts.require("./Migrations.sol");
var ERC20 = artifacts.require("./ERC20.sol");
var CTNToken = artifacts.require("./CTNToken.sol");

const web3 = require('web3');

const TruffleConfig = require('../truffle');


module.exports = function(deployer) {

  const config = TruffleConfig.networks[development];

  web3.personal.unlockAccount(config.from, "Passc0de", 36000);

  deployer.deploy(Migrations);
  deployer.deploy(ERC20);
  deployer.deploy(CTNToken);
  deployer.link(ERC20, CTNToken);
};
