pragma solidity ^0.6.0;

// import "../node_modules/@openzeppelin/contracts/math/SafeMath.sol";
// import "github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/math/SafeMath.sol";
// import "@openzeppelin/contracts/math/SafeMath.sol";

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

contract MyToken {
    using SafeMath for uint256;
    string public name = "ValTokenBurnFull";
    string public symbol = "VLTBF";
    uint256 public totalSupply;
    uint256 public feePerTransaction = 1;
    address private owner;
    uint8 public decimals = 0;
    
    address[] public owners;
    string testMessage = 'it works';
    //from this time on tokens may be burned +24 hours from 01.07.20
    uint256 public burnStartTime = now + 24 hours;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    event Burned(uint256 amount);

    mapping(address => uint256) public balanceOf;

    mapping(address => mapping(address => uint256)) public allowance;

    constructor(uint256 _initialSupply) public {
        owner = msg.sender;
        
        owners = [owner, 0x30B61000B318dFaFEf31b7Dc9A7084f4EF1CE4cb, 0x6350b6659210C47e4810fE885151bCdC07DDa758,
        0xd07DffA0006d9fea011E26479D55E8Bcb2A8AE88, 0xa42fc7ae13fF09700F8169bCD0e26834E8D26750];
        uint256 tokenPerOwner = _initialSupply / owners.length;
        
        for (uint i = 0; i< owners.length; i++ ){
            balanceOf[owners[i]] = tokenPerOwner;
        }
        
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

    //change owner
    //checks  whether a person that called the contract is among owners 
    function isOwner() public view returns (bool) {
        for (uint i = 0; i<owners.length; i++){
            if(msg.sender == owners[i]){
                return true;
            }
        }
    }
    //modifier grands access to owners only
    modifier onlyOwner() {
        require(isOwner(), "You are not an owner");
        _;
    }
    
    function vote() public view   onlyOwner  returns (string memory){
         
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
