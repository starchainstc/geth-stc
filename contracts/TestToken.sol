pragma solidity ^0.4.18;

import './ERC20Interface.sol';
import './SafeMath.sol';

contract TestToken is ERC20Interface {
	using SafeMath for uint256;
	string public constant symbol = "TTC";
	string public constant name = "云云币";
	uint8 public constant decimals = 8;
	uint public startTm;
	uint256 _totalSupply = 10000*100000000;
	address public owner;
	mapping(address => uint256) balances;

	mapping(address => mapping (address => uint256)) allowed;

	mapping(address => uint256) locked;

	modifier onlyOwner(){
		require(msg.sender == owner);
		_;
	}

	function TestToken(){
		owner = msg.sender;
		balances[owner] = _totalSupply;
		startTm = now;
	}

	function totalSupply() public constant returns (uint256 total){
		total = _totalSupply;
	}

	function balanceOf(address _owner) public constant returns(uint256 balance){
		return balances[_owner];
	}

	function getlock(address _owner) public constant returns(uint256 unlock){
		if(now >= startTm && now < startTm + 30 days){
			return locked[_owner].mul(4).div(5);
		}else if( now >= startTm + 30 days && now < startTm + 60 days){
			return locked[_owner].mul(3).div(5);
		}else if( now >= startTm + 60 days && now < startTm + 90 days){
			return locked[_owner].mul(2).div(5);
		}else if( now >= startTm + 90 days && now < startTm + 120 days){
			return locked[_owner].mul(1).div(5);
		}else {
			return 0;
		}
	}

	function transfer(address _to,uint256 _amount) public returns (bool success){
		require((balances[msg.sender] - _amount) >= getlock(msg.sender));
		if(balances[msg.sender] >= _amount
			&& _amount >0
			&& (balances[_to]+_amount) > balances[_to]){
			balances[msg.sender] -= _amount;
			balances[_to] += _amount;
			Transfer(msg.sender,_to,_amount);
			return true;
		}else{
			return false;
		}
	}

	function transferFrom(address _from,address _to,uint256 _amount) public returns(bool success){
		require((balances[_from] - _amount) >= getlock(msg.sender));
		if(balances[_from] >= _amount
			&& _amount > 0
			&& (balances[_to]+_amount) > balances[_to]
			&& allowed[_from][msg.sender] >= 0){
			balances[_from] -= _amount;
			balances[_to] += _amount;
			allowed[_from][msg.sender] -= _amount;
			Transfer(_from,_to,_amount);
			return true;
		}else{
			return false;
		}
	}

	function approve(address _spender,uint256 _amount) public returns(bool success){
		allowed[msg.sender][_spender] = _amount;
		Approval(msg.sender,_spender,_amount);
		return true;
	}

	function allowance(address _owner,address _spender) public constant returns(uint256 remaining){
		return allowed[_owner][_spender];
	}

	function setLock(address _owner,uint256 _amount) public returns (bool success){
		require(msg.sender == owner);
		locked[_owner] = _amount;
		return true;
	}

	

	function mint(uint256 _value) public returns(uint256){
		require(msg.sender == owner);
		_totalSupply += _value;
		balances[owner] += _value;
		return balances[owner];
	}
	

	
}