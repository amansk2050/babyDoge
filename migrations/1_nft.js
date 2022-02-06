const BabyDogeNFT = artifacts.require("BabyDogeNFT");

module.exports = function (deployer) {
  deployer.deploy(BabyDogeNFT,"BABY_TEST_RINKEBY","BTR","https://ipfs.io/ipfs/QmT6hwxiSLapLusF8LW9wXvJXjDav9ThAFeyyQQH6KZeHm/");
};
