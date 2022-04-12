// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "./Pool.sol";

contract BettingContract {
    address public owner;
    uint public team1 = 1;
    uint public team2 = 2;
    uint public totalBetsTeam1;
    uint public totalBetsTeam2;
    uint public duration;
    bool bettingStart = false;
    address[] public players;
    struct Player {
        uint amount;
        uint teamSelected;     
    }

    mapping(address => Player) public playerInfo;
    constructor() {
        owner = payable(msg.sender);
    }
    modifier notOwner(){
        require(msg.sender != owner,"Owner can not bet");
        _;
    }

    modifier OnlyOwner(){
        require(msg.sender == owner,"Only Owner can access");
        _;
    }
    
    function isPlayerExist(address player) public view returns (bool) {
        for(uint256 i = 0; i<players.length; i++) {
            if(players[i] == player) return true;
        }
        return false;
    }

    function startBetting(uint _duration) public OnlyOwner {
        bettingStart = true;
        duration = block.timestamp + _duration;
    } 

    function bet(uint _teamSelected) payable public notOwner   {
        require(block.timestamp <= duration,"Betting is over");
        require(bettingStart==true,"Bet Over");
        require(!isPlayerExist(msg.sender), "You have already bet");
        require(msg.value >= 1 ether, "Bet amount should be greater then or equal to 1 ether");
        playerInfo[msg.sender].amount = msg.value;
        playerInfo[msg.sender].teamSelected = _teamSelected;
        players.push(msg.sender);
    
        if(_teamSelected == 1) {    
            totalBetsTeam1 += msg.value;
        } else {
            totalBetsTeam2 += msg.value;
        }
    }

    
    function distributeWinnerAmount(uint teamWinner, address poolCAddress) public OnlyOwner {
        require(bettingStart != false, "Betting Should not be over");
        bettingStart = false;
        address[500]  memory winners;
        uint256 count = 0; 
        uint256 loserTeam = 0; 
        uint256 winnerTeam = 0;
        
        for(uint i = 0; i < players.length; i++){
            address playerAddress = players[i];
            if(playerInfo[playerAddress].teamSelected == teamWinner){
                winners[count] = playerAddress;
                count++;
            }
        }
      
        if ( teamWinner == 1){
            loserTeam = totalBetsTeam2;
            winnerTeam = totalBetsTeam1;
        } else {
            loserTeam = totalBetsTeam1;
            winnerTeam = totalBetsTeam2;
        }

        uint stakeAmount = (loserTeam * 20)/100;
        loserTeam -= stakeAmount;
        payable(poolCAddress).transfer(stakeAmount);
        PoolContract Pool = new PoolContract();
        Pool.distributeEarning(stakeAmount);
        
        for(uint j = 0; j < count; j++){
                address addressOfWinner = winners[j];
                uint256 betAmount = playerInfo[addressOfWinner].amount;
                payable(winners[j]).transfer(betAmount+(loserTeam/winnerTeam));
                delete playerInfo[addressOfWinner];
                delete players[j];
        }
        
        loserTeam = 0;
        winnerTeam = 0;
        totalBetsTeam1 = 0;
        totalBetsTeam2 = 0;  

    }
}