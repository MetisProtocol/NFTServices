const EX = artifacts.require("NTFExchange");
require('@openzeppelin/test-helpers/configure')({ provider: web3.currentProvider, environment: 'truffle' });

const { singletons } = require('@openzeppelin/test-helpers');

const BN = require('bignumber.js');

module.exports = async function(deployer, network, accounts) {
     if (network == "main") {
        await deployer.deploy(EX, "0x9e77a615ecCB9aF832B7c72E474B6609c5E4E44F");
     }
     else {
        await deployer.deploy(EX, "0x9e77a615ecCB9aF832B7c72E474B6609c5E4E44F");
     }
};
