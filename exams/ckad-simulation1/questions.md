# CKAD Exam Simulator - Questions

> **Total Score**: 113 points | **Passing Score**: ~66% (75 points)
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
| **Points** | 1/113 (1%) |
| **Namespace** | - |
| **File to create** | `./exam/course/1/namespaces` |

### Task

The DevOps team would like to get the list of all **Namespaces** in the cluster.

The list can contain other columns like STATUS or AGE.

Save the list to `./exam/course/1/namespaces`.

---

## Question 2 | Pods

| | |
|---|---|
| **Points** | 5/113 (4%) |
| **Namespace** | `default` |
| **Resources** | Pod `pod1` |
| **File to create** | `./exam/course/2/pod1-status-command.sh` |

### Task

Create a single **Pod** of image `httpd:2.4.41-alpine` in Namespace `default`. The Pod should be named `pod1` and the container should be named `pod1-container`.

Your manager would like to run a command manually on occasion to output the status of that exact Pod. Please write a command that does this into `./exam/course/2/pod1-status-command.sh`. The command should use `kubectl`.

---

## Question 3 | Job

| | |
|---|---|
| **Points** | 6/113 (5%) |
| **Namespace** | `neptune` |
| **Resources** | Job `neb-new-job` |
| **File to create** | `./exam/course/3/job.yaml` |

### Task

Team Neptune needs a **Job** template located at `./exam/course/3/job.yaml`. This Job should run image `busybox:1.31.0` and execute `sleep 2 && echo done`. It should be in namespace `neptune`, run a total of **3 times** and should execute **2 runs in parallel**.

Start the Job and check its history. Each pod created by the Job should have the label `id: awesome-job`. The job should be named `neb-new-job` and the container `neb-new-job-container`.

---

## Question 4 | Helm Management

| | |
|---|---|
| **Points** | 5/113 (4%) |
| **Namespace** | `mercury` |
| **Resources** | Helm releases |

### Task

Team Mercury asked you to perform some operations using Helm, all in Namespace `mercury`:

1. **Delete** release `internal-issue-report-apiv1`
2. **Upgrade** release `internal-issue-report-apiv2` to any newer version of chart `bitnami/nginx` available
3. **Install** a new release `internal-issue-report-apache` of chart `bitnami/apache`. The Deployment should have **two replicas**, set these via Helm-values during install
4. There seems to be a **broken release**, stuck in `pending-install` state. Find it and delete it

---

## Question 5 | ServiceAccount, Secret

| | |
|---|---|
| **Points** | 1/113 (1%) |
| **Namespace** | `neptune` |
| **Resources** | ServiceAccount `neptune-sa-v2` |
| **File to create** | `./exam/course/5/token` |

### Task

Team Neptune has its own **ServiceAccount** named `neptune-sa-v2` in Namespace `neptune`. A coworker needs the token from the Secret that belongs to that ServiceAccount.

Write the **base64 decoded token** to file `./exam/course/5/token`.

---

## Question 6 | ReadinessProbe

| | |
|---|---|
| **Points** | 5/113 (4%) |
| **Namespace** | `default` |
| **Resources** | Pod `pod6` |

### Task

Create a single **Pod** named `pod6` in Namespace `default` of image `busybox:1.31.0`. The Pod should have a **readiness-probe** executing `cat /tmp/ready`. It should initially wait **5 seconds** and periodically wait **10 seconds**. This will set the container ready only if the file `/tmp/ready` exists.

The Pod should run the command `touch /tmp/ready && sleep 1d`, which will create the necessary file to be ready and then idles.

Create the Pod and confirm it starts.

---

## Question 7 | Pods, Namespaces

| | |
|---|---|
| **Points** | 6/113 (5%) |
| **Source Namespace** | `saturn` |
| **Target Namespace** | `neptune` |
| **Resources** | Pod `webserver-sat-003` |

### Task

The board of Team Neptune decided to take over control of one e-commerce webserver from Team Saturn. The administrator who once setup this webserver is not part of the organisation any longer. All information you could get was that the e-commerce system is called `my-happy-shop`.

Search for the correct **Pod** in Namespace `saturn` and **move it** to Namespace `neptune`. It doesn't matter if you shut it down and spin it up again, it probably hasn't any customers anyways.

---

## Question 8 | Deployment, Rollouts

| | |
|---|---|
| **Points** | 4/113 (4%) |
| **Namespace** | `neptune` |
| **Resources** | Deployment `api-new-c32` |

### Task

There is an existing **Deployment** named `api-new-c32` in Namespace `neptune`. A developer did make an update to the Deployment but the updated version never came online.

Check the Deployment **history** and find a revision that works, then **rollback** to it. Could you tell Team Neptune what the error was so it doesn't happen again?

---

## Question 9 | Pod → Deployment

| | |
|---|---|
| **Points** | 10/113 (9%) |
| **Namespace** | `pluto` |
| **Resources** | Deployment `holy-api` (3 replicas) |
| **Template file** | `./exam/course/9/holy-api-pod.yaml` |
| **File to create** | `./exam/course/9/holy-api-deployment.yaml` |

### Task

In Namespace `pluto` there is single **Pod** named `holy-api`. It has been working okay for a while now but Team Pluto needs it to be more reliable.

**Convert** the Pod into a **Deployment** named `holy-api` with **3 replicas** and delete the single Pod once done. The raw Pod template file is available at `./exam/course/9/holy-api-pod.yaml`.

In addition, the new Deployment should set:
- `allowPrivilegeEscalation: false`
- `privileged: false`

for the **security context** on container level.

Please create the Deployment and save its yaml under `./exam/course/9/holy-api-deployment.yaml`.

---

## Question 10 | Service, Logs

| | |
|---|---|
| **Points** | 9/113 (8%) |
| **Namespace** | `pluto` |
| **Resources** | Service `project-plt-6cc-svc`, Pod `project-plt-6cc-api` |
| **Files to create** | `./exam/course/10/service_test.html`, `./exam/course/10/service_test.log` |

### Task

Team Pluto needs a new cluster internal **Service**. Create a **ClusterIP Service** named `project-plt-6cc-svc` in Namespace `pluto`. This Service should expose a single Pod named `project-plt-6cc-api` of image `nginx:1.17.3-alpine`, create that Pod as well.

| Configuration | Value |
|---------------|-------|
| Pod label | `project: plt-6cc-api` |
| Service port | `3333:80` (TCP) |

Finally use for example `curl` from a temporary `nginx:alpine` Pod to get the response from the Service:
- Write the response into `./exam/course/10/service_test.html`
- Check the logs of Pod `project-plt-6cc-api` and write those into `./exam/course/10/service_test.log`

---

## Question 11 | Working with Containers

| | |
|---|---|
| **Points** | 7/113 (6%) |
| **Tools** | Docker, Podman |
| **Registry** | `localhost:5000` |
| **Source files** | `./exam/course/11/image/` |
| **File to create** | `./exam/course/11/logs` |

### Task

There are files to build a container image located at `./exam/course/11/image`. The container will run a Golang application which outputs information to stdout.

> ⚠️ Use `sudo docker` and `sudo podman` or become root with `sudo -i`

Perform the following tasks:

| # | Task |
|---|------|
| 1 | Modify the **Dockerfile**: set ENV variable `SUN_CIPHER_ID` to `5b9c1065-e39d-4a43-a04a-e59bcea3e03f` |
| 2 | **Build** with Docker, tag `localhost:5000/sun-cipher:v1-docker` and **push** |
| 3 | **Build** with Podman, tag `localhost:5000/sun-cipher:v1-podman` and **push** |
| 4 | **Run** a detached container with Podman named `sun-cipher` using image `localhost:5000/sun-cipher:v1-podman` |
| 5 | Write the container **logs** to `./exam/course/11/logs` |

---

## Question 12 | Storage, PV, PVC, Pod volume

| | |
|---|---|
| **Points** | 6/113 (5%) |
| **Namespace** | `earth` |
| **Resources** | PV, PVC, Deployment `project-earthflower` |

### Task

Create a new **PersistentVolume** named `earth-project-earthflower-pv`:

| Configuration | Value |
|---------------|-------|
| Capacity | `2Gi` |
| AccessMode | `ReadWriteOnce` |
| HostPath | `/Volumes/Data` |
| StorageClassName | (none) |

Next create a new **PersistentVolumeClaim** in Namespace `earth` named `earth-project-earthflower-pvc`:

| Configuration | Value |
|---------------|-------|
| Storage request | `2Gi` |
| AccessMode | `ReadWriteOnce` |
| StorageClassName | (none) |

The PVC should **bound** to the PV correctly.

Finally create a new **Deployment** `project-earthflower` in Namespace `earth` which mounts that volume at `/tmp/project-data`. The Pods should use image `httpd:2.4.41-alpine`.

---

## Question 13 | Storage, StorageClass, PVC

| | |
|---|---|
| **Points** | 6/113 (5%) |
| **Namespace** | `moon` |
| **Resources** | StorageClass `moon-retain`, PVC `moon-pvc-126` |
| **File to create** | `./exam/course/13/pvc-126-reason` |

### Task

Team Moonpie, which has the Namespace `moon`, needs more storage.

Create a new **StorageClass** `moon-retain`:

| Configuration | Value |
|---------------|-------|
| Provisioner | `moon-retainer` |
| ReclaimPolicy | `Retain` |

Create a new **PersistentVolumeClaim** named `moon-pvc-126` in namespace `moon`:

| Configuration | Value |
|---------------|-------|
| Storage request | `3Gi` |
| AccessMode | `ReadWriteOnce` |
| StorageClassName | `moon-retain` |

The provisioner `moon-retainer` will be created by another team, so it's expected that the PVC will **not boot yet** (status: Pending).

Confirm this by writing the **event message** from the PVC into file `./exam/course/13/pvc-126-reason`.

---

## Question 14 | Secret, Secret-Volume, Secret-Env

| | |
|---|---|
| **Points** | 8/113 (7%) |
| **Namespace** | `moon` |
| **Resources** | Secrets `secret1`, `secret2`, Pod `secret-handler` |
| **Template files** | `./exam/course/14/secret-handler.yaml`, `./exam/course/14/secret2.yaml` |
| **File to create** | `./exam/course/14/secret-handler-new.yaml` |

### Task

You need to make changes on an existing **Pod** in Namespace `moon` called `secret-handler`.

**Part 1 - Secret as Environment Variables:**
Create a new Secret `secret1` with:
- `user=test`
- `pass=pwd`

The Secret's content should be available in Pod `secret-handler` as environment variables:
- `SECRET1_USER`
- `SECRET1_PASS`

**Part 2 - Secret as Volume:**
There is existing yaml for another Secret at `./exam/course/14/secret2.yaml`. Create this Secret and **mount** it inside the same Pod at `/tmp/secret2`.

Save your changes under `./exam/course/14/secret-handler-new.yaml`. Both Secrets should only be available in Namespace `moon`.

---

## Question 15 | ConfigMap, Configmap-Volume

| | |
|---|---|
| **Points** | 3/113 (3%) |
| **Namespace** | `moon` |
| **Resources** | ConfigMap `configmap-web-moon-html`, Deployment `web-moon` |

### Task

Team Moonpie has a nginx server **Deployment** called `web-moon` in Namespace `moon`. Someone started configuring it but it was never completed.

To complete please create a **ConfigMap** called `configmap-web-moon-html` containing the content of file `./exam/course/15/web-moon.html` under the data key-name `index.html`.

The Deployment `web-moon` is already configured to work with this ConfigMap and serve its content. Test the nginx configuration using `curl` from a temporary `nginx:alpine` Pod.

---

## Question 16 | Logging sidecar

| | |
|---|---|
| **Points** | 6/113 (5%) |
| **Namespace** | `mercury` |
| **Resources** | Deployment `cleaner` |
| **Template file** | `./exam/course/16/cleaner.yaml` |
| **File to create** | `./exam/course/16/cleaner-new.yaml` |

### Task

The Tech Lead of Mercury2D decided it's time for more logging. There is an existing container named `cleaner-con` in Deployment `cleaner` in Namespace `mercury`. This container mounts a volume and writes logs into a file called `cleaner.log`.

The yaml for the existing Deployment is available at `./exam/course/16/cleaner.yaml`. Persist your changes at `./exam/course/16/cleaner-new.yaml` but also make sure the Deployment is running.

Create a **sidecar container** named `logger-con`:
- Image: `busybox:1.31.0`
- Mount the same volume
- Command: `tail -f /var/log/cleaner/cleaner.log` (writes to stdout)

This way logs can be picked up by `kubectl logs`. Check if the logs reveal something about the missing data incidents.

---

## Question 17 | InitContainer

| | |
|---|---|
| **Points** | 5/113 (4%) |
| **Namespace** | `mars` |
| **Resources** | Deployment `test-init-container` |
| **Template file** | `./exam/course/17/test-init-container.yaml` |

### Task

There is a Deployment yaml at `./exam/course/17/test-init-container.yaml`. This Deployment spins up a single Pod of image `nginx:1.17.3-alpine` and serves files from a mounted volume, which is empty right now.

Create an **InitContainer** named `init-con`:
- Image: `busybox:1.31.0`
- Mount the same volume
- Create a file `index.html` with content `check this out!` in the root of the mounted volume

Test your implementation using `curl` from a temporary `nginx:alpine` Pod.

---

## Question 18 | Service misconfiguration

| | |
|---|---|
| **Points** | 2/113 (2%) |
| **Namespace** | `mars` |
| **Resources** | Service `manager-api-svc`, Deployment `manager-api-deployment` |

### Task

There seems to be an issue in Namespace `mars` where the ClusterIP service `manager-api-svc` should make the Pods of Deployment `manager-api-deployment` available inside the cluster.

You can test this with:
```bash
curl manager-api-svc.mars:4444
```
from a temporary `nginx:alpine` Pod.

Check for the **misconfiguration** and apply a fix.

---

## Question 19 | Service ClusterIP → NodePort

| | |
|---|---|
| **Points** | 2/113 (2%) |
| **Namespace** | `jupiter` |
| **Resources** | Service `jupiter-crew-svc`, Deployment `jupiter-crew-deploy` |

### Task

In Namespace `jupiter` you'll find an apache Deployment (with one replica) named `jupiter-crew-deploy` and a ClusterIP Service called `jupiter-crew-svc` which exposes it.

**Change** this service to a **NodePort** one to make it available on all nodes on port **30100**.

Test the NodePort Service using the internal IP of all available nodes and the port 30100 using `curl`. On which nodes is the Service reachable? On which node is the Pod running?

---

## Question 20 | NetworkPolicy

| | |
|---|---|
| **Points** | 5/113 (4%) |
| **Namespace** | `venus` |
| **Resources** | NetworkPolicy `np1`, Deployments `api`, `frontend` |

### Task

In Namespace `venus` you'll find two Deployments named `api` and `frontend`. Both Deployments are exposed inside the cluster using Services.

Create a **NetworkPolicy** named `np1` which:
- Restricts **outgoing** tcp connections from Deployment `frontend`
- Only allows connections going to Deployment `api`
- Still allows outgoing traffic on **UDP/TCP ports 53** for DNS resolution

Test using:
```bash
# From a Pod of Deployment frontend:
wget www.google.com    # Should FAIL
wget api:2222          # Should SUCCEED
```

---

## Question 21 | Requests and Limits, ServiceAccount

| | |
|---|---|
| **Points** | 8/113 (7%) |
| **Namespace** | `neptune` |
| **Resources** | Deployment `neptune-10ab` |

### Task

Team Neptune needs 3 Pods of image `httpd:2.4-alpine`, create a **Deployment** named `neptune-10ab` for this.

| Configuration | Value |
|---------------|-------|
| Replicas | `3` |
| Container name | `neptune-pod-10ab` |
| Memory request | `20Mi` |
| Memory limit | `50Mi` |
| ServiceAccount | `neptune-sa-v2` |

The Deployment should be in Namespace `neptune`.

---

## Question 22 | Labels, Annotations

| | |
|---|---|
| **Points** | 3/113 (3%) |
| **Namespace** | `sun` |

### Task

Team Sunny needs to identify some of their Pods in namespace `sun`.

1. Add label `protected: true` to all Pods with existing label:
   - `type: worker` OR
   - `type: runner`

2. Add annotation `protected: do not delete this pod` to all Pods having the new label `protected: true`

---

# Preview Questions

> These additional questions are not counted in the main score.

---

## Preview Question 1 | Liveness Probe

| | |
|---|---|
| **Namespace** | `shell-intern` |
| **Resources** | Deployment `project-23-api` |
| **Template file** | `./exam/course/p1/project-23-api.yaml` |

### Task

In Namespace `shell-intern` there is a Deployment named `project-23-api`. The Pods have not been scheduled yet.

There is a template file at `./exam/course/p1/project-23-api.yaml`. Configure the Deployment to use a **liveness probe**:

| Configuration | Value |
|---------------|-------|
| Path | `/health` |
| Port | `80` |
| Period | `10` seconds |
| Initial delay | `15` seconds |

Apply the changes and verify the Pods are running.

---

## Preview Question 2 | CronJob

| | |
|---|---|
| **Namespace** | `default` |
| **Resources** | CronJob `hello` |

### Task

Create a **CronJob** named `hello` in Namespace `default` that runs **every minute**.

| Configuration | Value |
|---------------|-------|
| Command | `echo "Hello from Kubernetes cluster"` |
| Container name | `hello` |
| Image | `busybox:1.28` |
| Restart policy | `OnFailure` |

---

## Preview Question 3 | Multi-container Pod

| | |
|---|---|
| **Namespace** | `default` |
| **Resources** | Pod `multi-container-pod` |

### Task

Create a **Pod** named `multi-container-pod` in Namespace `default` with two containers:

| Container | Image |
|-----------|-------|
| `nginx-container` | `nginx:1.17.6-alpine` |
| `redis-container` | `redis:5.0.4-alpine` |

Both containers should be in the same Pod and should be able to communicate with each other.
