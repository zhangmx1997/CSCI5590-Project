pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;



// ----------------------------------------------------------------------------
// Safe maths
// ----------------------------------------------------------------------------
contract SafeMath {
    function safeAdd(uint a, uint b) public pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }
    function safeSub(uint a, uint b) public pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }
    function safeMul(uint a, uint b) public pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }
    function safeDiv(uint a, uint b) public pure returns (uint c) {
        require(b > 0);
        c = a / b;
    }
}


// ----------------------------------------------------------------------------
// ERC Token Standard #20 Interface
// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
// ----------------------------------------------------------------------------
contract ERC20Interface {
    function totalSupply() public view returns (uint);
    function balanceOf(address tokenOwner) public view returns (uint balance);
    function allowance(address tokenOwner, address spender) public view returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}



// ----------------------------------------------------------------------------
// Owned contract
// ----------------------------------------------------------------------------
contract Owned {
    address public owner;
    address public newOwner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }
    function acceptOwnership() public {
        require(msg.sender == newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}


// ----------------------------------------------------------------------------
// ERC20 Token, with the addition of symbol, name and decimals and assisted
// token transfers
// ----------------------------------------------------------------------------
contract GangToken is ERC20Interface, Owned, SafeMath {
    string public symbol;
    string public  name;
    uint8 public decimals;
    uint public _totalSupply;
    uint public amountRaised;
    bool GangClosed = false;
    address public ifSuccessfulSendTo;

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;


    // ------------------------------------------------------------------------
    // Constructor
    // ------------------------------------------------------------------------
    constructor() public {
        symbol = "GANG";
        name = "Gang Token";
        decimals = 18;
        _totalSupply = 10000;
        ifSuccessfulSendTo = 0x441D18409E5C5e552a2DbD5B6c40646C730Dcf99;
        if (balances[ifSuccessfulSendTo] == 0)
        {
            balances[ifSuccessfulSendTo] = _totalSupply;
            emit Transfer(address(0), ifSuccessfulSendTo, _totalSupply);
        }
    }



    // ------------------------------------------------------------------------
    // Total supply
    // ------------------------------------------------------------------------
    function totalSupply() public view returns (uint) {
        return _totalSupply  - balances[0x441D18409E5C5e552a2DbD5B6c40646C730Dcf99];
    }


    
    function modifyBalance(address target, uint value, uint flag) public returns (bool success){
	if (flag == 1)
	{
        	balances[target] = safeSub(balances[target], value); 
	}
	else
	{
		balances[target] = safeAdd(balances[target], value); 
	}
        return true;
    }
    // ------------------------------------------------------------------------
    // Get the token balance for account tokenOwner
    // ------------------------------------------------------------------------
    function balanceOf(address tokenOwner) public view returns (uint balance) {
        return balances[tokenOwner];
    }


    // ------------------------------------------------------------------------
    // Transfer the balance from token owner's account to to account
    // - Owner's account must have sufficient balance to transfer
    // - 0 value transfers are allowed
    // ------------------------------------------------------------------------
    function transfer(address to, uint tokens) public returns (bool success) {
        balances[msg.sender] = safeSub(balances[msg.sender], tokens);
        balances[to] = safeAdd(balances[to], tokens);
        emit Transfer(msg.sender, to, tokens);
        return true;
    }


    // ------------------------------------------------------------------------
    // Token owner can approve for spender to transferFrom(...) tokens
    // from the token owner's account
    //
    // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
    // recommends that there are no checks for the approval double-spend attack
    // as this should be implemented in user interfaces 
    // ------------------------------------------------------------------------
    function approve(address spender, uint tokens) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }


    // ------------------------------------------------------------------------
    // Transfer tokens from the from account to the to account
    // 
    // The calling account must already have sufficient tokens approve(...)-d
    // for spending from the from account and
    // - From account must have sufficient balance to transfer
    // - Spender must have sufficient allowance to transfer
    // - 0 value transfers are allowed
    // ------------------------------------------------------------------------
    function transferFrom(address from, address to, uint tokens) public returns (bool success) {
        balances[from] = safeSub(balances[from], tokens);
        allowed[from][msg.sender] = safeSub(allowed[from][msg.sender], tokens);
        balances[to] = safeAdd(balances[to], tokens);
        emit Transfer(from, to, tokens);
        return true;
    }


    // ------------------------------------------------------------------------
    // Returns the amount of tokens approved by the owner that can be
    // transferred to the spender's account
    // ------------------------------------------------------------------------
    function allowance(address tokenOwner, address spender) public view returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }

    function () external payable{
        require(!GangClosed);
        uint amount = msg.value / 1e18;
        balances[msg.sender] += amount;
        balances[ifSuccessfulSendTo] -= amount;
        amountRaised += amount;
        emit Transfer(ifSuccessfulSendTo, msg.sender, amount);
    }


    // ------------------------------------------------------------------------
    // Owner can transfer out any accidentally sent ERC20 tokens
    // ------------------------------------------------------------------------
    function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {
        return ERC20Interface(tokenAddress).transfer(owner, tokens);
    }
}

contract Library{
    event _library (
        address indexed _from,
        uint indexed _id,
        address indexed logged_addr
    );
    address[][16] public users;  // address of users
    uint[2][16] public counters = [[9,0], [5,0], [2,0], [4,0], [4,0], [2,0], [5,0], [9,0], [9,0], [5,0], [2,0], [4,0], [4,0], [2,0], [5,0], [9,0]]; // number of books
    GangToken myToken;
    constructor(address payable addressToken) public{
        myToken = GangToken(addressToken);
    }
    // borrow books
    function borrow(uint bookId, uint price) public returns (uint) {
        require(bookId >= 0 && bookId <= 15);  // ensure id does NOT exceed boundary
        require(counters[bookId][0] > 0); // ensure more than 1 book is left
        myToken.modifyBalance(msg.sender, price, 1);
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
    function () external payable{
        require(1>0);
    }
}
