pragma solidity ^0.4.15;

/**
*  ERC Token Standard #20 Interface
*/
contract ERC20 {
    
    /**
    * Get the total token supply
    */
    function totalSupply() public constant returns (uint256 _totalSupply);
    
    /**
    * Get the account balance of another account with address _owner
    */
    function balanceOf(address _owner) public constant returns (uint256 balance);
    
    /**
    * Send _amount of tokens to address _to
    */
    function transfer(address _to, uint256 _amount) public returns (bool success);
    
    /**
    * Send _amount of tokens from address _from to address _to
    */
    function transferFrom(address _from, address _to, uint256 _amount) public returns (bool success);
    
    /**
    * Allow _spender to withdraw from your account, multiple times, up to the _amount.
    * If this function is called again it overwrites the current allowance with _amount.
    * this function is required for some DEX functionality
    */
    function approve(address _spender, uint256 _amount) public returns (bool success);
    
    /**
    * Returns the amount which _spender is still allowed to withdraw from _owner
    */
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining);
    
    /**
    * Triggered when tokens are transferred.
    */
    event Transfer(address indexed _from, address indexed _to, uint256 _amount);
    
    /**
    * Triggered whenever approve(address _spender, uint256 _amount) is called.
    */
    event Approval(address indexed _owner, address indexed _spender, uint256 _amount);
}