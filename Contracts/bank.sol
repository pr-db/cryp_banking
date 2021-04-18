pragma solidity ^0.4.24;

contract Bank
{
    address public owner;
    uint public sB;                           //start blockhash
    uint public eB;                           //end blockhash
    string public ipfshash;
    uint private Bank_balance;
    uint private account_number;
    enum acct{loan,current,savings,credit}      //type of account
    acct public account_type;
    
    
    mapping(address=>uint) private accounts;    //address to account number mapping
    mapping(uint=>acct)private accts;           //account number to account type mapping
    mapping(uint=>uint)private balance;         //account number to balance mapping
    
    constructor() public payable
    {
        Bank_balance=msg.value;
        owner=msg.sender;
        accounts[msg.sender]= account_number;
        account_number++;
        ipfshash="";
        Bank_balance=msg. value;
    }
    modifier condition_notowner(){
        require (msg.sender!=owner);
        _;
    }
    modifier condition_onlyowner(){
        require (msg.sender==owner);
        _;
    }
    modifier condition_loan(){
        require(account_type==acct.loan);
        _;
    }
    modifier condition_current(){
        require(account_type==acct.current);
        _;
    }
    modifier condition_savings(){
        require(account_type==acct.savings);
        _;
    }
    modifier condition_credit(){
        require(account_type==acct.credit);
        _;
    }
    modifier condition_s(){                                                                //start condition
        require(block.number>=sB);
        _;
    }
    modifier condition_e(){                                                                //end condition
        require(block.number<=eB);
        _;
    }
   
    function create_account(acct _account_type) public payable condition_notowner
    {
        if(msg.value>=0.001 ether)
        {
            accounts[msg.sender]= account_number;
            accts[account_number]=_account_type;
            account_number++;
        }
    }
    //act is local variable for account number
    //acct is enum with accounnt types loan,current,savings,credit
    //accts is mapping for account number to account type
    //accounts is mapping for address to account number
    
    function check_account_type(uint act)public view condition_notowner returns(acct)
    {
        return accts[act];
    }
    function view_balance(uint act) public view condition_notowner returns(uint)
    {
        return balance[act];
    }
    function view_bank_balance()public view condition_onlyowner returns(uint)
    {
        return Bank_balance;
    }

    function savings_account(uint act) public payable condition_notowner condition_s condition_e  returns(bool)
    {
        if(accts[act]==acct.savings)
        {
            if(msg.value>=0.1 ether)
            {
                balance(act)+=msg.value;
                Bank_balance+=msg.value;
                return true;
            }
        }
        return false;  
    }
    function current_account(uint act)public payable condition_notowner condition_s condition_e returns(bool)
    {
        if(accts[act]==acct.current)
        {
            if(msg.value>=0.01 ether)
            {
                balance(act)+=msg.value;
                Bank_balance+=msg.value;
                return true;
            }
        }
        return false; 
    }
    function withdraw(uint act,uint amount)public condition_notowner condition_s condition_e returns(bool)
    {
        if(accts[act]==acct.savings)
        {

        if(accts[act]==acct.current)
        {
    }

}

