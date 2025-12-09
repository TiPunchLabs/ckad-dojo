# CKAD Exam Simulator - Questions

> **Total Score**: 105 points | **Passing Score**: ~66% (69 points)
>
> **Local Simulator Adaptations**:
> | Original | Local Simulator |
> |----------|-----------------|
> | `/opt/course/N/` | `./exam/course/N/` |
> | Original registry | `localhost:5000` |
> | SSH to different instances | Single cluster (no SSH needed) |

---

## Question 1 | Namespaces

| | |
|---|---|
| **Points** | 1/105 (1%) |
| **Namespace** | - |
| **File to create** | `./exam/course/1/namespaces` |

### Task

The DevOps team would like to get the list of all **Namespaces** in the cluster that contain the word "a" in their name.

Save the filtered list to `./exam/course/1/namespaces`.

---

## Question 2 | Multi-container Pod

| | |
|---|---|
| **Points** | 6/105 (6%) |
| **Namespace** | `athena` |
| **Resources** | Pod `wisdom-pod` |

### Task

In Namespace `athena`, create a Pod named `wisdom-pod` with **two containers**:

| Container | Image | Configuration |
|-----------|-------|---------------|
| `main` | `nginx:1.21-alpine` | Expose port `80` |
| `sidecar` | `busybox:1.35` | Run command: `while true; do echo "$(date) - Wisdom shared" >> /var/log/wisdom.log; sleep 5; done` |

Both containers should share an **emptyDir** volume named `shared-logs`:
- `main` container mounts it at `/usr/share/nginx/html`
- `sidecar` container mounts it at `/var/log`

---

## Question 3 | CronJob

| | |
|---|---|
| **Points** | 5/105 (5%) |
| **Namespace** | `apollo` |
| **Resources** | CronJob `sun-check` |

### Task

Team Apollo needs a **CronJob** named `sun-check` in namespace `apollo` that runs every **15 minutes**.

| Configuration | Value |
|---------------|-------|
| Image | `busybox:1.35` |
| Command | `echo "Apollo sun check: $(date)"` |
| Restart Policy | `OnFailure` |
| Successful Jobs History | `3` |
| Failed Jobs History | `1` |

---

## Question 4 | Helm Management

| | |
|---|---|
| **Points** | 5/105 (5%) |
| **Namespace** | `olympus` |
| **Resources** | Helm releases |

### Task

Team Olympus asked you to perform some operations using Helm, all in Namespace `olympus`:

| # | Task |
|---|------|
| 1 | **Delete** release `olympus-web-v1` |
| 2 | **Upgrade** release `olympus-web-v2` to any newer version of chart `bitnami/nginx` available |
| 3 | **Install** a new release `olympus-apache` of chart `bitnami/apache` with **3 replicas** |
| 4 | Find and **delete** a broken release stuck in `pending-install` state |

---

## Question 5 | ConfigMap and Environment Variables

| | |
|---|---|
| **Points** | 5/105 (5%) |
| **Namespace** | `hermes` |
| **Resources** | ConfigMap `messenger-config`, Pod `messenger-pod` |

### Task

Create a **ConfigMap** named `messenger-config` in namespace `hermes` with the following data:

| Key | Value |
|-----|-------|
| `SPEED` | `fast` |
| `DESTINATION` | `olympus` |
| `MESSAGE_COUNT` | `100` |

Then create a **Pod** named `messenger-pod` using image `nginx:1.21-alpine` that uses **all keys** from this ConfigMap as environment variables.

---

## Question 6 | Secret Volume Mount

| | |
|---|---|
| **Points** | 6/105 (6%) |
| **Namespace** | `hades` |
| **Resources** | Secret `underworld-creds`, Pod `cerberus-pod` |

### Task

Create a **Secret** named `underworld-creds` in namespace `hades` with:

| Key | Value |
|-----|-------|
| `username` | `hades` |
| `password` | `3headed-dog` |

Create a **Pod** named `cerberus-pod` using image `nginx:1.21-alpine` that mounts this secret at `/etc/secrets` as a **read-only** volume.

---

## Question 7 | Pod with Resource Limits

| | |
|---|---|
| **Points** | 5/105 (5%) |
| **Namespace** | `zeus` |
| **Resources** | Pod `thunder-pod` |

### Task

Create a **Pod** named `thunder-pod` in namespace `zeus` using image `nginx:1.21-alpine` with the following resource configuration:

| Type | CPU | Memory |
|------|-----|--------|
| **Requests** | `100m` | `64Mi` |
| **Limits** | `200m` | `128Mi` |

---

## Question 8 | Deployment Rollback

| | |
|---|---|
| **Points** | 6/105 (6%) |
| **Namespace** | `ares` |
| **Resources** | Deployment `battle-app` |
| **File to create** | `./exam/course/8/rollback-info.txt` |

### Task

There is a **Deployment** named `battle-app` in namespace `ares`. It was recently updated with a broken image.

1. **Rollback** the deployment to the previous working revision
2. Write the **revision number** you rolled back to into `./exam/course/8/rollback-info.txt`
3. Ensure the deployment is running successfully

---

## Question 9 | Service ClusterIP

| | |
|---|---|
| **Points** | 5/105 (5%) |
| **Namespace** | `artemis` |
| **Resources** | Pod `hunter-api`, Service `hunter-svc` |
| **File to create** | `./exam/course/9/service-test.txt` |

### Task

Create a **Pod** named `hunter-api` in namespace `artemis` using image `nginx:1.21-alpine` with label `app: hunter`.

Create a **ClusterIP Service** named `hunter-svc` that exposes this Pod on port `8080` targeting container port `80`.

Use `curl` from a temporary Pod to test the service and write the response to `./exam/course/9/service-test.txt`.

---

## Question 10 | NetworkPolicy

| | |
|---|---|
| **Points** | 7/105 (7%) |
| **Namespace** | `poseidon` |
| **Resources** | NetworkPolicy `sea-wall` |

### Task

Create a **NetworkPolicy** named `sea-wall` in namespace `poseidon` that:

1. Applies to all Pods with label `zone: deep-sea`
2. **Allows ingress** only from Pods with label `trusted: true` in the same namespace
3. **Allows egress** only to Pods with label `zone: surface` on port `80`

---

## Question 11 | PersistentVolume and PVC

| | |
|---|---|
| **Points** | 6/105 (6%) |
| **Namespace** | `hera` |
| **Resources** | PV `hera-pv`, PVC `hera-pvc`, Pod `hera-storage-pod` |

### Task

Create a **PersistentVolume** named `hera-pv`:

| Configuration | Value |
|---------------|-------|
| Capacity | `1Gi` |
| AccessMode | `ReadWriteOnce` |
| HostPath | `/data/hera` |
| StorageClassName | (none - empty string) |

Create a **PersistentVolumeClaim** named `hera-pvc` in namespace `hera`:

| Configuration | Value |
|---------------|-------|
| Storage request | `500Mi` |
| AccessMode | `ReadWriteOnce` |
| StorageClassName | (none - empty string) |

Create a **Pod** named `hera-storage-pod` using image `nginx:1.21-alpine` that mounts this PVC at `/data`.

---

## Question 12 | Init Container

| | |
|---|---|
| **Points** | 6/105 (6%) |
| **Namespace** | `titan` |
| **Resources** | Pod `titan-init-pod` |

### Task

Create a **Pod** named `titan-init-pod` in namespace `titan` with:

**Init Container:**
| Configuration | Value |
|---------------|-------|
| Name | `init-setup` |
| Image | `busybox:1.35` |
| Command | `echo "Titan awakening..." && sleep 5` |

**Main Container:**
| Configuration | Value |
|---------------|-------|
| Name | `titan-main` |
| Image | `nginx:1.21-alpine` |

---

## Question 13 | Probes (Liveness and Readiness)

| | |
|---|---|
| **Points** | 7/105 (7%) |
| **Namespace** | `apollo` |
| **Resources** | Pod `oracle-pod` |

### Task

Create a **Pod** named `oracle-pod` in namespace `apollo` using image `nginx:1.21-alpine` with:

**Liveness Probe:**
| Configuration | Value |
|---------------|-------|
| Type | HTTP GET |
| Path | `/healthz` |
| Port | `80` |
| Initial Delay | `10` seconds |
| Period | `5` seconds |

**Readiness Probe:**
| Configuration | Value |
|---------------|-------|
| Type | HTTP GET |
| Path | `/ready` |
| Port | `80` |
| Initial Delay | `5` seconds |
| Period | `3` seconds |

---

## Question 14 | ServiceAccount

| | |
|---|---|
| **Points** | 4/105 (4%) |
| **Namespace** | `hermes` |
| **Resources** | ServiceAccount `messenger-sa`, Pod `messenger-runner` |

### Task

Create a **ServiceAccount** named `messenger-sa` in namespace `hermes`.

Create a **Pod** named `messenger-runner` using image `nginx:1.21-alpine` that uses this ServiceAccount.

The Pod should have `automountServiceAccountToken: false`.

---

## Question 15 | Labels and Selectors

| | |
|---|---|
| **Points** | 5/105 (5%) |
| **Namespace** | `olympus` |
| **File to create** | `./exam/course/15/gods-pods.txt` |

### Task

In namespace `olympus`, there are several Pods with various labels.

1. Find all Pods that have the label `role=god`
2. Write the **names** of these Pods to `./exam/course/15/gods-pods.txt` (one per line)
3. Add the label `power=divine` to all these Pods

---

## Question 16 | Deployment Scaling

| | |
|---|---|
| **Points** | 4/105 (4%) |
| **Namespace** | `ares` |
| **Resources** | Deployment `warrior-squad` |

### Task

There is a **Deployment** named `warrior-squad` in namespace `ares`.

1. **Scale** the deployment to **5 replicas**
2. Set the deployment's **update strategy** to `RollingUpdate` with `maxSurge: 2` and `maxUnavailable: 1`

---

## Question 17 | Job with Completions

| | |
|---|---|
| **Points** | 5/105 (5%) |
| **Namespace** | `athena` |
| **Resources** | Job `wisdom-task` |

### Task

Create a **Job** named `wisdom-task` in namespace `athena`:

| Configuration | Value |
|---------------|-------|
| Image | `busybox:1.35` |
| Command | `echo "Task completed by Athena" && sleep 2` |
| Completions | `4` |
| Parallelism | `2` |
| Backoff Limit | `3` |
| Container name | `wisdom-container` |
| Pod label | `task: wisdom` |

---

## Question 18 | Pod Logs and Debugging

| | |
|---|---|
| **Points** | 5/105 (5%) |
| **Namespace** | `hades` |
| **Resources** | Pod `shadow-app` |
| **File to create** | `./exam/course/18/shadow-logs.txt` |

### Task

There is a Pod named `shadow-app` in namespace `hades` that has been running for a while.

1. Get the **last 50 lines** of logs from this Pod
2. Write these logs to `./exam/course/18/shadow-logs.txt`
3. Find any **ERROR** messages in the logs and count them. Write the count to `./exam/course/18/error-count.txt`

---

## Question 19 | Annotations

| | |
|---|---|
| **Points** | 3/105 (3%) |
| **Namespace** | `zeus` |
| **Resources** | Pod `lightning-pod` |

### Task

There is a Pod named `lightning-pod` in namespace `zeus`.

Add the following **annotations** to this Pod:

| Key | Value |
|-----|-------|
| `description` | `Primary lightning generator` |
| `maintainer` | `zeus-team@olympus.io` |
| `version` | `2.0` |

---

## Question 20 | Container Image Build

| | |
|---|---|
| **Points** | 9/105 (9%) |
| **Registry** | `localhost:5000` |
| **Source files** | `./exam/course/20/image/` |
| **File to create** | `./exam/course/20/container-logs.txt` |

### Task

There are files to build a container image at `./exam/course/20/image/`. The container runs a simple application.

> Use `sudo docker` and `sudo podman` or become root with `sudo -i`

| # | Task |
|---|------|
| 1 | Modify the **Dockerfile**: add ENV variable `APP_VERSION` with value `3.0.0` |
| 2 | **Build** with Docker, tag `localhost:5000/olympus-app:v1-docker` and **push** |
| 3 | **Build** with Podman, tag `localhost:5000/olympus-app:v1-podman` and **push** |
| 4 | **Run** a detached container with Podman named `olympus-runner` using image `localhost:5000/olympus-app:v1-podman` |
| 5 | Write the container **logs** to `./exam/course/20/container-logs.txt` |

---
