pragma solidity ^0.6.0;

import './Sharing.sol';

library IterableMapping {
    // Iterable mapping from address to uint;
    struct Map {
        address[] keys;
        mapping(address => uint) values;
        mapping(address => uint) indexOf;
        mapping(address => bool) inserted;

    }

    function get(Map storage map, address key) public view returns (uint) {
        return map.values[key];
    }

    function getKeyAtIndex(Map storage map, uint index) public view returns (address) {
        return map.keys[index];
    }

    function size(Map storage map) public view returns (uint) {
        return map.keys.length;
    }

    function set(Map storage map, address key, uint val) public {
        if (map.inserted[key]) {
            map.values[key] = val;
        } else {
            map.inserted[key] = true;
            map.values[key] = val;
            map.indexOf[key] = map.keys.length;
            map.keys.push(key);
        }
    }

    function remove(Map storage map, address key) public {
        if (!map.inserted[key]) {
            return;
        }

        delete map.inserted[key];
        delete map.values[key];

        uint index = map.indexOf[key];
        uint lastIndex = map.keys.length - 1;
        address lastKey = map.keys[lastIndex];

        map.indexOf[lastKey] = index;
        delete map.indexOf[key];

        map.keys[index] = lastKey;
        map.keys.pop();
    }
}

contract VotingToken is Sharing(1000) {
    using IterableMapping for IterableMapping.Map;

    string public name = "ValTokenBurnFull";
    string public symbol = "VLTBF";
    uint256 public feePerTransaction = 1;
    uint8 public decimals = 0;
    uint256 public voteDuration;
    //from this time on tokens may be burned +24 hours from release date
    uint256 public burnStartTime = now + 24 hours;
    uint256 public totalReward;
    uint256 restReward;
    uint256 lastDivideRewardTime = now;
    uint ownerReward;
    //a list of events to be checked on Etherscan.io
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    event Burned(uint256 amount);
    event CandidateAdded(address indexed _candidate);
    event VoteHappened(address indexed _candidate, uint256 _numberOfVotes);
    event Received(address sender, uint256 value);
    
    struct CandidateData {
        address proposal;
        mapping(address => uint8) votes;
        uint32 positive;
        bool alreadyOwner;
        bool isCandidate;
    }
    
    IterableMapping.Map private map;
    
    // mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    mapping(address => CandidateData) private candidates;
    mapping(address => bool) public eligibleOwners;
    
    //modifier grands access to owners only
    modifier onlyOwners() {
        require(eligibleOwners[msg.sender] == true, "You are not an owner");
        _;
    }
    

    constructor() public {
        owner = msg.sender;
        for (uint i = 0; i < owners.length; i++ ){
            eligibleOwners[owners[i]] = true; 
            // balanceOf[owners[i]] = tokenPerOwner;
            map.set(owners[i], 0);
        }
    }
    //Reward distribution
    function divideUpReward() private onlyOwners {
        for (uint8 i = 0; i < map.size(); i++){
            ownerReward = totalReward * balanceOf[map.getKeyAtIndex(i)] / totalTokenSupply;
            map.values[map.getKeyAtIndex(i)] += ownerReward; 
        }
        totalReward = 0;
    }

    function withdrawReward() public onlyOwners {
        require(map.values[msg.sender] > 0, 'You do not have funds to withdraw');
        msg.sender.transfer(map.values[msg.sender]);
        map.values[msg.sender] = 0;
    }

    function getEthBalance(address _address) public view returns(uint256) {
        return map.get(_address);
    }
    
    receive() external payable {
        totalReward += msg.value;
        divideUpReward();
        emit Received(msg.sender, msg.value);
    }
    //Voting functionality
    
    function addCandidate(address _candidateAddress) public onlyOwners {
        require(eligibleOwners[_candidateAddress] == false, 'You are adding a person that is already among owners');
        require(candidates[_candidateAddress].isCandidate == false, 'This person is already a candidate!');
        candidates[_candidateAddress].proposal = msg.sender;
        candidates[_candidateAddress].votes[msg.sender] = 1;
        candidates[_candidateAddress].positive = 1;
        candidates[_candidateAddress].alreadyOwner = eligibleOwners[_candidateAddress];
        candidates[_candidateAddress].isCandidate = true;
        emit CandidateAdded(_candidateAddress);
    }
    
    function vote(address _candidateAddress, bool _choice) public onlyOwners {
        require(candidates[_candidateAddress].isCandidate, 'this address is not among candidates');
        require(candidates[_candidateAddress].votes[msg.sender] == 0, 'You have already voted!');
        if(_choice){
            candidates[_candidateAddress].votes[msg.sender] = 1;
            candidates[_candidateAddress].positive++;
        }else {
            candidates[_candidateAddress].votes[msg.sender] = 2;
        }
    }
    
    function endVote(address _candidateAddress) public onlyOwners returns(bool decision) {
        // require(candidates[_candidateAddress].totalVotes == owners.length, 'Not enoght votes to end the voting');
        if(candidates[_candidateAddress].positive > owners.length / 2) {
            owners.push(_candidateAddress);
            eligibleOwners[_candidateAddress] = true;
            delete candidates[_candidateAddress];
            emit VoteHappened(_candidateAddress, candidates[_candidateAddress].positive);
            return true;

        }else {
            delete candidates[_candidateAddress];
            emit VoteHappened(_candidateAddress, candidates[_candidateAddress].positive);
            return false;
        }
        
    }
    
      //Transfer function
    function transfer(address _to, uint256 _value)
        public
        payable
        returns (bool success)
    {
        require(balanceOf[msg.sender] >= _value, 'error, balance is insufficient');
        balanceOf[msg.sender] = balanceOf[msg.sender].sub(_value);
        balanceOf[_to] = balanceOf[_to].add(_value.sub(feePerTransaction));
        balanceOf[owner] = balanceOf[owner].add(feePerTransaction);
        //transfer event
        emit Transfer(msg.sender, _to, _value);
        return true;
    }
    //allowance implementation
    function approve(address _spender, uint256 _value) public returns (bool success) {
      allowance[msg.sender][_spender] = _value;

      //will trigger the approve event
      emit Approval(msg.sender, _spender, _value);
      return true;
  }

    function transferFrom(address _from, address _to, uint256 _value) public returns(bool) {
      require(balanceOf[_from] >= _value, "insufficient balance");
      require(allowance[_from][msg.sender] >= _value, "allowance exceeded");
      balanceOf[_from] = balanceOf[_from].sub(_value);
      balanceOf[_to] = balanceOf[_to].add(_value);
      allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value);
      emit Transfer(_from, _to, _value);
      return true;
    }

    //burnign function
  function burn(uint256 _value)  public onlyOwners returns (bool success)  {
      //we restrict ourseleves to burn tokens after some perion of time.
      if (now > burnStartTime) {
          //checking that amount is less or equal to user's balance
          require(balanceOf[msg.sender] >= _value, 'balance insufficient');
          //decreasing the users balance by the amount
          balanceOf[msg.sender] = balanceOf[msg.sender].sub(_value);
            //decreasing the totalSupply by the amount
          totalTokenSupply = totalTokenSupply.sub(_value);
          emit Burned(_value);
          return true;
      }
  }
}










