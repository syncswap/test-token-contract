#!/usr/bin/env bash

# Compile 'zk' artifacts.
echo "[deploy-zksync] Compiling zkSync artifacts.."

if [ -d "./artifacts-zk" ]; then
  rm -rf ./artifacts-zk
fi
if [ -d "./cache-zk" ]; then
  rm -rf ./cache-zk
fi

yarn hardhat compile --network zksync

# Replace 'normal' artifacts with 'zk' artifacts.
echo "[deploy-zksync] Moving zkSync artifacts.."

if [ -d "./artifacts-normal" ]; then
  rm -rf ./artifacts-normal
fi
if [ -d "./cache-normal" ]; then
  rm -rf ./cache-normal
fi

if [ -d "./artifacts" ]; then
  mv ./artifacts ./artifacts-normal
fi
if [ -d "./cache" ]; then
  mv ./cache ./cache-normal
fi

if [[ ! -d "./artifacts-zk" || ! -d "./cache-zk" ]]; then
    echo "[deploy-zksync] Not found zkSync artifacts, please compile it first."
    exit 1
  else
    mv ./artifacts-zk ./artifacts
    mv ./cache-zk ./cache
fi

# Deploy into zkSync
# yarn hardhat deploy-zksync --script {name}.ts
echo "[deploy-zksync] Deploying zkSync artifacts.."

script=""
if [[ "$skippedCompile" == 0 && "$1" ]]; then
    script=$1
  else
    if [[ "$skippedCompile" == 1 && "$2" ]]; then
      script=$2
    fi
fi

if [[ ! -z "$script" ]]; then
    echo "[deploy-zksync] Use deploy script: $script"
    yarn hardhat deploy-zksync --script "$script".ts
  else
    echo "[deploy-zksync] Use all deploy scripts."
    yarn hardhat deploy-zksync
fi


# Rename artifacts back
echo "[deploy-zksync] Restoring artifact files"
mv ./artifacts ./artifacts-zk
mv ./cache ./cache-zk

if [ -d "./artifacts-normal" ]; then
  mv ./artifacts-normal ./artifacts
fi
if [ -d "./cache-normal" ]; then
  mv ./cache-normal ./cache
fi

echo "[deploy-zksync] zkSync artifacts deployed successfully."