pragma solidity ^0.8.10;

contract batch {
    uint public num;
    address public sender;
    uint public value;

    function mintBatch(uint _num) public payable {
        // 使用一个以太币就能够利用delegatecall方法来调用_num次mint函数
        for(uint i = 0; i < _num; i++) {
            (bool success, ) = address(this).delegatecall(
                abi.encodeWithSignature("mint(uint256)", _num)
            );
            require(success, "failed to mintBatch");
        }
    }

    // 只能单独调用mint函数一次，之后，只能通过mintBatch来进行间接调用mint函数
    function mint(uint _num) public payable {
        require(msg.value == 1 ether, "error");
        num = _num;
        sender = msg.sender;
        value += msg.value;
    }
}