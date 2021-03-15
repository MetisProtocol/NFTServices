// Contracts
const Vault = artifacts.require("TokenVault")
const fs = require('fs');
const line= fs.readFileSync("investors").toString().trim();
console.log(line);
//
// Utils
const ether = (n) => {
   return new web3.utils.BN(
       web3.utils.toWei(n.toString(), 'ether')
   )
}

module.exports = async function(callback) {
    try {
        // Fetch accounts from wallet - these are unlocked
        const accounts = await web3.eth.getAccounts()

        // Fetch the deployed exchange
        const vault = await Vault.deployed()
        await vault.addNewPending(accounts[4],  1000);

        // Set up users
        const user1 = accounts[0]
        console.log(await vault.checkArrangements({from:accounts[4]}));

    }
    catch(error) {
        console.log(error)
    }

    callback()
}

