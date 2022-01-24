//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
interface BabyDogeNFT {
    function mint(address, uint256) external;
}
contract BabyDogeMarketplace is Ownable{
    BabyDogeNFT public babyDogeNFT;
    uint256 public constant TOTAL_CATEGORIES = 3;
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
    event buy(address buyer, uint256 tokenCategory, uint256 tokenId, uint256 price, uint256 boughtAt, uint256 stage);
    event buyForOwner(address buyer, uint256 tokenCategory, uint256 tokenId, uint256 boughtAt);
   
    //modifer
    modifier isValidCategory(uint256 _tokenCategory){
        require(_tokenCategory < TOTAL_CATEGORIES, 'Invalid token categories');
        _;
    }
    constructor(address _babyDogeNFT, uint256[TOTAL_CATEGORIES] memory _prices, uint256[TOTAL_CATEGORIES] memory _total, uint256[TOTAL_CATEGORIES] memory _totalForPresale, uint256[TOTAL_CATEGORIES] memory _totalForOwner) {
        babyDogeNFT = BabyDogeNFT(_babyDogeNFT);
        uint256 nextTokenId = 1;
        for(uint8 index = 0; index < TOTAL_CATEGORIES; index++){
            require(_total[index] >= _totalForPresale[index] + _totalForOwner[index], 'Invalid token counts');
            tokenCategories[index] = CategoryDetail(_prices[index], _total[index], _totalForPresale[index], _totalForOwner[index], 0,0, nextTokenId);
            nextTokenId = nextTokenId + _total[index];
        }
    }
    //USER FUNCTIONS
    function buyToken(uint256 _tokenCategory) external isValidCategory(_tokenCategory) payable{
        CategoryDetail storage categoryDetail = tokenCategories[_tokenCategory];
        if(stage == 0){
            require(whitelistedAddress[msg.sender], 'Not eligible to buy in presale');
            require(categoryDetail.totalMinted < categoryDetail.totalForPresale, 'All Tokens of this cateogry are sold for presale');
        } else {
            require(categoryDetail.totalMinted - categoryDetail.totalMintedForOwner < categoryDetail.total - categoryDetail.totalForOwner, 'All Tokens of this cateogry are sold');
        }
        uint256 price = currentPrice(_tokenCategory);
        require(msg.value >= price, 'Price of token is more than the given');
        categoryDetail.totalMinted++;
        uint256 tokenId = categoryDetail.nextTokenId;
        categoryDetail.nextTokenId++;
        babyDogeNFT.mint(msg.sender, tokenId);
        emit buy(msg.sender, _tokenCategory, tokenId, price, block.timestamp, stage);
    }

    //ADMIN FUNCTIONS
    function updateStage() external onlyOwner(){

    }

    function updatePrices(uint256[TOTAL_CATEGORIES] memory _prices) external onlyOwner(){
        for(uint8 index = 0; index < TOTAL_CATEGORIES; index++){
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

    function buyTokenForOwner(uint256 _tokenCategory) external isValidCategory(_tokenCategory) onlyOwner(){
        CategoryDetail storage categoryDetail = tokenCategories[_tokenCategory];
        require(categoryDetail.totalMintedForOwner < categoryDetail.totalForOwner, 'All Tokens of this cateogry are sold');
        categoryDetail.totalMinted++;
        categoryDetail.totalMintedForOwner++;
        uint256 tokenId = categoryDetail.nextTokenId;
        categoryDetail.nextTokenId++;
        babyDogeNFT.mint(msg.sender, tokenId);
        emit buyForOwner(msg.sender, _tokenCategory, tokenId, block.timestamp);
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

 
	

	// changeStage			- Function to change the stage	
}