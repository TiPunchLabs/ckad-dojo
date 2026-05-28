# CKAD Exam Simulator - Dojo Amaterasu ☀️

> **Total Score**: 104 points | **Passing Score**: ~66% (69 points)
>
> *「天照は光を導く」 - Amaterasu guides the light*

---

## Question 1 | Build Container Image and Save as Tarball (6 points)

|                     |                                          |
| ------------------- | ---------------------------------------- |
| **Points**    | 6                                        |
| **CNCF Domain** | Application Design and Build |
| **CNCF Weight** | 20% |
| **Namespace** | -                                        |
| **Resources** | Container image `solar-app:1.0`          |
| **Files**     | `./exam/course/1/image/Dockerfile`, `./exam/course/1/image/index.html` |

### Task

Directory `./exam/course/1/image/` contains a `Dockerfile` and an `index.html` file.

Your tasks:

1. Build a container image using Docker with name **`solar-app:1.0`** using `./exam/course/1/image/` as build context
2. Save the image as a tarball to **`./exam/course/1/solar-app.tar`**

**Hint**: Use `docker build -t <name>:<tag> <context>` and `docker save -o <file> <image>`.

---

## Question 2 | Create Deployment with Labels and Annotations (4 points)

|                     |                             |
| ------------------- | --------------------------- |
| **Points**    | 4                           |
| **CNCF Domain** | Application Design and Build |
| **CNCF Weight** | 20% |
| **Namespace** | `solar`                   |
| **Resources** | Deployment `frontend-app` |

### Task

Create a Deployment named **`frontend-app`** in namespace `solar` with:

- Replicas: **3**
- Pod labels: `app=frontend, tier=web`
- Container name: `web`
- Image: `nginx:1.25`
- Container port: `80`
- Deployment annotation: `kubernetes.io/change-cause: "initial deployment"`

**Hint**: Use `kubectl create deployment` with `--dry-run=client -o yaml` to generate YAML, then add labels and annotations.

---

## Question 3 | Sidecar Container with Shared Volume (6 points)

|                     |                                  |
| ------------------- | -------------------------------- |
| **Points**    | 6                                |
| **CNCF Domain** | Application Design and Build |
| **CNCF Weight** | 20% |
| **Namespace** | `corona`                       |
| **Resources** | Pod `web-with-sidecar`         |

### Task

Create a Pod named **`web-with-sidecar`** in namespace `corona` with a main container and a **sidecar** that ships logs:

1. **Main container** named `app`:
   - Image: `nginx:1.25`
   - Mount shared volume at `/var/log/nginx`

2. **Sidecar container** named `log-shipper`:
   - Image: `busybox:1.36`
   - Command: `["/bin/sh", "-c", "tail -f /var/log/nginx/access.log 2>/dev/null || sleep 3600"]`
   - Mount shared volume at `/var/log/nginx`

3. Use an **`emptyDir`** volume named `log-volume` shared between both containers

**Hint**: Both containers must reference the same volume name in their `volumeMounts`.

---

## Question 4 | Create PVC and Mount in Pod (6 points)

|                     |                                               |
| ------------------- | --------------------------------------------- |
| **Points**    | 6                                             |
| **CNCF Domain** | Application Design and Build |
| **CNCF Weight** | 20% |
| **Namespace** | `aurora`                                    |
| **Resources** | PVC `app-data-pvc`, Pod `data-pod`, PV `app-data-pv` |

### Task

In the cluster, a PersistentVolume named **`app-data-pv`** (1Gi, ReadWriteOnce) already exists.

Your tasks:

1. Create a PersistentVolumeClaim named **`app-data-pvc`** in namespace `aurora` with:
   - Storage request: **500Mi**
   - Access mode: `ReadWriteOnce`
2. Create a Pod named **`data-pod`** in namespace `aurora` with:
   - Image: `nginx:1.25`
   - Container name: `web`
   - Mount `app-data-pvc` at **`/usr/share/nginx/html`**

**Hint**: Use `kubectl explain pvc.spec` to find the correct fields.

---

## Question 5 | Blue/Green Deployment (8 points)

|                     |                                                                  |
| ------------------- | ---------------------------------------------------------------- |
| **Points**    | 8                                                                |
| **CNCF Domain** | Application Deployment |
| **CNCF Weight** | 20% |
| **Namespace** | `flare`                                                        |
| **Resources** | Deployment `app-blue`, Deployment `app-green`, Service `webapp-svc` |

### Task

In namespace `flare`, the following resources exist:

- Deployment `app-blue` with 3 replicas, labels `app=webapp, version=blue`
- Service `webapp-svc` with selector `app=webapp, version=blue`

Implement a **Blue/Green deployment** by:

1. Create Deployment **`app-green`** with:
   - **3 replicas**
   - Pod labels: `app=webapp, version=green`
   - Image: `nginx:1.26`
   - Container name: `web`
2. Switch Service `webapp-svc` to point to the **green** version (change selector to `version=green`)
3. Scale Deployment `app-blue` to **0 replicas**

**Hint**: Edit the Service selector with `kubectl edit svc webapp-svc -n flare`.

---

## Question 6 | Configure Rolling Update Strategy (6 points)

|                     |                          |
| ------------------- | ------------------------ |
| **Points**    | 6                        |
| **CNCF Domain** | Application Deployment |
| **CNCF Weight** | 20% |
| **Namespace** | `dawn`                 |
| **Resources** | Deployment `api-app`   |

### Task

In namespace `dawn`, Deployment `api-app` exists with 4 replicas and the default rolling update strategy.

Your tasks:

1. Configure the rolling update strategy to:
   - `maxSurge: 1`
   - `maxUnavailable: 0`
2. Update the image to **`nginx:1.26`**
3. Verify the rolling update completes with zero downtime

**Tip**: This strategy ensures at least 4 pods are available at all times during the update.

---

## Question 7 | Deploy with Kustomize (6 points)

|                     |                                                      |
| ------------------- | ---------------------------------------------------- |
| **Points**    | 6                                                    |
| **CNCF Domain** | Application Deployment |
| **CNCF Weight** | 20% |
| **Namespace** | `zenith`                                           |
| **Resources** | Deployment `prod-web-app`, Service `prod-web-svc`  |
| **Files**     | `./exam/course/7/deployment.yaml`, `./exam/course/7/service.yaml` |

### Task

Directory `./exam/course/7/` contains two base Kubernetes manifests: `deployment.yaml` and `service.yaml`.

Your tasks:

1. Create a `kustomization.yaml` file in `./exam/course/7/` that:
   - References both `deployment.yaml` and `service.yaml` as resources
   - Adds a `namePrefix: prod-`
   - Sets the replica count to **3** using a patch
2. Apply using **`kubectl apply -k ./exam/course/7/`**
3. Verify that Deployment `prod-web-app` and Service `prod-web-svc` exist in namespace `zenith`

**Hint**: Use `kubectl kustomize ./exam/course/7/` to preview the output before applying.

---

## Question 8 | Helm Upgrade with Custom Values (4 points)

|                     |                                    |
| ------------------- | ---------------------------------- |
| **Points**    | 4                                  |
| **CNCF Domain** | Application Deployment |
| **CNCF Weight** | 20% |
| **Namespace** | `radiance`                       |
| **Resources** | Helm release `web-release`       |

### Task

In namespace `radiance`, a Helm release named **`web-release`** is installed.

Your tasks:

1. Inspect the current values of the release using `helm get values`
2. Upgrade the release to set **`replicaCount=3`**
3. Verify the upgrade is at **revision 2** or higher

**Hint**: Use `helm upgrade web-release <chart> -n radiance --set replicaCount=3 --reuse-values`.

---

## Question 9 | Add Startup Probe (4 points)

|                     |                            |
| ------------------- | -------------------------- |
| **Points**    | 4                          |
| **CNCF Domain** | Application Observability and Maintenance |
| **CNCF Weight** | 15% |
| **Namespace** | `eclipse`                |
| **Resources** | Deployment `slow-app`    |

### Task

In namespace `eclipse`, Deployment `slow-app` runs a slow-starting application on port `8080`.

Add a **startup probe** to the Deployment with:

- HTTP GET on path **`/healthz`**
- Port **`8080`**
- `failureThreshold: 30`
- `periodSeconds: 10`

Ensure the Deployment rolls out successfully.

**Tip**: Startup probes prevent liveness probes from killing slow-starting containers.

---

## Question 10 | Troubleshoot Pending Pod (6 points)

|                     |                                         |
| ------------------- | --------------------------------------- |
| **Points**    | 6                                       |
| **CNCF Domain** | Application Observability and Maintenance |
| **CNCF Weight** | 15% |
| **Namespace** | `solar`                               |
| **Resources** | Pod `stuck-pod`                       |
| **Files to create** | `./exam/course/10/pending-reason.txt` |

### Task

In namespace `solar`, Pod `stuck-pod` has been stuck in **Pending** state.

Your tasks:

1. Use `kubectl describe` and events to identify **why** the Pod is Pending
2. Save the `nodeSelector` key that causes the issue to **`./exam/course/10/pending-reason.txt`** (just the key name, e.g., `disktype`)
3. **Fix** the Pod so it enters Running state (delete and recreate without the problematic nodeSelector, or label a node to match)

---

## Question 11 | Extract Logs from Multi-container Pod (4 points)

|                     |                                          |
| ------------------- | ---------------------------------------- |
| **Points**    | 4                                        |
| **CNCF Domain** | Application Observability and Maintenance |
| **CNCF Weight** | 15% |
| **Namespace** | `corona`                               |
| **Resources** | Pod `multi-logger`                     |
| **Files to create** | `./exam/course/11/sidecar-logs.txt`    |

### Task

In namespace `corona`, Pod `multi-logger` runs with two containers: `app` and `sidecar`.

Your tasks:

1. Extract the **last 20 lines** of logs from the **`sidecar`** container
2. Save the output to **`./exam/course/11/sidecar-logs.txt`**

**Hint**: Use `kubectl logs <pod> -c <container> --tail=20` to select a specific container.

---

## Question 12 | Discover and Use Custom Resource Definition (6 points)

|                     |                                        |
| ------------------- | -------------------------------------- |
| **Points**    | 6                                      |
| **CNCF Domain** | Application Environment, Configuration and Security |
| **CNCF Weight** | 25% |
| **Namespace** | `aurora`                             |
| **Resources** | CRD `backups.ckad.example.com`, Backup `daily-backup` |
| **Files to create** | `./exam/course/12/crd-group.txt`     |

### Task

A Custom Resource Definition (CRD) has been installed in the cluster for managing backups.

Your tasks:

1. Discover the CRD using `kubectl get crd` and find the one related to backups
2. Save the CRD **group** (e.g., `ckad.example.com`) to **`./exam/course/12/crd-group.txt`**
3. Create a custom resource named **`daily-backup`** in namespace `aurora` with:
   - `apiVersion`: the CRD group + `/v1`
   - `kind`: `Backup`
   - `spec.schedule`: `"0 2 * * *"`
   - `spec.retentionDays`: `30`
   - `spec.storageLocation`: `"s3://backups/daily"`

**Hint**: Use `kubectl explain backup` after discovering the CRD to see available fields.

---

## Question 13 | Create TLS Secret (4 points)

|                     |                                      |
| ------------------- | ------------------------------------ |
| **Points**    | 4                                    |
| **CNCF Domain** | Application Environment, Configuration and Security |
| **CNCF Weight** | 25% |
| **Namespace** | `flare`                            |
| **Resources** | Secret `web-tls`                   |
| **Files**     | `./exam/course/13/tls.crt`, `./exam/course/13/tls.key` |

### Task

Files `./exam/course/13/tls.crt` and `./exam/course/13/tls.key` contain a TLS certificate and private key.

Create a **TLS Secret** named **`web-tls`** in namespace `flare` using these files.

**Hint**: Use `kubectl create secret tls` with `--cert` and `--key` flags.

---

## Question 14 | Harden Deployment with SecurityContext (4 points)

|                     |                              |
| ------------------- | ---------------------------- |
| **Points**    | 4                            |
| **CNCF Domain** | Application Environment, Configuration and Security |
| **CNCF Weight** | 25% |
| **Namespace** | `dawn`                     |
| **Resources** | Deployment `hardened-app`  |

### Task

In namespace `dawn`, Deployment `hardened-app` exists without any security hardening.

Add security constraints to the container named `app`:

1. **`runAsNonRoot: true`** at the Pod level
2. **`readOnlyRootFilesystem: true`** at the container level
3. Drop **all** capabilities: `drop: ["ALL"]` at the container level

Ensure the Deployment rolls out successfully after the changes.

**Hint**: Use `kubectl edit deploy hardened-app -n dawn` and add the securityContext fields.

---

## Question 15 | ServiceAccount with RBAC and Verification (6 points)

|                     |                                                                              |
| ------------------- | ---------------------------------------------------------------------------- |
| **Points**    | 6                                                                            |
| **CNCF Domain** | Application Environment, Configuration and Security |
| **CNCF Weight** | 25% |
| **Namespace** | `zenith`                                                                   |
| **Resources** | ServiceAccount `deploy-sa`, Role `deploy-role`, RoleBinding `deploy-rb`    |
| **Files to create** | `./exam/course/15/auth-check.txt`                                          |

### Task

Create RBAC resources in namespace `zenith` to allow a ServiceAccount to manage deployments:

1. Create ServiceAccount **`deploy-sa`**
2. Create Role **`deploy-role`** that grants `get`, `list`, `create`, and `update` on `deployments`
3. Create RoleBinding **`deploy-rb`** binding `deploy-role` to `deploy-sa`
4. Verify the permissions using `kubectl auth can-i list deployments --as=system:serviceaccount:zenith:deploy-sa -n zenith`
5. Save the output (`yes` or `no`) to **`./exam/course/15/auth-check.txt`**

**Hint**: Use `kubectl create role` and `kubectl create rolebinding` for quick imperative creation.

---

## Question 16 | ConfigMap from env-file (4 points)

|                     |                                     |
| ------------------- | ----------------------------------- |
| **Points**    | 4                                   |
| **CNCF Domain** | Application Environment, Configuration and Security |
| **CNCF Weight** | 25% |
| **Namespace** | `eclipse`                         |
| **Resources** | ConfigMap `app-config`, Pod `config-pod` |
| **Files**     | `./exam/course/16/app.env`        |

### Task

File `./exam/course/16/app.env` contains application configuration in key=value format.

Your tasks:

1. Create a ConfigMap named **`app-config`** in namespace `eclipse` from the env file
2. Create a Pod named **`config-pod`** in namespace `eclipse` with:
   - Image: `nginx:1.25`
   - Container name: `web`
   - Load **all** ConfigMap keys as environment variables using `envFrom`

**Hint**: Use `kubectl create configmap app-config --from-env-file=./exam/course/16/app.env`.

---

## Question 17 | Create docker-registry Secret (4 points)

|                     |                                |
| ------------------- | ------------------------------ |
| **Points**    | 4                              |
| **CNCF Domain** | Application Environment, Configuration and Security |
| **CNCF Weight** | 25% |
| **Namespace** | `radiance`                   |
| **Resources** | Secret `registry-creds`      |

### Task

Create a **docker-registry** Secret named **`registry-creds`** in namespace `radiance` with:

- Docker server: `registry.example.com`
- Username: `admin`
- Password: `s3cur3P@ss`

**Hint**: Use `kubectl create secret docker-registry` with `--docker-server`, `--docker-username`, and `--docker-password` flags.

---

## Question 18 | NetworkPolicy with ipBlock (6 points)

|                     |                                   |
| ------------------- | --------------------------------- |
| **Points**    | 6                                 |
| **CNCF Domain** | Services and Networking |
| **CNCF Weight** | 20% |
| **Namespace** | `sunbeam`                       |
| **Resources** | NetworkPolicy `api-allow`       |

### Task

In namespace `sunbeam`, Pod `api-server` (label `app=api`) and Pod `web-frontend` (label `role=frontend`) exist.

Create a NetworkPolicy named **`api-allow`** in namespace `sunbeam` that:

1. Targets Pods with label `app=api` (podSelector)
2. Allows **ingress** traffic only from:
   - Pods with label `role=frontend` (podSelector)
   - CIDR block **`10.0.0.0/24`** (ipBlock)
3. Allows ingress on port **80** (TCP)

**Hint**: Both `podSelector` and `ipBlock` rules go under `spec.ingress[0].from` as separate items.

---

## Question 19 | Ingress with TLS Termination (6 points)

|                     |                                                          |
| ------------------- | -------------------------------------------------------- |
| **Points**    | 6                                                        |
| **CNCF Domain** | Services and Networking |
| **CNCF Weight** | 20% |
| **Namespace** | `solstice`                                             |
| **Resources** | Ingress `secure-ingress`, Secret `secure-tls`, Service `secure-svc` |

### Task

In namespace `solstice`, the following resources exist:

- Service `secure-svc` on port 443 (targets port 80)
- TLS Secret `secure-tls` with a certificate for `secure.example.com`

Create an Ingress named **`secure-ingress`** in namespace `solstice` that:

1. Configures **TLS** for host `secure.example.com` using Secret `secure-tls`
2. Routes traffic for host `secure.example.com`:
   - Path `/` with `pathType: Prefix`
   - Backend: Service `secure-svc` on port **443**

---

## Question 20 | Fix Service and Verify DNS Resolution (4 points)

|                     |                                          |
| ------------------- | ---------------------------------------- |
| **Points**    | 4                                        |
| **CNCF Domain** | Services and Networking |
| **CNCF Weight** | 20% |
| **Namespace** | `sunbeam`                              |
| **Resources** | Deployment `dns-app`, Service `dns-svc` |
| **Files to create** | `./exam/course/20/dns-output.txt`      |

### Task

In namespace `sunbeam`, Deployment `dns-app` (labels `app=dns-app`) exists, but Service `dns-svc` has a wrong selector and no endpoints.

Your tasks:

1. Fix Service `dns-svc` to correctly select Pods from Deployment `dns-app`
2. Verify DNS resolution by running `nslookup dns-svc.sunbeam.svc.cluster.local` from a temporary Pod
3. Save the nslookup output to **`./exam/course/20/dns-output.txt`**

**Hint**: Use `kubectl run tmp-dns --rm -i --restart=Never --image=busybox:1.36 -- nslookup dns-svc.sunbeam.svc.cluster.local`.
