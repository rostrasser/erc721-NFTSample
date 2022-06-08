# Extended ERC721 NFT contract sample

This repository holds an extender Solidity NFT smart contract according to the ERC721 standard.
The contract should help beginners to aquire knowledge in ERC721 development.

This repository holds two contracts:
- *erc721-NFTSample.sol* The basic contract with imports of the used libraries.
- *erc721-NFTSample_flat.sol* The flattened contract with dissolved libraries.

The contract itself follows the metadata structuring according to OpenSea and requires the user to have the metadata ready in .json files with links to the images.
See: [Opensea metadata description](https://docs.opensea.io/docs/metadata-standards)

# Contract attributes
The following highlights are included in the contract, that vary from the ERC721 standard:

- *Reveal mechanism*
- *EIP-2981 functionality*
- *List of NFTs per wallet address*
- *OpenSea contract.json connection*
- *Pause mechanism*
- *Free owner minting*
- *Basic withdraw function*

# Contract libraries
The following libraries are used in the contract:

- *ERC721Enumerable.sol by [Openzeppelin](https://github.com/OpenZeppelin/openzeppelin-contracts/tree/master/contracts/token/ERC721)*
- *Ownable.sol by [Openzeppelin](https://github.com/OpenZeppelin/openzeppelin-contracts/tree/master/contracts/access)*
- *IERC2981.sol by [Openzeppelin](https://github.com/OpenZeppelin/openzeppelin-contracts/tree/master/contracts/interfaces)*

# Included functions
The contract holds the following important functions, a long side the basic ERC721 functions, that are not listed here.

**mintNFT:**
Mints the inputed amount (limited by maxmintAmount) to the msg.sender.

**tokenURI:**
Overriden function to include the reveal mechanism.

**setMintingPrice:**
To change the price for the minting. Requires input in WEI denomination.
See [ETH Converter](https://eth-converter.com/)

**setBaseURI:**
To update the baseURI of the contract. Requires to end with a "/"

**setRevealURI:**
To update the revealURI of the contract. Must point to a single file.

**setContractURI:**
To update the contractURI of the contract. Must point to a single file according the Opensea standard.
See: [Opensea Contract Level Documentation](https://docs.opensea.io/docs/contract-level-metadata)

**setMaxmintAmount:**
Changes the maximal mintable NFTs per transaction.

**switchPaused:**
Swichtes the state of the paused parameter. If true, minting is not possible.

**switchRevealed:**
Swichtes the state of the reveal parameter. If true, contract returns proper NFT data.

**withdraw:**
Withdraws all funds on the contract to the owner.

# Find me for questions
If you need your specific designed smart contract, don't hesitate to contact me at [roland@rostrasser.ch](mailto:roland@rostrasser.ch) or book me on [Fiverr](https://www.fiverr.com/rolandstrasser).