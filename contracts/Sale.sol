pragma solidity ^0.4.15;

import './Token.sol';


/**
* The initial crowdsale of the token
*/
contract Sale is Ownable {


    using QuickMafs for uint256;
    
    /**
     * The hard cap of the token sale
     */
    uint256 hardCap;
    
    /**
     * The soft cap of the token sale
     */
    uint256 softCap;
    
    /**
     * The bonus cap for the token sale
     */
    uint256 bonusCap;
    
    /**
     * How many tokens you get per ETH
     */
    uint256 tokensPerETH;
    
    /** 
    * //the start time of the sale (new Date("Dec 22 2017 18:00:00 GMT").getTime() / 1000)
    */
    uint256 public start = 1513965600;
                
    
    /**
     * The end time of the sale (new Date("Jan 22 2018 18:00:00 GMT").getTime() / 1000)
     */ 
    uint256 public end = 1516644000;
    
    /**
     * Two months after the sale ends used to retrieve unclaimed refunds (new Date("Mar 22 2018 18:00:00 GMT").getTime() / 1000)
     */
    uint256 public twoMonthsLater = 1521741600;
    
    /**
    * Token for minting purposes
    */
    Token public token;
    
    /**
    * The address to store eth in during sale 
    */
    address public vault;
    
    
    /**
    * How much ETH each user has sent to this contract. For softcap unmet refunds
    */
    mapping(address => uint256) investments;
    
    
    /**
    * Every purchase during the sale
    */
    event TokenSold(address recipient, uint256 etherAmount, uint256 ctnAmount, bool bonus);
    
    
    /**
    * Triggered when tokens are transferred.
    */
    event PriceUpdated(uint256 amount);
    
    /**
    * Only make certain changes before the sale starts
    */
    modifier isPreSale(){
         require(now < start);
        _;
    }
    
    /**
    * Is the sale still on
    */
    modifier isSaleOn() {
        require(now >= start && now <= end);
        _;
    }
    
    /**
    * Has the sale completed
    */
    modifier isSaleFinished() {
        
        bool hitHardCap = token.totalSupply().sub(token.baseSupply()) >= hardCap;
        require(now > end || hitHardCap);
        
        _;
    }
    
    /**
    * Has the sale completed
    */
    modifier isTwoMonthsLater() {
        require(now > twoMonthsLater);
        _;
    }
    
    /**
    * Make sure we are under the hardcap
    */
    modifier isUnderHardCap() {
    
        bool underHard = token.totalSupply().sub(token.baseSupply()) <= hardCap;
        require(underHard);
        _;
    }
    
    /**
    * Make sure we are over the soft cap
    */
    modifier isOverSoftCap() {
        bool overSoft = token.totalSupply().sub(token.baseSupply()) >= softCap;
        require(overSoft);
        _;
    }
    
    /**
    * Make sure we are over the soft cap
    */
    modifier isUnderSoftCap() {
        bool underSoft = token.totalSupply().sub(token.baseSupply()) < softCap;
        require(underSoft);
        _;
    }
    
    /** 
    *   The token sale constructor
    */
    function Sale() public {
        hardCap = 10500000 * 1 ether;
        softCap = 500000 * 1 ether;
        bonusCap = 2000000 * 1 ether;
        tokensPerETH = 536; //Tokens per 1 ETH
        token = new Token();
        vault = 0x6e794AAA2db51fC246b1979FB9A9849f53919D1E; 
    }
    
    /**
    * Fallback function which receives ether and created the appropriate number of tokens for the 
    * msg.sender.
    */
    function() external payable {
        createTokens(msg.sender);
    }
    
        
    /**
    * If the soft cap has not been reached and the sale is over investors can reclaim their funds
    */ 
    function refund() public isSaleFinished isUnderSoftCap {
        uint256 amount = investments[msg.sender];
        investments[msg.sender] = investments[msg.sender].sub(amount);
        msg.sender.transfer(amount);
    }
    
    /**
    * Withdrawl the funds from the contract.
    * Make the token tradeable and finish minting
    */ 
    function withdrawl() public isSaleFinished isOverSoftCap {
        vault.transfer(this.balance);
        
        //Stop minting of the token and make the token tradeable
        token.finishMinting();
        token.makeTradable();
    }
    
    /**
    * Update the ETH price for the token sale
    */
    function updatePrice(uint256 _newPrice) public onlyOwner isPreSale {
        tokensPerETH = _newPrice;
        PriceUpdated(_newPrice);
    }
    
    /**
    * Allows user to buy coins if we are under the hardcap also adds a bonus if under the bonus amount
    */
    function createTokens(address recipient) public isUnderHardCap isSaleOn payable {
    
        uint256 amount = msg.value;
        uint256 tokens = tokensPerETH.mul(amount);
        bool bonus = false;
        
        if (token.totalSupply().sub(token.baseSupply()) < bonusCap) {
            bonus = true;
            tokens = tokens.add(tokens.div(5));
        }
        
        //Add the amount to user invetment total
        investments[msg.sender] = investments[msg.sender].add(msg.value);
        
        token.mint(recipient, tokens);
        
        TokenSold(recipient, amount, tokens, bonus);
    }
    
    /**
     * Withdrawl the funds from the contract.
     * Make the token tradeable and finish minting
     */ 
    function cleanup() public isTwoMonthsLater {
        vault.transfer(this.balance);
        token.finishMinting();
        token.makeTradable();
    }
    
    function destroy() public onlyOwner isTwoMonthsLater {
         token.finishMinting();
         token.makeTradable();
         token.transferOwnership(owner);
         selfdestruct(vault);
    }
    
    /**
     * Get the ETH balance of this contract
     */ 
    function getBalance() public constant returns (uint256 totalAmount) {
          totalAmount = this.balance;
    }
}