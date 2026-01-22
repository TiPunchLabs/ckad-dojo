# Research: CKAD Exam Simulator

**Date**: 2025-12-04
**Feature**: 001-ckad-exam-simulator

## Technical Decisions

### 1. Local Helm Repository for Q4

**Decision**: Use `chartmuseum` or a simple HTTP server to host Helm charts locally.

**Rationale**: The exam uses a Helm repo with nginx/apache charts. We need a local equivalent that can serve charts and allow `helm repo add`, `helm search`, `helm upgrade`, etc.

**Alternatives considered**:

- Use Bitnami public repo: Rejected - different chart structure, not exam-faithful
- Pre-install charts without repo: Rejected - Q4 requires `helm search` and `helm upgrade`
- Use OCI registry for Helm: Rejected - exam uses traditional Helm repo

**Implementation**: Deploy a lightweight HTTP server (python -m http.server or nginx) serving packaged charts from `manifests/setup/helm-repo/`.

### 2. Local Docker Registry for Q11

**Decision**: Deploy registry:2 container accessible at `localhost:5000`.

**Rationale**: Q11 requires pushing images to a registry. Using `localhost:5000` is the standard local registry approach.

**IMPORTANT**: Q11 is purely container-based (Docker) and does NOT involve Kubernetes cluster operations. All scoring for Q11 uses docker commands, not kubectl.

**Alternatives considered**:

- Use DockerHub: Rejected - requires authentication, network dependency
- Use in-cluster registry (K8s deployment): Rejected - Q11 doesn't use K8s at all
- Use insecure localhost registry: Chosen - simplest, works with Docker

**Implementation**: Run `docker run -d -p 5000:5000 --restart=always --name registry registry:2` during setup.

**Q11 Scoring (no kubectl)**:

- `docker images | grep localhost:5000/sun-cipher` - check Docker image
- `docker ps | grep sun-cipher` - check running container
- File `./exam/course/11/logs` exists and contains expected output

### 3. Scoring Script Architecture

**Decision**: Single bash script with per-question functions, output in table format.

**Rationale**: Matches the format in `scorring.md`, easy to read, no external dependencies.

**Alternatives considered**:

- Python script: Rejected - adds dependency not in CKAD exam
- JSON output: Rejected - less human-readable
- Separate scripts per question: Rejected - harder to maintain total score

**Implementation**: `ckad-score.sh` sources `lib/scoring-functions.sh` with functions like `score_q1()`, `score_q2()`, etc.

### 4. Idempotency Strategy

**Decision**: Use kubectl apply with `--server-side` and check existence before create.

**Rationale**: Constitution requires idempotent operations. kubectl apply handles existing resources gracefully.

**Alternatives considered**:

- Delete before create: Rejected - destructive, not idempotent
- Check existence with conditionals: Combined with apply for robustness
- Use Helm for all resources: Rejected - over-engineering for simple manifests

**Implementation**:

```bash
kubectl get ns neptune 2>/dev/null || kubectl create ns neptune
kubectl apply -f manifests/setup/ --server-side
```

### 5. Pre-existing Resources per Question

**Decision**: Create minimal resources that match exam expectations exactly.

**Rationale**: Exam fidelity principle requires matching original conditions. Over-provisioning would give hints.

**Questions requiring pre-existing resources**:

- Q5: ServiceAccount `neptune-sa-v2` with attached Secret
- Q7: Pods in `saturn` namespace including `webserver-sat-003`
- Q8: Deployment `api-new-c32` with broken image
- Q9: Pod `holy-api` in `pluto`
- Q14: Pod `secret-handler` and Secret `secret2`
- Q15: Deployment `web-moon` (waiting for ConfigMap)
- Q16: Deployment `cleaner` in `mercury`
- Q17: Deployment template at expected path
- Q18: Deployment `manager-api-deployment` and Service with wrong selector
- Q19: Deployment `jupiter-crew-deploy` and ClusterIP Service
- Q20: Deployments `api` and `frontend` in `venus`
- Q21: ServiceAccount `neptune-sa-v2` (shared with Q5)
- Q22: Pods in `sun` with various labels

## Dependencies Analysis

### Required Tools (verified available)

| Tool | Purpose | Version Check |
|------|---------|---------------|
| kubectl | K8s operations | `kubectl version --client` |
| helm | Helm questions | `helm version` |
| docker | Container operations | `docker --version` |
| bash | Script execution | `bash --version` (4.0+) |

### Cluster Requirements

- kubeadm cluster with working kubectl context
- Sufficient resources for ~50 pods across namespaces
- No restrictive NetworkPolicies blocking pod communication
- Storage provisioner optional (Q13 expects Pending PVC)

## Open Questions (Resolved)

All technical questions have been resolved during research. No blocking issues.
