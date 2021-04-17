const path = require('path');
const fs = require('fs');
const solc =require('solc');

const BlockPath =path.resolve(__dirname,'Contracts','bank.sol');
const source = fs.readFileSync(BlockPath,'utf8');

module.exports= solc.compile(source,1).contracts[':Bank'];

