const VotingToken = artifacts.require('VotingToken');
const IterableMapping = artifacts.require('IterableMapping');
const address = '0xbC4b9C3a094C517114d973C633450ab0276E6e35';

module.exports = function(deployer) {
	deployer.deploy(IterableMapping);
	deployer.link(IterableMapping, VotingToken);
	deployer.deploy(VotingToken);
};
