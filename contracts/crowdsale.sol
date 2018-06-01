pragma solidity 0.4.18;

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) view public returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) view public returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }

}

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {

  address public owner;

  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() public{
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) onlyOwner public{
    require(newOwner != address(0));
    owner = newOwner;
  }

}

contract CrowdSale is Ownable {

   using SafeMath for uint;
    //wallet for profit
    address public multisig;
    //token
    ERC20Basic public token ;
    //state of preSale
    enum StateCrowdSale {Active, Closed}
    // rate for payments
    uint  public rate;

    StateCrowdSale public statecrowdsale;
    //benefeciar balanses
    mapping(address => uint) public balances;

    function CrowdSale() public{

      multisig = 0xF4e16e79102B19702Cc10Cbcc02c6EC0CcAD8b1D; //a wallet for withdrawal of money
      rate = 13250*10**18;
      statecrowdsale = StateCrowdSale.Active;

    }

    //Exchange Rates
    function setExchangeRate(uint _rate)onlyOwner public{

        require(_rate > 0);
        rate = _rate;

    }

    // establishes a contractual relationship with a token contract
    function setTokenContract(address _newCat)onlyOwner public payable {
        token = ERC20Basic(_newCat);
    }

    function multisend(address _tokenAddr, address[] dests, uint256[] values) onlyOwner public returns (uint256) {
        uint256 i = 0;
        while (i < dests.length) {
           ERC20(_tokenAddr).transfer(dests[i], values[i]);
           i += 1;
        }
        return(i);
    }
    //the method changes the address to which to transfer money after the end of ico
    function changeMultisigAddress(address _newAddress)onlyOwner public{
        require(_newAddress!=0x0);
        //procedure for change of address
        multisig = _newAddress;
    }

    //function after the end of the crowdsale, after the call, we transfer all the eth into the account of the multisig
    function finishCrowdsale()onlyOwner public{
        multisig.transfer(this.balance);
        token.transfer(multisig, token.balance);
        statecrowdsale = StateCrowdSale.Closed;
    }
    //sales start
    function startCrowdsale()onlyOwner public{
        statecrowdsale = StateCrowdSale.Active;
    }

    //sales stop
    function stopCrowdsale()onlyOwner public{
        statecrowdsale = StateCrowdSale.Closed;
    }

    modifier saleIsOn() {
      //check that this coin goes to the crowdsdale
      require(statecrowdsale == StateCrowdSale.Active);
      _;
    }

    function saleTokens()saleIsOn payable public{
        //if money came, we translate tokens to the beneficiary
        //calculate how many tokens translate
        uint tokens = rate.mul(msg.value).div(10**18);
        //transfer tokens
        token.transfer(msg.sender,tokens);
        balances[msg.sender] = balances[msg.sender].add(msg.value);
    }


    //function that is launched when transferring money to a contract
    function() external payable {
        saleTokens();
    }
}
