pragma solidity ^0.8.9;

contract EtherStore {

    mapping(address => uint) balances;

    // 存款函数
    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }

    // 取款函数
    function withdraw() public {
        uint val = balances[msg.sender];
        require(val > 0);

        (bool sent, ) = msg.sender.call{value: val}(""); // 攻击者可能通过多次执行这个函数，来发起重入攻击
        require(sent, "failed to send ether");

        balances[msg.sender] = 0; 
    }
    
    // 获取合约余额
    function getBalances() public view returns(uint){
        return address(this).balance;
    }
}
