// const BabyDogeNFT = artifacts.require("BabyDogeNFT");

// module.exports = function (deployer) {
//   deployer.deploy(BabyDogeNFT,"BABY_RINKEBY_3","BR_3","ipfs//QmT6hwxiSLapLusF8LW9wXvJXjDav9ThAFeyyQQH6KZeHm/");
// };


///-------

const BabyDogeMarketplace = artifacts.require("BabyDogeMarketplace");

module.exports = function (deployer) {
    const address = "0x4b93cb7545A01D5654f18eb13D85194a4d66F5e9";
    const price = ["10000000000000000", "100000000000000000","1000000000000000000"];
    const total = [3000,120,30];
    const totalForPresale = [1000,40,10];
    const totalForOwner = [90,6,3];
    const random = [[0,0,0],[9,0,0],[6,3,0]];
    const superOwner = "0xb1551B2b46df680E8e25E97232888a26ecdc01F5"
  deployer.deploy(BabyDogeMarketplace,address,price,total,totalForPresale,totalForOwner,random,superOwner);
};
