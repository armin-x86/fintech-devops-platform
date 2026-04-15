# Architecture (infrastructure)

This repository’s **infrastructure is expressed as Terraform on AWS** (`infra/terraform/aws/`). Application images are built in CI and stored in **ECR**; workloads are intended to run on **EKS** with **Helm** charts kept next to each app.

## Layout (IaC)

```
infra/terraform/aws/
├── modules/                    # Reusable building blocks (VPC, EKS, ECR, S3, …)
└── environments/<env>/
    ├── configs/                # Shared inputs: region, VPC shape, tags, account ids, …
    ├── core/                   # “Foundation” stack: remote state bucket, ECR, GitHub OIDC → IAM, DNS, …
    └── services/               # Per-service roots (e.g. eks-euw-1): cluster + related AWS resources
```

- **`configs`** is a small Terraform module consumed by **`core`** and **`services`** so naming, tagging, and account metadata stay **DRY**.
- **`core`** and each **`services/...`** root module use **separate Terraform state** (different backends / state keys) so blast radius and ownership stay clear; apply order still matters (bootstrap **core** before relying on shared resources—see `infra/terraform/aws/README.md`).

## Main AWS components (code)

| Area | Role |
|------|------|
| **Core** | Shared primitives: Terraform **state** backend (S3), **ECR** repos (+ optional cache repos), **IAM OIDC** for GitHub Actions → IAM role (ECR push), Route 53, secrets placeholders, etc. |
| **EKS stack** (`services/eks-euw-1`) | **VPC**, **EKS** control plane + node/fargate patterns via shared **`modules/eks`**, optional **VPC endpoints** (S3/ECR) for private egress patterns. |
| **Modules** | Encapsulate opinionated patterns (tags, networking, EKS addons/IAM) so environment roots stay thin. |

## Delivery path (images → cluster)

1. **GitHub Actions** (`.github/workflows/ci.yml`) builds container images and pushes to **ECR** (`companyNM-backend`, `companyNM-frontend`) using **OIDC** to assume an IAM role (no long-lived AWS keys in GitHub).
2. **Helm** charts under `backend/helm/` and `frontend/helm/` describe how workloads run on Kubernetes (Service, Ingress for the frontend, NetworkPolicies, etc.).
3. **Deploy workflow** (`.github/workflows/deploy.yml`) is **mocked** in-repo but shows the intended Helm `--set image.repository` / `image.tag` against the ECR registry; **production** uses a GitHub **Environment** for optional manual approval (documented in the root `README.md`).

## GitOps (optional / future)

`infra/fluxcd/` is reserved for a **cascading / app-of-apps** style GitOps flow (e.g. Flux or Argo CD) to install cluster add-ons (ingress, external-dns, secrets, monitoring, …). It is **not** required for the Terraform layout above; bootstrap order would be: account foundations → EKS → then GitOps controller → app releases.
