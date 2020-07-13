const Web3 = require('web3');

const ganacheUrl = 'http://127.0.0.1:7545';
const web3 = new Web3(ganacheUrl);

const contractAddress = '0xf5C2cA1a85BC43eE5096590d8F61ECD1c6b75CB7';
const abi = [
	{
		inputs: [
			{
				internalType: 'address',
				name: '_candidateAddress',
				type: 'address'
			}
		],
		name: 'addCandidate',
		outputs: [],
		stateMutability: 'nonpayable',
		type: 'function'
	},
	{
		inputs: [],
		stateMutability: 'nonpayable',
		type: 'constructor'
	},
	{
		anonymous: false,
		inputs: [
			{
				indexed: true,
				internalType: 'address',
				name: '_owner',
				type: 'address'
			},
			{
				indexed: true,
				internalType: 'address',
				name: '_spender',
				type: 'address'
			},
			{
				indexed: false,
				internalType: 'uint256',
				name: '_value',
				type: 'uint256'
			}
		],
		name: 'Approval',
		type: 'event'
	},
	{
		inputs: [
			{
				internalType: 'address',
				name: '_spender',
				type: 'address'
			},
			{
				internalType: 'uint256',
				name: '_value',
				type: 'uint256'
			}
		],
		name: 'approve',
		outputs: [
			{
				internalType: 'bool',
				name: 'success',
				type: 'bool'
			}
		],
		stateMutability: 'nonpayable',
		type: 'function'
	},
	{
		inputs: [
			{
				internalType: 'uint256',
				name: '_value',
				type: 'uint256'
			}
		],
		name: 'burn',
		outputs: [
			{
				internalType: 'bool',
				name: 'success',
				type: 'bool'
			}
		],
		stateMutability: 'nonpayable',
		type: 'function'
	},
	{
		anonymous: false,
		inputs: [
			{
				indexed: false,
				internalType: 'uint256',
				name: 'amount',
				type: 'uint256'
			}
		],
		name: 'Burned',
		type: 'event'
	},
	{
		anonymous: false,
		inputs: [
			{
				indexed: true,
				internalType: 'address',
				name: '_candidate',
				type: 'address'
			}
		],
		name: 'CandidateAdded',
		type: 'event'
	},
	{
		inputs: [
			{
				internalType: 'uint256',
				name: '_amount',
				type: 'uint256'
			}
		],
		name: 'emitAndShareTokens',
		outputs: [],
		stateMutability: 'nonpayable',
		type: 'function'
	},
	{
		inputs: [
			{
				internalType: 'address',
				name: '_candidateAddress',
				type: 'address'
			}
		],
		name: 'endVote',
		outputs: [
			{
				internalType: 'bool',
				name: 'decision',
				type: 'bool'
			}
		],
		stateMutability: 'nonpayable',
		type: 'function'
	},
	{
		anonymous: false,
		inputs: [
			{
				indexed: false,
				internalType: 'address',
				name: 'sender',
				type: 'address'
			},
			{
				indexed: false,
				internalType: 'uint256',
				name: 'value',
				type: 'uint256'
			}
		],
		name: 'Received',
		type: 'event'
	},
	{
		inputs: [
			{
				internalType: 'address',
				name: '_to',
				type: 'address'
			},
			{
				internalType: 'uint256',
				name: '_value',
				type: 'uint256'
			}
		],
		name: 'transfer',
		outputs: [
			{
				internalType: 'bool',
				name: 'success',
				type: 'bool'
			}
		],
		stateMutability: 'payable',
		type: 'function'
	},
	{
		anonymous: false,
		inputs: [
			{
				indexed: true,
				internalType: 'address',
				name: '_from',
				type: 'address'
			},
			{
				indexed: true,
				internalType: 'address',
				name: '_to',
				type: 'address'
			},
			{
				indexed: false,
				internalType: 'uint256',
				name: '_value',
				type: 'uint256'
			}
		],
		name: 'Transfer',
		type: 'event'
	},
	{
		inputs: [
			{
				internalType: 'address',
				name: '_from',
				type: 'address'
			},
			{
				internalType: 'address',
				name: '_to',
				type: 'address'
			},
			{
				internalType: 'uint256',
				name: '_value',
				type: 'uint256'
			}
		],
		name: 'transferFrom',
		outputs: [
			{
				internalType: 'bool',
				name: '',
				type: 'bool'
			}
		],
		stateMutability: 'nonpayable',
		type: 'function'
	},
	{
		inputs: [
			{
				internalType: 'address',
				name: '_candidateAddress',
				type: 'address'
			},
			{
				internalType: 'bool',
				name: '_choice',
				type: 'bool'
			}
		],
		name: 'vote',
		outputs: [],
		stateMutability: 'nonpayable',
		type: 'function'
	},
	{
		anonymous: false,
		inputs: [
			{
				indexed: true,
				internalType: 'address',
				name: '_candidate',
				type: 'address'
			},
			{
				indexed: false,
				internalType: 'uint256',
				name: '_numberOfVotes',
				type: 'uint256'
			}
		],
		name: 'VoteHappened',
		type: 'event'
	},
	{
		inputs: [],
		name: 'withdrawReward',
		outputs: [],
		stateMutability: 'nonpayable',
		type: 'function'
	},
	{
		stateMutability: 'payable',
		type: 'receive'
	},
	{
		inputs: [
			{
				internalType: 'address',
				name: '',
				type: 'address'
			},
			{
				internalType: 'address',
				name: '',
				type: 'address'
			}
		],
		name: 'allowance',
		outputs: [
			{
				internalType: 'uint256',
				name: '',
				type: 'uint256'
			}
		],
		stateMutability: 'view',
		type: 'function'
	},
	{
		inputs: [
			{
				internalType: 'address',
				name: '',
				type: 'address'
			}
		],
		name: 'balanceOf',
		outputs: [
			{
				internalType: 'uint256',
				name: '',
				type: 'uint256'
			}
		],
		stateMutability: 'view',
		type: 'function'
	},
	{
		inputs: [],
		name: 'burnStartTime',
		outputs: [
			{
				internalType: 'uint256',
				name: '',
				type: 'uint256'
			}
		],
		stateMutability: 'view',
		type: 'function'
	},
	{
		inputs: [],
		name: 'decimals',
		outputs: [
			{
				internalType: 'uint8',
				name: '',
				type: 'uint8'
			}
		],
		stateMutability: 'view',
		type: 'function'
	},
	{
		inputs: [
			{
				internalType: 'address',
				name: '',
				type: 'address'
			}
		],
		name: 'eligibleOwners',
		outputs: [
			{
				internalType: 'bool',
				name: '',
				type: 'bool'
			}
		],
		stateMutability: 'view',
		type: 'function'
	},
	{
		inputs: [],
		name: 'feePerTransaction',
		outputs: [
			{
				internalType: 'uint256',
				name: '',
				type: 'uint256'
			}
		],
		stateMutability: 'view',
		type: 'function'
	},
	{
		inputs: [
			{
				internalType: 'address',
				name: '_address',
				type: 'address'
			}
		],
		name: 'getEthBalance',
		outputs: [
			{
				internalType: 'uint256',
				name: '',
				type: 'uint256'
			}
		],
		stateMutability: 'view',
		type: 'function'
	},
	{
		inputs: [],
		name: 'name',
		outputs: [
			{
				internalType: 'string',
				name: '',
				type: 'string'
			}
		],
		stateMutability: 'view',
		type: 'function'
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
		type: 'function'
	},
	{
		inputs: [
			{
				internalType: 'uint256',
				name: '',
				type: 'uint256'
			}
		],
		name: 'owners',
		outputs: [
			{
				internalType: 'address',
				name: '',
				type: 'address'
			}
		],
		stateMutability: 'view',
		type: 'function'
	},
	{
		inputs: [],
		name: 'symbol',
		outputs: [
			{
				internalType: 'string',
				name: '',
				type: 'string'
			}
		],
		stateMutability: 'view',
		type: 'function'
	},
	{
		inputs: [],
		name: 'totalReward',
		outputs: [
			{
				internalType: 'uint256',
				name: '',
				type: 'uint256'
			}
		],
		stateMutability: 'view',
		type: 'function'
	},
	{
		inputs: [],
		name: 'totalTokenSupply',
		outputs: [
			{
				internalType: 'uint256',
				name: '',
				type: 'uint256'
			}
		],
		stateMutability: 'view',
		type: 'function'
	},
	{
		inputs: [],
		name: 'voteDuration',
		outputs: [
			{
				internalType: 'uint256',
				name: '',
				type: 'uint256'
			}
		],
		stateMutability: 'view',
		type: 'function'
	}
];

const contract = new web3.eth.Contract(abi, contractAddress);

const owner = '0xbC4b9C3a094C517114d973C633450ab0276E6e35';
const account1 = '0x0B5b83cAd5b898681FFc848db469e451C7Bb01db';
const account2 = '0x35d16a52d1659d3D410d791581f6d57Bf71bbE4b';

async function showTotalSupply() {
	const result = await contract.methods.totalTokenSupply().call();
	console.log(`Total supply is ${result}`);
}

async function getBalance(address) {
	const result = await contract.methods.balanceOf(address).call();
	console.log(`${address} balance is ${result}`);
}

async function sendTokens(address, amount) {
	const amountToSend = amount.toString();
	await contract.methods.transfer(address, amountToSend).send({ from: owner });
	console.log(`${amount} was successfully send from ${owner} to ${address}`);
}

showTotalSupply();

getBalance(owner);
getBalance(account1);

sendTokens(account1, 200);
