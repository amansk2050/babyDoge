pragma solidity ^0.8.0;
//SPDX-License-Identifier: UNLICENSED
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract BabyDogeNFT is ERC721Enumerable, Ownable {
  using Strings for uint256;

  string public baseURI;
  string public baseExtension = ".json";
  uint256 public maxSupply = 3150;
  uint256 public maxMint = 10;
  address public minterAddress;
  uint256 public totalMinted;
  bool public visibility;
  bool public mintActivate;
  string private defaultBaseURI;
  constructor(
    string memory _name,
    string memory _symbol,
    string memory _initBaseURI
  ) ERC721(_name, _symbol) {
    setBaseURI(_initBaseURI);
  }

  modifier onlyMinter() {
        require(minterAddress == msg.sender,"BabyDoge NFT: caller is not the Minter");
        _;
    }

  modifier isMintLive() {
        require(mintActivate == true,"BabyDoge NFT: Mint is not activated now");
        _;
    }

  function _baseURI() internal view virtual override returns (string memory) {
    return baseURI;
  }


  function mint(address _to, uint _id, uint _amount) external onlyMinter() isMintLive() {

        
        require(_amount <= maxMint, "BabyDoge NFT: Cannot mint this much amount");
        require(totalMinted + _amount <= maxSupply, "BabyDoge NFT: No more NFT left");
        for (uint256 i = 0; i < _amount; i++) {
          _mint(_to, _id);
          _id ++ ;
          
        }
        totalMinted = totalMinted + _amount;
    }


  function tokenURI(uint256 tokenId)
    public
    view
    virtual
    override
    returns (string memory)
  {
    require(
      _exists(tokenId),
      "ERC721Metadata: URI query for nonexistent token"
    );
    if(!visibility){
      return defaultBaseURI;
    }
    else{
    string memory currentBaseURI = _baseURI();
    return bytes(currentBaseURI).length > 0
        ? string(abi.encodePacked(currentBaseURI, tokenId.toString(), baseExtension))
        : "";
    }
  }

  function burn(uint256 _nftId) external{
        require(ownerOf(_nftId) == msg.sender, 'Invalid Owner');
        _burn(_nftId);
    }

  function setmaxMint(uint256 _newmaxMint) external onlyOwner {
    maxMint = _newmaxMint;
  }
  function setMinterAddress(address _minterAddress) external onlyOwner {
    minterAddress = _minterAddress;
  }
  function setBaseURI(string memory _newBaseURI) public onlyOwner {
    baseURI = _newBaseURI;
  }

  function setDefaultBaseURI(string memory _newDefaultBaseURI) public onlyOwner {
    defaultBaseURI = _newDefaultBaseURI;
  }
  function setMintActivation(bool _isMint) public onlyOwner {
    mintActivate = _isMint;
  }

  function setBaseExtension(string memory _newBaseExtension) public onlyOwner {
    baseExtension = _newBaseExtension;
  }
  function setVisibility(bool _visibility) public onlyOwner {
    visibility = _visibility;
  }

}

