# CKAD Exam Simulator - Dojo Ryujin 🐲

> **Total Score**: 99 points | **Passing Score**: ~66% (65 points)
>
> *「龍神は波を操る」 - Ryujin commande les vagues*
>
> **Original Questions**: Adapted from [CKAD-exercises](https://github.com/dgkanatsios/CKAD-exercises) by [@dgkanatsios](https://github.com/dgkanatsios)
>
> **Local Simulator Adaptations**:
>
> | Original | Local Simulator |
> |----------|-----------------|
> | `/opt/course/N/` | `./exam/course/N/` |
> | Original registry | `localhost:5000` |
> | SSH to different instances | Single cluster (no SSH needed) |

---

## Question 1 | Helm Create Chart

| | |
|---|---|
| **Points** | 5 |
| **Namespace** | N/A |
| **Resources** | Helm chart `sea-app` |

### Task

Create a basic Helm chart named `sea-app` in `./exam/course/1/`.

The chart should be created with `helm create`.

**Hint**: Use `helm create sea-app`.

---

## Question 2 | Helm Install with Custom Values

| | |
|---|---|
| **Points** | 6 |
| **Namespace** | `tide` |
| **Resources** | Helm release `my-release` |

### Task

Install the `bitnami/nginx` chart in namespace `tide` with:

- Release name: `my-release`
- Set `replicaCount=2`

**Hint**: Use `helm install --set`.

---

## Question 3 | Helm Upgrade Release

| | |
|---|---|
| **Points** | 5 |
| **Namespace** | `tide` |
| **Resources** | Helm release `my-release` |

### Task

Upgrade the `my-release` Helm release in namespace `tide` to have `replicaCount=3`.

**Hint**: Use `helm upgrade --set`.

---

## Question 4 | Helm Rollback

| | |
|---|---|
| **Points** | 5 |
| **Namespace** | `wave` |
| **Resources** | Helm release `rollback-app` |

### Task

A Helm release `rollback-app` exists in namespace `wave` with revision 2.

Rollback to revision 1.

**Hint**: Use `helm rollback`.

---

## Question 5 | PersistentVolume Creation

| | |
|---|---|
| **Points** | 6 |
| **Namespace** | N/A (cluster-scoped) |
| **Resources** | PersistentVolume `sea-pv` |

### Task

Create a PersistentVolume named `sea-pv` with:

- Capacity: `5Gi`
- Access modes: `ReadWriteOnce`
- Storage class: `manual`
- Host path: `/data/sea`

**Hint**: PersistentVolumes are cluster-scoped (no namespace).

---

## Question 6 | PersistentVolumeClaim

| | |
|---|---|
| **Points** | 5 |
| **Namespace** | `depths` |
| **Resources** | PersistentVolumeClaim `sea-pvc` |

### Task

Create a PersistentVolumeClaim named `sea-pvc` in namespace `depths` that:

- Requests: `2Gi` storage
- Access mode: `ReadWriteOnce`
- Storage class: `manual`

**Hint**: The PVC should bind to the `sea-pv` PersistentVolume.

---

## Question 7 | Pod with PVC

| | |
|---|---|
| **Points** | 5 |
| **Namespace** | `depths` |
| **Resources** | Pod `pvc-pod` |

### Task

Create a Pod named `pvc-pod` in namespace `depths` that:

- Uses image `busybox:1.36` with command `sleep 3600`
- Mounts the PVC `sea-pvc` at `/data`

**Hint**: Use `spec.volumes` with `persistentVolumeClaim`.

---

## Question 8 | Pod with nodeName

| | |
|---|---|
| **Points** | 5 |
| **Namespace** | `coral` |
| **Resources** | Pod `direct-pod` |

### Task

Create a Pod named `direct-pod` in namespace `coral` with image `nginx:1.25` that is scheduled directly on a specific node using `nodeName`.

Use the first node in your cluster (get it with `kubectl get nodes`).

**Hint**: Use `spec.nodeName` in the Pod YAML.

---

## Question 9 | Pod Lifecycle - Echo and Exit

| | |
|---|---|
| **Points** | 4 |
| **Namespace** | `current` |
| **Resources** | Pod `echo-pod` |

### Task

Create a Pod named `echo-pod` in namespace `current` with image `busybox:1.36` that:

- Echoes "hello world"
- Then exits

The Pod should automatically be deleted when it completes (use `--rm` if using kubectl run interactively, or create normally).

**Hint**: Use `kubectl run` with the echo command.

---

## Question 10 | Get Pod YAML

| | |
|---|---|
| **Points** | 4 |
| **Namespace** | `abyss` |
| **Resources** | Pod `inspect-pod`, file `./exam/course/10/pod.yaml` |

### Task

1. Create a Pod named `inspect-pod` with image `nginx:1.25` in namespace `abyss`
2. Export its YAML to `./exam/course/10/pod.yaml`

**Hint**: Use `kubectl get pod -o yaml`.

---

## Question 11 | Describe Pod and Find Events

| | |
|---|---|
| **Points** | 5 |
| **Namespace** | `pearl` |
| **Resources** | file `./exam/course/11/events.txt` |

### Task

A Pod named `problem-pod` exists in namespace `pearl` but is not running correctly.

1. Describe the Pod
2. Save the Events section to `./exam/course/11/events.txt`

**Hint**: Use `kubectl describe pod` and grep for events.

---

## Question 12 | Execute Command in Pod

| | |
|---|---|
| **Points** | 4 |
| **Namespace** | `storm` |
| **Resources** | Pod `exec-pod`, file `./exam/course/12/hostname.txt` |

### Task

1. Create a Pod named `exec-pod` with image `nginx:1.25` in namespace `storm`
2. Execute the `hostname` command inside the Pod
3. Save the output to `./exam/course/12/hostname.txt`

**Hint**: Use `kubectl exec`.

---

## Question 13 | Get Previous Container Logs

| | |
|---|---|
| **Points** | 5 |
| **Namespace** | `harbor` |
| **Resources** | Pod `restart-pod`, file `./exam/course/13/previous.txt` |

### Task

A Pod named `restart-pod` exists in namespace `harbor` and has been restarted.

Get the logs from the previous container instance and save to `./exam/course/13/previous.txt`.

**Hint**: Use `kubectl logs --previous`.

---

## Question 14 | Top Nodes

| | |
|---|---|
| **Points** | 4 |
| **Namespace** | N/A |
| **Resources** | file `./exam/course/14/nodes.txt` |

### Task

Get the CPU and memory utilization of all nodes and save to `./exam/course/14/nodes.txt`.

**Note**: This requires metrics-server to be running.

**Hint**: Use `kubectl top nodes`.

---

## Question 15 | ConfigMap from .env File

| | |
|---|---|
| **Points** | 5 |
| **Namespace** | `voyage` |
| **Resources** | ConfigMap `env-config`, file `./exam/course/15/config.env` |

### Task

1. Create a file `./exam/course/15/config.env` with content:

   ```
   DB_HOST=localhost
   DB_PORT=5432
   ```

2. Create a ConfigMap named `env-config` in namespace `voyage` from this .env file

**Hint**: Use `kubectl create configmap --from-env-file`.

---

## Question 16 | Deployment Rollout to Specific Revision

| | |
|---|---|
| **Points** | 5 |
| **Namespace** | `tide` |
| **Resources** | Deployment `web-deploy` |

### Task

A Deployment `web-deploy` exists in namespace `tide` with multiple revisions.

Rollback to revision `2`.

**Hint**: Use `kubectl rollout undo --to-revision`.

---

## Question 17 | Check Rollout History Details

| | |
|---|---|
| **Points** | 5 |
| **Namespace** | `wave` |
| **Resources** | file `./exam/course/17/revision.txt` |

### Task

A Deployment `history-deploy` exists in namespace `wave`.

Get the details of revision `3` and save to `./exam/course/17/revision.txt`.

**Hint**: Use `kubectl rollout history --revision`.

---

## Question 18 | Job with Perl Image

| | |
|---|---|
| **Points** | 5 |
| **Namespace** | `coral` |
| **Resources** | Job `pi-job` |

### Task

Create a Job named `pi-job` in namespace `coral` that:

- Uses image `perl:5.34`
- Runs the command: `perl -Mbignum=bpi -wle 'print bpi(100)'`
- Calculates Pi to 100 decimal places

**Hint**: This is a compute-intensive task.

---

## Question 19 | Multi-Container Pod with Shared Volume

| | |
|---|---|
| **Points** | 6 |
| **Namespace** | `abyss` |
| **Resources** | Pod `sidecar-pod` |

### Task

Create a Pod named `sidecar-pod` in namespace `abyss` with:

**Container 1 (main):**

- Name: `app`
- Image: `busybox:1.36`
- Command: `while true; do echo "$(date)" >> /logs/app.log; sleep 5; done`
- Mount volume at `/logs`

**Container 2 (sidecar):**

- Name: `sidecar`
- Image: `busybox:1.36`
- Command: `tail -f /logs/app.log`
- Mount same volume at `/logs`

Use an emptyDir volume named `log-volume`.

**Hint**: Sidecar pattern for log streaming.

---

## Question 20 | Resource Utilization of Pods

| | |
|---|---|
| **Points** | 5 |
| **Namespace** | `storm` |
| **Resources** | file `./exam/course/20/top-pods.txt` |

### Task

Get the CPU and memory utilization of all Pods in namespace `storm` and save to `./exam/course/20/top-pods.txt`.

**Note**: This requires metrics-server to be running.

**Hint**: Use `kubectl top pods -n storm`.
