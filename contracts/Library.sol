pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;

contract Library {
    event _library (
        address indexed _from,
        uint indexed _id,
        address indexed logged_addr
    );
    address[][16] public users;  // address of users
    uint[2][16] public counters = [[9,0], [5,0], [2,0], [4,0], [4,0], [2,0], [5,0], [9,0], [9,0], [5,0], [2,0], [4,0], [4,0], [2,0], [5,0], [9,0]]; // number of books

    // borrow books
    function borrow(uint bookId) public returns (uint) {
        require(bookId >= 0 && bookId <= 15);  // ensure id does NOT exceed boundary
        require(counters[bookId][0] > 0); // ensure more than 1 book is left
        users[bookId].push(msg.sender);        // save address of those borrowing books
        counters[bookId][0] = counters[bookId][0]-1;  
        counters[bookId][1] = counters[bookId][1]+1; // update counters
        return bookId;
    }

    // return borrowed books
    function giveback(uint bookId) public returns (uint) {     
        //emit _library(msg.sender, bookId, users[bookId]);
        require(bookId >= 0 && bookId <= 15);  // ensure id does NOT exceed boundary
        bool _match = false;
        for(uint i = 0; i < users[bookId].length; i++) {
            if(users[bookId][i] == msg.sender) {
                delete users[bookId][i];
                _match = true;
                break;
            }
        }
        require(_match); // only the user who borrowed this book can return it
         
        counters[bookId][0] = counters[bookId][0] + 1;  
        counters[bookId][1] = counters[bookId][1] - 1; // update counters
        return bookId;
    }

    // return users
    function getUsers() public view returns (address[][16] memory) {
        return users;
    }

    // get counters
    function getCounters() public view returns (uint[2][16] memory) {
        return counters;
    }
}
