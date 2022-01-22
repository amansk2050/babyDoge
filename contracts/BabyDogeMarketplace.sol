//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
interface BabyDogeNFT {

}
contract BabyDogeMarketplace is Ownable{
    BabyDogeNFT public babyDogeNFT;
    struct CategoryDetail {
        uint256 price;
        uint256 total;
        uint256 totalForPresale;
        uint256 totalForOwner;
        uint256 totalMinted;
        uint256 totalMintedForOwner;
        uint256 nextTokenId;
    }
    //0 = presale 1 = postSale
    uint256 public stage;
    //0 gold 1 platinum 2 black
    mapping(uint256 => CategoryDetail) public tokenCategories;
    mapping(address => bool) public whitelistedAddress;

    //events
   
    //modifer

    modifier isWhitelisted(address _userAddress){
        require(whitelistedAddress[_userAddress], 'You are not whitelisted');
        _;
    }
    constructor(address _babyDogeNFT, uint256[3] memory _prices, uint256[3] memory _total, uint256[3] memory _totalForPresale, uint256[3] memory _totalForOwner) {
        babyDogeNFT = BabyDogeNFT(_babyDogeNFT);
        uint256 nextTokenId = 1;
        for(uint8 index = 0; index < 3; index++){
            require(_total[index] >= _totalForPresale[index] + _totalForOwner[index], 'Invalid token counts');
            tokenCategories[index] = CategoryDetail(_prices[index], _total[index], _totalForPresale[index], _totalForOwner[index], 0,0, nextTokenId);
            nextTokenId = nextTokenId + _total[index];
        }
    }
    //USER FUNCTIONS
    function buy(uint256 tokenType) external onlyOwner(){

    }

    //ADMIN FUNCTIONS
    function updateStage() external onlyOwner(){

    }

    function updatePrices(uint256[3] memory _prices) external onlyOwner(){
        for(uint8 index = 0; index < 3; index++){
            tokenCategories[index].price = _prices[index];
        }
    }

    function whitelist(address[] memory _userAddress) external onlyOwner(){
        for(uint256 index = 0; index < _userAddress.length; index++){
            whitelistedAddress[_userAddress[index]] = true;
        }
    }

    function blacklist(address[] memory _userAddress) external onlyOwner(){
        for(uint256 index = 0; index < _userAddress.length; index++){
            whitelistedAddress[_userAddress[index]] = false;
        }
    }

    //VIEW FUNCTIONS

    function currentPrice(uint256 _category) public view returns(uint256) {
        CategoryDetail memory categoryDetail = tokenCategories[_category];
        if(categoryDetail.totalMinted >= categoryDetail.total / 2) {
            return categoryDetail.price * 2;
        } else if(categoryDetail.totalMinted >= 3 * categoryDetail.total / 4){
            return categoryDetail.price * 4;
        } 
        return categoryDetail.price;
    }

    function availableTokens(uint256 _category) public view returns(uint256) {
        CategoryDetail memory categoryDetail = tokenCategories[_category];
        return categoryDetail.total - categoryDetail.totalMinted;
    }

    function availableTokensForOwner(uint256 _category) public view returns(uint256) {
        CategoryDetail memory categoryDetail = tokenCategories[_category];
        return categoryDetail.totalForOwner - categoryDetail.totalMintedForOwner;
    }

	// totalGoldNFTForOwner		-  Total number of Gold NFT for owner
	// totalPlatinumNFT 			- Total number of Platinum NFTs
	// totalPlatinumForGoldLottery 		- Total number of platinum NFTs for gold lotteries
	// totalPlatinumNFTForOwner		- Total number of platinum NFT for owner
	// totalBlackNFT 				- Total number of Black NFTs
	// totalBlackForGoldLottery 		- Total number of Black NFTs for gold lotteries
	// totalBlackForPlatinumLottery 		- Total number of Black NFTs for platinum lotteries
    // totalBlackNFTForOwner		- Total number of black NFT for owner
	// mintedPlatniumForGoldLottery 	- minted platinum NFTs for gold lottery
	// mintedBlackForGoldLottery 		- minted black NFTs for gold lottery
	// mintedBlackForPlatinumLottery 	- minted black NFTs for platinum lottery
    // mintedGoldForOwner 			- minted gold NFTs for owner
    // mintedPlatinumForOwner 		- minted platinum NFTs for owner
    // mintedBlackdForOwner 		- minted black NFTs for owner

 
	
	// buy				- Function to buy the NFT
	// buyForOwner			- Function for owner to buy the NFT
	// changeStage			- Function to change the stage	
}