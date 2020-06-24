pragma solidity ^0.6.0;

contract myToken {
    string public name = "ValToken";
    string public symbol = "VLT";
    uint256 public totalSupply;
    uint256 public feePerTransaction = 1;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    mapping(address => uint256) public balanceOf;

    constructor(uint256 _initialSupply) public {
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
        require(balanceOf[tx.origin] >= _value);
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value - feePerTransaction;
        //transfer event
        emit Transfer(msg.sender, _to, _value);
        return true;
    }
}
