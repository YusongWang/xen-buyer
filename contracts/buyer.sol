// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

interface XEN {
    function claimRank(uint256 term) external;
    function claimMintRewardAndShare(address other, uint256 pct) external;    
}

interface IBuyer{
    function fetchAddr() external view returns(XEN);
}

contract MintForMint is Ownable{
    address public _owner;
    uint8 public _day;
    IBuyer public _buyer;    
    XEN public _token;

    constructor(IBuyer buyer,address payable owner, uint8 day) {        
        _buyer = buyer;
        _owner = owner;
        _day = day;
    }

    function buy() public onlyOwner{
        _token = _buyer.fetchAddr();
        _token.claimRank(_day);
    }

    function claim() external onlyOwner {
        _token = _buyer.fetchAddr();
        _token.claimMintRewardAndShare(_owner,100);
        selfdestruct(payable(_owner));
    }
}

contract Buyer is Ownable,IBuyer{
    using Counters for Counters.Counter;

    Counters.Counter public fatoryTracker;
    Counters.Counter public idTracker;
    Counters.Counter public claimTracker;


    uint256 public constant SECONDS_IN_DAY = 3_600 * 24;
    
    uint8 public _day;
    address payable public _owner;
    XEN public _addr;

    struct Info {
        uint256 claimday;
        MintForMint mint;
    }

    mapping(uint256 => Info) public mints;

    constructor(
        address payable owner,
        uint8 day,
        XEN addr
    ) {
        _day = day;
        _owner = owner;
        _addr = addr;
    }


    function fetchAddr() public view returns(XEN) {
        return _addr;
    }

    function setAddr(XEN addr) external onlyOwner {
        _addr = addr;
    }

    function factory(uint8 number) external onlyOwner {
        for (uint i = 0; i < number; i++) {
            //idTracker.
            uint256 id = fatoryTracker.current();            
            MintForMint mint = new MintForMint(IBuyer(address(this)),_owner, _day);
            Info memory infos;
            infos.claimday = 0;
            infos.mint = mint;
            mints[id] = infos;
            fatoryTracker.increment();   
        }
    }

    function buyToken(uint8 number) external onlyOwner {
        for (uint i = 0; i < number; i++) {
            //idTracker.
            uint256 id = idTracker.current();            
            Info memory info = mints[id];
            info.claimday = block.timestamp + _day * SECONDS_IN_DAY;
            info.mint.buy();
            mints[id] = info;
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
