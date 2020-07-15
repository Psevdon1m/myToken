const HDWalletProvider = require('truffle-hdwallet-provider');
const Web3 = require('web3');
const fs = require('fs');

const compiledContract = fs.readFileSync('./build/contracts/Migrations.json', { encoding: 'utf8' });

const infraUrl = 'https://ropsten.infura.io/v3/0dc8a11d025249599e51017be0d573fb';

const provider = new HDWalletProvider(
	'uncover solar stock pilot census toilet grid elbow lounge repair hub shy',
	infraUrl
);

const web3 = new Web3(provider);

const deploy = async () => {
	const accounts = await web3.eth.getAccounts();
	console.log('Attempting to deploy from account', accounts[0]);
	const result = await new web3.eth.Contract(JSON.parse(compiledContract).abi)
		.deploy({ data: JSON.parse(compiledContract).bytecode })
		.send({ from: accounts[0], gas: '3000000' });

	console.log('Contract deployed to', result.options.address);
};
deploy();
