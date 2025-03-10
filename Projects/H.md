# Advanced DevOps Engineering Projects Portfolio

## Project 6: GitOps Platform(H)

**Complexity Level: Expert**

### Description

- Declarative infrastructure
- Automated reconciliation
- Policy enforcement
- Drift detection
- Rollback capabilities

```
# ArgoCD Application
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: my-app
spec:
  destination:
    namespace: default
    server: https://kubernetes.default.svc
  source:
    path: k8s
    repoURL: https://github.com/org/repo
    targetRevision: HEAD
```

### Key Learning Objectives

- GitOps principles
- Declarative infrastructure
- Automated reconciliation
- Policy enforcement
- Drift detection
- Rollback capabilities

# Project 6: GitOps Platform(H) - High-Level Design

```mermaid
graph TD;
    A[Advanced DevOps Engineering Projects Portfolio] --> B[Project 6: GitOps Platform - G]

    B --> C[Declarative Infrastructure]
    B --> D[Automated Reconciliation]
    B --> E[Policy Enforcement]
    B --> F[Drift Detection]
    B --> G[Rollback Capabilities]

    B --> H[ArgoCD Application]
    
    H --> I[API Version: argoproj.io/v1alpha1]
    H --> J[Kind: Application]
    H --> K[Metadata: name - my-app]
    H --> L[Destination: Namespace - default]
    H --> M[Server: https://kubernetes.default.svc]
    H --> N[Source: Path - k8s]
    H --> O[Repo URL: https://github.com/org/repo]
    H --> P[Target Revision: HEAD]

    B --> Q[Key Learning Objectives]
    
    Q --> R[GitOps Principles]
    Q --> S[Declarative Infrastructure]
    Q --> T[Automated Reconciliation]
    Q --> U[Policy Enforcement]
    Q --> V[Drift Detection]
    Q --> W[Rollback Capabilities]
