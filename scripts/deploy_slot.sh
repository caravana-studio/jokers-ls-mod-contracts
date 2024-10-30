#!/bin/bash

profile="$1"

action="$2"

if [ "$profile" != "prod" ] && [ "$profile" != "testing" ]; then
    echo "Error: Invalid profile. Please use 'prod' or 'testing'."
    exit 1
fi

if [ "$action" != "create" ] && [ "$action" != "update" ]; then
    echo "Error: Invalid action. Please use 'create' or 'update'."
    exit 1
fi

echo "Deploying Slot in ${profile}."

set -e

rm -rf "target"
rm -rf "manifests"
rm -rf "abis"

if [ "$action" == "create" ]; then
    slot deployments delete jon-${profile} katana
    slot deployments delete jon-${profile} torii
    sleep 10
    slot deployments create --tier epic jon-${profile} katana -b 3000 -v v1.0.0-alpha.19 --disable-fee true --invoke-max-steps 4294967295 --seed 420 -a 10
fi

echo "sozo -P ${profile} build && sozo -P ${profile} migrate plan && sozo -P ${profile} migrate apply"
sozo -P ${profile} build && sozo -P ${profile} migrate plan && sozo -P ${profile} migrate apply

echo -e "\n✅ Setup finish!"

export world_address=$(cat ./manifests/$profile/deployment/manifest.json | jq -r '.world.address')

if [ "$action" == "create" ]; then
    echo -e "\n✅ Init Torii!"
    slot d create --tier epic jon-${profile} torii --rpc https://api.cartridge.gg/x/jon-${profile}/katana --world $world_address -v v1.0.0-alpha.19
fi
