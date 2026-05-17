// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract LPToken is ERC20 {
    address public immutable amm;
    constructor() ERC20("GameFi-LP", "GFLP") { amm = msg.sender; }
    function mint(address to, uint256 amount) external { require(msg.sender == amm); _mint(to, amount); }
    function burn(address from, uint256 amount) external { require(msg.sender == amm); _burn(from, amount); }
}

contract GameAMM is ReentrancyGuard {
    using SafeERC20 for IERC20;

    IERC20  public immutable token0;
    IERC20  public immutable token1;
    LPToken public immutable lpToken;

    uint256 public reserve0;
    uint256 public reserve1;

    uint256 private constant MIN_LIQUIDITY = 1_000;
    uint256 private constant FEE_NUM = 997;
    uint256 private constant FEE_DEN = 1_000;

    event Swap(address indexed user, address indexed tokenIn, uint256 amountIn, uint256 amountOut);
    event LiquidityAdded(address indexed provider, uint256 amount0, uint256 amount1, uint256 lp);
    event LiquidityRemoved(address indexed provider, uint256 amount0, uint256 amount1, uint256 lp);

    constructor(address _token0, address _token1) {
        require(_token0 != _token1, "Same tokens");
        token0  = IERC20(_token0);
        token1  = IERC20(_token1);
        lpToken = new LPToken();
    }

    function addLiquidity(uint256 amount0, uint256 amount1, uint256 minLp)
        external nonReentrant returns (uint256 lp)
    {
        token0.safeTransferFrom(msg.sender, address(this), amount0);
        token1.safeTransferFrom(msg.sender, address(this), amount1);

        uint256 supply = lpToken.totalSupply();
        if (supply == 0) {
            lp = _sqrt(amount0 * amount1) - MIN_LIQUIDITY;
            lpToken.mint(address(0xdead), MIN_LIQUIDITY);
        } else {
            lp = _min((amount0 * supply) / reserve0, (amount1 * supply) / reserve1);
        }
        require(lp >= minLp, "Slippage");
        lpToken.mint(msg.sender, lp);
        reserve0 += amount0;
        reserve1 += amount1;
        emit LiquidityAdded(msg.sender, amount0, amount1, lp);
    }

    function removeLiquidity(uint256 lp, uint256 min0, uint256 min1)
        external nonReentrant returns (uint256 amount0, uint256 amount1)
    {
        uint256 supply = lpToken.totalSupply();
        amount0 = (lp * reserve0) / supply;
        amount1 = (lp * reserve1) / supply;
        require(amount0 >= min0 && amount1 >= min1, "Slippage");
        lpToken.burn(msg.sender, lp);
        reserve0 -= amount0;
        reserve1 -= amount1;
        token0.safeTransfer(msg.sender, amount0);
        token1.safeTransfer(msg.sender, amount1);
        emit LiquidityRemoved(msg.sender, amount0, amount1, lp);
    }

    function swap(address tokenIn, uint256 amountIn, uint256 minOut)
        external nonReentrant returns (uint256 amountOut)
    {
        require(tokenIn == address(token0) || tokenIn == address(token1), "Bad token");
        bool zeroForOne = tokenIn == address(token0);
        IERC20(tokenIn).safeTransferFrom(msg.sender, address(this), amountIn);
        uint256 inWithFee = amountIn * FEE_NUM;
        if (zeroForOne) {
            amountOut = (inWithFee * reserve1) / (reserve0 * FEE_DEN + inWithFee);
            reserve0 += amountIn;
            reserve1 -= amountOut;
            token1.safeTransfer(msg.sender, amountOut);
        } else {
            amountOut = (inWithFee * reserve0) / (reserve1 * FEE_DEN + inWithFee);
            reserve1 += amountIn;
            reserve0 -= amountOut;
            token0.safeTransfer(msg.sender, amountOut);
        }
        require(amountOut >= minOut, "Slippage");
        emit Swap(msg.sender, tokenIn, amountIn, amountOut);
    }

    function getAmountOut(address tokenIn, uint256 amountIn) external view returns (uint256) {
        bool z = tokenIn == address(token0);
        (uint256 rIn, uint256 rOut) = z ? (reserve0, reserve1) : (reserve1, reserve0);
        uint256 inWithFee = amountIn * FEE_NUM;
        return (inWithFee * rOut) / (rIn * FEE_DEN + inWithFee);
    }

    function _sqrt(uint256 x) private pure returns (uint256 y) {
        if (x == 0) return 0;
        uint256 z = x / 2 + 1; y = x;
        while (z < y) { y = z; z = (x / z + z) / 2; }
    }
    function _min(uint256 a, uint256 b) private pure returns (uint256) { return a < b ? a : b; }
}