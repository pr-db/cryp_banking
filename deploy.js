const HDWalletProvider = require('truffle-hdwallet-provider');
const Web3 = require('web3');
const {interface,bytecode} = require('./compile');
const provider = new HDWalletProvider(
    'unlock indicate roof catch rule uncle knee recall outdoor diamond input bottom',
    'https://rinkeby.infura.io/v3/6c0d508000a0466b8c00c4058443bf6d'
);
const web3 = new Web3(provider);
const deploy = async ()=>{
    const accounts = await web3.eth.getAccounts();
    console.log('attempting to deploy from',accounts[0]);
    const res = await new web3.eth.Contract(JSON.parse(interface))
        .deploy({
            data: bytecode
        })
        .send({
            gas: '1000000',
            from: accounts[0]
        });
    console.log('contract address',res.options.address);
};
deploy();