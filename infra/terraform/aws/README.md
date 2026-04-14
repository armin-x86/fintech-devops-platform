# Terraform - AWS

## Prerequisites (local workstation)

Install the required tools:

- **Terraform**: `brew install hashicorp/tap/terraform`
- **Workflow helpers**: `brew install just pre-commit`
- **Terraform tooling**: `brew install terraform-docs tflint`
- **Security tooling**:
  - `brew install trivy`
  - `brew install detect-secrets`

To verify installs:

```bash
terraform version
pre-commit --version
trivy --version
detect-secrets --version
tflint --version
terraform-docs version
```

After you finished bootstrapping you workstation, ensure running the following command:
  ```shell
  pre-commit install
  ```

### Secrets Detection
If the commit files contains sensitive information, for example the word `secret` or `secrets`, the `detect-secrets` will
pick up those words and stop you committing. You then decide those are allowed to commit then run the command to redefine the
baseline of the settings.

```shell
detect-secrets scan > .secrets.baseline
```


## ⚠️ Important Note
### Terraform state:
At the begining there should be a bucket to store the state and terraform can't create it (Chicken Egg) so you will need to follow these steps. Consider that the `core` folder (inside each environment) is responsible for creation of core parts of our infra. Like backend bucket, log buckets and ...
1. Comment out `backend block` inside `versions.tf` in core directory to use local state and do a `terraform init`
 

### Running for the first time:
On the **first Terraform run**, the VPC and subnet IDs do **not yet exist**, so it's not possible to create the **EKS managed node groups** immediately, because they require the `subnet_ids` to be passed and data resources will be evaluated before the run.

**To work around this:**
1. **Temporarily comment out** the `node_managed_groups` block inside your EKS cluster module definition and also the `cluster_addons` (except `vpc CNI` which is fine to be included on first run) inside the eks module code (as addons need Node groups to get installed on them)
2. Run plan+apply to create the **VPC** and the **EKS control plane**.
3. After that, **uncomment** the `node_managed_groups` block and `cluster_addons` and push the changes.
4. Run plan + Apply to have the fully working **Data Plane as well**.



- **`environments/<env>/configs`** - environment layer config(e.g. staging): region, VPC definitions, default tags.
- **Root modules** under **`environments/<env>/core`** and **`environments/<env>/services/...`** compose shared **`modules/`** so naming, tagging, and patterns stay consistent (**DRY**), and the same shape can be reused for another business unit or company by changing config, not copying stacks wholesale.

## State model

Each logical part (**core**, **eks**,  …) has **its own Terraform state**. That trades some cross-stack coupling for clearer blast radius, ownership, and parallel apply; we accept the usual **ordering and data-source** trade-offs and document the intended bootstrap sequence below.

## Terraform interface

We use **Makefiles** in each root module directory (`make plan`, `make apply`, `make clean`) so everyone runs the same init/plan/apply flow and options across the team.

## Bootstrap sequence (new account / greenfield)

1. **Core (local state first)** - In `environments/<env>/core`, run **`make plan`** then **`make apply`** with backend **not** using the shared S3 remote yet (local state), so the state bucket (and other core prereqs) will be created and printed as outputs.
2. **Point core at S3** - Switch the **core** backend to **S3** and **migrate** state into the bucket you just created as commented in `versions.tf`
3. **Wire remote state everywhere else** - Update **backend** blocks (or backend config) for **vpc**, **ec2**, **alb**, and any other roots so they use the same S3 backend pattern.
4. **DNS delegation** - After core creates the **Route 53 hosted zone**, take the zone **NS** records and delegate them at the **root domain** DNS (registrar / parent zone).
5. **Point eks state at newly created S3** - Time to update the versions.tf within `environments/<env>/services/eks-euw-1` by addressing the newly created `S3` bucket for terraform state. We'll use a single bucket but different `path` inside it to isolate `tf states`.
6. **VPC + EKS** - Run Terraform for the EKS stack to create VPC and EKS and required IAM roles. (e.g. `environments/<env>/services/eks-euw-1`): **`make plan`** / **`make apply`**.



## Access EKS Clusters
In this demo I have exposed the API server of the EKS and limited the LB access to the VPN IPs but in real production this should be governed by ZTNA or at least bastion host and the API shouldnt be exposed.
