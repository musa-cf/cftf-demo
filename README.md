# Terraform & cf-terraforming Demo

The v5 Terraform provider support in cf-terraforming is still a work-in-progress, but this is a preview of how
the tool could be used to Terraform an existing set of configured Cloudflare resources, and extend
it by adding a new resource via Terraform.

The main application of cf-terraforming is for creating a new Terraform project using existing configurations
that aren't currently managed by Terraform.

The following resources are included in this demo:

**Account-scoped:**

✔️ Zones

✔️ Load Balancer Pools

✔️ R2 Buckets (new in v5)

**Zone-scoped**

✔️ Browser Cache TTL Zone Setting

✔️ IP Geolocation Zone Setting

✔️ Caching Level Zone Setting

✔️ Load Balancers

✔️ DNS Records

✔️ Workers KV Namespace

## Prerequisites
1. Git, Go, and Terraform are installed locally
2. You've cloned this repo
3. You've populated the required environment variables in `env.sh`

## Files
- `env.sh`: Contains all of the required environment variables.
- `configs/*`: Terraform files that are used by the script.
- `run-demo.sh`: Script that builds `cf-terraforming` binary, initializes the Terraform project, and generates and imports resources.
- `create-r2-bucket.sh`: Script that adds a new R2 Bucket config to the Terraform project and applies the change. 
- `clean-demo.sh`: Cleans up the files and resources created by the demo so it can be cleanly re-ran if needed.

## Walkthrough
1. **Move into the cloned project directory**
2. **Source your environment variables**

   ```bash
   source env.sh
   ```
3. **Generate and import resources from existing Cloudflare configurations**

   ```bash
   ./run-demo.sh
   ```

   This will go through each configured resource and create the Terraform project with the generated HCL.
   Once the HCL generation finishes, it will then import each resource into the project's Terraform state.
4. **You can explore the generated Terraform in the `tf-project` directory. Each resource type will have its
   own file.**
5. **Apply the Terraform to your account/zone**
   ```bash
   cd tf-project
   terraform fmt && terraform validate && terraform apply
   ```
   There can be diffs on some resources because there are computed values that won't be in our HCL or state file.
6. **Create a new resource (R2 Bucket)**
   ```bash
   cd ..
   ./create-r2-bucket.sh
   ```
   This script copies the bucket config from `configs/` into the project, then applies the change.
7. **Verify that the R2 bucket is now in your CLoudflare account**
   ```bash
   curl https://api.cloudflare.com/client/v4/accounts/$CF_ACCOUNT_ID/r2/buckets/demo-example-bucket \
     -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN"
   ```
8. **Once you're done exploring, clean up the demo artifacts**
   ```bash
   ./clean-demo.sh
   ```
   Note: The change that should get applied here is the deletion of the R2 bucket. If you see anything else getting destroyed, decline the Terraform apply.
