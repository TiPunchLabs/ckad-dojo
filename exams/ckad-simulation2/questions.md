# CKAD Exam Simulator - Dojo Suzaku 🔥

> **Total Score**: 112 points | **Passing Score**: ~66% (74 points)
>
> *「朱雀は灰から蘇る」 - Le phénix renaît de ses cendres*
>
> **Local Simulator Adaptations**:
> | Original | Local Simulator |
> |----------|-----------------|
> | `/opt/course/N/` | `./exam/course/N/` |
> | Original registry | `localhost:5000` |
> | SSH to different instances | Single cluster (no SSH needed) |

---

## Question 1 | API Resources

| | |
|---|---|
| **Points** | 1 |
| **Namespace** | - |
| **File to create** | `./exam/course/1/api-resources` |

### Task

The DevOps team needs a complete list of all **API resources** available in the cluster. This should include the resource name, shortnames, API group, and whether the resource is namespaced.

Save the complete output to `./exam/course/1/api-resources`.

---

## Question 2 | Deployment Recreate Strategy

| | |
|---|---|
| **Points** | 6 |
| **Namespace** | `blaze` |
| **Resources** | Deployment `fire-app` |
| **File to create** | `./exam/course/2/fire-app.yaml` |

### Task

Create a **Deployment** named `fire-app` in namespace `blaze` with the following specifications:

- Image: `nginx:1.21`
- Replicas: 3
- Strategy type: **Recreate** (not RollingUpdate)
- Container name: `fire-container`

Save the Deployment YAML to `./exam/course/2/fire-app.yaml` and apply it to the cluster.

---

## Question 3 | Job with Timeout

| | |
|---|---|
| **Points** | 6 |
| **Namespace** | `spark` |
| **Resources** | Job `data-processor` |
| **File to create** | `./exam/course/3/job.yaml` |

### Task

A template Job manifest exists at `./exam/course/3/job.yaml`. Modify it to add a **timeout of 60 seconds** using `activeDeadlineSeconds`.

The Job should:
- Be named `data-processor`
- Run in namespace `spark`
- Automatically terminate if running longer than 60 seconds
- Have `backoffLimit: 2`

Apply the Job to the cluster.

---

## Question 4 | Helm Template Debug

| | |
|---|---|
| **Points** | 5 |
| **Namespace** | `flare` |
| **File to create** | `./exam/course/4/rendered.yaml` |

### Task

A Helm release `phoenix-web` is installed in namespace `flare`. Use `helm template` to render the manifests and save the complete output to `./exam/course/4/rendered.yaml`.

**Note**: Use the correct flags to simulate the installed release's values.

---

## Question 5 | Fix CrashLoopBackOff

| | |
|---|---|
| **Points** | 6 |
| **Namespace** | `ember` |
| **Resources** | Pod `crash-app` |

### Task

A Pod named `crash-app` in namespace `ember` is in **CrashLoopBackOff** state. The Pod has a command error that prevents it from starting.

1. Investigate the Pod to find the issue
2. Fix the Pod so it runs successfully
3. The Pod should be in **Running** state after your fix

**Hint**: Check the container command configuration.

---

## Question 6 | ConfigMap Items Mount

| | |
|---|---|
| **Points** | 6 |
| **Namespace** | `flame` |
| **Resources** | ConfigMap `app-settings`, Pod `config-reader` |

### Task

A ConfigMap named `app-settings` exists in namespace `flame` with multiple keys. Create a Pod named `config-reader` that:

- Uses image `busybox:1.36`
- Mounts **only** the `database.host` and `database.port` keys from the ConfigMap
- Mounts them to `/config/` directory as files
- Runs command `["sleep", "3600"]`
- Container name: `reader`

The Pod should only have those two specific keys mounted, not all keys from the ConfigMap.

---

## Question 7 | Secret from File

| | |
|---|---|
| **Points** | 5 |
| **Namespace** | `magma` |
| **Resources** | Secret `db-credentials` |
| **File to create** | `./exam/course/7/password.txt` |

### Task

Create a file at `./exam/course/7/password.txt` containing the text `FirePhoenix2024!` (no newline at end).

Then create a **Secret** named `db-credentials` in namespace `magma` from this file. The key in the Secret should be `password.txt`.

---

## Question 8 | Headless Service

| | |
|---|---|
| **Points** | 6 |
| **Namespace** | `corona` |
| **Resources** | Service `backend-headless` |

### Task

Create a **Headless Service** named `backend-headless` in namespace `corona` that:

- Has `clusterIP: None`
- Selects pods with label `app=backend`
- Exposes port 80
- Uses protocol TCP

---

## Question 9 | Canary Deployment

| | |
|---|---|
| **Points** | 7 |
| **Namespace** | `blaze` |
| **Resources** | Deployment `canary-v2`, Service `frontend-svc` |

### Task

A Deployment named `stable-v1` already exists in namespace `blaze` with 3 replicas running `nginx:1.21`.

Implement a **canary deployment pattern**:

1. Create a new Deployment named `canary-v2`:
   - Image: `nginx:1.22`
   - Replicas: 1
   - Labels: `app=web-frontend`, `version=v2`

2. Create a Service named `frontend-svc`:
   - Type: ClusterIP
   - Port: 80
   - Selector: `app=web-frontend` (should route to BOTH stable and canary pods)

The traffic split should be approximately 75% stable / 25% canary (3:1 replica ratio).

---

## Question 10 | Sidecar Data Processing

| | |
|---|---|
| **Points** | 6 |
| **Namespace** | `phoenix` |
| **Resources** | Pod `data-transform` |

### Task

Create a Pod named `data-transform` in namespace `phoenix` with a sidecar pattern:

**Main container** (`producer`):
- Image: `busybox:1.36`
- Command: `["sh", "-c", "while true; do echo $(date) >> /data/input.log; sleep 5; done"]`
- Mounts volume `shared-data` at `/data`

**Sidecar container** (`transformer`):
- Image: `busybox:1.36`
- Command: `["sh", "-c", "tail -f /data/input.log | while read line; do echo \"PROCESSED: $line\" >> /data/output.log; done"]`
- Mounts same volume `shared-data` at `/data`

Use an **emptyDir** volume named `shared-data`.

---

## Question 11 | Cross-Namespace NetworkPolicy

| | |
|---|---|
| **Points** | 6 |
| **Namespace** | `corona` |
| **Resources** | NetworkPolicy `allow-from-flame` |

### Task

Create a **NetworkPolicy** named `allow-from-flame` in namespace `corona` that:

- Applies to pods with label `app=backend`
- Allows ingress traffic **only** from pods in namespace `flame`
- Allows traffic on port 80 (TCP)
- Denies all other ingress traffic

**Hint**: You'll need to use `namespaceSelector` to specify the source namespace.

---

## Question 12 | Docker Build with ARG

| | |
|---|---|
| **Points** | 6 |
| **Namespace** | `inferno` |
| **File to modify** | `./exam/course/12/Dockerfile` |
| **Image to create** | `localhost:5000/phoenix-app:2.0.0` |

### Task

A Dockerfile template exists at `./exam/course/12/Dockerfile`. Modify it to:

1. Add an **ARG** named `APP_VERSION` with default value `1.0.0`
2. Add a **LABEL** `version=${APP_VERSION}`

Then build the image with:
- `APP_VERSION=2.0.0`
- Tag: `localhost:5000/phoenix-app:2.0.0`

Push the image to the local registry.

---

## Question 13 | Helm Values File

| | |
|---|---|
| **Points** | 5 |
| **Namespace** | `flare` |
| **Resources** | Helm release `phoenix-api` |
| **File to use** | `./exam/course/13/values.yaml` |

### Task

A values file exists at `./exam/course/13/values.yaml`. Use it to install a new Helm release:

- Release name: `phoenix-api`
- Namespace: `flare`
- Chart: `bitnami/nginx`
- Values file: `./exam/course/13/values.yaml`

The values file specifies 3 replicas and service port 8080.

---

## Question 14 | PostStart Lifecycle Hook

| | |
|---|---|
| **Points** | 6 |
| **Namespace** | `phoenix` |
| **Resources** | Pod `lifecycle-pod` |

### Task

Create a Pod named `lifecycle-pod` in namespace `phoenix` that:

- Uses image `nginx:1.21`
- Container name: `main`
- Has a **postStart** lifecycle hook that executes:
  ```
  /bin/sh -c "echo 'Started at $(date)' > /usr/share/nginx/html/started.txt"
  ```

The hook should create a file indicating when the container started.

---

## Question 15 | Guaranteed QoS Class

| | |
|---|---|
| **Points** | 5 |
| **Namespace** | `spark` |
| **Resources** | Pod `qos-guaranteed` |

### Task

Create a Pod named `qos-guaranteed` in namespace `spark` that achieves **Guaranteed** QoS class:

- Image: `nginx:1.21`
- Container name: `web`
- Must have QoS class of exactly **Guaranteed**

**Hint**: Resources must be set correctly for Guaranteed QoS.

---

## Question 16 | ServiceAccount Projected Token

| | |
|---|---|
| **Points** | 4 |
| **Namespace** | `magma` |
| **Resources** | Pod `token-pod` |

### Task

A ServiceAccount named `fire-sa` exists in namespace `magma`. Create a Pod named `token-pod` that:

- Uses image `busybox:1.36`
- Command: `["sleep", "3600"]`
- Container name: `app`
- Uses ServiceAccount `fire-sa`
- Mounts the ServiceAccount token via **projected volume** at `/var/run/secrets/fire-token/`
- Token should have an expiration of 3600 seconds

---

## Question 17 | TCP Liveness Probe

| | |
|---|---|
| **Points** | 6 |
| **Namespace** | `ember` |
| **Resources** | Pod `tcp-health` |

### Task

Create a Pod named `tcp-health` in namespace `ember` that:

- Uses image `nginx:1.21`
- Container name: `web`
- Has a **tcpSocket** liveness probe on port 80
- Initial delay: 10 seconds
- Period: 5 seconds

---

## Question 18 | Service with Named Ports

| | |
|---|---|
| **Points** | 6 |
| **Namespace** | `flame` |
| **Resources** | Service `web-svc` |

### Task

A Deployment named `web-deploy` exists in namespace `flame` with pods exposing named ports `http-web` (80) and `https-web` (443).

Create a Service named `web-svc` that:

- Type: ClusterIP
- Exposes port 80 targeting the named port `http-web`
- Exposes port 443 targeting the named port `https-web`
- Selector: `app=web-app`

---

## Question 19 | Topology Spread Constraints

| | |
|---|---|
| **Points** | 6 |
| **Namespace** | `blaze` |
| **Resources** | Deployment `spread-deploy` |

### Task

Create a Deployment named `spread-deploy` in namespace `blaze` that:

- Image: `nginx:1.21`
- Replicas: 4
- Container name: `web`
- Uses **topologySpreadConstraints** to spread pods evenly across nodes
- `topologyKey`: `kubernetes.io/hostname`
- `maxSkew`: 1
- `whenUnsatisfiable`: `ScheduleAnyway`
- Label selector: `app=spread-app`

---

## Question 20 | Field Selectors

| | |
|---|---|
| **Points** | 4 |
| **Namespace** | - |
| **File to create** | `./exam/course/20/running-pods.txt` |

### Task

Use **field selectors** (not label selectors) to list all Pods in the cluster that have `status.phase=Running`.

Save the Pod names (one per line) to `./exam/course/20/running-pods.txt`.

**Hint**: Use `--field-selector` with kubectl.

---

## Question 21 | Node Drain

| | |
|---|---|
| **Points** | 4 |
| **Namespace** | `solar` |
| **File to create** | `./exam/course/21/drain-command.sh` |

### Task

Write a command to `./exam/course/21/drain-command.sh` that would drain a node named `worker-node-1`:

- Ignore DaemonSets
- Delete emptyDir data
- Force deletion of pods
- Use a timeout of 60 seconds

**Note**: Do not actually execute the drain command. Just write it to the file.

---
