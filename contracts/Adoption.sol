pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;

contract Adoption {
    event Adopt (
        address indexed _from,
        uint indexed _id,
        address indexed logged_addr
    );
    address[][16] public adopters;  // address of users
    uint[2][16] public counters = [[9,0], [5,0], [2,0], [4,0], [4,0], [2,0], [5,0], [9,0], [9,0], [5,0], [2,0], [4,0], [4,0], [2,0], [5,0], [9,0]]; // number of books

    // borrow books
    function adopt(uint petId) public returns (uint) {
        require(petId >= 0 && petId <= 15);  // ensure id does NOT exceed boundary
        require(counters[petId][0] > 0); // ensure more than 1 book is left
        adopters[petId].push(msg.sender);        // save address of those borrowing books
        counters[petId][0] = counters[petId][0]-1;  
        counters[petId][1] = counters[petId][1]+1; // update counters
        return petId;
    }

    // return borrowed books
    function giveback(uint petId) public returns (uint) {
        
        //emit Adopt(msg.sender, petId, adopters[petId]);

        require(petId >= 0 && petId <= 15);  // ensure id does NOT exceed boundary
        bool _match = false;
        for(uint i = 0; i < adopters[petId].length; i++) {
            if(adopters[petId][i] == msg.sender) {
                delete adopters[petId][i];
                _match = true;
                break;
            }
        }
        require(_match); // only the user who borrowed this book and return it
        
        // clear record 
        //adopters[petId] = address(0x0000000000000000000000000000000000000000); 
        counters[petId][0] = counters[petId][0] + 1;  
        counters[petId][1] = counters[petId][1] - 1; // update counters
        return petId;
    }

    // 返回领养者
    function getAdopters() public view returns (address[][16] memory) {
        return adopters;
    }

    // get counters
    function getCounters() public view returns (uint[2][16] memory) {
        return counters;
    }
}