import { utils, Wallet } from "zksync-web3";
import * as ethers from "ethers";
import { HardhatRuntimeEnvironment } from "hardhat/types";
import { Deployer } from "@matterlabs/hardhat-zksync-deploy";

import * as secrets from "../secrets.json";

const feeToken: string | undefined = '';

let deployer: Deployer;
let faucet: ethers.Contract;

enum TokenType {
    ERC20 = 'ERC20TestToken',
    ERC20_WITH_PERMIT = 'ERC20TestTokenWithPermit',
    ERC677 = 'ERC677TestToken'
}

async function deployERC20TestToken(faucetAddress: string, type: TokenType, name: string, symbol: string, decimals: number) {
    if (!faucetAddress || !faucetAddress.startsWith('0x')) {
        throw Error(`Invalid faucet address ${faucetAddress}`);
    }
    
    console.log(`Deploying ${name} (${symbol}) as decimals ${decimals} and type ${type}`);
    const artifact = await deployer.loadArtifact(type);
    const token = await deployer.deploy(artifact, [name, symbol, decimals, faucetAddress], feeToken ? {
        feeToken: feeToken
    } : undefined);

    await token.deployed();

    if (await token.faucet() === faucetAddress) {
        console.log(`Token ${symbol} has been successfully deployed to ${token.address}.`);
    } else {
        console.error('Unexpected faucet address, something wrong happened.', faucetAddress);
    }
    
    return token;
}

export default async function (hre: HardhatRuntimeEnvironment) {
    // Initialize deployer.
    const wallet = new Wallet(secrets.privateKey);
    deployer = new Deployer(hre, wallet);
    console.log(`Use account ${wallet.address} as deployer.`);

    const faucetAddress = '0x1458a212860e756f9E3D4b016db037a054EA4C5F'; // Address of the testnet faucet.

    // Tokens to deploy.
    console.log('Faucet address', faucetAddress);
    await deployERC20TestToken(faucetAddress, TokenType.ERC20, 'Swap', 'SWAP', 18);

    console.log('All tasks finished.');
}
