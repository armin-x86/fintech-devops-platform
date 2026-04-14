# Infra Common EKS Cluster

This is the EKS cluster to provide common services including observability and CI operations

## Key Information
- Karpenter Ready
- Multi AZ
- Private subnets  - API exposed to public but limited to VPNs
- creates ACM entry

## Essential IAMs
### IRSA
- Gitlab Runners
- We should also add External DNS
- We should also add External Secrets

### Node Group IAM
- Essential ECR, EC2 and Cluster access policies
