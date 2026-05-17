Compiling 118 files with Solc 0.8.24
Solc 0.8.24 finished in 1.18s
Compiler run successful!
Analysing contracts...
Running tests...

Ran 8 tests for test/LootBox.t.sol:LootBoxTest
[PASS] test_FulfillRandomWords_GoldJackpot() (gas: 101448)
[PASS] test_FulfillRandomWords_Potion() (gas: 123372)
[PASS] test_FulfillRandomWords_Sword() (gas: 123444)
[PASS] test_OpenBox_BurnsGold() (gas: 104385)
[PASS] test_RevertFulfill_OnlyCoordinator() (gas: 10982)
[PASS] test_RevertOpenBox_NotEnoughGold() (gas: 60596)
[PASS] test_SetKeyHash() (gas: 31645)
[PASS] test_SetSubId() (gas: 14779)
Suite result: ok. 8 passed; 0 failed; 0 skipped; finished in 3.20ms (3.54ms CPU time)

Ran 8 tests for test/ItemFactory.t.sol:ItemFactoryTest
[PASS] test_Deploy2_CREATE2() (gas: 461821)
[PASS] test_Deploy_CREATE() (gas: 462404)
[PASS] test_Deploy_InitializesCorrectly() (gas: 465065)
[PASS] test_DifferentSalts_DifferentAddresses() (gas: 892487)
[PASS] test_Implementation() (gas: 8125)
[PASS] test_IsRegistered_Yul() (gas: 467270)
[PASS] test_IsRegistered_YulMatchesSolidity() (gas: 471639)
[PASS] test_PredictAddress_MatchesActual() (gas: 472594)
Suite result: ok. 8 passed; 0 failed; 0 skipped; finished in 3.75ms (2.93ms CPU time)

Ran 6 tests for test/Governance.t.sol:GovernanceTest
[PASS] test_FullLifecycle() (gas: 363271)
[PASS] test_GovernorName() (gas: 13441)
[PASS] test_ProposalThreshold() (gas: 8089)
[PASS] test_QuorumPositive() (gas: 21373)
[PASS] test_VotingDelay() (gas: 8065)
[PASS] test_VotingPeriod() (gas: 8072)
Suite result: ok. 6 passed; 0 failed; 0 skipped; finished in 4.03ms (2.23ms CPU time)

Ran 15 tests for test/GOV.t.sol:GOVTest
[PASS] testFuzz_DelegateVotingPower(uint256) (runs: 1000, μ: 122161, ~: 121634)
[PASS] testFuzz_Transfer(uint256) (runs: 1000, μ: 45682, ~: 45598)
[PASS] test_Approve() (gas: 35743)
[PASS] test_Decimals() (gas: 5909)
[PASS] test_DelegateToOther() (gas: 123292)
[PASS] test_InitialBalance() (gas: 8520)
[PASS] test_Name() (gas: 13352)
[PASS] test_NoncesStartAtZero() (gas: 10717)
[PASS] test_RevertTransfer_InsufficientBalance() (gas: 17026)
[PASS] test_SelfDelegate() (gas: 83233)
[PASS] test_Symbol() (gas: 13441)
[PASS] test_TotalSupply() (gas: 7924)
[PASS] test_Transfer() (gas: 45235)
[PASS] test_TransferFrom() (gas: 88950)
[PASS] test_VotingPower_ZeroBeforeDelegate() (gas: 47328)
Suite result: ok. 15 passed; 0 failed; 0 skipped; finished in 119.59ms (163.12ms CPU time)

Ran 16 tests for test/GameItems.t.sol:GameItemsTest
[PASS] testFuzz_Craft(uint8) (runs: 1000, μ: 70461, ~: 70716)
[PASS] testFuzz_Mint(uint256) (runs: 1000, μ: 49556, ~: 50141)
[PASS] test_Burn() (gas: 55731)
[PASS] test_BuyItem() (gas: 70140)
[PASS] test_Craft_Sword() (gas: 91829)
[PASS] test_Initialize_AdminRole() (gas: 15490)
[PASS] test_Initialize_CraftCosts() (gas: 17666)
[PASS] test_Initialize_MinterRole() (gas: 15506)
[PASS] test_Initialize_Prices() (gas: 17647)
[PASS] test_Mint() (gas: 48282)
[PASS] test_RevertBurn_NotMinter() (gas: 54392)
[PASS] test_RevertBuyItem_InsufficientETH() (gas: 38982)
[PASS] test_RevertBuyItem_StalePrice() (gas: 38784)
[PASS] test_RevertCraft_NotEnoughGold() (gas: 55015)
[PASS] test_RevertMint_NotMinter() (gas: 20087)
[PASS] test_SetCraftCost() (gas: 21024)
Suite result: ok. 16 passed; 0 failed; 0 skipped; finished in 203.32ms (263.92ms CPU time)

Ran 11 tests for test/RentalVault.t.sol:RentalVaultTest
[PASS] testFuzz_Deposit(uint256) (runs: 1000, μ: 126861, ~: 127041)
[PASS] testFuzz_DepositAndRedeem(uint256) (runs: 1000, μ: 130344, ~: 130483)
[PASS] testFuzz_YieldDistribution(uint256) (runs: 1000, μ: 141739, ~: 141910)
[PASS] test_AddYield_IncreasesShareValue() (gas: 142120)
[PASS] test_Asset() (gas: 8044)
[PASS] test_Deposit() (gas: 115648)
[PASS] test_Redeem() (gas: 116585)
[PASS] test_RevertAddYield_NotOwner() (gas: 13990)
[PASS] test_TwoDepositors_ShareYield() (gas: 209242)
[PASS] test_VaultName() (gas: 13420)
[PASS] test_VaultSymbol() (gas: 13418)
Suite result: ok. 11 passed; 0 failed; 0 skipped; finished in 285.35ms (621.04ms CPU time)

Ran 17 tests for test/GameAMM.t.sol:GameAMMTest
[PASS] testFuzz_AddRemoveLiquidity(uint256) (runs: 1000, μ: 290351, ~: 303201)
[PASS] testFuzz_GetAmountOut(uint256) (runs: 1001, μ: 282859, ~: 283140)
[PASS] testFuzz_KInvariant(uint256) (runs: 1000, μ: 352555, ~: 352726)
[PASS] testFuzz_Swap(uint256) (runs: 1000, μ: 348048, ~: 348194)
[PASS] test_AddLiquidity_Initial() (gas: 280210)
[PASS] test_AddLiquidity_MintLP() (gas: 280783)
[PASS] test_GetAmountOut_Symmetric() (gas: 284796)
[PASS] test_KInvariant_AfterSwap() (gas: 339488)
[PASS] test_RemoveLiquidity() (gas: 308396)
[PASS] test_ReservesUpdateAfterSwap() (gas: 336632)
[PASS] test_RevertAddLiquidity_Slippage() (gas: 308615)
[PASS] test_RevertConstructor_SameTokens() (gas: 64410)
[PASS] test_RevertSwap_BadToken() (gas: 284151)
[PASS] test_RevertSwap_Slippage() (gas: 336025)
[PASS] test_Swap_AforB() (gas: 337901)
[PASS] test_Swap_BforA() (gas: 324230)
[PASS] test_Swap_FeeApplied() (gas: 281317)
Suite result: ok. 17 passed; 0 failed; 0 skipped; finished in 1.13s (1.74s CPU time)

Ran 3 tests for test/Invariants.t.sol:AMMInvariantTest
[PASS] invariant_KNeverDecreases() (runs: 256, calls: 7680, reverts: 0)

╭------------+----------+-------+---------+----------╮
| Contract   | Selector | Calls | Reverts | Discards |
+====================================================+
| AMMHandler | swap     | 7680  | 0       | 0        |
╰------------+----------+-------+---------+----------╯

[PASS] invariant_LPSupplyPositive() (runs: 256, calls: 7680, reverts: 0)

╭------------+----------+-------+---------+----------╮
| Contract   | Selector | Calls | Reverts | Discards |
+====================================================+
| AMMHandler | swap     | 7680  | 0       | 0        |
╰------------+----------+-------+---------+----------╯

[PASS] invariant_ReservesMatchBalances() (runs: 256, calls: 7680, reverts: 0)

╭------------+----------+-------+---------+----------╮
| Contract   | Selector | Calls | Reverts | Discards |
+====================================================+
| AMMHandler | swap     | 7680  | 0       | 0        |
╰------------+----------+-------+---------+----------╯

Suite result: ok. 3 passed; 0 failed; 0 skipped; finished in 2.04s (4.23s CPU time)

Ran 3 tests for test/Fork.t.sol:ForkTest
[PASS] test_Fork_BuyItemWithRealPrice() (gas: 3998454)
[PASS] test_Fork_ChainlinkFeedValid() (gas: 24799)
[PASS] test_Fork_DeployGameItemsWithRealFeed() (gas: 3927979)
Suite result: ok. 3 passed; 0 failed; 0 skipped; finished in 2.10s (3.67s CPU time)

Ran 9 test suites in 2.11s (5.89s CPU time): 87 tests passed, 0 failed, 0 skipped (87 total tests)

╭----------------------------------+------------------+------------------+----------------+-----------------╮
| File                             | % Lines          | % Statements     | % Branches     | % Funcs         |
+===========================================================================================================+
| script/Deploy.s.sol              | 0.00% (0/30)     | 0.00% (0/43)     | 100.00% (0/0)  | 0.00% (0/1)     |
|----------------------------------+------------------+------------------+----------------+-----------------|
| src/GOV.sol                      | 100.00% (6/6)    | 100.00% (4/4)    | 100.00% (0/0)  | 100.00% (3/3)   |
|----------------------------------+------------------+------------------+----------------+-----------------|
| src/GameAMM.sol                  | 100.00% (58/58)  | 98.53% (67/68)   | 78.95% (15/19) | 100.00% (10/10) |
|----------------------------------+------------------+------------------+----------------+-----------------|
| src/GameGovernor.sol             | 80.00% (8/10)    | 78.95% (15/19)   | 100.00% (0/0)  | 80.00% (8/10)   |
|----------------------------------+------------------+------------------+----------------+-----------------|
| src/GameItems.sol                | 92.68% (38/41)   | 94.87% (37/39)   | 69.23% (9/13)  | 77.78% (7/9)    |
|----------------------------------+------------------+------------------+----------------+-----------------|
| src/ItemFactory.sol              | 100.00% (30/30)  | 100.00% (33/33)  | 100.00% (2/2)  | 100.00% (7/7)   |
|----------------------------------+------------------+------------------+----------------+-----------------|
| src/LootBox.sol                  | 100.00% (26/26)  | 100.00% (29/29)  | 100.00% (6/6)  | 100.00% (7/7)   |
|----------------------------------+------------------+------------------+----------------+-----------------|
| src/RentalVault.sol              | 100.00% (3/3)    | 100.00% (2/2)    | 100.00% (0/0)  | 100.00% (1/1)   |
|----------------------------------+------------------+------------------+----------------+-----------------|
| src/mocks/MockPriceFeed.sol      | 71.43% (5/7)     | 50.00% (3/6)     | 100.00% (0/0)  | 50.00% (2/4)    |
|----------------------------------+------------------+------------------+----------------+-----------------|
| src/mocks/MockVRFCoordinator.sol | 100.00% (4/4)    | 100.00% (3/3)    | 100.00% (0/0)  | 100.00% (2/2)   |
|----------------------------------+------------------+------------------+----------------+-----------------|
| test/GameAMM.t.sol               | 100.00% (1/1)    | 100.00% (1/1)    | 100.00% (0/0)  | 100.00% (1/1)   |
|----------------------------------+------------------+------------------+----------------+-----------------|
| test/Invariants.t.sol            | 100.00% (10/10)  | 100.00% (14/14)  | 100.00% (2/2)  | 100.00% (3/3)   |
|----------------------------------+------------------+------------------+----------------+-----------------|
| Total                            | 83.63% (189/226) | 79.69% (208/261) | 80.95% (34/42) | 87.93% (51/58)  |
╰----------------------------------+------------------+------------------+----------------+-----------------╯
