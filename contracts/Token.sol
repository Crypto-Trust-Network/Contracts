pragma solidity ^0.4.15;

import './QuickMafs.sol';

import './Ownable.sol';

import './ERC20.sol';

/**
* The CTN Token
*/
contract Token is ERC20, Ownable {

    using QuickMafs for uint256;
    
    string public constant SYMBOL = "CTN";
    string public constant NAME = "Crypto Trust Network";
    uint8 public constant DECIMALS = 18;
    
    /**
    * Total supply of tokens
    */
    uint256 totalTokens;
    
    /**
    * The initial supply of coins before minting
     */
    uint256 initialSupply;
    
    /**
    * Balances for each account
    */
    mapping(address => uint256) balances;
    
    /**
    * Whos allowed to withdrawl funds from which accounts
    */
    mapping(address => mapping (address => uint256)) allowed;
    
    /**
     * If the token is tradable
     */ 
     bool tradable;
     
    /**
    * The address to store the initialSupply
    */
    address public vault;
    
    /**
    * If the coin can be minted
    */
    bool public mintingFinished = false;
    
    /**
     * Event for when new coins are created 
     */
    event Mint(address indexed _to, uint256 _value);
    
    /**
    * Event that is fired when token sale is over
    */
    event MintFinished();
    
    /**
     * Tokens can now be traded
     */ 
    event TradableTokens(); 
    
    /**
     * Allows this coin to be traded between users
     */ 
    modifier isTradable(){
        require(tradable);
        _;
    }
    
    /**
     * If this coin can be minted modifier
     */
    modifier canMint() {
        require(!mintingFinished);
        _;
    }
    
    /**
    * Initializing the token, setting the owner, initial supply & vault
    */
    function Token() public {
        initialSupply = 4500000 * 1 ether;
        totalTokens = initialSupply;
        tradable = false;
        vault = 0x6e794AAA2db51fC246b1979FB9A9849f53919D1E; 
        balances[vault] = balances[vault].add(initialSupply); //Set initial supply to the vault
    }
    
    /**
    * Obtain current total supply of CTN tokens 
    */
    function totalSupply() public constant returns (uint256 totalAmount) {
          totalAmount = totalTokens;
    }
    
    /**
    * Get the initial supply of CTN coins 
    */
    function baseSupply() public constant returns (uint256 initialAmount) {
          initialAmount = initialSupply;
    }
    
    /**
    * Returns the balance of a wallet
    */ 
    function balanceOf(address _address) public constant returns (uint256 balance) {
        return balances[_address];
    }
    
    /**
    * Transfer CTN between wallets
    */ 
    function transfer(address _to, uint256 _amount) public isTradable returns (bool) {
        balances[msg.sender] = balances[msg.sender].sub(_amount);
        balances[_to] = balances[_to].add(_amount);
        Transfer(msg.sender, _to, _amount);
        return true;
    }

    /**
    * Send _amount of tokens from address _from to address _to
    * The transferFrom method is used for a withdraw workflow, allowing contracts to send
    * tokens on your behalf, for example to "deposit" to a contract address and/or to charge
    * fees in sub-currencies; the command should fail unless the _from account has
    * deliberately authorized the sender of the message via some mechanism; we propose
    * these standardized APIs for approval:
    */
    function transferFrom(
        address _from,
        address _to,
        uint256 _amount
    ) public isTradable returns (bool success) 
    {
        var _allowance = allowed[_from][msg.sender];
    
        /** 
        *   QuickMaf will roll back any changes so no need to check before these operations
        */
        balances[_to] = balances[_to].add(_amount);
        balances[_from] = balances[_from].sub(_amount);
        allowed[_from][msg.sender] = _allowance.sub(_amount);
        Transfer(_from, _to, _amount);
        return true;  
    }

    /**
    * Allows an address to transfer money out this is administered by the contract owner who can specify how many coins an account can take.
    * Needs to be called to feault the amount to 0 first -> https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    */
    function approve(address _spender, uint256 _amount) public returns (bool) {
        
        /**
        *Set the amount they are able to spend to 0 first so that transaction ordering cannot allow multiple withdrawls asyncly
        *This function always requires to calls if a user has an amount they can withdrawl.
        */
        require((_amount == 0) || (allowed[msg.sender][_spender] == 0));
    
        allowed[msg.sender][_spender] = _amount;
        Approval(msg.sender, _spender, _amount);
        return true;
    }


    /**
     * Check the amount of tokens the owner has allowed to a spender
     */
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
         return allowed[_owner][_spender];
    }

    /**
     * Makes the coin tradable between users cannot be undone
     */
    function makeTradable() public onlyOwner {
        tradable = true;
        TradableTokens();
    }
    
    /**
    * Mint tokens to users
    */
    function mint(address _to, uint256 _amount) public onlyOwner canMint returns (bool) {
        totalTokens = totalTokens.add(_amount);
        balances[_to] = balances[_to].add(_amount);
        Mint(_to, _amount);
        return true;
    }

    /**
    * Function to stop minting tokens irreversable
    */
    function finishMinting() public onlyOwner returns (bool) {
        mintingFinished = true;
        MintFinished();
        return true;
    }
}