var HDWalletProvider = require("truffle-hdwallet-provider");
var mnemonic = "kitten zebra adult danger share gold inspire coin fiction invest sudden book";
module.exports = {
  // See <http://truffleframework.com/docs/advanced/configuration>
  // for more about customizing your Truffle configuration!
  networks: {
    development: {
      host: "127.0.0.1",
      port: 7545,
      network_id: "*" // Match any network id
    },
    ropsten: {
          host: "localhost",
          port: 8545,
          network_id: "3"
    }

//   ropsten: {
//       provider: function(){
//           return new HDWalletProvider(mnemonic, "https://ropsten.infura.io/v3/20401dc3e9834236b08463d5ae5a4616")
//       },
//       network_id: "3"
//   }
    }
};

