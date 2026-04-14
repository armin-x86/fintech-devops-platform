## Setup instructions (local)

Prereqs: Docker Desktop (or Docker Engine + Compose).

From `fintech-devops-platform/`:

```bash
docker compose up --build
```

- Backend API: `http://localhost:8000`
  - Health: `GET /health`
  - Data: `GET /assets`, `GET /insights`
- Dashboard: `http://localhost:3000`

To run backend tests in the container:

```bash
docker compose exec -T backend pytest -q
```

## Architecture overview

- **Backend**: FastAPI app serving mock assets and portfolio insights.
- **Frontend**: Next.js app calling the backend via `NEXT_PUBLIC_API_URL`.
- **Local compose**: Frontend talks to backend via the Compose service name (`http://backend:8000`).

## Deployment guide (baseline)

**Flow:** CI builds and pushes images to **ECR**; you deploy to Kubernetes by pointing Helm at those images (today: manually or via scripted `helm`; in a fuller setup: **GitOps** applies the same charts/values—see end of file).

**Prereqs on your machine:** `kubectl` configured for the target cluster, **Helm 3**, and access to pull from **ECR** (IAM / `aws eks update-kubeconfig`, etc.).

**Charts in this repo:**

| Chart | Role |
|-------|------|
| `backend/helm/backend` | ClusterIP Service (intended private / internal) |
| `frontend/helm/frontend` | ClusterIP + **Ingress** annotated for **AWS Load Balancer Controller** (ALB) |

**Example (staging)** — from repo root, after you know your ECR registry and tag (e.g. the commit SHA or `latest` from CI):

```bash
export REGISTRY="<account>.dkr.ecr.eu-west-1.amazonaws.com"
export TAG="<git-sha-or-latest>"

helm upgrade --install fintech-backend backend/helm/backend --namespace fintech --create-namespace \
  --set image.repository="${REGISTRY}/fence-backend" --set image.tag="${TAG}"

helm upgrade --install fintech-frontend frontend/helm/frontend --namespace fintech \
  --set image.repository="${REGISTRY}/fence-frontend" --set image.tag="${TAG}"
```

The **mocked** deploy workflow (`.github/workflows/deploy.yml`) only **prints** these-style values; it does not run `helm` for you.

## CI/CD overview

- **GitHub Actions → AWS**: add repository **variable** **`AWS_ROLE_ARN`** = Terraform output `github_actions_ecr_role_arn` (OIDC; no long-lived AWS keys). The workflow uses `vars.AWS_ROLE_ARN` for `configure-aws-credentials`.
- **ECR image repos**: **`fence-backend`** and **`fence-frontend`** (tags `latest` and `${{ github.sha }}` on pushes to `main`). Repositories **`fence-backend/cache`** and **`fence-frontend/cache`** exist for pull-through / cache use in Terraform; CI does **not** push app images there.
- `.github/workflows/ci.yml`
  - **Path-based**: backend jobs run only when `backend/**` (or shared `docker-compose.yml` / this workflow) changes; frontend jobs only when `frontend/**` (or those shared files) changes.
  - Backend: ruff + pytest + `pip-audit`
  - Frontend: `next lint` + `next build` (`npm ci` if `package-lock.json` exists, else `npm install`)
  - Docker: on push to `main`, build/push **only changed apps** to ECR; on PRs, `docker build` only for changed sides
  - Infra tests: container structure tests (matching sides only)
  - Trivy: HIGH/CRITICAL on `main` for images that were built in the run

- `.github/workflows/deploy.yml`
  - Staging deploy is **mocked**; printed Helm values use ECR URLs. Optional GitHub **variable** `AWS_ACCOUNT_ID` fills `<account>.dkr.ecr.eu-west-1.amazonaws.com` in the echo.
  - Production is a **separate job** that runs only after staging succeeds; see below.

## Production manual approval (documented gate)

The deploy workflow (`.github/workflows/deploy.yml`) uses **GitHub Environments** so you can require a **human approval** before any production deploy step runs.

| Job | Environment name | Purpose |
|-----|------------------|--------|
| `deploy-staging` | `staging` | Runs first (mocked Helm echo). |
| `deploy-production` | `production` | Runs only after `deploy-staging` completes (`needs: deploy-staging`). |

**How to turn on the manual gate**

1. In the GitHub repo: **Settings → Environments**.
2. Create or select the **`production`** environment.
3. Under **Deployment protection rules**, enable **Required reviewers** and add one or more people or teams.
4. (Optional) Restrict **deployment branches** so only `main` (or your release branch) can deploy to `production`.

Until **Required reviewers** is set on `production`, GitHub may run the `deploy-production` job **without** waiting for a person—the workflow wiring is there, but the **approval wall** exists only when you configure it on the environment.

**Secrets / variables**

- Use **repository** or **environment** variables/secrets depending on whether staging and production should use different AWS roles or accounts (see GitHub docs: *Managing environments for deployment*).

## Runbook (minimal)

- **Is it up?**
  - Backend: `curl -fsSL http://localhost:8000/health`
  - Frontend: `curl -fsSL http://localhost:3000/ >/dev/null`
- **Logs**
  - `docker compose logs -f backend`
  - `docker compose logs -f frontend`
- **Rollback**
  - Re-deploy previous image tag in Helm (`--set image.tag=<old>`), or in Compose rebuild with older tag.

## Key decisions (why)

- **Dockerfiles**
  - Multi-stage builds for smaller runtime images and better caching.
  - Non-root runtime users.
  - Healthchecks included for container orchestrators.
- **Backend runtime**
  - Gunicorn + Uvicorn worker for a sensible production baseline.
  - JSON logs to stdout (easy aggregation).
- **CI/CD**
  - “Shift-left” lint/test before image build/push.
  - `pip-audit` for Python dependency scanning.
  - Trivy for container vulnerability scanning.
  - Container structure tests for basic image assertions.

## GitHub Actions: AWS variables

After applying Terraform for **core**, set these under **Repository → Settings → Secrets and variables → Actions → Variables** (or use **environment-scoped** variables for staging vs production):

| Variable | Purpose |
|----------|---------|
| `AWS_ROLE_ARN` | Terraform output `github_actions_ecr_role_arn` — OIDC role CI uses to push to ECR (`vars.AWS_ROLE_ARN` in workflows). |
| `AWS_ACCOUNT_ID` | Optional: 12-digit id so the **deploy** workflow can print the ECR registry hostname in its examples. |

You can keep the role ARN in **Secrets** instead if you prefer (`secrets.AWS_ROLE_ARN`); align workflows accordingly.

### GitOps vs GitHub Actions deploy

In a production-grade setup I treat **GitHub Actions** as **build and push only**: images land in **ECR** with a known tag. **Deployment** is owned by **GitOps** (e.g. **Flux** or **Argo CD**): manifests/Helm values live in git, the controller reconciles the cluster, and optional **image automation** (e.g. image updater) bumps tags when new images appear. The **deploy workflow** in this repository remains **mocked** on purpose—it documents the Helm image wiring, not a live pipeline.

**Not provisioned in this repo yet (typical next steps on EKS):**

- **AWS Load Balancer Controller** installed via GitOps so **Ingress** resources get **ALB**s (`ingress.k8s.aws/alb` class as used in the frontend chart).
- **Karpenter** (or another autoscaler) installed via Helm/GitOps for node scaling.
- **AWS WAF** in front of public HTTP if ALB exposes the app to the internet (policy and rules per risk review).
- **External Secrets Controller**: I've prepared the IRSA role within the EKS installation and we just need to roleout the helmchart for the externalSecrets. So application secrets will be fetched from aws secrets and will be provisioned as K8S secrets ready for our app to consume it.