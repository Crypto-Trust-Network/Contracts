pragma solidity ^0.4.15;

/** 
* The ownable contract contains an owner address. This give us simple ownership privledges and can allow ownship transfer. 
*/
contract Ownable {

     /** 
     * The owner/admin of the contract
     */ 
     address public owner;
    
     /**
     * Constructor for contract. Sets The contract creator to the default owner.
     */
     function Ownable() public {
         owner = msg.sender;
     }
    
    /**
    * Modifier to apply to methods to restrict access to the owner
    */
     modifier onlyOwner(){
         require(msg.sender == owner);
         _; //Placeholder for method content
     }
    
    /**
    * Transfer the ownership to a new owner can only be done by the current owner. 
    */
    function transferOwnership(address _newOwner) public onlyOwner {
    
        //Only make the change if required
        if (_newOwner != address(0)) {
            owner = _newOwner;
        }
    }
}