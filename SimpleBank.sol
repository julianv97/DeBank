/*
Simple Bank
Create a simple Bank contract which:

holds balances of users
holds the owner of the contract
function deposit – user deposits ether to the bank
    method must be payable
    use require to validate corner cases (e.g. overflow)
    return the balance of the user
function withdraw(amount) – user withdraws ether from the bank
    use require to validate corner cases
    use msg.sender.transfer
    return the new balance of the user
function getBalance – returns the caller's balance
Use modifiers where it is appropriate. Add appropriate events for the functions.
*/

/*
TODOlist
    
    -Pensar en el modo de que lo depositado genere intereses,
    una manera que se me ocurre es que el banco cree un Token ERC20 y deposite en las cuentas segun lo stakeado.
    
    Completado:
        -Si es el primer depósito del cliente, le regalamos un NFT.
*/

pragma solidity ^0.6.6;

import "github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v3.4/contracts/token/ERC721/ERC721.sol";



 contract NFTGift is ERC721 {
    uint public tokenCounter;
    
    constructor() public ERC721 ("FelipeCoin", "FLC") {
        tokenCounter = 0;
    }
    //devuelve el id del NFT
    function createNFT(string memory tokenURI, address _sender) public  returns(uint256) {
        uint newNFTId = tokenCounter;
        _safeMint(_sender, newNFTId);
        _setTokenURI(newNFTId, tokenURI);
        tokenCounter += 1;
        return newNFTId;
    }   
}


contract SimpleBank {
    mapping(address => bool) clients;
    mapping(address => uint) usersBalances;
    address public owner;
    address public _giftContract;
    event VaultDeposit(address accountHolder, uint deposit, uint newBalance);
    event VaultWithdrawal(address accountHolder, uint withdrawal, uint newBalance);
    
    constructor(address giftContract) public payable {
        owner = msg.sender;
        _giftContract = giftContract;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner,'only bank owner');
        _;
    }
    
    function deposit() public payable {
        require(msg.value > 0 ether, 'you cant deposit 0 ether');
        gift(msg.sender);
        clients[msg.sender] = true;
        usersBalances[msg.sender] += msg.value;
        
        emit VaultDeposit(msg.sender, msg.value, usersBalances[msg.sender]);
        
    }
    
    function gift(address _addr)  public {
        if(clients[_addr] == false) {
           NFTGift _gift = NFTGift(_giftContract);
            _gift.createNFT("FelipeCoin", tx.origin);  
        }
    }
    
    function withdraw(uint amount) public returns(bool) {
        require(amount > 0 ether, 'you cant deposit 0 ether');
        require(usersBalances[msg.sender] >= amount, 'insufficients funds');
        require(clients[msg.sender] == true, 'you are not a client');
        usersBalances[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
        return true;
    }
    
    function getBalance() public view returns(uint) {
        return usersBalances[msg.sender];
    }
    
    function bankBalance() public view onlyOwner returns(uint) {
        return address(this).balance;
    }
    
    function isClient(address _addr) public view onlyOwner returns(bool) {
        return clients[_addr];
    }
}