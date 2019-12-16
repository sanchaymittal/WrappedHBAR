pragma solidity ^0.5.0;

contract ERC20_mintable {
    mapping(address => uint256) public balances;
    mapping(address => mapping (address => uint256)) public allowed;
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;

    address private owner;

    uint256 private constant MAX_UINT256 = 2**256 - 1;

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Mint(address indexed to, uint value);
    event Destroy(address indexed to, uint value);
    event Locker(address from, address reciever, uint value);

    constructor(uint256 initialAmount, string memory tokenName, uint8 decimalUnits, string memory tokenSymbol)
        public
    {
        balances[msg.sender] = initialAmount;
        totalSupply = initialAmount;
        name = tokenName;
        decimals = decimalUnits;
        symbol = tokenSymbol;
        owner = msg.sender;
    }

    function transfer(address to, uint256 value)
        public returns (bool)
    {
        require(balances[msg.sender] >= value, "Low Balance");
        require(msg.sender == to || balances[to] <= MAX_UINT256 - value);

        balances[msg.sender] -= value;
        balances[to] += value;

        emit Transfer(msg.sender, to, value);
        return true;
    }

    function balanceOf(address _owner)
        public view returns (uint256)
    {
        return balances[_owner];
    }

    function mint(address to, uint256 amount)
        public returns (bool)
    {
        require(totalSupply <= MAX_UINT256 - amount);
        require(balances[to] <= MAX_UINT256 - amount);
        require(msg.sender == owner);

        totalSupply += amount;
        balances[to] += amount;

        emit Mint(to, amount);
        emit Transfer(address(0), to, amount);
        return true;
    }

    function remit(address from, uint256 amount)
        public returns (bool)
    {
        require(totalSupply - amount >= 0);
        require(balances[from] - amount >= 0);

        totalSupply -= amount;
        balances[from] -= amount;

        emit Destroy(from, amount);
        emit Transfer(from, address(0), amount);
        return true;
    }

    function hbar_to_wrappedHbar(address reciever, uint256 value)
        public returns (bool)
    {
        require(balances[msg.sender] >= value, "Low Balance");

        balances[msg.sender] -= value;
        remit(msg.sender, value);

        emit Locker(msg.sender, reciever, value);
        return true;
    }

    function wrappedHbar_to_hbar(uint256 amount)
        public returns (bool)
    {
        require(totalSupply <= MAX_UINT256 - amount);
        require(balances[msg.sender] <= MAX_UINT256 - amount);

        totalSupply += amount;
        balances[msg.sender] += amount;

        emit Mint(msg.sender, amount);
        return true;
    }

}
