pragma solidity ^0.4.24;

contract Bank
{
    uint public start_time; 
    uint public end_time;                         
    string public ipfshash;
    address public owner;

    uint private Bank_balance;
    uint private account_number;
    uint private transaction_id;
    enum acct{loan,current,savings,credit,admin}        //type of account

    uint public current_interest = 3;
    uint public savings_interest = 6;
    uint public loan_interest = 10;
    uint public current_wtime = 1;
    uint public savings_wtime = 10;
    
    uint public min_current_bal = 0.05 ether;
    uint public min_savings_bal = 0.1 ether;
    uint public min_savings_trans = 0.1 ether;
    uint public min_current_trans = 0.05 ether;
 
    mapping(address=>uint) private accounts;            //address to account number mapping
    mapping(uint=>acct)private accts;                   //account number to account type mapping
    mapping(uint=>uint)private balance;                 //account number to balance mapping
    mapping(uint=>uint)private total_transac;           //account number to total no of transactionns
    mapping(uint=>uint)private transaction;             //transaction id to account number 
    mapping(uint=>uint)private amount;                  //transaction id to ammount
    mapping(uint=>uint)private ttime;                   //transaction id to time                        (time of the transaction)
    mapping(uint=>uint)private ttype;                   //transaction id to transaction type            (0 for deposit 1 for withdrawal)
    mapping(uint=>uint)private wtime;                   //account number to time                        (withdraw time left)
    mapping(uint=>uint)private wamount;                 //account number to amount                      (withdrawal allowed)
    mapping(uint=>uint)private wallow;                  //account number to allowed                     (0 for not allowed 1 for allowed)
    mapping(uint=>uint)private atime;                   //account number to time                        (account timestamp)

    constructor() public payable
    {
        Bank_balance=msg.value;
        owner=msg.sender;
        accounts[msg.sender]= account_number;
        accts[account_number]=acct.admin;
        balance[account_number]=Bank_balance;
        transaction[transaction_id ]=account_number;
        amount[transaction_id]=msg.value;
        ttime[transaction_id]=now-start_time;
        total_transac[account_number]++;

        account_number++;
        transaction_id++;
        ipfshash="";
        Bank_balance=msg. value;
        start_time=now;
    }
    modifier condition_notowner(){require (msg.sender!=owner); _;}
    modifier condition_onlyowner(){require (msg.sender==owner); _;}
    modifier condition_loan(){require(accts[accounts[msg.sender]]==acct.loan); _;}
    modifier condition_current(){require(accts[accounts[msg.sender]]==acct.current); _;}
    modifier condition_savings(){require(accts[accounts[msg.sender]]==acct.savings); _;}
    modifier condition_credit(){require(accts[accounts[msg.sender]]==acct.credit); _;}
    modifier condition_start(){require(now>=start_time); _;}
    modifier condition_end(){require(now>=end_time); _;}
   
    function create_account(acct actp) public payable condition_notowner
    {
        if(actp==acct.savings && msg.value>=min_savings_bal)
        {
            accounts[msg.sender]= account_number;
            accts[account_number]=actp;

            balance[account_number]+=msg.value;
            transaction[transaction_id]=account_number;
            amount[transaction_id]=msg.value;
            ttime[transaction_id]=now-start_time;
            total_transac[account_number]++;
            ttype[transaction_id]=0;

            if(wtime[account_number]==0)
            {
                atime[account_number]=now-start_time;
            }
            wtime[account_number]+=(now-start_time)-atime[account_number];
            
            account_number++;
            transaction_id++;
        }
        if(actp==acct.current && msg.value>=min_current_bal)
        {
            accounts[msg.sender]= account_number;
            accts[account_number]=actp;

            balance[account_number]+=msg.value;
            transaction[transaction_id]=account_number;
            amount[transaction_id]=msg.value;
            ttime[transaction_id]=now-start_time;
            total_transac[account_number]++;
            ttype[transaction_id]=0;

            if(wtime[account_number]==0)
            {
                atime[account_number]=now-start_time;
            }
            wtime[account_number]+=(now-start_time)-atime[account_number];
            
            account_number++;
            transaction_id++;
        }
    }
       
    function check_account_type(uint act)public view condition_notowner returns(acct){return accts[act];}
    function view_balance(uint act) public view condition_notowner returns(uint){return balance[act];}
    function view_bank_balance()public view condition_onlyowner returns(uint){return Bank_balance;}

    function savings_account(uint act) public payable condition_notowner condition_start condition_savings returns(bool)
    {
        if(accts[act]==acct.savings)
        {
            if(msg.value>=min_savings_trans)
            {
                balance[act]+=msg.value;
                Bank_balance+=msg.value;

                transaction[transaction_id]=act;
                amount[transaction_id]=msg.value;
                ttime[transaction_id]=now-start_time;
                total_transac[act]++;
                ttype[transaction_id]=0;

                wtime[act]+=(now-start_time)-atime[act];
                if(wallow[act]==0)
                {
                    if((wtime[act]/86400)>savings_wtime )
                    {
                        wamount[act]+=balance[act];
                        wallow[act]=1;
                        wtime[act]=0;
                        atime[act] =now-start_time;
                    }                
                }
                else
                {
                    wamount[act]+=balance[act];
                }
                transaction_id++;
                return true;
            }
        }
        return false;  
    }
    function current_account(uint act)public payable condition_notowner condition_start condition_current returns(bool)
    {
        if(accts[act]==acct.current)
        {
            if(msg.value>=min_current_trans)
            {
                balance[act]+=msg.value;
                Bank_balance+=msg.value;

                transaction[transaction_id]=act;
                amount[transaction_id]=msg.value;
                ttime[transaction_id]=now-start_time;
                total_transac[act]++;
                ttype[transaction_id]=0;
                
                wtime[act]+=(now-start_time)-atime[act];
                if(wallow[act]==0)
                {
                    if((wtime[act]/86400)>savings_wtime )
                    {
                        wamount[act]+=balance[act];
                        wallow[act]=1;
                        wtime[act]=0;
                        atime[act] =now-start_time;
                    }                
                }
                else
                {
                    wamount[act]+=balance[act];
                }                           

                transaction_id++;
                return true;
            }
        }
        return false; 
    }
    function check_wtime(uint act)public condition_notowner condition_start returns(uint)
    {
        if(accounts[msg.sender]==act)
        {
            wtime[act]+=(now-start_time)-atime[act];
            if((wtime[act]/86400)>savings_wtime)
            {
                wamount[act]+=balance[act];
                wallow[act]=1;
                wtime[act]=0;
                atime[act] =now-start_time;
            }  
            return 10-(wtime[act]/86400);         

        }
    }
    function withdraw(uint act,uint amt)public condition_notowner condition_start  returns(uint)
    {
        if(accounts[msg.sender]==act)
        {
            if(accts[act]==acct.savings)
            {
                if(balance[act]-amt>min_savings_bal)
                {
                    wtime[act]+=(now-start_time)-atime[act];
                    if((wtime[act]/86400)>savings_wtime||wallow[act]==1)
                    {
                        Bank_balance-=amt;
                        balance[act]-=amt;

                        transaction[transaction_id]=act;
                        amount[transaction_id]=amt;
                        ttime[transaction_id]=now-start_time;
                        total_transac[act]++;
                        ttype[transaction_id]=1;                    
                    
                        wamount[act]+=balance[act];
                        wallow[act]=0;
                        wtime[act]=0;
                        atime[act] =now-start_time;
                        transaction_id++;
                        return amt;
                    }
                    else
                    {
                        return 0;
                    }
                    
                }
                else if(balance[act]-amt>0)
                {
                    uint _amt = balance[act]-amt;
                    wtime[act]+=(now-start_time)-atime[act];
                    if((wtime[act]/86400)>savings_wtime)
                    {
                        Bank_balance-=_amt;
                        balance[act]-=_amt;

                        transaction[transaction_id]=act;
                        amount[transaction_id]=_amt;
                        ttime[transaction_id]=now-start_time;
                        total_transac[act]++;
                        ttype[transaction_id]=1;                    
                    
                        wamount[act]+=balance[act];
                        wallow[act]=1;
                        wtime[act]=0;
                        atime[act] =now-start_time;
                        transaction_id++;
                        return amt;
                    }
                    else
                    {
                        return 0;
                    }
                    
                    

                    transaction[transaction_id]=act;
                    amount[transaction_id]=_amt;
                    ttime[transaction_id]=now-start_time;
                    total_transac[act]++;
                    ttype[transaction_id]=1;

                    transaction_id++;
                    return _amt;
                }
                else
                {
                    return 0;
                }
            }
            if(accts[act]==acct.current)
            {
                if(balance[act]-amt>min_savings_bal)
                {
                    Bank_balance-=amt;
                    balance[act]-=amt;

                    transaction[transaction_id]=act;
                    amount[transaction_id]=amt;
                    ttime[transaction_id]=now-start_time;
                    total_transac[act]++;
                    ttype[transaction_id]=1;

                    transaction_id++;
                    return amt;
                }
                else if(balance[act]-amt>0)
                {
                    _amt = balance[act]-amt;
                    Bank_balance-=_amt;
                    balance[act]-=_amt;

                    transaction[transaction_id]=act;
                    amount[transaction_id]=_amt;
                    ttime[transaction_id]=now-start_time;
                    total_transac[act]++;
                    ttype[transaction_id]=1;

                    transaction_id++;
                    return _amt;
                }
                else
                {
                    return 0;
                }
            }
        }
        return 0;
    }

}


contract ERC20
{
    function total_supply()public view returns(uint);
    function balance(address token_owner) public view returns(uint bal);
    function transf(address to, uint tokens) public returns (bool success);
    
    function allowance(address token_owner ,address spender) public view returns (uint remaining);
    function approve(address spender,uint tokens) public returns(bool success);
    function transfer_from(address from,address to,uint tokens) public returns (bool success);
    
    event Tf(address indexed from,address indexed to, uint tokens);
    event Apr(address indexed token_owner,address indexed spender,uint tokens);
}

contract SPD is ERC20
{
    string public name="SPD";
    string public symbol="SPD";
    
    uint public decimals=0;
    uint public supply;
    address public owner;
    
    mapping(address=>uint) public bals;
    mapping(address=>mapping(address=>uint)) allowed;
    
    event Tf(address indexed from,address indexed to, uint tokens);
    event Apr(address indexed token_owner,address indexed spender,uint tokens);
    
    constructor() public
    {
        supply=1000;
        owner=msg.sender;
        bals[owner]=supply;
    }
    function total_supply()public view returns(uint)
    {
        return supply;
    }
    function balance(address token_owner) public view returns(uint bal)
    {
        return bals[token_owner];
    }
    function transf(address to, uint tokens) public returns (bool success)
    {
        require(bals[msg.sender]>=tokens && tokens>0);
        bals[to]+=tokens;
        bals[msg.sender]-=tokens;
        emit Tf(msg.sender,to,tokens); 
        return true;
    }
    function allowance(address token_owner ,address spender) public view returns (uint )
    {
        return allowed[token_owner][spender];
    }
    function approve(address spender,uint tokens) public returns(bool)
    {
        require(bals[msg.sender]>tokens);
        require(tokens>0);
        allowed[msg.sender][spender]=tokens;
        emit Apr(msg.sender,spender, tokens);
        return true;
    }
    function transfer_from(address from,address to,uint tokens) public returns (bool )
    {
        require(allowed[from][to] >=tokens);
        require(bals[from]>=tokens);
        
        bals[from]-=tokens;
        bals[to]+=tokens;
        allowed[from][to]-=tokens;
        return true;
    }
    
}

contract SPD_ico is SPD
{
    address public admin;
    address public deposit;
    
    uint public token_price =0.1 ether;
    uint public hard_cap =100;
    uint public raised_amt;
    
    uint public sales_start =now;
    uint public sales_end =now+ 1000;
    uint public trade_start =sales_end+100;
    
    uint min_investment =0.1 ether;
    uint max_investment =10 ether;
    
    enum state{start,running,end,halt}
    state public status =state.start;
    
    event Inv(address investor,uint value,uint tokens);
    
    modifier adm
    {
        require(msg.sender==admin);
        _;
    }
    
    constructor(address _deposit) public
    {
        deposit=_deposit;
        admin=msg.sender;
        status=state.start;
    }
    function halt_ico()public adm
    {
        status =state.end;
    }
    function continue_ico()public adm
    {
        status =state.running;
    }
    function current_state()public view returns(state)
    {
        if(status==state.halt)
        {
            return state.halt;
        }
        else if(now<sales_start)
        {
            return state.start;
        }
        else if(now>=sales_start&&now<sales_end)
        {
            return state.running;
        }
        else
        {
            return state.end;
        }
    }
    function new_deposit(address _depo)public adm
    {
        deposit=_depo;
    }
    function invest()payable public returns(bool)
    {
        status=current_state();
        require(status==state.running);
        require(msg.value>=min_investment&&msg.value<=max_investment);
        uint tokens=msg.value/token_price;
        require(raised_amt+msg.value<=hard_cap);
        raised_amt+=msg.value;
        
        bals[msg.sender]+=tokens;
        bals[owner]-=tokens;
        deposit.transfer(msg.value);
        
        emit Inv(msg.sender,msg.value,tokens);
        return true;

    }
    function ()payable public
    {
        invest();
    }
    function transf(address to,uint value)public returns(bool)
    {
        require(now>trade_start);
        super.transf(to,value);
    }
    function transfer_from(address _from,address _to,uint _value) public returns(bool)
    {
        require(now>trade_start);
        super.transfer_from(_from,_to,_value);
    }
    function burn_tokens()public adm returns(bool)
    {
        require(status==state.end);
        bals[owner]=0;
        
        
    }
}

