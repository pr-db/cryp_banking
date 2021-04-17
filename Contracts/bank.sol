pragma solidity ^0.4.24;

contract Bank
{
    address public owner;
    string public ipfshash;
    uint private Bank_balance;
    uint private account_number;
    enum acct{loan,current,savings,credit} //type of account
    acct public acount_type;
    
    
    mapping(address=>uint) public accounts;
    
    constructor() public payable
    {
        Bank_balance=msg.value;
        owner=msg.sender;
        accounts[msg.sender]= account_number;
        ipfshash="";
    }
}