// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

/// @title Generic ERC721 NFT Contract
/// @author Roland Strasser - https://kryptohr.ch
/// @notice This is a generic NFT contract to be used under the MIT licence
/// @notice No warranties or whatsoever are taken by the author.
/// @notice Usage of this contract in a productive environment is on your own risk

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/interfaces/IERC2981.sol";

contract NFTContract is ERC721Enumerable, Ownable, IERC2981 {
    using Strings for uint256;

    /// @notice base attributes of the contract*/

    /// @dev base url and baseExtension are for the standard MetaData connection
    string public baseExtension = ".json";
    string private baseURI;

    /// @dev revealURI holds the URI to the metadata file that should be loaded before reveal
    string private revealURI;
    bool public revealed = false;

    /// @dev contractURI holds URI to the contract.json according to OpenSea
    string public contractURI;

    uint256 public tokenCounter;
    bool public paused = true;
    uint256 public maxmintAmount = 10;

    /// @notice royalty fields for eip-2981
    address public royaltyReceiver;
    uint16 public royaltyBasisPoints;

    /// @notice minting price
    uint256 public mintingPrice;

    /// @notice supply
    uint256 public maxSupply;

    /// @notice constructor
    /// @param _collectionName as the name of the contract collection
    /// @param _shortcut as the shortcut of the collection
    /// @param _newBaseURI for the base URI connection
    /// @param _royaltyReceiver receiver address for royalties according eip-2981
    /// @param _royaltyBasisPoints amount of royalties to claim as basis points according eip-2981
    /// @param _newRevealURI the uri pointing to the reveal json file
    /// @param _newContractURI the uri pointing to the contract json file
    /// @param _newSupply set maximul supply of collection
    /// @param _newPrice as the price for the minting in WEI denomination
    constructor(
        string memory _collectionName,
        string memory _shortcut,
        string memory _newBaseURI,
        address _royaltyReceiver,
        uint16 _royaltyBasisPoints,
        string memory _newRevealURI,
        string memory _newContractURI,
        uint256 _newSupply,
        uint256 _newPrice
    ) ERC721(_collectionName, _shortcut) {
        tokenCounter = 0;
        setBaseURI(_newBaseURI);
        setroyaltyReceiver(_royaltyReceiver);
        setroyaltyBasisPoints(_royaltyBasisPoints);
        setRevealURI(_newRevealURI);
        setContractURI(_newContractURI);
        setmintingPrice(_newPrice);
        maxSupply = _newSupply;
    }

    /// @notice public minting to msg.sender. Free for contract owner
    /// @param _mintAmount amount of NFTs that should be minted.
    function mintNFT(uint256 _mintAmount) public payable {
        require(!paused, "Contract is paused!");

        require(
            tokenCounter + _mintAmount <= maxSupply,
            "Maximum of possible NFTs is reached"
        );
        require(_mintAmount > 0, "At least one token must be minted");
        require(
            _mintAmount <= maxmintAmount,
            "Minting capacity exeeds allowed limit"
        );

        /// @notice only not-owner user pays for the minting
        if (msg.sender != owner()) {
            require(
                msg.value >= mintingPrice * _mintAmount,
                "Payed Ether is too less for minting."
            );
        }

        for (uint256 i = 1; i <= _mintAmount; i++) {
            tokenCounter++;
            _safeMint(msg.sender, tokenCounter);
        }
    }

    /// @notice read URI of Token for Metadata
    /// @param _tokenId represents the ID of the NFT to view
    /// @dev if reveal is true it returns the baseURI + tokenID + baseExtension
    /// @dev if reveal is false it returns only the revealURI
    /// @return string as the URI to the MetaData json file
    function tokenURI(uint256 _tokenId) public view virtual override returns (string memory) {
        require(
            _exists(_tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );
        if (revealed) {
            return
                string(
                    abi.encodePacked(
                        baseURI,
                        _tokenId.toString(),
                        baseExtension
                    )
                );
        } else {
            return string(revealURI);
        }
    }

    /// @notice get NFTs of specific address
    /// @param _owner Wallet address to input. Not to be confused with the Ownable owner
    /// @return tokenIds as a list of all the NFT ids the wallet owns
    function getNFTContract(address _owner) public view returns (uint256[] memory) {
        uint256 ownerTokenCount = balanceOf(_owner);
        uint256[] memory tokenIds = new uint256[](ownerTokenCount);
        for (uint256 i; i < ownerTokenCount; i++) {
            tokenIds[i] = tokenOfOwnerByIndex(_owner, i);
        }
        return tokenIds;
    }

    /// @notice returns the royalty infos according eip-2981
    /// @param _tokenId not used
    /// @param _price to be calculated royalties of
    /// @return receiver the wallet address royalties must be paied to
    /// @return royaltyAmount calculated amount of royalties to be paied
    function royaltyInfo(uint256 _tokenId, uint256 _price) external view override returns (address receiver, uint256 royaltyAmount) {
        receiver = royaltyReceiver;
        royaltyAmount = getPercentageOf(_price, royaltyBasisPoints);
    }

    /// @notice calculates the royalties for secondary sale
    /// @param _amount as calculation bae
    /// @param _basisPoints to calculate royalties for
    /// @return value as the resulting royaltyamount
    function getPercentageOf(uint256 _amount, uint16 _basisPoints) internal pure returns (uint256 value) {
        value = (_amount * _basisPoints) / 10000;
    }

    /// @notice only owner functions

    /// @notice sets minting price
    /// @param _newPrice represents the new price in WEI format
    function setmintingPrice(uint256 _newPrice) public onlyOwner {
        mintingPrice = _newPrice;
    }

    /// @notice changes base uri
    /// @param _newBaseURI a string holding a URL
    /// @dev The _newBaseURI must contain a / at the end
    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
    }

    /// @notice changes reveal uri
    /// @param _newRevealURI a string holding a URL
    /// @dev The _newBaseURI must contain a / at the end
    function setRevealURI(string memory _newRevealURI) public onlyOwner {
        revealURI = _newRevealURI;
    }

    /// @notice changes contract uri
    /// @param _newContractURI a string holding a URL
    /// @dev The _newBaseURI must contain a / at the end
    function setContractURI(string memory _newContractURI) public onlyOwner {
        contractURI = _newContractURI;
    }

    /// @notice sets maximal amout of nft to mint in one transaction
    /// @param _newmaxMintAmount as a number for the maximum
    function setmaxMintAmount(uint256 _newmaxMintAmount) public onlyOwner {
        maxmintAmount = _newmaxMintAmount;
    }

    /// @notice changes extension of base uri
    /// @param _newBaseExtension a string holding a file extension. erc721 suggests it to be .json
    function setBaseExtension(string memory _newBaseExtension) public onlyOwner {
        baseExtension = _newBaseExtension;
    }

    /// @notice switches paused
    /// @dev normal and whitelist minting is stopped. Reserved minting is still possible
    function switchPaused() public onlyOwner {
        paused = !paused;
    }

    /// @notice switches reveal
    /// @dev switch the reveal state
    function switchRevealed() public onlyOwner {
        revealed = !revealed;
    }

    /// @notice changes receiver address for second sale royalties
    /// @param _receiver address of new wallet address
    function setroyaltyReceiver(address _receiver) public onlyOwner {
        royaltyReceiver = _receiver;
    }

    /// @notice changes basis point for royalties calculation
    /// @param _amount in basis points for charging roylaties
    function setroyaltyBasisPoints(uint16 _amount) public onlyOwner {
        royaltyBasisPoints = _amount;
    }

    /// @notice withdraws all ETH from the contract to the owner wallet
    function withdraw() public payable onlyOwner {
        require(payable(msg.sender).send(address(this).balance));
    }
}
