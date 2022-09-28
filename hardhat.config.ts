import 'dotenv/config';
import {HardhatUserConfig} from 'hardhat/types';
import 'hardhat-deploy';
import 'hardhat-deploy-ethers';
import 'hardhat-gas-reporter';
import {node_url, accounts} from './utils/networks';
require('dotenv').config({path: __dirname + '/.env'});
require('@nomiclabs/hardhat-etherscan');
const {API_URL, PRIVATE_KEY} = process.env;
const config: HardhatUserConfig = {
  solidity: {
    compilers: [
      {
        version: '0.8.15',
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
    ],
  },
  networks: {
    hardhat: {
      accounts: accounts('localhost'),
    },

    testnet: {
      url: API_URL,
      accounts: [`0x${PRIVATE_KEY}`],
      live: true,
    },
    mainnet: {
      url: 'https://mainnet.infura.io/v3/',
      accounts: [`0x${PRIVATE_KEY}`],
      live: true,
    },
  },
  etherscan: {
    apiKey: 'RZ9A67WTDP5Z7IWGN81XRGRRJCXK6PJ1NR',
  },
  gasReporter: {
    currency: 'USD',
    gasPrice: 5,
    enabled: !!process.env.REPORT_GAS,
  },
  namedAccounts: {
    creator: 1,
  },
};

export default config;
