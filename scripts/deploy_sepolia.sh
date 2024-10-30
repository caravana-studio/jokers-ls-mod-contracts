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
