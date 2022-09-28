import {DeployFunction} from 'hardhat-deploy/types';
import 'hardhat-deploy-ethers';
import 'hardhat-deploy';

const run: DeployFunction = async (hre) => {
  const {deployments, getNamedAccounts} = hre;
  const {deploy, execute} = deployments;
  const {creator} = await getNamedAccounts();
  console.log('Creator', creator);

  const uri = 'https://gateway.pinata.cloud/ipfs/QmXXSbAjfiYtrgX27TCTLpM6psjj75kArkUdhgUydFVPkS';

  const dojojibell = await deploy('DojojiBell', {
    from: creator,
    log: true,
    args: [uri, uri],
  });

  const dojoji = await deploy('Dojoji', {
    from: creator,
    log: true,
    args: [dojojibell.address, dojojibell.address],
  });
};

run.tags = ['testnet'];

run.skip = async (hre) => {
  return hre.network.name !== 'testnet';
};

export default run;
