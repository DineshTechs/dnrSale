pragma solidity 0.6.0;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */

library SafeMath {
    function percent(uint value,uint numerator, uint denominator, uint precision) internal pure  returns(uint quotient) {
        uint _numerator  = numerator * 10 ** (precision+1);
        uint _quotient =  ((_numerator / denominator) + 5) / 10;
        return (value*_quotient/1000000000000000000);
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
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

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
contract Context {
  // Empty internal constructor, to prevent people from mistakenly deploying
  // an instance of this contract, which should be used via inheritance.
  constructor () internal { }

  function _msgSender() internal view returns (address payable) {
    return msg.sender;
  }

  function _msgData() internal view returns (bytes memory) {
    this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
    return msg.data;
  }
}


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Context{
  address private _owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  /**
   * @dev Initializes the contract setting the deployer as the initial owner.
   */
  constructor () internal {
    address msgSender = _msgSender();
    _owner = msgSender;
    emit OwnershipTransferred(address(0), msgSender);
  }

  /**
   * @dev Returns the address of the current owner.
   */
  function owner() public view returns ( address ) {
    return _owner;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(_owner == _msgSender(), "Ownable: caller is not the owner");
    _;
  }

  /**
   * @dev Leaves the contract without owner. It will not be possible to call
   * `onlyOwner` functions anymore. Can only be called by the current owner.
   *
   * NOTE: Renouncing ownership will leave the contract without an owner,
   * thereby removing any functionality that is only available to the owner.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }

  /**
   * @dev Transfers ownership of the contract to a new account (`newOwner`).
   * Can only be called by the current owner.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }

  /**
   * @dev Transfers ownership of the contract to a new account (`newOwner`).
   */
  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}


contract DNRSale is Ownable{
    
    address public DNRToken;
    uint256 public price = 7*1e16; // 0.07 usdt 
    uint256 public oneMaticPrice = 72*1e16; // 0.72 usdt
    uint256 public phase = 1;
    bool saleActive=false; 
    uint256 public totalInvestmentUSDT = 0;
    uint256 public totalInvestmentMatic = 0;
    uint256 public tokenSold = 0;

    //Token usdt = Token(0xc2132D05D31c914a87C6611C10748AEb04B58e8F); // USDT polygon   
    Token usdt = Token(0xA38B6aea9c5b180106F9F4ed51Ad2854A1e5aab6); // USDT test polygon
    Token dnr = Token(0xbFC5cf00353614Ac676f66DCf9595671AC11Caaa); // dnr test

    
    mapping(address => uint256) public usdtInvestment;
    mapping(address => uint256) public maticInvestment;

    mapping(address => bool) public specialAffiliate;
    mapping(address => bool) public influencerAffiliate;
    mapping(address => uint256) public affiliateEarningUSDT;
    mapping(address => uint256) public affiliateEarningMatic;


    constructor() public{
    }

    function setSpecialAffiliate(address add) public onlyOwner{
        specialAffiliate[add] = true;
    }
    function setinfluencerAffiliate(address add) public onlyOwner{
        influencerAffiliate[add] = true;
    }
    function removeSpecialAffiliate(address add) public onlyOwner{
        specialAffiliate[add] = false;
    }
    function removeinfluencerAffiliate(address add) public onlyOwner{
        influencerAffiliate[add] = false;
    }

    // function updatePrice(uint256 newPrice) public onlyOwner{
    //     price = newPrice;
    // }

    function updateOneMaticPrice(uint256 newPrice) public onlyOwner{
        oneMaticPrice = newPrice;
    }

    function getTokenCurrentPrice() public view returns(uint256){
        if(tokenSold < 2000000*1e18){
            return 7*1e16;
        }
        else if(tokenSold > 2000000*1e18 && tokenSold < 6000000*1e18){
            return 75*1e15;
        }
        else {
            return 75*1e15;
        }
    }
    
    fallback() external  {
        revert();
    }  

     function referral(address ref , uint256 amount , uint256 payMode) internal{
        uint256 comm;
         
            if(specialAffiliate[ref]){
                comm = SafeMath.div(amount,20); // 5 percent               
            }
            else if(influencerAffiliate[ref]){
                comm = SafeMath.div(amount,10); // 10 percent
            }
            else{
                comm = SafeMath.div(amount,33); // ~3 percent
            }

            if(payMode == 1){
                affiliateEarningUSDT[ref] = affiliateEarningUSDT[ref] + comm;
                usdt.transfer(ref,comm);
            }
            else{
                affiliateEarningMatic[ref] = affiliateEarningMatic[ref] + comm;
                address payable refAdd = address(uint160(owner()));
                refAdd.transfer(comm);
            }
            //uint256 reff1 = SafeMath.div(amount,33); // ~3 percent
            //refferedEarning[ref] = refferedEarning[ref] + reff1;
            //address payable ICOadmin = address(uint160(owner()));
        //ICOadmin.transfer(address(this).balance);
         

     }

  

    function purchaseTokensWithUSDT(address affi, uint256 amount) public {
        require(saleActive == true,"Sale not active!"); 
        usdt.transferFrom(msg.sender,owner(),amount);

        if(affi != address(0) && affi != msg.sender){
            referral(affi,amount,1);
        }

        price = getTokenCurrentPrice();

        amount = amount * 1e12;
        uint256 usdToTokens = SafeMath.div(amount, price);
        uint256 tokenAmountDecimalFixed = SafeMath.mul(usdToTokens,1e18);

        dnr.transfer(msg.sender,tokenAmountDecimalFixed);

        usdtInvestment[msg.sender] = usdtInvestment[msg.sender] + amount;
        tokenSold = tokenSold + tokenAmountDecimalFixed;        
      

    }

    function purchaseWithMatic(address affi) payable public{
        require(msg.value > 0,"Enter some valid amount!");
        require(saleActive == true,"Sale not active!");  
        if(affi != address(0) && affi != msg.sender){
            referral(affi,msg.value,2);
        }

        
        ///uint256 fixedForCalc = SafeMath.mul(msg.value,1e18);   
        uint256 maticToUsd = SafeMath.mul(msg.value,oneMaticPrice);   
                maticToUsd = SafeMath.div(maticToUsd,1e18);

        price = getTokenCurrentPrice();
        uint256 usdToTokens = SafeMath.div(maticToUsd, price);
        uint256 tokenAmountDecimalFixed = SafeMath.div(usdToTokens,1e18);

        dnr.transfer(msg.sender,tokenAmountDecimalFixed);

        maticInvestment[msg.sender] = maticInvestment[msg.sender] + msg.value;
        tokenSold = tokenSold + tokenAmountDecimalFixed; 

    }
    
   
    
    function startSale() public onlyOwner{
        saleActive = true;
    }

    function stopSale() public onlyOwner{
        saleActive = false;
    }
    
        
    function withdrawRemainingTokensAfterICO() public{
        require(msg.sender==owner(),"Only owner can update contract!");
        require(dnr.balanceOf(address(this)) >=0 , "Tokens Not Available in contract, contact Admin!");
        dnr.transfer(msg.sender,dnr.balanceOf(address(this)));
    }
    
    function forwardFunds() internal {
        address payable ICOadmin = address(uint160(owner()));
        ICOadmin.transfer(address(this).balance);
        usdt.transfer(owner(), usdt.balanceOf(address(this)));        
    }
    
    function withdrawFunds() public{
        //require(totalInvestment >= softCap,"Sale Not Success!");
        require(msg.sender==owner(),"Only owner can Withdraw!");
        forwardFunds();
    }

       
    function calculateTokenAmount(uint256 amount) external view returns (uint256){
        uint tokens = SafeMath.mul(amount,price);
        return tokens;
    }
    
    function tokenPrice() external view returns (uint256){
        return price;
    }
    
    function investments(address add) external view returns (uint256,uint256){
        return (maticInvestment[add], usdtInvestment[add]);
    }
}

abstract contract Token {
    function transferFrom(address sender, address recipient, uint256 amount) virtual external;
    function transfer(address recipient, uint256 amount) virtual external;
    function balanceOf(address account) virtual external view returns (uint256)  ;

}