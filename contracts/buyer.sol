// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

interface XEN {
    function claimRank(uint256 term) external;
    function claimMintRewardAndShare(address other, uint256 pct) external;    
}

contract MintForMint is Ownable{
    address public _owner;
    uint8 public _day;
    XEN public _token;

    constructor(XEN token,address payable owner, uint8 day) {
        token.claimRank(day);        
        _token = token;
        _owner = owner;
        _day = day;
    }

    function claim() external onlyOwner {
        _token.claimMintRewardAndShare(_owner,100);
        selfdestruct(payable(_owner));
    }
}

contract Buyer is Ownable{
    using Counters for Counters.Counter;
    Counters.Counter public idTracker;
    Counters.Counter public claimTracker;

    uint8 public _day;
    address payable public _owner;
    XEN public _addr;

    struct Info {
        uint256 claimday;
        MintForMint mint;
    }

    mapping(uint256 => Info) private mints;

    constructor(
        address payable owner,
        uint8 day,
        XEN addr
    ) {
        _day = day;
        _owner = owner;
        _addr = addr;
    }

    function buyToken(uint8 number) external onlyOwner {
        for (uint i = 0; i < number; i++) {
            //idTracker.
            uint256 id = idTracker.current();            
            MintForMint mint = new MintForMint(_addr,_owner, _day);
            Info memory infos;
            infos.claimday = block.timestamp;
            infos.mint = mint;
            mints[id] = infos;
            idTracker.increment();   
        }
    }

    function claimToken(uint8 number) external onlyOwner {
        for (uint i = 0; i < number; i++) {
            //idTracker.
            uint256 id = claimTracker.current();            
            Info memory info = mints[id];
            info.mint.claim();
            claimTracker.increment();   
        }
    }
}
