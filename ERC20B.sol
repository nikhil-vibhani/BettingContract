// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";

contract ERC20B is ERC20{
    address public admin;
    constructor() ERC20("ERC20B","ECB"){
        admin = msg.sender;
        _mint(msg.sender, 10000*10**18);

    }

    function mint(address to, uint amount) external{
        require(msg.sender == admin, "Only admin");
        _mint(to, amount);
    }
    
    function burn(uint amount) external{
        _burn(msg.sender,amount);
    }
}