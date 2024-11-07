#!/bin/bash

action="$1"

echo "Deploying Sepolia"

set -e

rm -rf "target"
rm -rf "manifests"
rm -rf "abis"

echo "sozo -P sepolia build && sozo -P sepolia migrate plan && sozo -P sepolia migrate apply"
sozo -P sepolia build && sozo -P sepolia migrate plan && sozo -P sepolia migrate apply

echo -e "\n✅ Setup finish!"


if [ "$action" == "create" ]; then
    export world_address=$(cat ./manifests/sepolia/deployment/manifest.json | jq -r '.world.address')
    slot deployments delete jon-sepolia torii
    sleep 10
    echo -e "\n✅ Init Torii!"
    slot d create --tier epic jon-sepolia torii --rpc https://api.cartridge.gg/x/starknet/sepolia --world $world_address -v v1.0.0-alpha.16
fi



sozo -P prod build && sozo -P prod migrate plan && sozo -P prod migrate apply -vvv

slot d create --tier epic jn-loot torii --rpc https://api.cartridge.gg/x/starknet/mainnet --world 0x194200e527a82862b684683b3c1994d6b6831e9d9da94a6865aada5dbcd53e8 -v v1.0.0-alpha.16

sozo -P prod execute game_system create_game -c 1 --wait --world 0x194200e527a82862b684683b3c1994d6b6831e9d9da94a6865aada5dbcd53e8
