pragma solidity ^0.5.0;

contract Adoption {
    address[16] public adopters;  // 保存领养者的地址

    // 领养宠物
    function adopt(uint petId) public returns (uint) {
        require(petId >= 0 && petId <= 15);  // 确保id在数组长度内
        adopters[petId] = msg.sender;        // 保存调用这地址 
        return petId;
    }

    // return borrowed books
    function giveback(uint petId) public returns (uint) {
        
        //emit Adopt(msg.sender, petId, adopters[petId]);

        require(petId >= 0 && petId <= 15);  // ensure id does NOT exceed boundary
        require(adopters[petId] == msg.sender); // only the user who borrowed this book and return it
        
        // clear record 
        adopters[petId] = address(0x0000000000000000000000000000000000000000); 
        return petId;
    }

    // 返回领养者
    function getAdopters() public view returns (address[16] memory) {
        return adopters;
    }
}
