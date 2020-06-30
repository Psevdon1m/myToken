pragma solidity ^0.6.0;

contract SafeMath {
  //internals

  function safeMul(uint a, uint b) internal pure returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function safeSub(uint a, uint b) internal pure returns (uint) {
    assert(b <= a);
    return a - b;
  }

  function safeAdd(uint a, uint b) internal pure returns (uint) {
    uint c = a + b;
    assert(c>=a && c>=b);
    return c;
  }

  function assert(bool assertion)  internal pure {
    if (!assertion) revert('Asser Error');
  }
}

contract MyToken is SafeMath {
    string public name = "ValTokenBurn";
    string public symbol = "VLTB";
    uint256 public totalSupply;
    uint256 public feePerTransaction = 1;
    address private owner;
    uint8 public decimals = 0;

    //from this time on tokens may be burned +24 hours from 29.06.20
    uint256 public burnStartTime = now + 24 hours;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Burned(uint256 amount);

    mapping(address => uint256) public balanceOf;

    constructor(uint256 _initialSupply) public {
        owner = msg.sender;
        balanceOf[msg.sender] = _initialSupply;
        totalSupply = _initialSupply;
        //allocate initial supply
    }

    //Transfer function
    function transfer(address _to, uint256 _value)
        public
        payable
        returns (bool success)
    {
        require(balanceOf[msg.sender] >= _value, 'error, balance is insufficient');
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value - feePerTransaction;
        balance[owner] += feePerTransaction;
        //transfer event
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner of the contract can burn tokens");
        _;
    }

    // burnign function
   function burn(uint256 _value)  public onlyOwner returns (bool success)  {
       //we restrict ourseleves to burn tokens after some perion of time.
       if (now > burnStartTime) {
           //checking that amount is less or equal to user's balance
           require(balanceOf[msg.sender] >= _value, 'balance insufficient');
           //decreasing the users balance by the amount
           balanceOf[msg.sender] = safeSub(balanceOf[msg.sender], _value);
            //decreasing the totalSupply by the amount
           totalSupply = safeSub(totalSupply, _value);
           emit Burned(_value);
           return true;
       }
   }
}
