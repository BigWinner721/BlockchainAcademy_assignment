const { ethers } = require("hardhat");

// 设置proxy合约地址
const ContractAddress = "";//代理地址

async function main() {
  // 获取已部署的合约实例
  const ArtistMe_V2 = await ethers.getContractFactory("ArtistMe_V2");
  const am2Contract = await ArtistMe_V2.attach(ContractAddress);

  // 调用setVersion函数

  const setvTx = await am2Contract.setVersion(33);
  await setvTx.wait();
  console.log("ArtistMe_V2 tx completed.");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });

// npx hardhat run --network tbsc ./scripts/3_setversion.js
