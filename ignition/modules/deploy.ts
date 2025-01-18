

import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const RewardSystemModule = buildModule("RewardSystem", (m: any) => {
 
  // Deploy LanSeller with token address and price feed
  const Token = m.contract("Token");
  //const verifier = m.contract("Verifier");
  const RewardSystem = m.contract("RewardSystem", [Token]);

  return { Token,RewardSystem };
});

export default RewardSystemModule;