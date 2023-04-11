const { ethers } = require("hardhat");

// 设置proxy合约地址
const ContractAddress = "0xf3d414635b8EF91C86A5dD918841871C050ff0e9";

async function main() {
  // 获取已部署的空投合约实例
  const ArtistMe_V2 = await ethers.getContractFactory("ArtistMe_V2");
  const am2Contract = await ArtistMe_V2.attach(ContractAddress);

  // 批量空投

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

// npx hardhat run --network tbsc ./scripts/setversion.js
