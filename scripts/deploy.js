// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

async function main() {
  const Buyer = await hre.ethers.getContractFactory("Buyer");
  const buy = await Buyer.deploy("0x4a1868E800198C010208154859feE45acA03093A","3","0x2AB0e9e4eE70FFf1fB9D67031E44F6410170d00e");
  await buy.deployed();

  console.log(
    `Buyer deployed to ${buy.address}`
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
