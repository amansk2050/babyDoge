const HDWalletProvider = require('truffle-hdwallet-provider');
const config = require('./config.js')
module.exports = {

  networks: {
    rinkeby: {
      networkCheckTimeout: 1000000,
      provider: () => new HDWalletProvider(config.mnemomics, config.nodeURL.rinkeby, 0,2),
      from: config.publicKey.rinkeby,
      network_id: config.networkId.rinkeby,
      gasPrice: 22000000000,
      gas: 5061160,       
      confirmations: 2,    
      timeoutBlocks: 200,  
      skipDryRun: true  ,  
    },
  },

  
  mocha: {
  },
  compilers: {
    solc: {
      version: "^0.8.0",    
     
    }
  },
  plugins: ["truffle-plugin-verify"],
  api_keys: {
    etherscan: "H7MVRK8MPF3K6NR2WJDJIJZRR5RM1VWWDK",
  },
};
