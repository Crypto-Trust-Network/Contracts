module.exports = {
  // See <http://truffleframework.com/docs/advanced/configuration>
  // to customize your Truffle configuration!
  networks: {
    rpc: {
      host: "localhost",
      port: 8545,
      network_id: "*" // Match any network id
    },
    development: {
      network_id: 4,
      host: '127.0.0.1',
      port: 8545,
      gas: 4000000,
      from: "0xF7092530595903Bd1363eE2F0778960be3C129a1", // default address to use for any transaction Truffle makes during migrations (Wills Rinkeby On his comp)
    }
  }
};
