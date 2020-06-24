const myToken = artifacts.require('./myToken.sol');

contract('myToken', function(accounts) {
	it('sets the total  supply upon deployment', function() {
		return myToken
			.deployed()
			.then(function(instance) {
				tokenInstance = instance;
				return tokenInstance.totalSuply();
			})
			.then(function(totalSupply) {
				assert.equal(totalSupply.toNumber(), 1000000, 'sets the total supply to 1,000,000');
			});
	});
});