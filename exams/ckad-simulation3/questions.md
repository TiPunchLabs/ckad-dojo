# CKAD Exam Simulator - Dojo Byakko 🐯

> **Total Score**: 105 points | **Passing Score**: ~66% (69 points)
>
> *「白虎は精密に狩る」 - Le tigre blanc chasse avec précision*
>
> **Local Simulator Adaptations**:
>
> | Original | Local Simulator |
> |----------|-----------------|
> | `/opt/course/N/` | `./exam/course/N/` |
> | Original registry | `localhost:5000` |
> | SSH to different instances | Single cluster (no SSH needed) |

---

## Question 1 | kubectl explain

| | |
|---|---|
| **Points** | 2 |
| **Namespace** | - |
| **File to create** | `./exam/course/1/pod-spec-fields.txt` |

### Task

Use `kubectl explain` to explore the Kubernetes API documentation.

1. Find the **full path** to document the `containers` field under Pod spec
2. Save the complete documentation output for `pod.spec.containers.resources` to `./exam/course/1/pod-spec-fields.txt`

The output should show all available sub-fields and their descriptions.

---

## Question 2 | Pod Anti-Affinity

| | |
|---|---|
| **Points** | 7 |
| **Namespace** | `tiger` |
| **Resources** | Deployment `spread-pods` |

### Task

Create a **Deployment** named `spread-pods` in namespace `tiger` with:

| Configuration | Value |
|---------------|-------|
| Image | `nginx:1.21` |
| Replicas | `3` |
| Container name | `web` |
| Labels | `app: spread-pods` |

Configure **requiredDuringSchedulingIgnoredDuringExecution** pod anti-affinity to ensure:

- Pods are scheduled on **different nodes** (topology key: `kubernetes.io/hostname`)
- Anti-affinity matches pods with label `app: spread-pods`

**Note**: If the cluster has fewer nodes than replicas, some pods may remain Pending. This is expected behavior.

---

## Question 3 | Blue-Green Deployment

| | |
|---|---|
| **Points** | 7 |
| **Namespace** | `stripe` |
| **Resources** | Deployment `stable-green`, Service `web-service` |

### Task

A Deployment named `stable-blue` already exists in namespace `stripe` with its corresponding Service `web-service`.

Implement a **Blue-Green deployment switch**:

1. Create a new Deployment named `stable-green`:
   - Image: `nginx:1.22`
   - Replicas: 3
   - Labels: `app: web-app`, `version: green`

2. Update the Service `web-service` to route **all traffic** to the green deployment
   - Change the selector to match `version: green`

3. Verify the switch is complete by ensuring green pods receive traffic

**Note**: Blue-Green differs from Canary - it's a complete switch, not gradual.

---

## Question 4 | CronJob Advanced

| | |
|---|---|
| **Points** | 6 |
| **Namespace** | `prowl` |
| **Resources** | CronJob `data-sync` |

### Task

A CronJob named `data-sync` exists in namespace `prowl`. Modify it with the following settings:

| Configuration | Value |
|---------------|-------|
| **suspend** | `true` (pause the CronJob) |
| **startingDeadlineSeconds** | `200` |
| **concurrencyPolicy** | `Forbid` |

After making changes, **resume** the CronJob by setting `suspend: false`.

The CronJob should now:

- Never run concurrent jobs
- Have a 200-second deadline window
- Be actively scheduling

---

## Question 5 | Immutable ConfigMap

| | |
|---|---|
| **Points** | 4 |
| **Namespace** | `hunt` |
| **Resources** | ConfigMap `locked-config` |

### Task

Create a **ConfigMap** named `locked-config` in namespace `hunt` that:

1. Contains the following data:

   | Key | Value |
   |-----|-------|
   | `DB_HOST` | `postgres.hunt.svc` |
   | `DB_PORT` | `5432` |
   | `LOG_LEVEL` | `info` |

2. Is **immutable** (cannot be modified after creation)

**Hint**: Use the `immutable: true` field.

---

## Question 6 | Projected Volume

| | |
|---|---|
| **Points** | 6 |
| **Namespace** | `hunt` |
| **Resources** | Pod `config-aggregator` |

### Task

A ServiceAccount `hunt-sa` and ConfigMap `app-config` already exist in namespace `hunt`.

Create a **Pod** named `config-aggregator` that uses a **projected volume** combining:

1. **ServiceAccount token** with 1 hour expiration (3600 seconds)
2. The existing **ConfigMap** `app-config`

| Configuration | Value |
|---------------|-------|
| Image | `busybox:1.36` |
| Command | `["sleep", "3600"]` |
| Container name | `aggregator` |
| Volume name | `combined-config` |
| Mount path | `/etc/config` |

The projected volume should expose both the token and ConfigMap at the same mount path.

---

## Question 7 | PodDisruptionBudget

| | |
|---|---|
| **Points** | 6 |
| **Namespace** | `jungle` |
| **Resources** | PodDisruptionBudget `critical-pdb` |

### Task

A Deployment named `critical-app` with 5 replicas exists in namespace `jungle`.

Create a **PodDisruptionBudget** named `critical-pdb` that:

1. Targets pods with label `app: critical-app`
2. Ensures **at least 3 pods** are always available during voluntary disruptions
3. Uses `minAvailable: 3`

Verify the PDB is correctly applied with `kubectl get pdb`.

---

## Question 8 | Service ExternalName

| | |
|---|---|
| **Points** | 4 |
| **Namespace** | `fang` |
| **Resources** | Service `external-api` |

### Task

Create an **ExternalName Service** named `external-api` in namespace `fang` that:

1. Type: `ExternalName`
2. Points to external hostname: `api.external-service.com`

This allows pods to access the external service using the internal DNS name `external-api.fang.svc.cluster.local`.

---

## Question 9 | LimitRange

| | |
|---|---|
| **Points** | 5 |
| **Namespace** | `pounce` |
| **Resources** | LimitRange `container-limits` |

### Task

Create a **LimitRange** named `container-limits` in namespace `pounce` that sets:

**Default limits for containers:**

| Resource | Default | Default Request |
|----------|---------|-----------------|
| CPU | `500m` | `100m` |
| Memory | `256Mi` | `64Mi` |

**Min/Max constraints:**

| Resource | Min | Max |
|----------|-----|-----|
| CPU | `50m` | `1` |
| Memory | `32Mi` | `512Mi` |

---

## Question 10 | Pod Security Context

| | |
|---|---|
| **Points** | 7 |
| **Namespace** | `stalker` |
| **Resources** | Pod `secure-pod` |

### Task

Create a **Pod** named `secure-pod` in namespace `stalker` with comprehensive security settings:

| Configuration | Value |
|---------------|-------|
| Image | `nginx:1.21` |
| Container name | `secure-nginx` |

**Pod-level security context:**

| Setting | Value |
|---------|-------|
| `runAsUser` | `1000` |
| `runAsGroup` | `3000` |
| `fsGroup` | `2000` |

**Container-level security context:**

| Setting | Value |
|---------|-------|
| `readOnlyRootFilesystem` | `true` |
| `allowPrivilegeEscalation` | `false` |

Add an **emptyDir** volume mounted at `/tmp` to allow the container to write temporary files.

---

## Question 11 | Deployment Rollout Control

| | |
|---|---|
| **Points** | 5 |
| **Namespace** | `pounce` |
| **Resources** | Deployment `rolling-app` |

### Task

A Deployment named `rolling-app` exists in namespace `pounce`.

1. **Pause** the deployment rollout
2. Update the image to `nginx:1.22`
3. Set `revisionHistoryLimit` to `5`
4. **Resume** the rollout

Verify the rollout completes successfully with `kubectl rollout status`.

---

## Question 12 | kubectl exec Troubleshooting

| | |
|---|---|
| **Points** | 4 |
| **Namespace** | `stalker` |
| **Resources** | Pod `config-pod` |
| **File to create** | `./exam/course/12/nginx-config.txt` |

### Task

A Pod named `config-pod` exists in namespace `stalker` running nginx with a custom configuration.

1. Use `kubectl exec` to read the content of `/etc/nginx/conf.d/custom.conf` inside the container
2. Save the configuration content to `./exam/course/12/nginx-config.txt`
3. Verify nginx is listening on port **8080** by running `curl localhost:8080` inside the container

---

## Question 13 | Resource Metrics

| | |
|---|---|
| **Points** | 3 |
| **Namespace** | `jungle` |
| **File to create** | `./exam/course/13/pod-resources.txt` |

### Task

Use `kubectl top` to analyze resource usage:

1. Get the CPU and memory usage of all pods in namespace `jungle`
2. Save the output to `./exam/course/13/pod-resources.txt`
3. Identify the pod consuming the most **CPU** and write its name to `./exam/course/13/top-cpu-pod.txt`

**Note**: If metrics-server is not available, the command will show an error. Document this in the file.

---

## Question 14 | Downward API

| | |
|---|---|
| **Points** | 6 |
| **Namespace** | `claw` |
| **Resources** | Pod `metadata-pod` |

### Task

Create a **Pod** named `metadata-pod` in namespace `claw` that exposes pod metadata as environment variables:

| Env Variable | Source Field |
|--------------|--------------|
| `POD_NAME` | `metadata.name` |
| `POD_NAMESPACE` | `metadata.namespace` |
| `POD_IP` | `status.podIP` |
| `NODE_NAME` | `spec.nodeName` |

| Configuration | Value |
|---------------|-------|
| Image | `busybox:1.36` |
| Command | `["sh", "-c", "env | grep POD && env | grep NODE && sleep 3600"]` |
| Container name | `info` |

---

## Question 15 | Job TTL

| | |
|---|---|
| **Points** | 5 |
| **Namespace** | `stripe` |
| **Resources** | Job `cleanup-job` |

### Task

Create a **Job** named `cleanup-job` in namespace `stripe` that:

| Configuration | Value |
|---------------|-------|
| Image | `busybox:1.36` |
| Command | `["sh", "-c", "echo 'Cleanup complete' && sleep 5"]` |
| Container name | `cleanup` |
| `ttlSecondsAfterFinished` | `60` |
| `backoffLimit` | `2` |

The Job should automatically delete itself **60 seconds** after completion.

---

## Question 16 | Container Capabilities

| | |
|---|---|
| **Points** | 6 |
| **Namespace** | `predator` |
| **Resources** | Pod `hardened-pod` |

### Task

Create a **Pod** named `hardened-pod` in namespace `predator` with security hardening:

| Configuration | Value |
|---------------|-------|
| Image | `nginx:1.21` |
| Container name | `secure-app` |

**Security Context:**

- Drop **ALL** capabilities
- Add only: `NET_BIND_SERVICE`
- Set `runAsNonRoot: true`
- Set `runAsUser: 101` (nginx user)

---

## Question 17 | Service Session Affinity

| | |
|---|---|
| **Points** | 5 |
| **Namespace** | `claw` |
| **Resources** | Service `backend-svc` |

### Task

A Service named `backend-svc` exists in namespace `claw` fronting a Deployment with 3 replicas.

Modify the Service to enable **session affinity**:

1. Set `sessionAffinity: ClientIP`
2. Configure `sessionAffinityConfig.clientIP.timeoutSeconds: 3600`

This ensures requests from the same client IP are routed to the same pod for 1 hour.

---

## Question 18 | Deployment Safe Rollout

| | |
|---|---|
| **Points** | 5 |
| **Namespace** | `fang` |
| **Resources** | Deployment `safe-deploy` |

### Task

A Deployment named `safe-deploy` exists in namespace `fang`.

Configure it for **safe rollouts**:

| Setting | Value |
|---------|-------|
| `minReadySeconds` | `30` |
| `progressDeadlineSeconds` | `120` |

Update the image to `nginx:1.22` and verify the rollout respects the minReadySeconds delay.

---

## Question 19 | Container Lifecycle Hook

| | |
|---|---|
| **Points** | 5 |
| **Namespace** | `tiger` |
| **Resources** | Pod `graceful-pod` |

### Task

Create a **Pod** named `graceful-pod` in namespace `tiger` with a graceful shutdown mechanism:

| Configuration | Value |
|---------------|-------|
| Image | `nginx:1.21` |
| Container name | `main` |

Add a **preStop** lifecycle hook that:

- Executes: `/bin/sh -c "nginx -s quit && sleep 5"`
- Allows nginx to finish handling requests before termination

Also set `terminationGracePeriodSeconds: 30` at pod level.

---

## Question 20 | NetworkPolicy Default Deny

| | |
|---|---|
| **Points** | 7 |
| **Namespace** | `predator` |
| **Resources** | NetworkPolicy `default-deny-all`, `allow-frontend-to-api` |

### Task

Implement a **default deny** network security model in namespace `predator`:

1. Create NetworkPolicy `default-deny-all` that:
   - Applies to **all pods** in the namespace
   - Denies all **ingress** and **egress** traffic by default

2. Create NetworkPolicy `allow-frontend-to-api` that:
   - Applies to pods with label `tier: backend`
   - Allows ingress from pods with label `tier: frontend` on port `80`
   - Allows egress to DNS (port `53` UDP/TCP)

Test by verifying frontend pods can reach backend pods, but not external services.

---
