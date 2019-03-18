const HDWalletProvider = require('truffle-hdwallet-provider');
const Web3 = require('web3');
const compiledContract = require('./build/ProjectFactory.json');

const provider = new HDWalletProvider(
    'pepper chief boring depend lottery dirt neither sad next stand double actual',
    'https://rinkeby.infura.io/v3/d6be1f0fbed5401aa742622f4015e431',
);

const web3 = new Web3(provider);

const deploy = async ()=>{
    const accounts = await web3.eth.getAccounts();

    console.log('Attempting to deploy from account', accounts[0]);
    
    const result = await new web3.eth.Contract(JSON.parse(compiledContract.interface))
                    .deploy({ data: '0x'+compiledContract.bytecode })
                    .send({ gas: '4000000', from: accounts[0] })


    
    console.log('contract deployed to', result.options.address);
}
deploy();