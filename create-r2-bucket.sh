#!/usr/bin/env bash

set -euo pipefail

echo -e "Creating new R2 bucket...\n"
cp configs/r2_buckets.tf tf-project/r2_buckets.tf
cd tf-project
terraform validate
terraform apply
