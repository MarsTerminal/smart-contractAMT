pragma solidity ^0.4.21;


contract Crowdsale is Ownable {
    
    using SafeMath for uint;
    
    address public multisig;
 
    uint public restrictedPercent;
 
    address public restricted;
 
    ArbyMarsToken public token = new ArbyMarsToken();
 
    uint public start;
    
    uint public period;
 
    uint public hardcap;
 
    uint public rate;
    
    uint public softcap;
    
    mapping(address => uint) public balances;
 
    function Crowdsale() public{
      multisig =  0x552c5db52afb926e545f6a3ab52352115a472ac3;
      restricted =  0x552c5db52afb926e545f6a3ab52352115a472ac3;
      restrictedPercent = 24;
      rate = 100000000000;
      start = 1519927200;
      period = 56;
      hardcap = 7428000000000000000000;
      softcap = 34000000000000000000;
    }
 
    modifier saleIsOn() {
      require(now > start && now < start + period * 1 days);
      _;
    }
	
    modifier isUnderHardCap() {
      address onMultisig = this;
      require(onMultisig.balance <= hardcap);
      _;
    }
 
    function refund() public{
      address onMultisig = this;
      require(onMultisig.balance < softcap && now > start + period * 1 days);
      uint value = balances[msg.sender]; 
      balances[msg.sender] = 0; 
      msg.sender.transfer(value); 
    }
 
    function finishMinting() public onlyOwner {
      address onMultisig = this;
      if(onMultisig.balance > softcap) {
        multisig.transfer(onMultisig.balance);
        uint issuedTokenSupply = token.totalSupply();
        uint restrictedTokens = issuedTokenSupply.mul(restrictedPercent).div(100 - restrictedPercent);
        token.mint(restricted, restrictedTokens);
        token.finishMinting();
      }
    }
 
   function createTokens() public isUnderHardCap saleIsOn payable {
      uint tokens = rate.mul(msg.value).div(1 ether);
      uint bonusTokens = 0;
      if(now < start + (period * 1 days).div(4)) {
        bonusTokens = tokens.div(2);
      } else if(now >= start + (period * 1 days).div(4) && now < start + (period * 1 days).div(4).mul(2)) {
        bonusTokens = tokens.div(4);
      } else if(now >= start + (period * 1 days).div(4).mul(2) && now < start + (period * 1 days).div(4).mul(3)) {
        bonusTokens = tokens.div(10);
      }
      tokens += bonusTokens;
      token.mint(msg.sender, tokens);
      balances[msg.sender] = balances[msg.sender].add(msg.value);
    }
 
    function() external payable {
      createTokens();
    }
    
}
