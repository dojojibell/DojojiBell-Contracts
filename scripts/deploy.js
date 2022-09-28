async function main() {
  const [deployer] = await ethers.getSigners();
  const uri = 'https://gateway.pinata.cloud/ipfs/QmXXSbAjfiYtrgX27TCTLpM6psjj75kArkUdhgUydFVPkS';

  console.log('Deploying contracts with the account:', deployer.address);

  console.log('Account balance:', (await deployer.getBalance()).toString());

  const DojojiBell = await ethers.getContractFactory('DojojiBell');
  const dojojibell = await DojojiBell.deploy(uri, uri);
  await dojojibell.deployTransaction.wait();
  const mint = await dojojibell.teamMinting(deployer.address, 3);
  await mint.wait();
  console.log('DojojiERC721 address:', dojojibell.address);

  const Dojoji = await ethers.getContractFactory('Dojoji');
  const dojoji = await Dojoji.deploy(dojojibell.address, dojojibell.address);
  console.log('DojojiERC20 address:', dojoji.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
