// scripts/upgrade-am.js
const { ethers, upgrades } = require("hardhat");
const V1_address = ""; //代理地址

async function main() {
  const ArtistMe2 = await ethers.getContractFactory("ArtistMe_V2");
  const am2 = await upgrades.upgradeProxy(V1_address, ArtistMe2);
  console.log("Aritistme upgraded to", am2.address);
}

main();

//npx hardhat run --network tbsc scripts/2_upgrade.js

//验证代理合约的地址
//npx hardhat verify --network tbsc ""//代理地址

