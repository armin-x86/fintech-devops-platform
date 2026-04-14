EKS cluster components like:
- ExternalDNS
- ExternalSecrets
- ALB controller
- Prometheus
- Storage Classes for Persistent Volume claims
- Karpenter
and ....
Needs to be manifested here.
Using a cascading strategy. App of Apps model.
Where we bootstrap the FluxCD/ArgoCD manually and in a cascading action, it goes for all the parent apps and inner apps inside them and ends up in configuring the whole cluster.
