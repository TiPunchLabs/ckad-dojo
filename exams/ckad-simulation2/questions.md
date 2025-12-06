# CKAD Exam Simulator - Simulation 2

> **Total Score**: 112 points | **Passing Score**: ~66% (74 points)
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
| **Points** | 1/112 (1%) |
| **Namespace** | - |
| **File to create** | `./exam/course/1/namespaces` |

### Task

The DevOps team in the Andromeda cluster would like to get the list of all **Namespaces** in the cluster.

The list can contain other columns like STATUS or AGE.

Save the list to `./exam/course/1/namespaces`.

---

## Question 2 | Multi-container Pod

| | |
|---|---|
| **Points** | 5/112 (4%) |
| **Namespace** | `andromeda` |
| **Resources** | Pod `multi-container-pod` |

### Task

Create a **Pod** named `multi-container-pod` in Namespace `andromeda` with two containers:

| Container | Image | Purpose |
|-----------|-------|---------|
| `nginx` | `nginx:1.21-alpine` | Web server |
| `busybox` | `busybox:1.35` | Sidecar utility |

The busybox container should run the command `sleep 3600` to keep it running.

Both containers should be in the same Pod.

---

## Question 3 | CronJob

| | |
|---|---|
| **Points** | 5/112 (4%) |
| **Namespace** | `orion` |
| **Resources** | CronJob `galaxy-backup` |
| **File to create** | `./exam/course/3/cronjob.yaml` |

### Task

Team Orion needs a **CronJob** to perform regular backup checks. Create a CronJob named `galaxy-backup` in Namespace `orion`:

| Configuration | Value |
|---------------|-------|
| Schedule | Every 5 minutes (`*/5 * * * *`) |
| Image | `busybox:1.35` |
| Command | `echo "Backup check completed at $(date)"` |

Save the CronJob YAML to `./exam/course/3/cronjob.yaml`.

---

## Question 4 | Deployment Scaling

| | |
|---|---|
| **Points** | 4/112 (4%) |
| **Namespace** | `pegasus` |
| **Resources** | Deployment `star-app` |
| **File to create** | `./exam/course/4/scale-command.sh` |

### Task

There is an existing **Deployment** named `star-app` in Namespace `pegasus` that currently runs with 2 replicas.

Due to increased traffic, you need to **scale** this Deployment to **5 replicas**.

Save the kubectl command you used to scale the Deployment to `./exam/course/4/scale-command.sh`.

Verify that all 5 replicas are running and ready.

---

## Question 5 | Deployment Troubleshooting

| | |
|---|---|
| **Points** | 6/112 (5%) |
| **Namespace** | `cygnus` |
| **Resources** | Deployment `broken-app` |
| **File to create** | `./exam/course/5/fix-reason.txt` |

### Task

There is a **Deployment** named `broken-app` in Namespace `cygnus` that is not working properly. The Pods are failing to start.

1. **Investigate** the issue by checking Pod status and events
2. **Fix** the problem so the Deployment runs successfully
3. **Document** what was wrong in file `./exam/course/5/fix-reason.txt`

Hint: Check the container image specification carefully.

---

## Question 6 | ConfigMap Volume Mount

| | |
|---|---|
| **Points** | 5/112 (4%) |
| **Namespace** | `lyra` |
| **Resources** | ConfigMap `app-config`, Pod `config-pod` |

### Task

Team Lyra needs an application that reads its configuration from a file.

1. Create a **ConfigMap** named `app-config` in Namespace `lyra` with the following data:
   - Key: `app.properties`
   - Value:
     ```
     database.host=galaxy-db.lyra
     database.port=5432
     app.name=GalaxyApp
     ```

2. Create a **Pod** named `config-pod` in Namespace `lyra`:
   - Image: `nginx:1.21-alpine`
   - Mount the ConfigMap as a volume at `/etc/config`

Verify the Pod is running and the configuration file is accessible.

---

## Question 7 | Secret Environment Variables

| | |
|---|---|
| **Points** | 5/112 (4%) |
| **Namespace** | `aquila` |
| **Resources** | Secret `db-credentials`, Pod `secret-pod` |

### Task

Team Aquila needs to securely pass database credentials to an application.

1. Create a **Secret** named `db-credentials` in Namespace `aquila` with:
   - `DB_USER`: `admin`
   - `DB_PASSWORD`: `galaxy-secret-2024`

2. Create a **Pod** named `secret-pod` in Namespace `aquila`:
   - Image: `busybox:1.35`
   - Command: `sleep 3600`
   - Environment variables from the Secret:
     - `DB_USER` from key `DB_USER`
     - `DB_PASSWORD` from key `DB_PASSWORD`

Verify the Pod is running with the correct environment variables.

---

## Question 8 | Service NodePort

| | |
|---|---|
| **Points** | 4/112 (4%) |
| **Namespace** | `draco` |
| **Resources** | Service `web-service`, Deployment `web-app` |

### Task

There is an existing **Deployment** named `web-app` in Namespace `draco` with label `app=web-app`.

Create a **NodePort Service** named `web-service` in Namespace `draco`:

| Configuration | Value |
|---------------|-------|
| Type | NodePort |
| Port | 80 |
| Target Port | 80 |
| Selector | `app=web-app` |

The Service should expose the Deployment's Pods on port 80.

---

## Question 9 | Pod to Deployment Conversion

| | |
|---|---|
| **Points** | 8/112 (7%) |
| **Namespace** | `phoenix` |
| **Resources** | Deployment `galaxy-api` (3 replicas) |
| **Template file** | `./exam/course/9/galaxy-api-pod.yaml` |
| **File to create** | `./exam/course/9/galaxy-api-deployment.yaml` |

### Task

In Namespace `phoenix` there is a single **Pod** named `galaxy-api`. The team needs it to be more reliable and scalable.

**Convert** the Pod into a **Deployment** named `galaxy-api` with **3 replicas** and delete the original Pod.

The template for the existing Pod is available at `./exam/course/9/galaxy-api-pod.yaml`.

In addition, the new Deployment should set the following **security context** on the container level:
- `allowPrivilegeEscalation: false`
- `privileged: false`

Please create the Deployment and save its YAML to `./exam/course/9/galaxy-api-deployment.yaml`.

---

## Question 10 | PV/PVC Creation

| | |
|---|---|
| **Points** | 6/112 (5%) |
| **Namespace** | `hydra` |
| **Resources** | PV `galaxy-pv`, PVC `galaxy-pvc`, Pod `storage-pod` |

### Task

Team Hydra needs persistent storage for their application.

1. Create a **PersistentVolume** named `galaxy-pv`:
   | Configuration | Value |
   |---------------|-------|
   | Capacity | `1Gi` |
   | AccessMode | `ReadWriteOnce` |
   | HostPath | `/data/galaxy` |
   | StorageClassName | `manual` |

2. Create a **PersistentVolumeClaim** named `galaxy-pvc` in Namespace `hydra`:
   | Configuration | Value |
   |---------------|-------|
   | Storage request | `1Gi` |
   | AccessMode | `ReadWriteOnce` |
   | StorageClassName | `manual` |

3. Create a **Pod** named `storage-pod` in Namespace `hydra`:
   - Image: `nginx:1.21-alpine`
   - Mount the PVC at `/usr/share/nginx/html`

Verify the PVC is bound and the Pod is running.

---

## Question 11 | NetworkPolicy

| | |
|---|---|
| **Points** | 6/112 (5%) |
| **Namespace** | `centaurus` |
| **Resources** | NetworkPolicy `allow-internal` |
| **File to create** | `./exam/course/11/networkpolicy.yaml` |

### Task

Team Centaurus needs to restrict network access to their backend Pods.

Create a **NetworkPolicy** named `allow-internal` in Namespace `centaurus` that:

1. Applies to Pods with label `app=backend`
2. Allows **Ingress** only from Pods with label `app=frontend` in the same namespace
3. Denies all other ingress traffic

Save the NetworkPolicy YAML to `./exam/course/11/networkpolicy.yaml`.

---

## Question 12 | Container Image Build

| | |
|---|---|
| **Points** | 7/112 (6%) |
| **Namespace** | `cassiopeia` |
| **Registry** | `localhost:5000` |
| **Source files** | `./exam/course/12/image/` |
| **File to create** | `./exam/course/12/logs` |

### Task

There are files to build a container image located at `./exam/course/12/image/`. The directory contains a Dockerfile and a simple Python application.

> Use `sudo docker` or `sudo podman` for container operations.

Perform the following tasks:

| # | Task |
|---|------|
| 1 | **Build** the container image with tag `localhost:5000/galaxy-app:v1` |
| 2 | **Push** the image to the local registry at `localhost:5000` |
| 3 | Create a **Pod** named `image-test-pod` in Namespace `cassiopeia` using image `localhost:5000/galaxy-app:v1` |
| 4 | Write the Pod **logs** to `./exam/course/12/logs` |

---

## Question 13 | Helm Operations

| | |
|---|---|
| **Points** | 5/112 (4%) |
| **Namespace** | `andromeda` |
| **Resources** | Helm releases |

### Task

Team Andromeda needs help managing their Helm releases. All operations should be in Namespace `andromeda`:

1. **Delete** the release `galaxy-nginx-v1`
2. **Upgrade** the release `galaxy-nginx-v2` to any newer version of its chart
3. **Install** a new release named `galaxy-redis` using chart `bitnami/redis` with **2 replicas** (set via Helm values)
4. There is a **broken release** stuck in `pending-install` state. Find it and delete it

---

## Question 14 | InitContainer

| | |
|---|---|
| **Points** | 5/112 (4%) |
| **Namespace** | `orion` |
| **Resources** | Deployment `init-app` |
| **Template file** | `./exam/course/14/init-app.yaml` |

### Task

There is a Deployment template at `./exam/course/14/init-app.yaml`. This Deployment runs nginx and serves content from a shared volume.

Add an **InitContainer** named `init-data`:
- Image: `busybox:1.35`
- Mount the same volume as the main container
- Create a file `/data/index.html` with content `Welcome to Galaxy!`

Apply the Deployment and verify the Pods are running with the InitContainer completing successfully.

---

## Question 15 | Sidecar Logging

| | |
|---|---|
| **Points** | 6/112 (5%) |
| **Namespace** | `pegasus` |
| **Resources** | Deployment `logger-app` |
| **File to create** | `./exam/course/15/logger-app.yaml` |

### Task

There is an existing **Deployment** named `logger-app` in Namespace `pegasus`. The main container writes logs to a file at `/var/log/app.log`.

Add a **sidecar container** named `log-sidecar`:
- Image: `busybox:1.35`
- Mount the same log volume
- Command: `tail -f /var/log/app.log` (streams logs to stdout)

This allows viewing logs via `kubectl logs -c log-sidecar`.

Save the updated Deployment YAML to `./exam/course/15/logger-app.yaml`.

---

## Question 16 | ServiceAccount Token

| | |
|---|---|
| **Points** | 2/112 (2%) |
| **Namespace** | `cygnus` |
| **Resources** | ServiceAccount `galaxy-sa` |
| **File to create** | `./exam/course/16/token` |

### Task

There is an existing **ServiceAccount** named `galaxy-sa` in Namespace `cygnus`.

A team member needs the token associated with this ServiceAccount.

Extract the **base64 decoded token** and save it to file `./exam/course/16/token`.

---

## Question 17 | Liveness Probe

| | |
|---|---|
| **Points** | 5/112 (4%) |
| **Namespace** | `lyra` |
| **Resources** | Pod `liveness-pod` |

### Task

Create a **Pod** named `liveness-pod` in Namespace `lyra` with a liveness probe:

| Configuration | Value |
|---------------|-------|
| Image | `nginx:1.21-alpine` |
| Probe type | HTTP GET |
| Path | `/` |
| Port | `80` |
| Initial delay | `10` seconds |
| Period | `5` seconds |

The liveness probe should check if nginx is responding correctly.

Verify the Pod is running and the liveness probe is passing.

---

## Question 18 | Readiness Probe

| | |
|---|---|
| **Points** | 5/112 (4%) |
| **Namespace** | `aquila` |
| **Resources** | Pod `readiness-pod` |

### Task

Create a **Pod** named `readiness-pod` in Namespace `aquila` with a readiness probe:

| Configuration | Value |
|---------------|-------|
| Image | `busybox:1.35` |
| Command | `touch /tmp/ready && sleep 3600` |
| Probe type | exec |
| Probe command | `cat /tmp/ready` |
| Initial delay | `5` seconds |
| Period | `10` seconds |

The readiness probe should check for the existence of `/tmp/ready`.

Verify the Pod becomes ready after the initial delay.

---

## Question 19 | Resource Limits

| | |
|---|---|
| **Points** | 5/112 (4%) |
| **Namespace** | `draco` |
| **Resources** | Deployment `resource-app` |

### Task

There is an existing **Deployment** named `resource-app` in Namespace `draco` that needs resource constraints.

Update the Deployment to set the following **resource requests and limits** on the container:

| Resource | Request | Limit |
|----------|---------|-------|
| Memory | `64Mi` | `128Mi` |
| CPU | `100m` | `200m` |

Verify the Deployment is running with the updated resource configuration.

---

## Question 20 | Labels and Selectors

| | |
|---|---|
| **Points** | 4/112 (4%) |
| **Namespace** | `phoenix` |
| **Resources** | Pod `labeled-pod` |
| **File to create** | `./exam/course/20/selected-pods.txt` |

### Task

Create a **Pod** named `labeled-pod` in Namespace `phoenix`:

| Configuration | Value |
|---------------|-------|
| Image | `nginx:1.21-alpine` |
| Labels | `app=galaxy`, `tier=frontend`, `version=v1` |

Then use **label selectors** to find all Pods in the cluster with label `app=galaxy` and save the output to `./exam/course/20/selected-pods.txt`.

---

## Question 21 | Rollback Deployment

| | |
|---|---|
| **Points** | 3/112 (3%) |
| **Namespace** | `hydra` |
| **Resources** | Deployment `rollback-app` |

### Task

There is an existing **Deployment** named `rollback-app` in Namespace `hydra`. A recent update used a broken image tag (`nginx:broken`) and the Pods are failing.

1. Check the Deployment **rollout history**
2. **Rollback** to the previous working revision
3. Verify the Deployment is running successfully after rollback

---

# Preview Questions

> These additional questions are not counted in the main score.

---

## Preview Question 1 | Startup Probe

| | |
|---|---|
| **Points** | 4 (not counted) |
| **Namespace** | `centaurus` |
| **Resources** | Pod `startup-pod` |

### Task

Create a **Pod** named `startup-pod` in Namespace `centaurus` with a startup probe:

| Configuration | Value |
|---------------|-------|
| Image | `nginx:1.21-alpine` |
| Probe type | HTTP GET |
| Path | `/` |
| Port | `80` |
| Failure threshold | `30` |
| Period | `10` seconds |

The startup probe allows the application up to 5 minutes (30 * 10s) to start before the liveness probe takes over.

Verify the Pod starts successfully with the startup probe.

---
