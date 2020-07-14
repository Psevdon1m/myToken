const HDWalletProvider = require('truffle-hdwallet-provider');
const Web3 = require('web3');
const fs = require('fs');

const compiledContract = fs.readFileSync('./build/contracts/Migrations.json', { encoding: 'utf8' });

const infraUrl = 'https://ropsten.infura.io/v3/0dc8a11d025249599e51017be0d573fb';

const provider = new HDWalletProvider(
	'uncover solar stock pilot census toilet grid elbow lounge repair hub shy',
	infraUrl
);
const abi = [
	{
		inputs: [],
		name: 'last_completed_migration',
		outputs: [
			{
				internalType: 'uint256',
				name: '',
				type: 'uint256'
			}
		],
		stateMutability: 'view',
		type: 'function',
		constant: true
	},
	{
		inputs: [],
		name: 'owner',
		outputs: [
			{
				internalType: 'address',
				name: '',
				type: 'address'
			}
		],
		stateMutability: 'view',
		type: 'function',
		constant: true
	},
	{
		inputs: [],
		name: 'Migration',
		outputs: [],
		stateMutability: 'nonpayable',
		type: 'function'
	},
	{
		inputs: [
			{
				internalType: 'uint256',
				name: 'completed',
				type: 'uint256'
			}
		],
		name: 'setCompleted',
		outputs: [],
		stateMutability: 'nonpayable',
		type: 'function'
	}
];
const web3 = new Web3(provider);
const bytecode = JSON.parse(compiledContract).bytecode;

const deploy = async () => {
	const accounts = await web3.eth.getAccounts();
	console.log('Attempting to deploy from account', accounts[0]);
	const result = await new web3.eth.Contract(abi)
		.deploy({ data: web3.utils.utf8ToHex(bytecode) })
		.send({ from: accounts[0], gas: '8000000' });
	l;

	console.log('Contract deployed to', result.options.address);
};
deploy();
