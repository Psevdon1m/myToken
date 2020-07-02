pragma solidity ^0.6.0;

contract Voting {
    
    struct Voter {
        
        bool voted;  // if true, that person already voted
        address voterAddress; // address of a person who voted
        uint vote;   // index of the voted proposal
        
    }
    
    uint8 positive;
    uint8 negative;
    uint256 votingPeriod;
    address newOwner;
    
    mapping(address => Voter) public voters;
    
    constructor(address _newOwner) public {
        newOwner = _newOwner;
        positive = 0;
        negative = 0;
        votingPeriod = now + 24 hours;
        for(uint256 i = 0; i < owners.length; i++){
            // voters[owners[i]].voted = false;
            voters[owners[i]].voterAddress = owners[i];
            voters[owners[i]].vote = 1;
        }
    }
    
    function vote(bool _choise) public onlyOwners {
        require(voters[msg.sender].vote = 1, 'You can vote only once');
        // require(msg.sender == voters.voterAddress, 'You are not allowed to vote' )
        require(voters[msg.sender].voted != true, 'You already voted')
        if(_choise){
            positive++
        }else {
            negative++;
        }
    }
    
    function endOfVote() public onlyOwners {
        require(now> votingPeriod, "Voting is not over");
        require(positive>negative, 'The address wasn\'t accepted) 
        owners.push(newOwner);
        }
    
    
}