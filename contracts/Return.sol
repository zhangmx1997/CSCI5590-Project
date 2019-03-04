pragma solidity ^0.5.0;

contract Return {
     address[16] public users;  // addresses of users who borrowed books
    // return borrowed books
    function giveback(uint bookId) public returns (uint) {
        require(bookId >= 0 && bookId <= 15);  // ensure id does NOT exceed boundary
        require(users[bookId] == msg.sender); // only the user who borrowed this book and return it
        
        // clear record 
        users[bookId] = address(0x0000000000000000000000000000000000000000); 
        return bookId;
    }
    // return user list
    function getUsers() public view returns (address[16] memory) {
        return users;
    }

}