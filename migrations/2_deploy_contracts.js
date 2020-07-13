const VotingToken = artifacts.require('./build/dist/VotingToken.sol');

module.exports = function(deployer) {
	deployer.deploy(VotingToken);
};
