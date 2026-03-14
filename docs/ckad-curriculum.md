# CKAD Official Curriculum Reference

> **Source**: [CNCF Curriculum Repository](https://github.com/cncf/curriculum)
> **File**: `CKAD_Curriculum_v1.35.pdf`
> **Kubernetes Version**: 1.35
> **Last Updated**: 2026-03-14
> **Exam Duration**: 2 hours | **Questions**: 15-20 tasks | **Passing Score**: 66%

------

## How to Keep This Up to Date

The CNCF updates the curriculum when a new Kubernetes minor version is released (usually every ~4 months). The exam environment aligns with the latest K8s minor within 4-8 weeks of release.

| Source | URL | What to Watch |
|--------|-----|---------------|
| CNCF Curriculum (GitHub) | https://github.com/cncf/curriculum | Watch repo for commits on CKAD files |
| Linux Foundation CKAD | https://training.linuxfoundation.org/certification/certified-kubernetes-application-developer-ckad/ | K8s version updates, exam format changes |
| CNCF Certification Page | https://www.cncf.io/training/certification/ckad/ | Official announcements |

When the curriculum changes:

1. Check for a new `CKAD_Curriculum_v1.XX.pdf` in the CNCF repo
2. Compare domains/competencies with the tables below
3. Update this file and `docs/simulation-coverage.csv`
4. Open an issue to track any new competencies that need simulation coverage

------

## Official Domains and Competencies (5 domains, 22 competencies)

### 1. Application Design and Build — 20%

| ID | Competency |
|----|------------|
| DB-01 | Define, build and modify container images |
| DB-02 | Choose and use the right workload resource (Deployment, DaemonSet, CronJob, etc.) |
| DB-03 | Understand multi-container Pod design patterns (e.g. sidecar, init and others) |
| DB-04 | Utilize persistent and ephemeral volumes |

### 2. Application Deployment — 20%

| ID | Competency |
|----|------------|
| AD-01 | Use Kubernetes primitives to implement common deployment strategies (e.g. blue/green or canary) |
| AD-02 | Understand Deployments and how to perform rolling updates |
| AD-03 | Use the Helm package manager to deploy existing packages |
| AD-04 | Kustomize |

### 3. Application Observability and Maintenance — 15%

| ID | Competency |
|----|------------|
| OM-01 | Understand API deprecations |
| OM-02 | Implement probes and health checks |
| OM-03 | Use built-in CLI tools to monitor Kubernetes applications |
| OM-04 | Utilize container logs |
| OM-05 | Debugging in Kubernetes |

### 4. Application Environment, Configuration and Security — 25%

| ID | Competency |
|----|------------|
| CS-01 | Discover and use resources that extend Kubernetes (CRD, Operators) |
| CS-02 | Understand authentication, authorization and admission control |
| CS-03 | Understand requests, limits, quotas |
| CS-04 | Understand ConfigMaps |
| CS-05 | Create and consume Secrets |
| CS-06 | Understand ServiceAccounts |
| CS-07 | Understand Application Security (SecurityContexts, Capabilities, etc.) |

### 5. Services and Networking — 20%

| ID | Competency |
|----|------------|
| SN-01 | Demonstrate basic understanding of NetworkPolicies |
| SN-02 | Provide and troubleshoot access to applications via services |
| SN-03 | Use Ingress rules to expose applications |

------

## Competency Breakdown into Testable Skills

Each official competency maps to concrete skills that can be tested in simulations.

### DB-01: Container Images

- Build images with Dockerfile
- Multi-stage Dockerfile builds
- Modify/tag existing images
- Push to local registry

### DB-02: Workload Resources

- Deployments (create, scale, update)
- DaemonSets
- CronJobs / Jobs (completions, parallelism, activeDeadlineSeconds)
- StatefulSets
- ReplicaSets

### DB-03: Multi-container Patterns

- Sidecar containers
- Init containers (single and multiple)
- Ambassador pattern
- Adapter pattern

### DB-04: Volumes

- PersistentVolumes / PersistentVolumeClaims
- emptyDir (shared between containers)
- hostPath
- ConfigMap/Secret as volumes

### AD-01: Deployment Strategies

- Blue/Green deployment
- Canary deployment
- Rollback to specific revision

### AD-02: Rolling Updates

- Rolling update strategy (maxSurge, maxUnavailable)
- Rollout history / undo
- Pause/resume rollouts

### AD-03: Helm

- Install/upgrade/rollback releases
- Search and add repositories
- Inspect values
- Create charts (helm create)
- Template rendering

### AD-04: Kustomize

- kustomization.yaml
- Overlays and patches
- kubectl apply -k

### OM-01: API Deprecations

- Identify deprecated API versions
- Migrate resources to current API versions

### OM-02: Probes and Health Checks

- Liveness probes (httpGet, tcpSocket, exec)
- Readiness probes
- Startup probes
- Probe parameters (initialDelaySeconds, periodSeconds, etc.)

### OM-03: CLI Monitoring Tools

- kubectl top (pods, nodes)
- kubectl describe (events)
- kubectl get (wide output, custom columns)
- kubectl debug (ephemeral containers)

### OM-04: Container Logs

- kubectl logs (current, previous)
- Multi-container log selection (-c)

### OM-05: Debugging

- Troubleshoot CrashLoopBackOff
- Troubleshoot ImagePullBackOff
- kubectl exec into containers
- Events analysis
- Node drain/cordon

### CS-01: CRDs and Operators

- Discover CRDs (kubectl get crd)
- Use custom resources

### CS-02: Auth and Admission Control

- RBAC (Roles, RoleBindings, ClusterRoles, ClusterRoleBindings)
- kubectl auth can-i
- ServiceAccount token mounting

### CS-03: Requests, Limits, Quotas

- Resource requests and limits (cpu, memory)
- LimitRange
- ResourceQuota
- Troubleshoot quota violations

### CS-04: ConfigMaps

- Create from literal, file, env-file
- Mount as volume
- Use as environment variables (envFrom, valueFrom)

### CS-05: Secrets

- Create generic, docker-registry, tls secrets
- Mount as volume
- Use as environment variables (secretKeyRef)
- Base64 encode/decode

### CS-06: ServiceAccounts

- Create and assign to pods
- Token projection
- Automount control

### CS-07: Application Security

- SecurityContext (runAsUser, runAsGroup, runAsNonRoot, fsGroup)
- Capabilities (add/drop)
- seccompProfile
- readOnlyRootFilesystem

### SN-01: NetworkPolicies

- Ingress rules (podSelector, namespaceSelector, ipBlock)
- Egress rules
- Default deny policies
- Label-based selection

### SN-02: Services

- ClusterIP, NodePort, LoadBalancer
- ExternalName services
- Service selector troubleshooting
- kubectl expose
- DNS resolution

### SN-03: Ingress

- Path-based routing
- Host-based routing
- TLS termination
- Ingress controller troubleshooting
