pragma solidity 0.8.19;

import "hardhat/console.sol";
contract Test {
    
    function testEOA(uint _num) public payable {
        address EOA = 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2;
        (bool success, ) = address(EOA).call(
            abi.encodeWithSignature("mint(uint256)", _num)
        );

        // 这个居然是true，这个存在攻击可能
        console.log("result:", success);
    }

    function testNotExist(uint _num) public payable {
        (bool success, ) = address(this).call(
            abi.encodeWithSignature("notExist(uint256)", _num)
        );

         // true，因为执行了fallback
         // 如果fallback不存在，则返回false，但是不会抛异常
        console.log("result:", success);
    }

    function testExist(uint _num) public payable {
        // call函数只会检查是否执行了底层的EVM操作。因此，这种方式可能无法准确地检测函数是否按预期执行
        (bool success, ) = address(this).call(
            abi.encodeWithSignature("mint(uint256)", _num)
        );

         // true
        console.log("result:", success);
    }
    function mint(uint _num) public payable {
        console.log("mint called:", _num);
    }

    fallback() external payable {
        console.log("fallback called");
    }

    receive() external payable { }
}