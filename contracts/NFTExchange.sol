pragma solidity >=0.4.22 <0.6.0;

import "@openzeppelin/contracts/ownership/Ownable.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract NFTExchange is Ownable{
    
    using SafeMath for uint256;

    event NewListing(address owner, uint256 index, address tokenaddr, uint256 tokenid); 
    event CloseListing(address owner, uint256 index, address purchaser, address tokenaddr, uint256 tokenid, uint256 price); 

   
    enum STATUS {NONE, OPEN, CLOSED}
    
    struct Listing{
        address owner; //owner of the token
        STATUS status;
        uint expiry; // must finish before the expiry, 0 if infinite 
        uint timestamp; // last updated timestamp
        address tokenaddress;  // token address
        address tokenid;  // id
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

        address owner = msg.sender;
        Listing l;
        l.owner = owner;
        l.expiry = expiry;
        l.timestamp = now;
        l.tokenaddress = tokenaddr;
        l.tokenid = tokenid;
        l.status = STATUS.OPEN;
        l.price = price;
        IERC721 token = IERC721(tokendaddr);

        require(token.transferFrom(owner, address(this), tokenid), "Token transfer failed");
        _addToListing(l);
    }

    function _addToListing(Listing l) internal {

        uint index;
        if (openings.length > 0) {
            index = openings.pop();
        } else {
            index = listings.length;
            listings.push(l);
        }
        emit NewListing(l.owner, index, l.tokenaddress, l.tokenid, l.price);
    }

    function closeListing(uint256 index, address purchaser) public {

        address owner = msg.sender;
        Listing l memory = listings[index];
        require(l.status == STATUS.OPEN, "status is not open");
        require(settlementToken.transferFrom(purchaser, l.owner, l.price), "fund transfer failed");
        IERC721 token = IERC721(l.tokenaddress);
        require(token.transfer(purchaser, l.tokenid), "token transfer failed");
        _removeFromListing(index);
    }

    function removeListing(uint256 index) public {

        address owner = msg.sender;
        Listing l memory = listings[index];
        require(l.owern == owner, "Only owner can remove");
        require(l.status == STATUS.OPEN, "status is not open");
        _removeFromListing(index);
    }
    
    function _removeFromListing(uint256 index) internal {
        Listing l storage = listings[index];
        l.status = STATUS.CLOSED;
        openings.push(index);
    }
}
