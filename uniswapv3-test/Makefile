# 从 .env 文件加载
include .env
test-vvv:
	forge test --fork-url $(ETH_RPC_URL) -vvv
	
# 运行特定合约的所有测试
forge test --match-contract SupplyTest

# 运行特定的测试方法
forge test --match-test test_supply

# 组合使用 - 运行特定合约的特定测试
forge test --match-contract SupplyTest --match-test test_supply

# 加上 fork-url
forge test --match-contract SupplyTest --fork-url $ETH_RPC_URL