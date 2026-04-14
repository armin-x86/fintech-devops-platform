FROM alpine:3.20

WORKDIR /work

# Minimal tooling for a "local IaC runner" container:
# - terraform: to run plans/applies
# - awscli: to authenticate and interact with AWS
# - kubectl + helm: to interact with EKS and deploy charts
# - git/ssh: to fetch modules/private repos (if needed)
RUN apk add --no-cache \
    bash curl ca-certificates git openssh-client jq python3 py3-pip && \
    pip3 install --no-cache-dir awscli

ARG TERRAFORM_VERSION=1.8.5
RUN curl -fsSL -o /tmp/terraform.zip "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" && \
    unzip /tmp/terraform.zip -d /usr/local/bin && \
    rm -f /tmp/terraform.zip

ARG KUBECTL_VERSION=1.30.2
RUN curl -fsSL -o /usr/local/bin/kubectl "https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl" && \
    chmod +x /usr/local/bin/kubectl

ARG HELM_VERSION=3.15.2
RUN curl -fsSL -o /tmp/helm.tar.gz "https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz" && \
    tar -xzf /tmp/helm.tar.gz -C /tmp && \
    mv /tmp/linux-amd64/helm /usr/local/bin/helm && \
    rm -rf /tmp/helm.tar.gz /tmp/linux-amd64

CMD ["bash"]

