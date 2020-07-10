pragma solidity ^0.6.0;

library SafeMath {
   
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

   
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

   
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

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

    // function remove(Map storage map, address payable key) public {
    //     if (!map.inserted[key]) {
    //         return;
    //     }

    //     delete map.inserted[key];
    //     delete map.values[key];

    //     uint index = map.indexOf[key];
    //     uint lastIndex = map.keys.length - 1;
    //     address lastKey = map.keys[lastIndex];

    //     map.indexOf[lastKey] = index;
    //     delete map.indexOf[key];

    //     map.keys[index] = lastKey;
    //     map.keys.pop();
    // }
}

contract MyToken {
    using SafeMath for uint256;
    using IterableMapping for IterableMapping.Map;

    string  name = "ValTokenBurnFull";
    string  symbol = "VLTBF";
    uint256 totalSupply;
    uint256  feePerTransaction = 1;
    address private owner;
    uint8  decimals = 0;
    address[] public owners;
    uint256  voteDuration;
    //from this time on tokens may be burned +24 hours from 01.07.20
    uint256  burnStartTime = now + 24 hours;
    uint256 public  totalReward;
    uint256 lastDivideRewardTime = now;
    uint256 ownerReward;
    
    
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    event Burned(uint256 amount);
    event CandidateAdded(address indexed _candidate);
    event VoteHappened(address indexed _candidate, uint256 _numberOfVotes);
    event Received(address, uint);
    
    struct CandidateData {
        address proposal;
        mapping(address => uint8) votes;
        // do we need total votes?
        uint32 positive;
        //we can track only positive number;
        // uint32 negative;
        bool alreadyOwner;
        bool isCandidate;
    }
    
    IterableMapping.Map private map;
    
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) allowance;
    mapping(address => CandidateData) private candidates;
    mapping(address => bool) eligibleOwners;

    constructor(uint256 _initialSupply) public {
        owner = msg.sender;
        owners = [owner, 0x0DC69b189ad4668CAA54262d037F7d97E79b8CeC, 0x361D0e759BC7AaD5C1e1F10086087bDaEFcF3D26];
        
        uint256 tokenPerOwner = _initialSupply.div(owners.length);
        uint256 tokensLeft = _initialSupply.mod(owners.length);
        
        for (uint i = 0; i < owners.length; i++ ){
            eligibleOwners[owners[i]] = true; 
            balanceOf[owners[i]] = tokenPerOwner;
            map.set(owners[i], 0);
        }
        
        totalSupply = _initialSupply.sub(tokensLeft);
        //allocate initial supply
        emit Transfer(address(0), owner, _initialSupply);
    }
    receive() external payable {
        totalReward += msg.value;
        divideUpReward();
        
        
        emit Received(msg.sender, msg.value);
    }
    
    //Reward distribution
    function divideUpReward() internal  onlyOwners {
        for (uint8 i = 0; i < map.size(); i++){
            ownerReward = totalReward * balanceOf[map.getKeyAtIndex(i)] / totalSupply;
            map.values[map.getKeyAtIndex(i)] += ownerReward; 
            address payable addressToSendReward = address(uint160(map.getKeyAtIndex(i)));
            // totalReward = totalReward.sub(ownerReward);
            
            addressToSendReward.transfer(map.values[map.getKeyAtIndex(i)]);
            map.values[map.getKeyAtIndex(i)] = 0;
            
            
        }
        totalReward = 0;
    }
    
    function getEthBalance(address _address) public view returns(uint256) {
        return map.get(_address);
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

    //modifier grands access to owners only
    modifier onlyOwners() {
        require(eligibleOwners[msg.sender] == true, "You are not an owner");
        _;
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



    // burnign function
  function burn(uint256 _value)  public onlyOwners returns (bool success)  {
      //we restrict ourseleves to burn tokens after some perion of time.
      if (now > burnStartTime) {
          //checking that amount is less or equal to user's balance
          require(balanceOf[msg.sender] >= _value, 'balance insufficient');
          //decreasing the users balance by the amount
          balanceOf[msg.sender] = balanceOf[msg.sender].sub(_value);
            //decreasing the totalSupply by the amount
          totalSupply = totalSupply.sub(_value);
          emit Burned(_value);
          return true;
      }
  }
   
   
}










