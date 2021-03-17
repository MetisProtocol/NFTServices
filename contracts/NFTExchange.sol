pragma solidity ^0.6.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract NFTExchange is Ownable, IERC721Receiver{
    
    using SafeMath for uint256;

    event NewListing(address owner, uint256 index, address tokenaddr, uint256 tokenid, uint256 price); 
    event CloseListing(address owner, uint256 index, address purchaser, address tokenaddr, uint256 tokenid, uint256 price); 

   
    enum STATUS {NONE, OPEN, CLOSED}
    
    struct Listing{
        address owner; //owner of the token
        STATUS status;
        uint expiry; // must finish before the expiry, 0 if infinite 
        uint timestamp; // last updated timestamp
        address tokenaddress;  // token address
        uint256 tokenid;  // id
        uint256 price;
    }
    
    Listing[] listings;
    uint[] openings;
    IERC20 settlementToken;
    
    constructor(address tokenaddr) public {
        settlementToken = IERC20(tokenaddr);
    }

    /// add a new listing to the list
    function addListing(address tokenaddr, uint256 tokenid, uint256 expiry, uint256 price) public {

        require(price > 0, "price should be > 0");
        address owner = msg.sender;
        Listing memory l;
        l.owner = owner;
        l.expiry = expiry;
        l.timestamp = now;
        l.tokenaddress = tokenaddr;
        l.tokenid = tokenid;
        l.status = STATUS.OPEN;
        l.price = price;
        IERC721 token = IERC721(tokenaddr);

        token.safeTransferFrom(owner, address(this), tokenid);
        _addToListing(l);
    }

    function _addToListing(Listing memory l) internal {

        uint index;
        if (openings.length > 0) {
            index = openings[openings.length - 1];
            openings.pop();
            listings[index] = l;
        } else {
            index = listings.length;
            listings.push(l);
        }
        emit NewListing(l.owner, index, l.tokenaddress, l.tokenid, l.price);
    }

    function closeListing(uint256 index, address purchaser) public {
        require(purchaser == msg.sender, "only purchaser can close the listing");

        Listing memory l = listings[index];
        require(l.status == STATUS.OPEN, "status is not open");
        require(settlementToken.transferFrom(purchaser, l.owner, l.price), "fund transfer failed");
        IERC721 token = IERC721(l.tokenaddress);
        token.safeTransferFrom(address(this), purchaser, l.tokenid);
        emit CloseListing(l.owner, index, purchaser, l.tokenaddress, l.tokenid, l.price);
        _removeFromListing(index);
    }

    function removeListing(uint256 index) public {

        address owner = msg.sender;
        Listing memory l = listings[index];
        require(l.owner == owner, "Only owner can remove");
        require(l.status == STATUS.OPEN, "status is not open");
        IERC721 token = IERC721(l.tokenaddress);
        token.safeTransferFrom(address(this), owner, l.tokenid);
        emit CloseListing(l.owner, index, address(0), l.tokenaddress, l.tokenid, 0);
        _removeFromListing(index);
    }
    
    function _removeFromListing(uint256 index) internal {
        Listing storage l = listings[index];
        l.status = STATUS.CLOSED;
        openings.push(index);
    }
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) override external returns (bytes4){
        return IERC721Receiver.onERC721Received.selector;
    }
}
