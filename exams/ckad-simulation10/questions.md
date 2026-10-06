# CKAD Exam Simulator - Dojo Oni 👹

> **Total Score**: 102 points | **Passing Score**: ~66% (68 points)
>
> *「鬼の目にも涙」— Even the demon sheds tears*
>
> **Focus**: Debugging and fixing real workloads — the core of the CKAD exam.
>
> **Local Simulator Adaptations**:
>
> | Original | Local Simulator |
> |----------|-----------------|
> | `/opt/course/N/` | `./exam/course/N/` |
> | Original registry | `localhost:5000` |
> | SSH to different instances | Single cluster (no SSH needed) |

---

## Question 1 | Secrets & Environment Variables

| | |
|---|---|
| **Points** | 5 |
| **CNCF Domain** | Application Environment, Configuration and Security |
| **CNCF Weight** | 25% |
| **Namespace** | `fortress` |
| **Resources** | Pod `webapp` |

### Task

A Pod named `webapp` is running in namespace `fortress` with hardcoded database credentials as environment variables.

1. Inspect the Pod to find the current environment variables `DB_USER` and `DB_PASS`
2. Create a Secret named `db-credentials` in namespace `fortress` containing those same key-value pairs
3. Delete the existing Pod and recreate it with the same name, image, and port, but replace the hardcoded environment variables with references to the Secret using `secretKeyRef`

The Pod must be running with the environment variables sourced from the Secret.

---

## Question 2 | Fix a Broken Ingress

| | |
|---|---|
| **Points** | 6 |
| **CNCF Domain** | Services and Networking |
| **CNCF Weight** | 20% |
| **Namespace** | `bastion` |
| **Resources** | Deployment `frontend`, Service `frontend-svc`, Ingress `frontend-ingress` |

### Task

An Ingress named `frontend-ingress` exists in namespace `bastion` but traffic is not reaching the application.

Inspect the existing Service and Ingress, identify the problems, and fix the Ingress so that:

- Host `frontend.example.com` routes to the correct Service
- The path `/` routes traffic correctly
- The `pathType` is set to `Prefix`
- The backend Service name and port match the actual Service

**Hint**: Always inspect the Service first with `kubectl get svc -n bastion` — then match the Ingress backend to the Service name and port. There are multiple errors to fix.

---

## Question 3 | Create a New Ingress

| | |
|---|---|
| **Points** | 5 |
| **CNCF Domain** | Services and Networking |
| **CNCF Weight** | 20% |
| **Namespace** | `citadel` |
| **Resources** | Deployment `api-server`, Service `api-svc` |

### Task

A Deployment `api-server` and Service `api-svc` already exist in namespace `citadel`.

Create an Ingress named `api-ingress` in namespace `citadel` that:

1. Routes traffic for host `api.example.com`
2. Routes path `/app` with `pathType: Prefix`
3. Sends traffic to Service `api-svc` on port `80`

---

## Question 4 | NetworkPolicy — Label Pods for Communication

| | |
|---|---|
| **Points** | 6 |
| **CNCF Domain** | Services and Networking |
| **CNCF Weight** | 20% |
| **Namespace** | `rampart` |
| **Resources** | Pods `frontend`, `backend`, `database`; NetworkPolicies `default-deny`, `allow-frontend-to-backend`, `allow-backend-to-db` |

### Task

Three Pods (`frontend`, `backend`, `database`) exist in namespace `rampart` but cannot communicate with each other.

Three NetworkPolicies are already configured. **Do NOT modify the NetworkPolicies.**

Instead:

1. Inspect the NetworkPolicies to understand which label selectors they use
2. Label the Pods correctly so that:
   - `frontend` can send traffic to `backend` on port 80
   - `backend` can send traffic to `database` on port 5432

**Hint**: Use `kubectl describe networkpolicy -n rampart` to read the pod selectors and ingress `from` selectors. The labels you need to apply are written in the policies themselves.

---

## Question 5 | Resource Requests and Limits

| | |
|---|---|
| **Points** | 5 |
| **CNCF Domain** | Application Environment, Configuration and Security |
| **CNCF Weight** | 25% |
| **Namespace** | `tower` |
| **Resources** | Deployment `compute-app` |

### Task

A Deployment named `compute-app` exists in namespace `tower` without resource settings.

Update the Deployment so that its container has:

- **Requests**: `cpu: 100m`, `memory: 128Mi`
- **Limits**: exactly **double** the requests — `cpu: 200m`, `memory: 256Mi`

The Deployment must have running Pods after the update.

---

## Question 6 | Fix ResourceQuota Issue

| | |
|---|---|
| **Points** | 5 |
| **CNCF Domain** | Application Environment, Configuration and Security |
| **CNCF Weight** | 25% |
| **Namespace** | `garrison` |
| **Resources** | ResourceQuota `compute-quota`, Deployment `quota-app` |

### Task

A Deployment named `quota-app` in namespace `garrison` has Pods stuck in `Pending` state because its resource requests exceed the namespace's ResourceQuota.

1. Inspect the ResourceQuota `compute-quota` to understand the limits
2. Reduce the Deployment's resource **requests** so the Pods can be scheduled within the quota
3. Keep resource **limits** at double the requests

The ResourceQuota allows: `requests.cpu: 500m`, `requests.memory: 512Mi`.

**Note**: The quota also enforces `limits.cpu: 1` and `limits.memory: 1Gi`. Both requests and limits must fit within the quota for Pods to be scheduled.

---

## Question 7 | Docker Image Build and Save

| | |
|---|---|
| **Points** | 5 |
| **CNCF Domain** | Application Design and Build |
| **CNCF Weight** | 20% |
| **Namespace** | N/A (local task) |
| **Resources** | Dockerfile at `./exam/course/7/image/Dockerfile` |

### Task

1. Build a Docker image using `./exam/course/7/image/` as build context
2. Tag the image as `localhost:5000/oni-app:1.0`
3. Save the image as a tar archive to `./exam/course/7/oni-app.tar`
4. Push the image to the local registry at `localhost:5000`

---

## Question 8 | Canary Deployment

| | |
|---|---|
| **Points** | 6 |
| **CNCF Domain** | Application Deployment |
| **CNCF Weight** | 20% |
| **Namespace** | `bulwark` |
| **Resources** | Deployment `stable-app`, Service `app-svc` |

### Task

A stable Deployment `stable-app` with 3 replicas is running in namespace `bulwark` with label `version=v1` and `app=webapp`.

A Service `app-svc` selects Pods with label `app=webapp` (both versions).

Create a **canary** Deployment named `canary-app` in namespace `bulwark` with:

- **1 replica**
- Image `nginx:1.25`
- Labels: `app=webapp` and `version=v2`
- The Service should automatically route traffic to both stable and canary Pods

**Hint**: The Service selects on `app=webapp` only. Your canary Deployment must use the same `app=webapp` label so the Service routes to both versions. The `version` label differentiates but does not affect routing.

---

## Question 9 | Fix Service Selector Mismatch

| | |
|---|---|
| **Points** | 4 |
| **CNCF Domain** | Services and Networking |
| **CNCF Weight** | 20% |
| **Namespace** | `parapet` |
| **Resources** | Deployment `backend`, Service `backend-svc` |

### Task

A Service `backend-svc` exists in namespace `parapet` but has no endpoints — traffic is not reaching the Pods.

1. Identify the selector mismatch between the Service and the Deployment's Pod labels
2. Fix the Service selector so it matches the actual Pod labels
3. Verify with `kubectl get endpoints backend-svc -n parapet`

**Hint**: Run `kubectl get endpoints` — if it shows `<none>`, the selector does not match any Pod labels.

---

## Question 10 | CronJob with Proper Exit

| | |
|---|---|
| **Points** | 5 |
| **CNCF Domain** | Application Design and Build |
| **CNCF Weight** | 20% |
| **Namespace** | `stronghold` |
| **Resources** | None (create from scratch) |

### Task

Create a CronJob named `cleanup-job` in namespace `stronghold`:

- Schedule: every 5 minutes (`*/5 * * * *`)
- Image: `busybox:1.36`
- Command: `echo "Cleanup completed at $(date)"`
- The Job must **exit after completion** — set `activeDeadlineSeconds: 30`
- Restart policy: `Never`

**Hint**: `activeDeadlineSeconds` goes in the **Job template spec** (`spec.jobTemplate.spec.activeDeadlineSeconds`), not at the CronJob level. Placing it at the wrong level is a common mistake.

---

## Question 11 | SecurityContext — Merge Settings

| | |
|---|---|
| **Points** | 5 |
| **CNCF Domain** | Application Environment, Configuration and Security |
| **CNCF Weight** | 25% |
| **Namespace** | `fortress` |
| **Resources** | Deployment `secure-app` |

### Task

A Deployment named `secure-app` in namespace `fortress` already has the following security settings on its container:

- `readOnlyRootFilesystem: true`
- `allowPrivilegeEscalation: false`

Add `runAsUser: 10000` to the security context **without removing or modifying** the existing settings.

The Deployment must have running Pods after the update.

**Note**: When editing YAML in-place, be careful not to accidentally delete existing fields. The scoring verifies all three security settings are present.

---

## Question 12 | RBAC — Fix Forbidden Error

| | |
|---|---|
| **Points** | 7 |
| **CNCF Domain** | Application Environment, Configuration and Security |
| **CNCF Weight** | 25% |
| **Namespace** | `bastion` |
| **Resources** | Deployment `pod-reader`, ServiceAccount `pod-reader-sa` |

### Task

The Deployment `pod-reader` in namespace `bastion` uses ServiceAccount `pod-reader-sa`. The application logs show:

```
forbidden: User "system:serviceaccount:bastion:pod-reader-sa" cannot list resource "pods" in API group "" in the namespace "bastion"
```

Fix this by:

1. Creating a Role named `pod-reader-role` that allows `get`, `list`, and `watch` on `pods` in namespace `bastion`
2. Creating a RoleBinding named `pod-reader-binding` that binds the Role to ServiceAccount `pod-reader-sa`
3. Verify the Deployment can now list pods (the error should disappear from new Pod logs)

**Hint**: The error message tells you exactly what permission is missing. Read it carefully: the resource, the verb, and the namespace are all specified.

---

## Question 13 | Deployment Rollback

| | |
|---|---|
| **Points** | 5 |
| **CNCF Domain** | Application Deployment |
| **CNCF Weight** | 20% |
| **Namespace** | `citadel` |
| **Resources** | Deployment `web-server` |

### Task

The Deployment `web-server` in namespace `citadel` was recently updated with a broken image and Pods are failing.

1. Check the rollout history to find the previous working revision
2. Roll back the Deployment to the **last working revision** (the one with `nginx:1.25`)
3. Verify the rollback was successful and Pods are running

Save the rollout history output to `./exam/course/13/rollout-history.txt`.

---

## Question 14 | Fix Deprecated API Version

| | |
|---|---|
| **Points** | 4 |
| **CNCF Domain** | Application Observability and Maintenance |
| **CNCF Weight** | 15% |
| **Namespace** | `rampart` |
| **Resources** | Manifest at `./exam/course/14/broken-deploy.yaml` |

### Task

The manifest file `./exam/course/14/broken-deploy.yaml` contains:

- A **deprecated API version** (`extensions/v1beta1` instead of `apps/v1`)
- A **deprecated field** (`spec.rollbackTo`)

Fix the manifest:

1. Update the `apiVersion` to `apps/v1`
2. Remove the deprecated `spec.rollbackTo` field
3. Add the required `spec.selector.matchLabels` field (must match the Pod template labels)
4. Apply the fixed manifest to namespace `rampart`

**Note**: The `extensions/v1beta1` API for Deployments was removed in Kubernetes 1.16. Migrating to `apps/v1` also requires a `spec.selector` field.

---

## Question 15 | Troubleshoot Failing Deployment

| | |
|---|---|
| **Points** | 5 |
| **CNCF Domain** | Application Observability and Maintenance |
| **CNCF Weight** | 15% |
| **Namespace** | `tower` |
| **Resources** | Deployment `health-app` |

### Task

A Deployment named `health-app` in namespace `tower` has Pods in `CrashLoopBackOff` state.

1. Investigate why the Pods are failing
2. Fix the issue
3. Ensure the Deployment has running Pods

Save the root cause description to `./exam/course/15/root-cause.txt`.

---

## Question 16 | ConfigMap as Environment Variables

| | |
|---|---|
| **Points** | 5 |
| **CNCF Domain** | Application Environment, Configuration and Security |
| **CNCF Weight** | 25% |
| **Namespace** | `gate` |
| **Resources** | None (create from scratch) |

### Task

1. Create a ConfigMap named `app-config` in namespace `gate` with:
   - `APP_ENV=production`
   - `APP_DEBUG=false`

2. Create a Pod named `config-app` in namespace `gate`:
   - Image: `nginx:1.25`
   - Use `envFrom` to load **all** keys from the ConfigMap `app-config` as environment variables

---

## Question 17 | Create ClusterIP Service

| | |
|---|---|
| **Points** | 4 |
| **CNCF Domain** | Services and Networking |
| **CNCF Weight** | 20% |
| **Namespace** | `gate` |
| **Resources** | Deployment `backend-app` |

### Task

A Deployment named `backend-app` is running in namespace `gate` with container port `80`.

Create a ClusterIP Service named `backend-svc` in namespace `gate` that:

- Exposes port `80`
- Targets port `80`
- Routes traffic to the `backend-app` Pods

Verify the Service has endpoints.

---

## Question 18 | Job with Completions and Parallelism

| | |
|---|---|
| **Points** | 5 |
| **CNCF Domain** | Application Design and Build |
| **CNCF Weight** | 20% |
| **Namespace** | `bulwark` |
| **Resources** | None (create from scratch) |

### Task

Create a Job named `batch-processor` in namespace `bulwark`:

- Image: `busybox:1.36`
- Command: `echo "Processing batch item"`
- Completions: `6` (6 total items to process)
- Parallelism: `2` (2 items processed at a time)
- Restart policy: `Never`

---

## Question 19 | Deployment Rolling Update Strategy

| | |
|---|---|
| **Points** | 5 |
| **CNCF Domain** | Application Deployment |
| **CNCF Weight** | 20% |
| **Namespace** | `parapet` |
| **Resources** | Deployment `rolling-app` |

### Task

A Deployment named `rolling-app` exists in namespace `parapet`.

Configure the Deployment's update strategy to use **RollingUpdate** with:

- `maxSurge: 1`
- `maxUnavailable: 0`

This ensures zero-downtime deployments. The Deployment must have running Pods after the update.

---

## Question 20 | Multi-container Pod with Shared Volume

| | |
|---|---|
| **Points** | 5 |
| **CNCF Domain** | Application Design and Build |
| **CNCF Weight** | 20% |
| **Namespace** | `stronghold` |
| **Resources** | Template at `./exam/course/20/sidecar-pod.yaml` |

### Task

Using the template at `./exam/course/20/sidecar-pod.yaml`, create a multi-container Pod named `logger-app` in namespace `stronghold`:

1. The **main** container `app` uses image `busybox:1.36` and writes logs:
   - Command: `sh -c "while true; do echo \"$(date) - App running\" >> /var/log/app.log; sleep 5; done"`
   - Mounts volume `shared-logs` at `/var/log`

2. Add a **sidecar** container named `log-reader` using image `busybox:1.36`:
   - Command: `sh -c "tail -f /var/log/app.log"`
   - Mounts the same volume `shared-logs` at `/var/log`

3. The volume `shared-logs` is of type `emptyDir`
