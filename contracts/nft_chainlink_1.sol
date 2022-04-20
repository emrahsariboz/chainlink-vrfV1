// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@chainlink/contracts/src/v0.6/VRFConsumerBase.sol";

contract AdvancedCollectible is ERC721, VRFConsumerBase {
    bytes32 internal keyHash;
    uint256 public fee;
    uint256 public tokenCounter;

    uint256 public randomNum;

    mapping(bytes32 => address) public requestIdToSender; // Every request id has a sender(creator).
    mapping(bytes32 => string) public requestIdToTokenURI; // Every request id has a tokenURI as well.
    mapping(uint256 => Breed) public tokenIdToBreed;
    mapping(bytes32 => uint256) public requestIdToTokenId;

    event requestedCollectible(bytes32 indexed requestId);

    enum Breed {
        PUG,
        SHIBA_INU,
        ST_BERNARD
    }

    constructor(
        address _VRFCoordinator,
        address _LinkToken,
        bytes32 _keyHash
    )
        public
        VRFConsumerBase(_VRFCoordinator, _LinkToken)
        ERC721("TEST123", "onetwothree")
    {
        keyHash = _keyHash;
        fee = 0.3 * 10**18;
    }

    function createCollectible(string memory tokenURI)
        public
        returns (bytes32)
    {
        // Randomness returns requestID
        bytes32 requestId = requestRandomness(keyHash, fee);
        // EveryRequestID has creater
        requestIdToSender[requestId] = msg.sender;

        // and every requestId hash tokenURI;
        requestIdToTokenURI[requestId] = tokenURI;
        emit requestedCollectible(requestId);
    }

    function fulfillRandomness(bytes32 requestId, uint256 randomNumber)
        internal
        override
    {
        randomNum = randomNumber;
        address dogOwner = requestIdToSender[requestId];
        string memory tokenURI = requestIdToTokenURI[requestId];
        uint256 newItemId = tokenCounter;

        _safeMint(dogOwner, newItemId);
        _setTokenURI(newItemId, tokenURI);

        Breed breed = Breed(randomNumber % 3);

        // TokenID has to be linked to breed;
        tokenIdToBreed[newItemId] = breed;
        requestIdToTokenId[requestId] = newItemId;

        tokenCounter += 1;
    }

    function setTokenURI(uint256 tokenId, string memory _tokenURI) public {
        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "Not owner nor approved"
        );
        _setTokenURI(tokenId, _tokenURI);
    }
}
