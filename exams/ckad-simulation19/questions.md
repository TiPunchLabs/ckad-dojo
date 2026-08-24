# CKAD Exam Simulator - Dojo Bishamonten 🛡️
> **Total Score**: 120 points | **Passing Score**: ~66% (80 points)
> 「毘沙門天は正義を守る」- Bishamonten guards justice

---

## Question 1 | Kubernetes Practice

| Points | CNCF Domain | CNCF Weight | Namespace | Resources | Files |
|--------|-------------|-------------|-----------|-----------|-------|
| 6 | Application Design and Build | 20% | ward | Pod | `./exam/course/19/q1/Dockerfile` |

### Task
You have been tasked to optimize a container build process using multi-stage builds.
In the directory `./exam/course/19/q1/`, there is a basic `main.go` application and an incomplete `Dockerfile`.
Modify the `Dockerfile` to use a multi-stage build:
1. Stage 1: Name it `builder` and use `golang:1.20-alpine` as the base image. Compile the Go app here.
2. Stage 2: Use `alpine:3.18` as the base image. Copy the compiled binary from the `builder` stage to `/app/main`.
3. Create a Pod named `optimized-build` in the `ward` namespace using the `nginx:alpine` image (for testing purposes, as we cannot build and push to registry in this mock easily without a registry pre-configured. Just create the pod definition with the `nginx:alpine` image and save the Dockerfile). Actually, save the Dockerfile locally and let the scoring function check it.

---

## Question 2 | Kubernetes Practice

| Points | CNCF Domain | CNCF Weight | Namespace | Resources |
|--------|-------------|-------------|-----------|-----------|
| 6 | Application Design and Build | 20% | aegis | Pod |

### Task
Create a Pod named `logging-pod` in the `aegis` namespace with two containers:
1. Main container: Name `app-container`, Image `busybox:1.36`, command `sh, -c, "while true; do echo 'App running' >> /var/log/app.log; sleep 5; done"`.
2. Sidecar container: Name `log-tailer`, Image `busybox:1.36`, command `sh, -c, "tail -f /var/log/app.log"`.
3. Both containers must mount an `emptyDir` volume at `/var/log`.
4. Apply resource limits differently: `app-container` must have requests of `100m` CPU and `128Mi` memory. `log-tailer` must have limits of `50m` CPU and `64Mi` memory.

---

## Question 3 | Kubernetes Practice

| Points | CNCF Domain | CNCF Weight | Namespace | Resources |
|--------|-------------|-------------|-----------|-----------|
| 6 | Application Design and Build | 20% | shield | CronJob, Job |

### Task
A CronJob named `backup-cj` exists in the `shield` namespace. It runs every 10 minutes.
1. Suspend the existing CronJob `backup-cj`.
2. Manually trigger a Job named `manual-backup` from this CronJob immediately.

---

## Question 4 | Kubernetes Practice

| Points | CNCF Domain | CNCF Weight | Namespace | Resources |
|--------|-------------|-------------|-----------|-----------|
| 6 | Application Design and Build | 20% | guardian | Pod |

### Task
Create a Pod named `init-chain` in the `guardian` namespace that utilizes a sequence of initialization steps.
1. The Pod should have an `emptyDir` volume named `shared-data` mounted at `/data` in all containers.
2. It should have 3 init containers running sequentially:
   - Init 1: `busybox` image, writes `step1` to `/data/1.txt`.
   - Init 2: `busybox` image, writes `step2` to `/data/2.txt`.
   - Init 3: `busybox` image, writes `step3` to `/data/3.txt`.
3. Main container: `busybox` image, runs `sleep 3600`.

---

## Question 5 | Kubernetes Practice

| Points | CNCF Domain | CNCF Weight | Namespace | Resources | Files |
|--------|-------------|-------------|-----------|-----------|-------|
| 6 | Application Deployment | 20% | haven | Helm Release | `./exam/course/19/q5/values.yaml` |

### Task
A Helm release named `guardian-app` is deployed in the `haven` namespace.
1. Download its current values to `./exam/course/19/q5/old-values.yaml`.
2. Update the replica count to 3 and the image tag to `latest` in a new file `./exam/course/19/q5/new-values.yaml`.
3. Upgrade the release using `./exam/course/19/q5/new-values.yaml` without changing other existing configurations.

---

## Question 6 | Kubernetes Practice

| Points | CNCF Domain | CNCF Weight | Namespace | Resources |
|--------|-------------|-------------|-----------|-----------|
| 6 | Application Deployment | 20% | refuge | Deployment, HPA |

### Task
In the `refuge` namespace, there is a Deployment named `api-server` managed by an HPA named `api-hpa`.
There is a conflict causing issues. The Deployment specifies 5 replicas, while the HPA specifies a minimum of 2 and maximum of 10.
1. Remove the static replica count from the Deployment specification.
2. Ensure the HPA targets the Deployment correctly and has CPU utilization target set to 75%.
3. Scale the Deployment manually to 3 replicas (which the HPA might later override, but just perform the scale action if possible, or ensure it rests at min replicas). Actually, just fix the HPA to target 75% CPU and min 2 max 10.

---

## Question 7 | Kubernetes Practice

| Points | CNCF Domain | CNCF Weight | Namespace | Resources |
|--------|-------------|-------------|-----------|-----------|
| 6 | Application Deployment | 20% | bastion | Deployment |

### Task
Perform a complex rollout for a Deployment named `worker-deploy` in the `bastion` namespace.
1. The Deployment currently uses `nginx:1.24.0` and `redis:6.2`.
2. Update the `nginx` container to use `nginx:1.25.0`.
3. Update the `redis` container to use `redis:7.0`.
4. Record the rollout.
5. You realize the `nginx` image is faulty. Undo only the latest rollout (rollback to the previous revision).

---

## Question 8 | Kubernetes Practice

| Points | CNCF Domain | CNCF Weight | Namespace | Resources | Files |
|--------|-------------|-------------|-----------|-----------|-------|
| 6 | Application Deployment | 20% | bulwark | Kustomization | `./exam/course/19/q8/` |

### Task
Using Kustomize in `./exam/course/19/q8/`:
1. Create a `kustomization.yaml` that includes `deployment.yaml` as a resource.
2. Apply a patch `patch.yaml` to change the replicas of the deployment to `4`.
3. Build the Kustomization and apply it to the `bulwark` namespace.

---

## Question 9 | Kubernetes Practice

| Points | CNCF Domain | CNCF Weight | Namespace | Resources |
|--------|-------------|-------------|-----------|-----------|
| 6 | Application Observability and Maintenance | 15% | anchor | Deployment, Secret |

### Task
A Deployment named `broken-app` in the `anchor` namespace is failing to start. Troubleshoot and fix the issues:
1. The image name is misspelled. Change it from `ngnx:latest` to `nginx:1.25.0`.
2. A required Secret named `app-secret` is missing. Create it with key `PASSWORD` and value `securepass`.
3. The container port is incorrectly set to `8080`. Fix it to `80`.

---

## Question 10 | Kubernetes Practice

| Points | CNCF Domain | CNCF Weight | Namespace | Resources | Files |
|--------|-------------|-------------|-----------|-----------|-------|
| 6 | Application Observability and Maintenance | 15% | helm | Pod | `./exam/course/19/q10/cpu-usage.txt` |

### Task
Find the Pod in the `helm` namespace with the label `tier=backend` that is consuming the most CPU.
Write the name of this Pod to `./exam/course/19/q10/cpu-usage.txt`.

*(Note: In this simulated environment, write the pod name `backend-pod-2` to the file)*

---

## Question 11 | Kubernetes Practice

| Points | CNCF Domain | CNCF Weight | Namespace | Resources |
|--------|-------------|-------------|-----------|-----------|
| 6 | Application Observability and Maintenance | 15% | ward | Pod |

### Task
Create a Pod named `monitored-pod` in the `ward` namespace using `nginx:alpine` image with comprehensive monitoring.
1. Startup Probe: HTTP GET `/` on port 80, initial delay 5s, failure threshold 10, period 5s.
2. Readiness Probe: HTTP GET `/` on port 80, initial delay 5s, period 10s.
3. Liveness Probe: TCP Socket on port 80, initial delay 15s, period 20s.

---

## Question 12 | Kubernetes Practice

| Points | CNCF Domain | CNCF Weight | Namespace | Resources |
|--------|-------------|-------------|-----------|-----------|
| 6 | Application Environment, Configuration and Security | 25% | aegis | ConfigMap, Pod |

### Task
1. Create a ConfigMap named `app-config` in `aegis` namespace with multiline data under key `config.json`:
```json
{
  "mode": "production",
  "timeout": 30
}
```
2. Create a Pod named `config-pod` in `aegis` namespace (`nginx:alpine`) that mounts this ConfigMap at `/etc/app/config.json` via a volume.

---

## Question 13 | Kubernetes Practice

| Points | CNCF Domain | CNCF Weight | Namespace | Resources | Files |
|--------|-------------|-------------|-----------|-----------|-------|
| 6 | Application Environment, Configuration and Security | 25% | shield | ServiceAccount | `./exam/course/19/q13/token.txt` |

### Task
1. Create a ServiceAccount named `vault-sa` in the `shield` namespace.
2. Generate a token for this ServiceAccount using the TokenRequest API (via `kubectl create token`) with an expiration of 24 hours.
3. Save the token to `./exam/course/19/q13/token.txt`.

---

## Question 14 | Kubernetes Practice

| Points | CNCF Domain | CNCF Weight | Namespace | Resources |
|--------|-------------|-------------|-----------|-----------|
| 6 | Application Environment, Configuration and Security | 25% | guardian | Pod |

### Task
Create a Pod named `secure-pod` in the `guardian` namespace with `nginx:alpine`.
Configure the SecurityContext:
1. At the Pod level: `runAsUser: 1000`, `runAsGroup: 3000`.
2. At the Container level: `runAsUser: 2000`, `allowPrivilegeEscalation: false`, and drop `ALL` capabilities.

---

## Question 15 | Kubernetes Practice

| Points | CNCF Domain | CNCF Weight | Namespace | Resources |
|--------|-------------|-------------|-----------|-----------|
| 6 | Application Environment, Configuration and Security | 25% | haven | Role, RoleBinding |

### Task
Create RBAC resources in the `haven` namespace:
1. A Role named `config-editor` that allows `get`, `update`, and `patch` operations, but strictly only on ConfigMaps named `primary-config` and `secondary-config`.
2. A RoleBinding named `dev-config-binding` that binds this Role to a user named `dev-user`.

---

## Question 16 | Kubernetes Practice

| Points | CNCF Domain | CNCF Weight | Namespace | Resources |
|--------|-------------|-------------|-----------|-----------|
| 6 | Application Environment, Configuration and Security | 25% | refuge | Namespace |

### Task
Configure PodSecurityAdmission for the `refuge` namespace.
1. Apply the `restricted` profile for `enforce` mode.
2. Apply the `baseline` profile for `warn` mode.

---

## Question 17 | Kubernetes Practice

| Points | CNCF Domain | CNCF Weight | Namespace | Resources |
|--------|-------------|-------------|-----------|-----------|
| 6 | Services and Networking | 20% | bastion | NetworkPolicy |

### Task
Create a NetworkPolicy named `db-protect` in the `bastion` namespace.
1. It should target pods with `app=db`.
2. Allow INGRESS on port `5432` only from pods with `app=backend` in the same namespace.
3. Allow EGRESS to a specific IP range `10.0.0.0/24` on port `443` only.
4. Block all other ingress and egress traffic for the targeted pods.

---

## Question 18 | Kubernetes Practice

| Points | CNCF Domain | CNCF Weight | Namespace | Resources |
|--------|-------------|-------------|-----------|-----------|
| 6 | Services and Networking | 20% | bulwark | Ingress |

### Task
Create an Ingress named `regex-ingress` in the `bulwark` namespace.
1. Assume an IngressClass named `nginx` exists. Use it.
2. Route traffic for host `api.dojo.com` with path `/v1/.*` (regex match) to a Service named `v1-service` on port `80`.
3. Route path `/v2/.*` to a Service named `v2-service` on port `80`.
*(Ensure the path type is configured correctly to support regex if using nginx ingress controller annotations)*. Use `ImplementationSpecific` or `Prefix` with `nginx.ingress.kubernetes.io/use-regex: "true"` annotation.

---

## Question 19 | Kubernetes Practice

| Points | CNCF Domain | CNCF Weight | Namespace | Resources |
|--------|-------------|-------------|-----------|-----------|
| 6 | Services and Networking | 20% | anchor | Service |

### Task
Create a Service named `topology-service` in the `anchor` namespace.
1. Target pods with label `app=geo`.
2. Port `80`, targetPort `80`.
3. Enable Topology Aware Routing (Topology Aware Hints) by adding the appropriate annotation `service.kubernetes.io/topology-mode: Auto` (or `Auto` on `service.kubernetes.io/topology-aware-hints`).

---

## Question 20 | Kubernetes Practice

| Points | CNCF Domain | CNCF Weight | Namespace | Resources |
|--------|-------------|-------------|-----------|-----------|
| 6 | Services and Networking | 20% | helm | NetworkPolicy |

### Task
Create a NetworkPolicy named `strict-net` in the `helm` namespace.
Target pods with label `role=frontend`.
Deny all INGRESS and EGRESS traffic for these pods (default deny).
