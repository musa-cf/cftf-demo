#!/usr/bin/env bash

set -euo pipefail

# Clone down cf-terraforming and build a binary from the master branch
# to use for the demo. The master branch has changes that have not been
# released yet, but that are required for the demo.
echo -e "Building cf-terraforming..."
git clone git@github.com:musa-cf/cf-terraforming.git cf-tf-repo
cd cf-tf-repo
git checkout demo
go build -o ../cf-terraforming cmd/cf-terraforming/main.go
cd ..
echo -e "Build successful.\n"

echo -e "Initializing Terraform project..."
mkdir tf-project
cp configs/main.tf tf-project/main.tf
cd tf-project
terraform init
cd ..
echo -e "Terraform project initialized successfully.\n"

# These individual commands can be ran all at once, since the 'resource-type'
# argument can be a comma-seperated list of all resource types to be generated.
# It's broken up into individual commands for clarity here.
echo -e "Generating 'zone' resource configurations..."
./cf-terraforming generate --account $CF_ACCOUNT_ID --token $CF_API_TOKEN --resource-type cloudflare_zone > tf-project/zones.tf
echo -e "Zones generated.\n"

echo -e "Generating 'workers_kv_namespace' resource configurations..."
./cf-terraforming generate --account $CF_ACCOUNT_ID --token $CF_API_TOKEN --resource-type cloudflare_workers_kv_namespace > tf-project/workers_kv_namespaces.tf
echo -e "Workers KV namespaces generated.\n"

echo -e "Generating 'load_balancer_pool' resource configurations..."
./cf-terraforming generate --account $CF_ACCOUNT_ID --token $CF_API_TOKEN --resource-type cloudflare_load_balancer_pool > tf-project/load_balancer_pools.tf
echo -e "Load balancer pools generated.\n"

# Zone-scoped resources
echo -e "Generating 'load_balancer' resource configurations..."
./cf-terraforming generate --zone $CF_ZONE_ID --token $CF_API_TOKEN --resource-type cloudflare_load_balancer > tf-project/load_balancers.tf
echo -e "Load balancers generated.\n"

echo -e "Generating 'zone_setting' resource configurations..."
zone_settings="cloudflare_zone_setting=browser_cache_ttl"
./cf-terraforming generate --zone $CF_ZONE_ID --token $CF_API_TOKEN --resource-type cloudflare_zone_setting --resource-id "$zone_settings" > tf-project/zone_settings.tf
zone_settings="cloudflare_zone_setting=ip_geolocation"
./cf-terraforming generate --zone $CF_ZONE_ID --token $CF_API_TOKEN --resource-type cloudflare_zone_setting --resource-id "$zone_settings" >> tf-project/zone_settings.tf
zone_settings="cloudflare_zone_setting=cache_level"
./cf-terraforming generate --zone $CF_ZONE_ID --token $CF_API_TOKEN --resource-type cloudflare_zone_setting --resource-id "$zone_settings" >> tf-project/zone_settings.tf
echo -e "Zone settings generated.\n"

echo -e "Generating 'dns_record' resource configurations..."
./cf-terraforming generate --zone $CF_ZONE_ID --token $CF_API_TOKEN --resource-type cloudflare_dns_record > tf-project/dns_records.tf
echo -e "DNS records generated.\n"

echo -e "Terraform generation complete!\n"

# Import the generated resources into Terraform state so that the plan and apply don't replace the resources
echo -e "Importing resources into Terraform state..."
cd tf-project
terraform import cloudflare_zone.terraform_managed_resource_395f310881742da81e6b703cbcf5412d 395f310881742da81e6b703cbcf5412d
terraform import cloudflare_zone_setting.terraform_managed_resource_browser_cache_ttl 395f310881742da81e6b703cbcf5412d/browser_cache_ttl
terraform import cloudflare_zone_setting.terraform_managed_resource_ip_geolocation 395f310881742da81e6b703cbcf5412d/ip_geolocation
terraform import cloudflare_zone_setting.terraform_managed_resource_cache_level 395f310881742da81e6b703cbcf5412d/cache_level
terraform import cloudflare_workers_kv_namespace.terraform_managed_resource_781d59f66fdf42649449a1ddb28ba75e a269fce7e9d14cfc975c5fd5942b193f/781d59f66fdf42649449a1ddb28ba75e
terraform import cloudflare_load_balancer_pool.terraform_managed_resource_ed6d9ec859f3e69f2a29e74d0ad2479b a269fce7e9d14cfc975c5fd5942b193f/ed6d9ec859f3e69f2a29e74d0ad2479b
terraform import cloudflare_load_balancer.terraform_managed_resource_bdd370fef3eeabdcedcd9331654af0d9 395f310881742da81e6b703cbcf5412d/bdd370fef3eeabdcedcd9331654af0d9
terraform import cloudflare_dns_record.terraform_managed_resource_9afb5ba652c936856cfa4c2a4a70f1d2 395f310881742da81e6b703cbcf5412d/9afb5ba652c936856cfa4c2a4a70f1d2
terraform import cloudflare_dns_record.terraform_managed_resource_7fe4dab0d8d194afaa7b67dd4cc5e290 395f310881742da81e6b703cbcf5412d/7fe4dab0d8d194afaa7b67dd4cc5e290
echo -e "Resources imported successfully.\n"
