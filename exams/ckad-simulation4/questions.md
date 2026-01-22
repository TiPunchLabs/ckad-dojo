# CKAD Exam Simulator - Dojo Genbu 🐢

> **Total Score**: 105 points | **Passing Score**: ~66% (69 points)
>
> *「玄武は深海を守る」 - La tortue noire garde les profondeurs*
>
> **Local Simulator Adaptations**:
>
> | Original | Local Simulator |
> |----------|-----------------|
> | `/opt/course/N/` | `./exam/course/N/` |
> | Original registry | `localhost:5000` |
> | SSH to different instances | Single cluster (no SSH needed) |

---

## Question 1 | ResourceQuota

| | |
|---|---|
| **Points** | 5 |
| **Namespace** | `shell` |
| **Resources** | ResourceQuota `namespace-limits` |

### Task

Create a **ResourceQuota** named `namespace-limits` in namespace `shell` that enforces:

| Resource | Limit |
|----------|-------|
| Max pods | `10` |
| Max CPU requests | `4` |
| Max memory requests | `4Gi` |
| Max CPU limits | `8` |
| Max memory limits | `8Gi` |
| Max ConfigMaps | `10` |
| Max Secrets | `10` |

Verify the quota is applied with `kubectl describe quota`.

---

## Question 2 | HorizontalPodAutoscaler

| | |
|---|---|
| **Points** | 6 |
| **Namespace** | `ocean` |
| **Resources** | HPA `web-app-hpa` |

### Task

A Deployment named `web-app` already exists in namespace `ocean`.

Create a **HorizontalPodAutoscaler** named `web-app-hpa` that:

| Configuration | Value |
|---------------|-------|
| Target Deployment | `web-app` |
| Min replicas | `2` |
| Max replicas | `10` |
| Target CPU utilization | `70%` |

Use `kubectl autoscale` or create the HPA manifest directly.

Verify the HPA is created with `kubectl get hpa`.

**Note**: If metrics-server is not installed, the HPA will show `<unknown>` for current metrics. This is expected.

---

## Question 3 | StatefulSet

| | |
|---|---|
| **Points** | 8 |
| **Namespace** | `reef` |
| **Resources** | StatefulSet `db-cluster`, Headless Service `db-headless` |

### Task

Create a **StatefulSet** named `db-cluster` in namespace `reef` for a database cluster:

| Configuration | Value |
|---------------|-------|
| Image | `redis:7-alpine` |
| Replicas | `3` |
| Container name | `redis` |
| Container port | `6379` |
| Volume claim template | `data` with 100Mi storage |

Also create a **Headless Service** named `db-headless`:

- Selector: `app: db-cluster`
- ClusterIP: `None`
- Port: `6379`

Verify pods are created with ordinal names (db-cluster-0, db-cluster-1, db-cluster-2).

---

## Question 4 | DaemonSet

| | |
|---|---|
| **Points** | 6 |
| **Namespace** | `deep` |
| **Resources** | DaemonSet `node-monitor` |

### Task

Create a **DaemonSet** named `node-monitor` in namespace `deep`:

| Configuration | Value |
|---------------|-------|
| Image | `busybox:1.36` |
| Command | `["sh", "-c", "while true; do echo Node: $NODE_NAME; sleep 60; done"]` |
| Container name | `monitor` |

The container should have an environment variable `NODE_NAME` set via the **Downward API** from `spec.nodeName`.

Add a **toleration** to run on all nodes including control-plane nodes:

- Key: `node-role.kubernetes.io/control-plane`
- Operator: `Exists`
- Effect: `NoSchedule`

---

## Question 5 | PriorityClass

| | |
|---|---|
| **Points** | 5 |
| **Namespace** | `tide` |
| **Resources** | PriorityClass `critical-priority`, Pod `critical-pod` |

### Task

1. Create a **PriorityClass** named `critical-priority`:
   - Value: `1000000`
   - Global default: `false`
   - Description: "Critical workloads priority"

2. Create a **Pod** named `critical-pod` in namespace `tide`:
   - Image: `nginx:1.21`
   - Container name: `nginx`
   - Use the `critical-priority` PriorityClass

Verify the pod has the correct priority with `kubectl get pod critical-pod -o yaml | grep priority`.

---

## Question 6 | startupProbe

| | |
|---|---|
| **Points** | 5 |
| **Namespace** | `wave` |
| **Resources** | Pod `slow-starter` |

### Task

Create a **Pod** named `slow-starter` in namespace `wave` for an application that takes a long time to start:

| Configuration | Value |
|---------------|-------|
| Image | `nginx:1.21` |
| Container name | `app` |

Configure a **startupProbe**:

| Setting | Value |
|---------|-------|
| HTTP GET path | `/` |
| Port | `80` |
| failureThreshold | `30` |
| periodSeconds | `10` |

This allows up to 5 minutes (30 * 10 seconds) for the application to start.

Also add a **livenessProbe** with HTTP GET on `/` port `80` with default settings.

---

## Question 7 | Pod Affinity (Preferred)

| | |
|---|---|
| **Points** | 6 |
| **Namespace** | `coral` |
| **Resources** | Deployment `web-frontend` |

### Task

Create a **Deployment** named `web-frontend` in namespace `coral`:

| Configuration | Value |
|---------------|-------|
| Image | `nginx:1.21` |
| Replicas | `3` |
| Container name | `frontend` |
| Labels | `app: web-frontend`, `tier: frontend` |

Configure **preferredDuringSchedulingIgnoredDuringExecution** pod affinity:

- Weight: `100`
- Prefer scheduling on the **same node** as pods with label `app: cache`
- Topology key: `kubernetes.io/hostname`

**Note**: This is a soft preference. Pods will be scheduled even if no cache pods exist.

---

## Question 8 | Ingress with Path Routing

| | |
|---|---|
| **Points** | 6 |
| **Namespace** | `lagoon` |
| **Resources** | Ingress `api-routing` |

### Task

Services `api-v1-svc` and `api-v2-svc` already exist in namespace `lagoon`.

Create an **Ingress** named `api-routing` with path-based routing:

| Path | Backend Service | Port |
|------|-----------------|------|
| `/v1` | `api-v1-svc` | `80` |
| `/v2` | `api-v2-svc` | `80` |

Configuration:

- Host: `api.lagoon.local`
- PathType: `Prefix`
- IngressClassName: `nginx`

---

## Question 9 | Job with Completions and Parallelism

| | |
|---|---|
| **Points** | 5 |
| **Namespace** | `current` |
| **Resources** | Job `parallel-processor` |

### Task

Create a **Job** named `parallel-processor` in namespace `current`:

| Configuration | Value |
|---------------|-------|
| Image | `busybox:1.36` |
| Command | `["sh", "-c", "echo Processing batch $RANDOM && sleep 5"]` |
| Container name | `processor` |
| Completions | `6` |
| Parallelism | `3` |
| backoffLimit | `4` |

The Job should run 6 total completions with 3 running in parallel at a time.

Verify with `kubectl get jobs` that completions reach 6/6.

---

## Question 10 | kubectl debug

| | |
|---|---|
| **Points** | 4 |
| **Namespace** | `anchor` |
| **Resources** | Pod `troubled-app` |
| **File to create** | `./exam/course/10/debug-output.txt` |

### Task

A Pod named `troubled-app` exists in namespace `anchor` but you need to debug it.

1. Use `kubectl debug` to create an **ephemeral container** in the running pod:
   - Image: `busybox:1.36`
   - Container name: `debugger`

2. From within the ephemeral container, run `ls -la /data` and save the output to `./exam/course/10/debug-output.txt`

**Note**: If your cluster doesn't support ephemeral containers, use `kubectl debug` with `--copy-to` to create a debug copy of the pod instead.

---

## Question 11 | EndpointSlice

| | |
|---|---|
| **Points** | 3 |
| **Namespace** | `shell` |
| **File to create** | `./exam/course/11/endpoints-info.txt` |

### Task

A Service named `backend-svc` exists in namespace `shell` with multiple pod endpoints.

1. List all **EndpointSlices** for the service `backend-svc`
2. Save the following information to `./exam/course/11/endpoints-info.txt`:
   - Number of endpoints
   - IP addresses of all endpoints
   - Ports exposed

Use `kubectl get endpointslices` and `kubectl describe endpointslice`.

---

## Question 12 | Service internalTrafficPolicy

| | |
|---|---|
| **Points** | 4 |
| **Namespace** | `ocean` |
| **Resources** | Service `local-svc` |

### Task

A Service named `local-svc` exists in namespace `ocean`.

Modify the Service to use **node-local traffic routing**:

1. Set `internalTrafficPolicy: Local`

This ensures traffic is only routed to pods on the same node as the client, reducing latency.

Verify the change with `kubectl get svc local-svc -o yaml`.

---

## Question 13 | EmptyDir with sizeLimit

| | |
|---|---|
| **Points** | 4 |
| **Namespace** | `reef` |
| **Resources** | Pod `cache-pod` |

### Task

Create a **Pod** named `cache-pod` in namespace `reef`:

| Configuration | Value |
|---------------|-------|
| Image | `redis:7-alpine` |
| Container name | `cache` |

Add an **emptyDir** volume with:

- Name: `cache-volume`
- sizeLimit: `100Mi`
- medium: `Memory` (use RAM-backed tmpfs)

Mount the volume at `/cache`.

This creates a memory-backed cache limited to 100Mi.

---

## Question 14 | Secret with stringData

| | |
|---|---|
| **Points** | 4 |
| **Namespace** | `deep` |
| **Resources** | Secret `app-credentials`, Pod `secret-consumer` |

### Task

1. Create a **Secret** named `app-credentials` in namespace `deep` using **stringData** (plain text, auto-encoded):

   | Key | Value |
   |-----|-------|
   | `api-key` | `super-secret-key-12345` |
   | `db-password` | `postgres@secure!` |

2. Make the Secret **immutable**

3. Create a **Pod** named `secret-consumer`:
   - Image: `busybox:1.36`
   - Command: `["sh", "-c", "cat /secrets/api-key && sleep 3600"]`
   - Mount the secret at `/secrets`

---

## Question 15 | kubectl patch

| | |
|---|---|
| **Points** | 5 |
| **Namespace** | `tide` |
| **Resources** | Deployment `patch-demo` |
| **File to create** | `./exam/course/15/patch-commands.sh` |

### Task

A Deployment named `patch-demo` exists in namespace `tide`.

Use `kubectl patch` to make the following changes:

1. **Strategic merge patch**: Update the image to `nginx:1.22`
2. **JSON patch**: Add a new environment variable `ENV_MODE=production`
3. **JSON patch**: Update replicas to `4`

Save all three patch commands to `./exam/course/15/patch-commands.sh`.

Verify changes with `kubectl describe deployment patch-demo`.

---

## Question 16 | NetworkPolicy with IPBlock

| | |
|---|---|
| **Points** | 8 |
| **Namespace** | `wave` |
| **Resources** | NetworkPolicy `external-access` |

### Task

Pods labeled `tier: api` exist in namespace `wave`.

Create a **NetworkPolicy** named `external-access` that:

1. Applies to pods with label `tier: api`

2. **Allows ingress** from:
   - Pods with label `tier: client` on port `80`
   - External IP range `10.0.0.0/8` on port `80` (using ipBlock)
   - **Except** block `10.0.1.0/24` (internal restricted subnet)

3. **Allows egress** to:
   - DNS on port `53` UDP/TCP (any destination)
   - External IP range `0.0.0.0/0` on port `443` (HTTPS to external APIs)

---

## Question 17 | Pod with hostNetwork

| | |
|---|---|
| **Points** | 5 |
| **Namespace** | `coral` |
| **Resources** | Pod `network-diagnostic` |

### Task

Create a **Pod** named `network-diagnostic` in namespace `coral` for network troubleshooting:

| Configuration | Value |
|---------------|-------|
| Image | `nicolaka/netshoot:latest` |
| Command | `["sleep", "3600"]` |
| Container name | `netshoot` |

Configure the pod with:

- `hostNetwork: true` - Use the host's network namespace
- `hostPID: true` - Use the host's PID namespace

**Warning**: This gives the pod elevated access. Only use for debugging.

Verify with `kubectl exec` that the pod can see host network interfaces (`ip addr`).

---

## Question 18 | ClusterRole and ClusterRoleBinding

| | |
|---|---|
| **Points** | 6 |
| **Namespace** | `lagoon` (ServiceAccount only) |
| **Resources** | ClusterRole `node-reader`, ClusterRoleBinding `node-reader-binding` |

### Task

Create cluster-wide RBAC for node monitoring:

1. Create a **ServiceAccount** named `node-monitor-sa` in namespace `lagoon`

2. Create a **ClusterRole** named `node-reader`:
   - Allow `get`, `list`, `watch` on `nodes`
   - Allow `get`, `list` on `namespaces`
   - Allow `get` on `nodes/status`

3. Create a **ClusterRoleBinding** named `node-reader-binding`:
   - Bind `node-reader` ClusterRole to `node-monitor-sa` ServiceAccount

Verify with `kubectl auth can-i list nodes --as=system:serviceaccount:lagoon:node-monitor-sa`.

---

## Question 19 | kubectl auth can-i

| | |
|---|---|
| **Points** | 4 |
| **Namespace** | `current` |
| **File to create** | `./exam/course/19/permissions.txt` |

### Task

A ServiceAccount named `app-deployer` exists in namespace `current` with specific permissions.

Use `kubectl auth can-i` to check and document its permissions:

1. Check if it can:
   - Create deployments in `current` namespace
   - Delete deployments in `current` namespace
   - Create pods in `current` namespace
   - Delete secrets in `current` namespace
   - List nodes (cluster-wide)

2. Save the results in the following format to `./exam/course/19/permissions.txt`:

   ```
   create deployments: yes/no
   delete deployments: yes/no
   create pods: yes/no
   delete secrets: yes/no
   list nodes: yes/no
   ```

---

## Question 20 | Multi-Container with Shared Volume

| | |
|---|---|
| **Points** | 6 |
| **Namespace** | `anchor` |
| **Resources** | Pod `data-pipeline` |

### Task

Create a **Pod** named `data-pipeline` in namespace `anchor` implementing a producer-consumer pattern:

**Container 1: producer**

- Image: `busybox:1.36`
- Command: `["sh", "-c", "while true; do date >> /data/log.txt; sleep 5; done"]`

**Container 2: consumer**

- Image: `busybox:1.36`
- Command: `["sh", "-c", "tail -f /data/log.txt"]`

**Container 3: monitor**

- Image: `busybox:1.36`
- Command: `["sh", "-c", "while true; do wc -l /data/log.txt; sleep 10; done"]`

All three containers must share an **emptyDir** volume mounted at `/data`.

Verify all containers are running and check logs of the consumer container.

---
