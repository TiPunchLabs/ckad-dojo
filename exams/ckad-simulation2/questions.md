# CKAD Exam Simulator - Dojo Byakko 🐯

> **Total Score**: 105 points | **Passing Score**: ~66% (69 points)
>
> *「白虎は精密に打つ」 - Le tigre frappe avec précision*
>
> **Local Simulator Adaptations**:
>
> | Original                   | Local Simulator                |
> | -------------------------- | ------------------------------ |
> | `/opt/course/N/`         | `./exam/course/N/`           |
> | Original registry          | `localhost:5000`             |
> | SSH to different instances | Single cluster (no SSH needed) |

---

## Question 1 | Pod with Anti-Affinity (6%)

|                     |                    |
| ------------------- | ------------------ |
| **Points**    | 6                  |
| **CNCF Domain** | Application Design and Build |
| **CNCF Weight** | 20% |
| **Namespace** | `zeus`           |
| **Resources** | Pod `titan-alpha`|

### Task

Create a Pod named `titan-alpha` in namespace `zeus` with the following specifications:

- Image: `nginx:1.21`
- Add a label `app=titan`
- Configure **pod anti-affinity** to prefer not scheduling on nodes that already have pods with label `app=titan`

The anti-affinity should use `preferredDuringSchedulingIgnoredDuringExecution` with weight `100` and topology key `kubernetes.io/hostname`.

---

## Question 2 | ConfigMap from Multiple Sources (5%)

|                     |                                                 |
| ------------------- | ----------------------------------------------- |
| **Points**    | 5                                               |
| **CNCF Domain** | Application Environment, Configuration & Security |
| **CNCF Weight** | 25% |
| **Namespace** | `athena`                                      |
| **Resources** | ConfigMap `app-config`, Pod `config-reader` |

### Task

In namespace `athena`:

1. Create a ConfigMap named `app-config` with:
   - A literal key `LOG_LEVEL=debug`
   - A literal key `MAX_CONNECTIONS=100`

2. Create a Pod named `config-reader` using image `busybox:1.36` that:
   - Mounts the ConfigMap as a volume at `/etc/config`
   - Runs command `sleep 3600`
   - Container name: `reader`

---

## Question 3 | ExternalName Service (4%)

|                     |                          |
| ------------------- | ------------------------ |
| **Points**    | 4                        |
| **CNCF Domain** | Services and Networking |
| **CNCF Weight** | 20% |
| **Namespace** | `hermes`               |
| **Resources** | Service `external-api` |

### Task

Create a Service of type `ExternalName` in namespace `hermes`:

- Name: `external-api`
- External name: `api.external-service.com`

This service should allow pods in the namespace to access the external API using the internal DNS name `external-api.hermes.svc.cluster.local`.

---

## Question 4 | LimitRange Configuration (6%)

|                     |                                               |
| ------------------- | --------------------------------------------- |
| **Points**    | 6                                             |
| **CNCF Domain** | Application Environment, Configuration & Security |
| **CNCF Weight** | 25% |
| **Namespace** | `apollo`                                    |
| **Resources** | LimitRange `resource-limits`, Pod `limited-pod` |

### Task

In namespace `apollo`:

1. Create a LimitRange named `resource-limits` with the following constraints for containers:
   - Default CPU limit: `500m`
   - Default memory limit: `256Mi`
   - Default CPU request: `100m`
   - Default memory request: `64Mi`

2. Create a Pod named `limited-pod` with image `nginx:1.21` (without specifying any resource requests/limits) to verify the defaults are applied.
   - Container name: `app`

---

## Question 5 | SecurityContext - Read-Only Root Filesystem (5%)

|                     |                    |
| ------------------- | ------------------ |
| **Points**    | 5                  |
| **CNCF Domain** | Application Environment, Configuration & Security |
| **CNCF Weight** | 25% |
| **Namespace** | `hades`          |
| **Resources** | Pod `secure-app` |

### Task

Create a Pod named `secure-app` in namespace `hades` with:

- Image: `nginx:1.21`
- Container name: `nginx`
- Read-only root filesystem enabled
- A writable emptyDir volume mounted at `/tmp`
- A writable emptyDir volume mounted at `/var/cache/nginx`
- A writable emptyDir volume mounted at `/var/run`

The pod should be able to run nginx successfully despite the read-only root filesystem.

---

## Question 6 | Pod with Multiple Init Containers (6%)

|                     |                   |
| ------------------- | ----------------- |
| **Points**    | 6                 |
| **CNCF Domain** | Application Design and Build |
| **CNCF Weight** | 20% |
| **Namespace** | `poseidon`      |
| **Resources** | Pod `multi-init`|

### Task

Create a Pod named `multi-init` in namespace `poseidon` with:

- Main container: `app` using image `nginx:1.21`
- Init container 1: `init-config` using image `busybox:1.36` that creates file `/work/config.txt` with content `initialized`
- Init container 2: `init-permissions` using image `busybox:1.36` that runs `chmod 644 /work/config.txt`

All containers should share an emptyDir volume named `workdir` mounted at `/work`.

---

## Question 7 | Deployment with Pause/Resume (5%)

|                          |                                       |
| ------------------------ | ------------------------------------- |
| **Points**         | 5                                     |
| **CNCF Domain**    | Application Deployment                |
| **CNCF Weight**    | 20%                                   |
| **Namespace**      | `ares`                              |
| **Resources**      | Deployment `battle-app`             |
| **File to create** | `./exam/course/7/rollout-status.txt`|

### Task

A Deployment named `battle-app` exists in namespace `ares` with 3 replicas using image `nginx:1.20`.

1. Update the image to `nginx:1.21`
2. Immediately **pause** the rollout after starting the update
3. Save the rollout status to `./exam/course/7/rollout-status.txt`

**Hint**: Use `kubectl rollout pause` and `kubectl rollout status`.

---

## Question 8 | Ambassador Pattern - Sidecar Proxy (7%)

|                     |                       |
| ------------------- | --------------------- |
| **Points**    | 7                     |
| **CNCF Domain** | Application Design and Build |
| **CNCF Weight** | 20% |
| **Namespace** | `olympus`           |
| **Resources** | Pod `ambassador-pod`|

### Task

Create a Pod named `ambassador-pod` in namespace `olympus` with an ambassador pattern:

- Main container `app`: image `nginx:1.21`, exposes port 80
- Sidecar container `proxy`: image `envoyproxy/envoy:v1.28-latest`
  - Add environment variable `ENVOY_UID=0`

Both containers should be in the same Pod to share the network namespace.

**Note**: This demonstrates the ambassador pattern where a proxy container handles external communication.

---

## Question 9 | Job with Backoff Limit (5%)

|                     |                  |
| ------------------- | ---------------- |
| **Points**    | 5                |
| **CNCF Domain** | Application Design and Build |
| **CNCF Weight** | 20% |
| **Namespace** | `artemis`      |
| **Resources** | Job `retry-job`|

### Task

Create a Job named `retry-job` in namespace `artemis` with:

- Image: `busybox:1.36`
- Command: `sh -c "exit 1"` (simulates failure)
- Backoff limit: `3`
- Restart policy: `Never`

The job should attempt to run 3 times before being marked as failed.

---

## Question 10 | Secret Types - Docker Registry (6%)

|                     |                                                   |
| ------------------- | ------------------------------------------------- |
| **Points**    | 6                                                 |
| **CNCF Domain** | Application Environment, Configuration & Security |
| **CNCF Weight** | 25% |
| **Namespace** | `hera`                                          |
| **Resources** | Secret `registry-creds`, Pod `private-app`    |

### Task

In namespace `hera`:

1. Create a docker-registry Secret named `registry-creds` with:
   - Docker server: `docker.io`
   - Username: `myuser`
   - Password: `mypassword`
   - Email: `user@example.com`

2. Create a Pod named `private-app` with image `nginx:1.21` that uses this secret as an `imagePullSecret`.
   - Container name: `app`

---

## Question 11 | Adapter Pattern - Log Transformer (6%)

|                     |                    |
| ------------------- | ------------------ |
| **Points**    | 6                  |
| **CNCF Domain** | Application Design and Build |
| **CNCF Weight** | 20% |
| **Namespace** | `zeus`           |
| **Resources** | Pod `adapter-pod`|

### Task

Create a Pod named `adapter-pod` in namespace `zeus` implementing the adapter pattern:

- Main container `app`: image `busybox:1.36`, command `sh -c "while true; do echo $(date): log message >> /var/log/app.log; sleep 5; done"`
- Adapter container `log-adapter`: image `busybox:1.36`, command `sh -c "tail -f /var/log/app.log | sed 's/^/[ADAPTED] /'"`

Both containers share an emptyDir volume named `logs` mounted at `/var/log`.

---

## Question 12 | Network Policy - Egress Rules (5%)

|                     |                              |
| ------------------- | ---------------------------- |
| **Points**    | 5                            |
| **CNCF Domain** | Services and Networking |
| **CNCF Weight** | 20% |
| **Namespace** | `athena`                   |
| **Resources** | NetworkPolicy `egress-policy`|

### Task

Create a NetworkPolicy named `egress-policy` in namespace `athena` that:

- Applies to pods with label `app=restricted`
- Allows egress traffic only to:
  - Pods with label `app=database` on port 5432
  - External IP block `10.0.0.0/8` on port 443

Deny all other egress traffic.

---

## Question 13 | RBAC - Service Account Permissions (6%)

|                     |                                                                 |
| ------------------- | --------------------------------------------------------------- |
| **Points**    | 6                                                               |
| **CNCF Domain** | Application Environment, Configuration & Security |
| **CNCF Weight** | 25% |
| **Namespace** | `hermes`                                                      |
| **Resources** | ServiceAccount `deployment-manager`, Role, RoleBinding      |

### Task

In namespace `hermes`:

1. Create a ServiceAccount named `deployment-manager`
2. Create a Role named `deploy-role` that allows:
   - `get`, `list`, `watch`, `create`, `update`, `delete` on Deployments
   - `get`, `list` on Pods
3. Create a RoleBinding named `deploy-binding` to bind the role to the service account

---

## Question 14 | Deployment Rolling Update Strategy (5%)

|                     |                        |
| ------------------- | ---------------------- |
| **Points**    | 5                      |
| **CNCF Domain** | Application Deployment |
| **CNCF Weight** | 20% |
| **Namespace** | `apollo`             |
| **Resources** | Deployment `rolling-app`|

### Task

Create a Deployment named `rolling-app` in namespace `apollo` with:

- Image: `nginx:1.21`
- Replicas: `4`
- Container name: `web`
- Rolling update strategy with:
  - Max surge: `25%`
  - Max unavailable: `1`
- Add label `version=v1` to pod template

---

## Question 15 | Ingress with Path-Based Routing (6%)

|                     |                        |
| ------------------- | ---------------------- |
| **Points**    | 6                      |
| **CNCF Domain** | Services and Networking |
| **CNCF Weight** | 20% |
| **Namespace** | `poseidon`           |
| **Resources** | Ingress `path-ingress`|

### Task

Create an Ingress named `path-ingress` in namespace `poseidon` that:

- Routes `/api` to service `api-svc` on port 8080
- Routes `/web` to service `web-svc` on port 80
- Uses pathType `Prefix` for both paths

**Note**: Pre-existing services `api-svc` and `web-svc` are already created.

---

## Question 16 | Pod with Token Projection (5%)

|                     |                   |
| ------------------- | ----------------- |
| **Points**    | 5                 |
| **CNCF Domain** | Application Environment, Configuration & Security |
| **CNCF Weight** | 25% |
| **Namespace** | `hades`         |
| **Resources** | Pod `token-pod` |

### Task

Create a Pod named `token-pod` in namespace `hades` with:

- Image: `nginx:1.21`
- Container name: `app`
- A projected volume named `token-volume` containing:
  - ServiceAccount token with audience `api` and expiration `3600` seconds
  - Mounted at `/var/run/secrets/tokens`

---

## Question 17 | CronJob with Concurrency Policy (5%)

|                     |                        |
| ------------------- | ---------------------- |
| **Points**    | 5                      |
| **CNCF Domain** | Application Design and Build |
| **CNCF Weight** | 20% |
| **Namespace** | `ares`               |
| **Resources** | CronJob `scheduled-task`|

### Task

Create a CronJob named `scheduled-task` in namespace `ares` with:

- Schedule: `*/5 * * * *` (every 5 minutes)
- Image: `busybox:1.36`
- Command: `echo "Task executed at $(date)"`
- Concurrency policy: `Forbid`
- Successful jobs history limit: `3`
- Failed jobs history limit: `1`

---

## Question 18 | Pod Disruption Budget (4%)

|                     |                    |
| ------------------- | ------------------ |
| **Points**    | 4                  |
| **CNCF Domain** | Application Deployment |
| **CNCF Weight** | 20% |
| **Namespace** | `hera`           |
| **Resources** | PDB `app-pdb`    |

### Task

Create a PodDisruptionBudget named `app-pdb` in namespace `hera` that:

- Selects pods with label `app=critical`
- Ensures at least `2` pods are always available during voluntary disruptions

---

## Question 19 | Deployment with Annotations (4%)

|                     |                          |
| ------------------- | ------------------------ |
| **Points**    | 4                        |
| **CNCF Domain** | Application Deployment |
| **CNCF Weight** | 20% |
| **Namespace** | `olympus`              |
| **Resources** | Deployment `annotated-app`|

### Task

Create a Deployment named `annotated-app` in namespace `olympus` with:

- Image: `nginx:1.21`
- Replicas: `2`
- Container name: `web`
- Add annotation `kubernetes.io/change-cause: "Initial deployment"` to the deployment
- Add annotation `prometheus.io/scrape: "true"` to the pod template

---

## Question 20 | Multi-Container Pod with Shared Process Namespace (5%)

|                     |                    |
| ------------------- | ------------------ |
| **Points**    | 5                  |
| **CNCF Domain** | Application Design and Build |
| **CNCF Weight** | 20% |
| **Namespace** | `artemis`        |
| **Resources** | Pod `shared-pid` |

### Task

Create a Pod named `shared-pid` in namespace `artemis` with:

- Enable `shareProcessNamespace: true`
- Container 1 `app`: image `nginx:1.21`
- Container 2 `debug`: image `busybox:1.36`, command `sleep 3600`

The debug container should be able to see processes from the app container using `ps aux`.

---
