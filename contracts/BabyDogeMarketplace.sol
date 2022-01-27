//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
interface BabyDogeNFT {
    function mint(address, uint256[] memory) external;
    function maxMint() external returns(uint256);
    
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
    mapping(uint256 => uint256[3]) public randomAvailable;
    mapping(address => bool) public whitelistedAddress;

    //events
    event buy(address buyer, uint256 requestedTokenCategory,uint256 givenTokenCategory, uint256[] tokenId, uint256 price, uint256 boughtAt, uint256 stage);
    event buyForOwner(address buyer, uint256 tokenCategory, uint256[] tokenIds, uint256 boughtAt);
   
    //modifer
    modifier isValidCategory(uint256 _tokenCategory){
        require(_tokenCategory < TOTAL_CATEGORIES, 'Invalid token categories');
        _;
    }
    constructor(
        address _babyDogeNFT, 
        uint256[TOTAL_CATEGORIES] memory _prices, 
        uint256[TOTAL_CATEGORIES] memory _total, 
        uint256[TOTAL_CATEGORIES] memory _totalForPresale, 
        uint256[TOTAL_CATEGORIES] memory _totalForOwner,
        uint256[TOTAL_CATEGORIES][TOTAL_CATEGORIES] memory _random) {
        babyDogeNFT = BabyDogeNFT(_babyDogeNFT);
        uint256 nextTokenId = 1;
        for(uint8 index = 0; index < TOTAL_CATEGORIES; index++){
            if(index == 0){
                require(_random[index][0] + _random[index][1] + _random[index][2] == 0, 'Invalid Random');
            } else if(index == 1){
                require(_random[index][1] + _random[index][2] == 0, 'Invalid Random');
            } else {
                require(_random[index][2] == 0, 'Invalid Random');
            }
            require(_random[index][0] + _random[index][1] + _random[index][2] <=  _total[index], 'Invalid Random sum');
            require(_total[index] >= _totalForPresale[index] + _totalForOwner[index], 'Invalid token counts');
            tokenCategories[index] = CategoryDetail(_prices[index], _total[index], _totalForPresale[index], _totalForOwner[index], 0,0, nextTokenId);
            nextTokenId = nextTokenId + _total[index];
        }
    }

    //USER FUNCTIONS
    function buyToken(uint256 _tokenCategory, uint256 _totalUnits) external isValidCategory(_tokenCategory) payable{
        require(_totalUnits <= babyDogeNFT.maxMint() && _totalUnits > 0, 'Invalid number of units');
        uint256[] memory tokenIds;
        uint8 index;
        uint256 categoryUnit = _totalUnits;
        CategoryDetail storage categoryDetail = tokenCategories[_tokenCategory];
        uint256 startTokenId = categoryDetail.nextTokenId;
        if(stage == 0){
            require(whitelistedAddress[msg.sender], 'Not eligible to buy in presale');
            require(categoryDetail.totalMinted - categoryDetail.totalMintedForOwner + _totalUnits <= categoryDetail.totalForPresale, 'That much token not left in presale');
        } else {
            require(categoryDetail.totalMinted - categoryDetail.totalMintedForOwner + _totalUnits <= categoryDetail.total - categoryDetail.totalForOwner, 'That much token are not left');
        }
        uint256 price = _totalUnits * currentPrice(_tokenCategory);
        require(msg.value >= price, 'Price of tokens is more than the given');
        uint random = uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp))) % 15;
        bool randomAllowed;
        if(random > _tokenCategory && random < TOTAL_CATEGORIES && randomAvailable[random][_tokenCategory] > 0){
            CategoryDetail storage randomCategoryDetail = tokenCategories[random];
            if(stage == 0){
                if(randomCategoryDetail.totalMinted - randomCategoryDetail.totalMintedForOwner < randomCategoryDetail.totalForPresale){
                    randomAllowed = true;
                }
            } else {
                if(categoryDetail.totalMinted - categoryDetail.totalMintedForOwner < categoryDetail.total - categoryDetail.totalForOwner){
                    randomAllowed = true;
                }
            }
            if(randomAllowed){
                randomCategoryDetail.totalMinted++;
                tokenIds[index] = randomCategoryDetail.nextTokenId;
                index++;
                randomCategoryDetail.nextTokenId++;
                randomAvailable[random][_tokenCategory]--;
                categoryUnit--;
            }
            else {
                random = _tokenCategory;
            }
        } 
        for(index; index < _totalUnits; index++){
            tokenIds[index] = startTokenId;
            startTokenId++;
        }
        categoryDetail.totalMinted = categoryDetail.totalMinted + categoryUnit;
        categoryDetail.nextTokenId = categoryDetail.nextTokenId + categoryUnit;
        babyDogeNFT.mint(msg.sender, tokenIds);
        emit buy(msg.sender, _tokenCategory, random, tokenIds, price, block.timestamp, stage);
    }

    //ADMIN FUNCTIONS
    function updateStage() external onlyOwner(){
        stage = 1;
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

    function withdraw() external onlyOwner(){
        require(address(this).balance > 0, 'Nothing to withdraw');
        payable(msg.sender).transfer(address(this).balance);
    }


      function buyTokenForOwner2(uint256 _tokenCategory, uint256 _totalUnits) external isValidCategory(_tokenCategory){
        require(_totalUnits <= babyDogeNFT.maxMint() && _totalUnits > 0, 'Invalid number of units');
        uint256[] memory tokenIds;
        CategoryDetail storage categoryDetail = tokenCategories[_tokenCategory];
        uint256 startTokenId = categoryDetail.nextTokenId;
        require(categoryDetail.totalMintedForOwner + _totalUnits <= categoryDetail.totalForOwner, 'That much token are not left');
        for(uint8 index = 0; index < _totalUnits; index++){
            tokenIds[index] = startTokenId;
            startTokenId++;
        }
        categoryDetail.totalMinted = categoryDetail.totalMinted + _totalUnits;
        categoryDetail.totalMintedForOwner = categoryDetail.totalMintedForOwner + _totalUnits;
        categoryDetail.nextTokenId = categoryDetail.nextTokenId + _totalUnits;
        babyDogeNFT.mint(msg.sender, tokenIds);
        emit buyForOwner(msg.sender, _tokenCategory, tokenIds, block.timestamp);
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
 }