// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

contract PoolContract{

    // Investors list 
    address[] public investors;
    mapping(address => uint) public investor;
    uint public totalInvestment;
    // Owner of the pool contract
    address public poolContractOwner;

    constructor() {
        poolContractOwner = payable(msg.sender);
    }

    modifier onlyOwner(){
        require(msg.sender == poolContractOwner,"Only Owner can access");
        _;
    }
    
    function addInvestor(address _address, uint _investmentAmount ) public {
        investor[_address] = _investmentAmount;
        totalInvestment += _investmentAmount;
        investors.push(_address);
    }

    function distributeEarning(uint _stackAmount) virtual public onlyOwner{
        uint totalInvestors = investors.length;
        require(totalInvestors<1, "No investors found");
                
        for(uint i=0; i<totalInvestors; i++){
            uint shareOfInvestors = (investor[investors[i]] * 100)/totalInvestment;
            uint perInvestorStack = (_stackAmount * shareOfInvestors)/100;
            payable(investors[i]).transfer(perInvestorStack);
        }
    }

}

