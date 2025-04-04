#!/usr/bin/env bash

set -uo pipefail

echo "Cleaning up demo artifacts..."
rm -rf ./cf-tf-repo
rm ./cf-terraforming
cd tf-project
rm r2_buckets.tf
terraform apply
cd ..
rm -rf ./tf-project
echo "Artifacts removed successfully."
