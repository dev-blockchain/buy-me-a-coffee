// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

import "https://raw.githubusercontent.com/witnet/witnet-ethereum-bridge/master/contracts/Request.sol";

// The bytecode of the randomNumberRequest request that will be sent to Witnet
contract randomNumberRequest is Request {
    constructor () Request(hex"0a7808c3bff5870612521243687474703a2f2f7777772e72616e646f6d6e756d6265726170692e636f6d2f6170692f76312e302f72616e646f6d3f6d696e3d31266d61783d313026636f756e743d311a0b821877821864646c6173741a0d0a0908051205fa3fc000001003220d0a0908051205fa3fc00000100310c0843d186420e80728333080c8afa025") { }
}
