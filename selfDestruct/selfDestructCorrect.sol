pragma solidity ^0.8.9;

contract EtherGame{

    uint public targetAmount = 7 ether;
    uint public balance;
    address public winner;

    function deposit() public payable{
        require(msg.value == 1 ether, "you can only send 1 ether");

        // 通过状态变量来统计ether，此时即使合约自杀传入ether，也不会干扰条件判断逻辑
        balance += msg.value; 

        require(balance <= targetAmount, "Game is over");

        if(balance == targetAmount) {
            winner = msg.sender;
        }
    }

    function claimReward() public {
        require(msg.sender == winner, "not winner");

        (bool sent, ) = msg.sender.call{value: balance}("");
        require(sent, "failed to send ether");
    }
}

contract Attack{

    EtherGame etherGame;

    constructor(EtherGame _etherGame){
        etherGame = EtherGame(_etherGame);
    }

    function attack() public payable{

        address payable addr = payable(address(etherGame));
        selfdestruct(addr); //将Attack合约内的以太币转给addr
    }
}