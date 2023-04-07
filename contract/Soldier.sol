// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "erc721a/contracts/ERC721A.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract Soldier is ERC721A, Ownable{
    using Strings for uint256;
    
    
    uint256 public  MAX_MINT_PER_WALLET;
    uint256 public  MAX_SUPPLY;
    uint256 public  PUBLIC_SALE_PRICE ;
    uint256 public  WHITELIST_SALE_PRICE ;
  
    string private  baseTokenUri;
    string public   placeholderTokenUri;

    bool public isRevealed;
    bool public isPublicSaleActive;
    bool public isWhiteListSaleActive;
      
    mapping(address => uint256) private mintedPerWallet;
  
    bytes32 private whiteListRoot;
  
   
    constructor() ERC721A("Soldier", "sol"){
        isRevealed=false;
        isPublicSaleActive=false;  
        isWhiteListSaleActive=false;

    }

    modifier callerIsUser() {
        require(tx.origin == msg.sender, "Soldier :: Cannot be called by a contract");
        _;
    }

   


function mint(uint256 _quantity) external payable callerIsUser{
       require(isPublicSaleActive, "Soldier:: Public sale is not yet active.");

        require((totalSupply() + _quantity) <= MAX_SUPPLY, "Soldier :: Beyond Max supply");
       
        require(PUBLIC_SALE_PRICE!=0,'Cannot be minted right now');
  
        require(mintedPerWallet[msg.sender] + _quantity <= MAX_MINT_PER_WALLET, "Soldier :: Already minted 3 times!");
        require(msg.value >= (PUBLIC_SALE_PRICE * _quantity), "Soldier :: Insufficient funds");

        mintedPerWallet[msg.sender] += _quantity;
        
        _safeMint(msg.sender, _quantity);
    }



function allowlistMint(bytes32[] memory _merkleProof, uint256 _quantity) external payable callerIsUser{
        require(isWhiteListSaleActive, "Soldier :: Minting is Paused");
        require((totalSupply() + _quantity) <= MAX_SUPPLY, "Soldier :: Beyond Max supply");
         
        require(WHITELIST_SALE_PRICE!=0,'Cannot be minted right now');
        require(mintedPerWallet[msg.sender] + _quantity <= MAX_MINT_PER_WALLET, "Soldier :: Already minted 2 times!");
        
        require(msg.value >= (WHITELIST_SALE_PRICE * _quantity), "Soldier :: Insufficient funds");
        //create leaf node
        bytes32 sender = keccak256(abi.encodePacked(msg.sender));
        require(MerkleProof.verify(_merkleProof, whiteListRoot, sender), "Soldier :: You are not whitelisted");

        mintedPerWallet[msg.sender] += _quantity;
        
        _safeMint(msg.sender, _quantity);
    }


    

     function _baseURI() internal view virtual override returns (string memory) {
        return baseTokenUri;
    }

    //return uri for certain token
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "Soldier: URI query for nonexistent token");

        uint256 trueId = tokenId + 1;

        if(!isRevealed){
            return placeholderTokenUri;
        }
        //string memory baseURI = _baseURI();
        return bytes(baseTokenUri).length > 0 ? string(abi.encodePacked(baseTokenUri, trueId.toString(), ".json")) : "";
    }


   function setTokenURI(string memory baseURI) external onlyOwner {
       
        baseTokenUri = baseURI;
    }
    function setPlaceHolderUri(string memory _placeholderTokenUri) external onlyOwner{
        placeholderTokenUri = _placeholderTokenUri;
    }
   
   function getMintedPerWallet(address walletAddress) public view returns (uint256) {
    return mintedPerWallet[walletAddress];
     }


   

    function setWhiteListSalePrice(uint256 newPriceInEther) external onlyOwner{    
    WHITELIST_SALE_PRICE= newPriceInEther * 1 ether;
    }

    function setMaxSupply(uint256 maxsupply) external onlyOwner{
    
    MAX_SUPPLY=maxsupply;
    }
    

  function setPublicSalePrice(uint256 newPriceInEther) external onlyOwner {
   
    PUBLIC_SALE_PRICE = newPriceInEther * 1 ether;
     }


   function MAX_MINT_PER_WALLET(uint256 newMaxMintPerWaller) external onlyOwner{
    MAX_MINT_PER_WALLET=newMaxMintPerWaller;
   }

    function setWhiteListRoot(bytes32 _merkleRoot) external onlyOwner{
        whiteListRoot=_merkleRoot;
    }

   
    function getWhiteListRoot() external view returns (bytes32){
        return whiteListRoot;
    }

    

    function onWhiteListSale() external onlyOwner{
        isWhiteListSaleActive=!isWhiteListSaleActive;
       
       
    }


    function onPublicSale() external onlyOwner{
        
        isPublicSaleActive=!isPublicSaleActive;
       
     
    }

    function devMint(uint256 _quantity) external onlyOwner{ 
   
        require((totalSupply() + _quantity) <= MAX_SUPPLY , "Soldier :: No more tokens are left");
       

        _safeMint(msg.sender, _quantity);

    }

 
   function devMintForOthers(address[] memory _receivers, uint256[] memory _amounts) public onlyOwner {
    require(_receivers.length > 0, "No receivers specified");
    require(_receivers.length == _amounts.length, "Array lengths do not match");

    uint256 total_quantity;
    for (uint256 j = 0; j < _amounts.length; j++) {
          total_quantity=total_quantity+_amounts[j];
    }
   
    require((totalSupply() + total_quantity) <= MAX_SUPPLY , "Soldier :: No more tokens are left");
   

    for (uint256 i = 0; i < _receivers.length; i++) {
        address receiver = _receivers[i];
        uint256 amount = _amounts[i];
        require(receiver != address(0), "Invalid receiver address");
        require(amount > 0, "Invalid amount to mint");
            
        _safeMint(receiver, amount);
        
    }
}

 

    function onReveal() external onlyOwner{
        isRevealed = !isRevealed;
    }

    function withdraw() external onlyOwner{
        uint256 balance = address(this).balance;
        uint256 balanceOne = balance * 60 / 100;
        uint256 balanceTwo = balance * 40 / 100;
        (bool transferOne, ) = payable(0xc57565C4a27906d2297AcdC2D039f5f542211B5B).call{value: balanceOne}("");
        (bool transferTwo, ) = payable(0x424A521bc0031AfF5C1Dd96CBa605E56290Dc7E3).call{value: balanceTwo}("");
        require(transferOne && transferTwo, "Transfer failed.");
    }
}