# CKAD Exam Simulator - Simulation 4 (Norse Mythology)

> **Total Score**: 115 points | **Passing Score**: ~66% (76 points)
>
> **Local Simulator Adaptations**:
> | Original | Local Simulator |
> |----------|-----------------|
> | `/opt/course/N/` | `./exam/course/N/` |
> | Original registry | `localhost:5000` |
> | SSH to different instances | Single cluster (no SSH needed) |

---

## Question 1 | Multi-Container Pod

| | |
|---|---|
| **Points** | 5/115 (4%) |
| **Namespace** | `odin` |
| **Resources** | Pod `ravens-pod` |
| **Template file** | `./exam/course/1/ravens-pod.yaml` |

### Task

Odin, the All-father, has two ravens named Huginn and Muninn who gather information from the nine realms.

Create a **multi-container Pod** named `ravens-pod` in Namespace `odin` with two containers:

1. **Container `huginn`**: image `nginx:1.21-alpine`, serving content on port 80
2. **Container `muninn`**: image `busybox:1.35`, running command `while true; do wget -qO- http://localhost:80 >> /var/log/raven.log; sleep 5; done`

Both containers should share an **emptyDir** volume mounted at `/var/log` to share the log file.

Use the template at `./exam/course/1/ravens-pod.yaml` and save your final Pod YAML there.

---

## Question 2 | Job

| | |
|---|---|
| **Points** | 5/115 (4%) |
| **Namespace** | `thor` |
| **Resources** | Job `mjolnir-forge` |
| **File to create** | `./exam/course/2/job.yaml` |

### Task

The dwarves need to forge Mjolnir for Thor. Create a **Job** named `mjolnir-forge` in Namespace `thor`.

The Job should:
- Use image `busybox:1.35`
- Execute command: `echo "Forging Mjolnir..." && sleep 3 && echo "Mjolnir complete!"`
- Run a total of **4 completions**
- Run **2 in parallel**
- Have container name `forge-container`
- Have label `dwarf: brokkr` on the Pod template

Save the Job YAML to `./exam/course/2/job.yaml` and create the Job.

---

## Question 3 | Init Container

| | |
|---|---|
| **Points** | 5/115 (4%) |
| **Namespace** | `loki` |
| **Resources** | Pod `shapeshifter` |

### Task

Loki is a shapeshifter who needs to prepare his disguise before appearing.

Create a **Pod** named `shapeshifter` in Namespace `loki` with:

1. **Init container `prepare-disguise`**: image `busybox:1.35`, runs `echo "Preparing disguise..." && sleep 5 && echo ready > /shared/status`
2. **Main container `loki-main`**: image `nginx:1.21-alpine`

Both containers should share an **emptyDir** volume named `shared-data` mounted at `/shared`.

The main container should only start after the init container completes successfully.

---

## Question 4 | CronJob

| | |
|---|---|
| **Points** | 5/115 (4%) |
| **Namespace** | `freya` |
| **Resources** | CronJob `blessing-ritual` |
| **File to create** | `./exam/course/4/cronjob.yaml` |

### Task

Freya performs blessing rituals at regular intervals for love and fertility.

Create a **CronJob** named `blessing-ritual` in Namespace `freya` that:
- Runs **every 15 minutes** (schedule: `*/15 * * * *`)
- Uses image `busybox:1.35`
- Executes: `echo "Freya's blessing at $(date)"`
- Has container name `ritual-container`
- Keeps only **3 successful** job histories
- Keeps only **1 failed** job history

Save the CronJob YAML to `./exam/course/4/cronjob.yaml` and create it.

---

## Question 5 | PersistentVolume and PVC

| | |
|---|---|
| **Points** | 6/115 (5%) |
| **Namespace** | `heimdall` |
| **Resources** | PV `bifrost-storage`, PVC `bifrost-claim` |
| **Template file** | `./exam/course/5/pv-pvc.yaml` |

### Task

Heimdall guards the Bifrost bridge and needs persistent storage for his observations.

1. Create a **PersistentVolume** named `bifrost-storage`:
   - Capacity: **500Mi**
   - Access mode: **ReadWriteOnce**
   - Host path: `/data/bifrost`
   - Storage class: `manual`

2. Create a **PersistentVolumeClaim** named `bifrost-claim` in Namespace `heimdall`:
   - Request: **200Mi**
   - Access mode: **ReadWriteOnce**
   - Storage class: `manual`

Verify the PVC is bound to the PV. Use template at `./exam/course/5/pv-pvc.yaml`.

---

## Question 6 | StorageClass

| | |
|---|---|
| **Points** | 4/115 (3%) |
| **Namespace** | `baldur` |
| **Resources** | StorageClass `light-storage` |
| **File to create** | `./exam/course/6/storageclass.yaml` |

### Task

Baldur, the god of light, needs a special storage class for his radiant data.

Create a **StorageClass** named `light-storage` with:
- Provisioner: `kubernetes.io/no-provisioner`
- Volume binding mode: `WaitForFirstConsumer`
- Reclaim policy: `Retain`
- Parameters: `type: local`

Save the YAML to `./exam/course/6/storageclass.yaml` and create the StorageClass.

---

## Question 7 | Deployment with Strategy

| | |
|---|---|
| **Points** | 5/115 (4%) |
| **Namespace** | `tyr` |
| **Resources** | Deployment `warrior-legion` |
| **File to create** | `./exam/course/7/deployment.yaml` |

### Task

Tyr, the god of war, commands a legion of warriors that must be deployed strategically.

Create a **Deployment** named `warrior-legion` in Namespace `tyr`:
- Image: `nginx:1.21-alpine`
- Replicas: **4**
- Container name: `warrior`
- Container port: **80**
- Deployment strategy: **RollingUpdate** with `maxSurge: 1` and `maxUnavailable: 1`
- Label on pods: `legion: einherjar`

Save to `./exam/course/7/deployment.yaml` and create the Deployment.

---

## Question 8 | Scale Deployment

| | |
|---|---|
| **Points** | 5/115 (4%) |
| **Namespace** | `njord` |
| **Resources** | Deployment `sea-fleet` (pre-existing) |
| **File to create** | `./exam/course/8/scale-command.sh` |

### Task

Njord, the god of the sea, has a fleet that needs to be scaled for an upcoming voyage.

There is an existing **Deployment** named `sea-fleet` in Namespace `njord` with 2 replicas.

1. **Scale** the Deployment to **5 replicas**
2. Write the kubectl command used to `./exam/course/8/scale-command.sh`
3. Verify all 5 pods are running

---

## Question 9 | Deployment Rollback

| | |
|---|---|
| **Points** | 6/115 (5%) |
| **Namespace** | `njord` |
| **Resources** | Deployment `voyage-app` (pre-existing, broken) |
| **File to create** | `./exam/course/9/rollback-command.sh` |

### Task

A sailor made an update to the `voyage-app` Deployment in Namespace `njord`, but the new version has a broken image and pods are failing.

1. Check the **rollout history** of the Deployment
2. **Rollback** to the previous working revision
3. Write the rollback command to `./exam/course/9/rollback-command.sh`
4. Verify the Deployment is healthy again

---

## Question 10 | Helm Management

| | |
|---|---|
| **Points** | 5/115 (4%) |
| **Namespace** | `asgard` |
| **Resources** | Helm releases |

### Task

The Asgardian DevOps team needs help managing Helm releases in Namespace `asgard`:

1. **Delete** release `asgard-web-v1`
2. **Upgrade** release `asgard-web-v2` to any newer version of chart `bitnami/nginx` available
3. **Install** a new release `asgard-gateway` of chart `bitnami/apache` with **2 replicas** (set via Helm values)
4. Find and **delete** a broken release stuck in `pending-install` state

---

## Question 11 | ClusterIP Service

| | |
|---|---|
| **Points** | 5/115 (4%) |
| **Namespace** | `thor` |
| **Resources** | Service `thunder-svc`, Pod `lightning-pod` (pre-existing) |
| **File to create** | `./exam/course/11/service.yaml` |

### Task

Thor's lightning needs to be accessible within the cluster.

There is an existing Pod `lightning-pod` in Namespace `thor` with label `app: lightning`.

Create a **ClusterIP Service** named `thunder-svc` in Namespace `thor`:
- Selector: `app: lightning`
- Port: **8080** → targetPort: **80**
- Protocol: TCP

Save to `./exam/course/11/service.yaml`. Verify the service has endpoints.

---

## Question 12 | NetworkPolicy

| | |
|---|---|
| **Points** | 6/115 (5%) |
| **Namespace** | `freya` |
| **Resources** | NetworkPolicy `love-protection` |
| **Pre-existing** | Pods with labels `role: lover` and `role: protector` |

### Task

Freya's realm needs protection. Only certain pods should be able to communicate.

Create a **NetworkPolicy** named `love-protection` in Namespace `freya`:

1. Apply to all pods with label `role: lover`
2. **Allow ingress** only from pods with label `role: protector` on port **80**
3. **Allow egress** to any pod in the same namespace on port **53** (DNS) and to pods with label `role: protector` on port **443**

Save to `./exam/course/12/networkpolicy.yaml`.

---

## Question 13 | Ingress

| | |
|---|---|
| **Points** | 5/115 (4%) |
| **Namespace** | `baldur` |
| **Resources** | Ingress `light-gateway` |
| **Template file** | `./exam/course/13/ingress.yaml` |
| **Pre-existing** | Service `radiance-svc` on port 80 |

### Task

Baldur's radiance needs to be exposed to the outside world.

Create an **Ingress** named `light-gateway` in Namespace `baldur`:
- Host: `baldur.asgard.local`
- Path: `/shine` (pathType: Prefix)
- Backend: Service `radiance-svc` on port **80**
- Ingress class: `nginx`

Use template at `./exam/course/13/ingress.yaml`.

---

## Question 14 | NodePort Service

| | |
|---|---|
| **Points** | 5/115 (4%) |
| **Namespace** | `asgard` |
| **Resources** | Service `realm-gateway`, Deployment `rainbow-bridge` (pre-existing) |
| **File to create** | `./exam/course/14/nodeport-service.yaml` |

### Task

The Rainbow Bridge (Bifrost) needs to be accessible from outside the cluster.

There is an existing Deployment `rainbow-bridge` in Namespace `asgard` with label `app: bifrost`.

Create a **NodePort Service** named `realm-gateway`:
- Selector: `app: bifrost`
- Port: **80** → targetPort: **80**
- NodePort: **30080**

Save to `./exam/course/14/nodeport-service.yaml`.

---

## Question 15 | RBAC Role and RoleBinding

| | |
|---|---|
| **Points** | 5/115 (4%) |
| **Namespace** | `odin` |
| **Resources** | Role `wisdom-role`, RoleBinding `wisdom-binding`, ServiceAccount `mimir-sa` |

### Task

Odin drinks from Mimir's well to gain wisdom. Create RBAC to allow Mimir access.

1. Create a **ServiceAccount** named `mimir-sa` in Namespace `odin`

2. Create a **Role** named `wisdom-role` in Namespace `odin` that allows:
   - `get`, `list`, `watch` on `pods`
   - `get`, `list` on `secrets`

3. Create a **RoleBinding** named `wisdom-binding` that binds `wisdom-role` to `mimir-sa`

---

## Question 16 | Secret

| | |
|---|---|
| **Points** | 5/115 (4%) |
| **Namespace** | `loki` |
| **Resources** | Secret `trick-secret`, Pod `trickster-pod` |

### Task

Loki needs to store his tricks securely and use them in a Pod.

1. Create a **Secret** named `trick-secret` in Namespace `loki` with:
   - `username: bGtpLXRyaWNrc3Rlcg==` (base64 encoded)
   - `password: c2hhcGVzaGlmdDEyMw==` (base64 encoded)

2. Create a **Pod** named `trickster-pod` with image `nginx:1.21-alpine` that:
   - Mounts the secret as a volume at `/etc/tricks`
   - Also exposes `username` as environment variable `TRICK_USER`

---

## Question 17 | SecurityContext

| | |
|---|---|
| **Points** | 6/115 (5%) |
| **Namespace** | `heimdall` |
| **Resources** | Pod `guardian-pod` |
| **File to create** | `./exam/course/17/secure-pod.yaml` |

### Task

Heimdall, the guardian, needs a secure Pod with specific capabilities.

Create a **Pod** named `guardian-pod` in Namespace `heimdall`:
- Image: `nginx:1.21-alpine`
- Container name: `guardian`

With **SecurityContext** at container level:
- `runAsUser: 1000`
- `runAsGroup: 3000`
- `allowPrivilegeEscalation: false`
- Capabilities: add `NET_BIND_SERVICE`, drop `ALL`

Save to `./exam/course/17/secure-pod.yaml`.

---

## Question 18 | ResourceQuota

| | |
|---|---|
| **Points** | 5/115 (4%) |
| **Namespace** | `tyr` |
| **Resources** | ResourceQuota `war-limits` |
| **File to create** | `./exam/course/18/quota.yaml` |

### Task

Tyr's war resources must be limited to prevent over-consumption.

Create a **ResourceQuota** named `war-limits` in Namespace `tyr`:
- Max pods: **10**
- Max CPU requests: **2** cores
- Max memory requests: **2Gi**
- Max CPU limits: **4** cores
- Max memory limits: **4Gi**

Save to `./exam/course/18/quota.yaml` and apply it.

---

## Question 19 | ConfigMap

| | |
|---|---|
| **Points** | 5/115 (4%) |
| **Namespace** | `njord` |
| **Resources** | ConfigMap `navigation-config`, Pod `navigator-pod` |

### Task

Njord's navigators need configuration for their sea voyages.

1. Create a **ConfigMap** named `navigation-config` in Namespace `njord` with:
   - `destination: midgard`
   - `route: coastal`
   - `speed: fast`

2. Create a **Pod** named `navigator-pod` with image `busybox:1.35` that:
   - Uses command: `env && sleep 3600`
   - Loads ALL ConfigMap keys as environment variables using `envFrom`

---

## Question 20 | Probes

| | |
|---|---|
| **Points** | 6/115 (5%) |
| **Namespace** | `asgard` |
| **Resources** | Pod `watchman-pod` |
| **File to create** | `./exam/course/20/probe-pod.yaml` |

### Task

Asgard needs a watchman Pod with proper health checks.

Create a **Pod** named `watchman-pod` in Namespace `asgard`:
- Image: `nginx:1.21-alpine`
- Container name: `watchman`

Configure:
1. **Readiness Probe**: HTTP GET on path `/` port 80, initialDelaySeconds: 5, periodSeconds: 10
2. **Liveness Probe**: HTTP GET on path `/` port 80, initialDelaySeconds: 15, periodSeconds: 20

Save to `./exam/course/20/probe-pod.yaml`.

---

## Question 21 | Debug Pod

| | |
|---|---|
| **Points** | 5/115 (4%) |
| **Namespace** | `asgard` |
| **Resources** | Pod `broken-valkyrie` (pre-existing, failing) |
| **Files to create** | `./exam/course/21/logs.txt`, `./exam/course/21/fix.txt` |

### Task

A Valkyrie Pod is failing and needs debugging.

There is a **Pod** named `broken-valkyrie` in Namespace `asgard` that is not starting correctly.

1. Get the **logs** of the failing Pod and save to `./exam/course/21/logs.txt`
2. **Describe** the Pod and identify the issue
3. Write a brief explanation of the problem to `./exam/course/21/fix.txt`
4. **Fix** the Pod by recreating it with the correct configuration

---

## Question 22 | Container Image Build

| | |
|---|---|
| **Points** | 6/115 (5%) |
| **Namespace** | `asgard` |
| **Resources** | Pod `runescript-pod` |
| **Template files** | `./exam/course/22/image/Dockerfile`, `./exam/course/22/image/app.sh` |

### Task

The Asgardians need a custom container image for their runescript application.

1. Build a container image using the **Dockerfile** at `./exam/course/22/image/`:
   - Tag the image as `localhost:5000/runescript:v1`

2. **Push** the image to the local registry at `localhost:5000`

3. Create a **Pod** named `runescript-pod` in Namespace `asgard`:
   - Image: `localhost:5000/runescript:v1`
   - Container name: `runescript`

Verify the Pod is running.
