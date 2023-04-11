const { ethers, upgrades } = require("hardhat");

const provider = new ethers.providers.FallbackProvider([ethers.provider], 1);
provider.getFeeData = async () => FEE_DATA;
provider.estimateGas = async () => BigNumber.from("<GAS_LIMIT>");

async function main() {
  const ArtistMe = await ethers.getContractFactory("ArtistMe");
  const artistme = await upgrades.deployProxy(ArtistMe);
  await artistme.deployed();
  console.log("ArtistMe deployed to proxy:", artistme.address);
}

main();

//npx hardhat run --network tbsc scripts/updeploy.js

//npx hardhat verify --network tbsc "0xf3d414635b8EF91C86A5dD918841871C050ff0e9"