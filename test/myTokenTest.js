const myToken = artifacts.require('./myToken.sol');
const accounts = web3.eth.getAccounts();

contract('myToken', function(accounts) {
	let tokenInstance;

	it('initializes the contract with correct values', function() {
		return myToken
			.deployed()
			.then(function(instance) {
				tokenInstance = instance;
				return tokenInstance.name();
			})
			.then(function(name) {
				assert.equal(name, 'ValToken', 'has the correct name');
				return tokenInstance.symbol();
			})
			.then(function(symbol) {
				assert.equal(symbol, 'VLT', 'has the correct symbol');
				return tokenInstance.standart();
			});
	});

	it('sets the total  supply upon deployment', function() {
		return myToken
			.deployed()
			.then(function(instance) {
				tokenInstance = instance;
				return tokenInstance.totalSupply();
			})
			.then(function(totalSupply) {
				assert.equal(totalSupply.toNumber(), 1000000, 'sets the total supply to 1,000,000');
				return tokenInstance.balanceOf(accounts[0]);
			})
			.then(function(adminBalance) {
				assert.equal(adminBalance.toNumber(), 1000000, 'it allocates initial supply to admin account');
			});
	});
});

// it('transfers token ownership', function() {
//     return DappToken.deployed().then(function(instance) {
//       tokenInstance = instance;
//       // Test `require` statement first by transferring something larger than the sender's balance
//       return tokenInstance.transfer.call(accounts[1], 99999999999999999999999);
//     }).then(assert.fail).catch(function(error) {
//       assert(error.message.indexOf('revert') >= 0, 'error message must contain revert');
//       return tokenInstance.transfer.call(accounts[1], 250000, { from: accounts[0] });
//     })

it('transfers token ownership', function() {
	return myToken
		.deployed()
		.then(function(instance) {
			tokenInstance = instance;
			//checking whether require statement works
			console.log(accounts[1]);

			return tokenInstance.transfer.call(accounts[1], 99999999999999999999999);
		})
		.then(assert.fail)
		.catch(function(error) {
			assert(error.message.indexOf('revert') >= 0, 'error message must contain revert');
			return tokenInstance.transfer.call(accounts[1], 250000, { from: accounts[0] });
		})
		.then(function(success) {
			assert.equal(success, true, 'it returns true');
			return tokenInstance.transfer(accounts[1], 250000, { from: accounts[0] });
		})
		.then(function(receipt) {
			assert.equal(receipt.logs.length, 1, 'triggers one event');
			assert.equal(receipt.logs[0].event, 'Transfer', 'should be the "Transfer" event');
			assert.equal(receipt.logs[0].args._from, accounts[0], 'logs the account the tokens are transfered from');
			assert.equal(receipt.logs[0].args._to, accounts[1], 'logs the account the tokens are transferred to');
			assert.equal(receipt.logs[0].args._value, 250000, 'logs the transfer amount');
			return tokenInstance.balanceOf(accounts[1]);
		})
		.then(function(balance) {
			assert.equal(balance.toNumber(), 250000, 'adds the amount to the receiving account');
			return tokenInstance.balanceOf(account[0]);
		})
		.then(function(balance) {
			assert.equal(balance.toNumber(), 750000, 'deducts the amount from sender account');
		});
});
