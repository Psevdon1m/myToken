pragma solidity ^0.6.0;

import 'github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/math/SafeMath.sol';

// contract SafeMath {
//   //internals

//   function safeMul(uint a, uint b) internal pure returns (uint) {
//     uint c = a * b;
//     assert(a == 0 || c / a == b);
//     return c;
//   }

//   function safeSub(uint a, uint b) internal pure returns (uint) {
//     assert(b <= a);
//     return a - b;
//   }

//   function safeAdd(uint a, uint b) internal pure returns (uint) {
//     uint c = a + b;
//     assert(c>=a && c>=b);
//     return c;
//   }

//   function assert(bool assertion)  internal pure {
//     if (!assertion) revert('Asser Error');
//   }
// }

contract MyToken {
    
    using SafeMath for uint256;
    
    string public name = "ValTokenBurnFull";
    string public symbol = "VLTBF";
    uint256 public totalSupply;
    uint256 public feePerTransaction = 1;
    address private owner;
    uint8 public decimals = 0;

    

    //from this time on tokens may be burned +24 hours from 01.07.20
    uint256 public burnStartTime = now + 24 hours;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    event Burned(uint256 amount);

    mapping(address => uint256) public balanceOf;

    mapping(address => mapping(address => uint256)) public allowance;

    constructor(uint256 _initialSupply) public {
        owner = msg.sender;
        balanceOf[msg.sender] = _initialSupply;
        totalSupply = _initialSupply;
        //allocate initial supply
        emit Transfer(address(0), owner, _initialSupply);
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

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner of the contract can burn tokens");
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
      balanceOf[_from] =  balanceOf[_from].sub(_value);
      balanceOf[_to] = balanceOf[_to].add(_value);
      allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value);
      emit Transfer(_from, _to, _value);
      return true;
    }



    // burnign function
   function burn(uint256 _value)  public onlyOwner returns (bool success)  {
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
