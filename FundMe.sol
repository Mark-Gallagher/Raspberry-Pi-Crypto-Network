pragma solidity >=0.6.6 <0.9.0;

import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";
import "@chainlink/contracts/src/v0.6/vendor/SafeMathChainlink.sol";

contract FundMe {
    using SafeMathChainlink for uint256;    //Checks and stops overflow
    
    mapping(address => uint256) public addressToAmountFunded;
    address[] public funders;
    address public owner;
    
    constructor() public {
        owner = msg.sender;     //executes once contract is deployed
    }
    
    //payable functions can send transactions
    function fund() public payable {
        uint256 minimumUSD = 50 * 10 ** 18;                     //usd minimum threshold 
        require(getConversionRate(msg.value) >= minimumUSD, "You need to spend more ETH!");     //require checks for truth of statement
        addressToAmountFunded[msg.sender] += msg.value;         //msg.sender is the owner, msg.value is the value
        funders.push(msg.sender);                               //send owner to funders array
    }
    
    function getVersion() public view returns (uint256){
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x8A753747A1Fa494EC906cE90E9f37563A8AF630e);       //interface object instance
        return priceFeed.version();
    }
    
    function getPrice() public view returns(uint256){
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x8A753747A1Fa494EC906cE90E9f37563A8AF630e);
        (,int256 answer,,,) = priceFeed.latestRoundData();  //each space after commma represents a variable from AggregatorV3Interface which isn't used 
         return uint256(answer * 10000000000);  //returns price with 18 decimal places instead of 10
    }
    
    // 1000000000 is 1 qwei
    function getConversionRate(uint256 ethAmount) public view returns (uint256){
        uint256 ethPrice = getPrice();
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1000000000000000000;
        return ethAmountInUsd;
    }
    
    modifier onlyOwner {    //changes behaviour of owner function 
        require(msg.sender == owner);
        _;  //run rest of code
    }
    
    function withdraw() payable onlyOwner public {
        msg.sender.transfer(address(this).balance);     //owner sends to specific address using balance 
        
        for (uint256 funderIndex=0; funderIndex < funders.length; funderIndex++){       //loop through array of funders
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;       //Reset funders balace to zero
        }
        funders = new address[](0);         //clear funders array
    }
}
