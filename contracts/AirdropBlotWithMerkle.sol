pragma solidity 0.5.7;

import "./PlotXToken.sol";
import "./external/openzeppelin-solidity/cryptography/MerkleProof.sol";
import "./interfaces/IMerkleDistributor.sol";

interface IbLOTToken {
  function mint(address account, uint256 amount) external returns (bool);
}

contract AirdropBlotWithMerkle is IMerkleDistributor {
    
    bytes32 public merkleRoot;
    IbLOTToken public bLotToken;
    PlotXToken public plotToken;
    uint public reward;

    // This is a packed array of booleans.
    mapping(uint256 => uint256) private claimedBitMap;

    constructor(address _bLotToken, address _plotToken, bytes32 _merkleRoot, uint _reward) public {
        require(_plotToken != address(0),"Can not be null address");
        require(_bLotToken != address(0),"Can not be null address");
        require(_reward > 0, "Should be positive");
        plotToken = PlotXToken(_plotToken);
        bLotToken = IbLOTToken(_bLotToken);
        merkleRoot = _merkleRoot;
        reward = _reward;
    }

    function isClaimed(uint256 index) public view returns (bool) {
        uint256 claimedWordIndex = index / 256;
        uint256 claimedBitIndex = index % 256;
        uint256 claimedWord = claimedBitMap[claimedWordIndex];
        uint256 mask = (1 << claimedBitIndex);
        return claimedWord & mask == mask;
    }

    function _setClaimed(uint256 index) private {
        uint256 claimedWordIndex = index / 256;
        uint256 claimedBitIndex = index % 256;
        claimedBitMap[claimedWordIndex] = claimedBitMap[claimedWordIndex] | (1 << claimedBitIndex);
    }

    function claim(uint256 index, address account, bytes32[] calldata merkleProof) external {
        require(!isClaimed(index), 'MerkleDistributor: Drop already claimed.');

        // Verify the merkle proof.
        bytes32 node = keccak256(abi.encodePacked(index, account, reward));
        require(MerkleProof.verify(merkleProof, merkleRoot, node), 'MerkleDistributor: Invalid proof.');

        // Mark it claimed and send the token.
        _setClaimed(index);
        bLotToken.mint(account, reward);
 
        emit Claimed(index, account, reward);
    }
}
