# CKAD Exam Simulator - Dojo Kappa 🐸

> **Total Score**: 88 points | **Passing Score**: ~66% (58 points)
>
> *「河童は水を知る」 - Le kappa connait les eaux*
>
> **Original Questions**: Adapted from [CKAD-Practice-Questions](https://github.com/aravind4799/CKAD-Practice-Questions) by [@aravind4799](https://github.com/aravind4799)
>
> **Local Simulator Adaptations**:
>
> | Original | Local Simulator |
> |----------|-----------------|
> | `/opt/course/N/` | `./exam/course/N/` |
> | Original registry | `localhost:5000` |
> | SSH to different instances | Single cluster (no SSH needed) |

---

## Question 1 | Secret from Hardcoded Variables

| | |
|---|---|
| **Points** | 4/88 (5%) |
| **Namespace** | `stream` |
| **Resources** | Secret `db-credentials`, Deployment `api-server` |
| **Files** | - |

### Task

In namespace `stream`, Deployment `api-server` exists with hard-coded environment variables:

- `DB_USER=admin`
- `DB_PASS=Secret123!`

Your tasks:

1. Create a Secret named **`db-credentials`** in namespace `stream` containing these credentials
2. Update Deployment `api-server` to use the Secret via `valueFrom.secretKeyRef`
3. Do not change the Deployment name or namespace

---

## Question 2 | CronJob with Schedule and History Limits

| | |
|---|---|
| **Points** | 8/88 (9%) |
| **Namespace** | `pond` |
| **Resources** | CronJob `backup-job` |
| **Files** | - |

### Task

Create a CronJob named **`backup-job`** in namespace `pond` with the following specifications:

- Schedule: Run every 30 minutes (`*/30 * * * *`)
- Image: `busybox:latest`
- Container name: `backup`
- Container command: `echo "Backup completed"`
- Set `successfulJobsHistoryLimit: 3`
- Set `failedJobsHistoryLimit: 2`
- Set `activeDeadlineSeconds: 300`
- Use `restartPolicy: Never`

**Tip:** Use `kubectl explain cronjob.spec` to find the correct field names.

---

## Question 3 | ServiceAccount, Role, and RoleBinding

| | |
|---|---|
| **Points** | 8/88 (9%) |
| **Namespace** | `marsh` |
| **Resources** | ServiceAccount `log-sa`, Role `log-role`, RoleBinding `log-rb`, Pod `log-collector` |
| **Files** | - |

### Task

In namespace `marsh`, Pod `log-collector` exists but is failing with authorization errors.

Check the Pod logs to identify what permissions are needed. The logs show:

```
User "system:serviceaccount:marsh:default" cannot list pods in the namespace "marsh"
```

Your tasks:

1. Create a ServiceAccount named **`log-sa`** in namespace `marsh`
2. Create a Role **`log-role`** that grants `get`, `list`, and `watch` on resource `pods`
3. Create a RoleBinding **`log-rb`** binding `log-role` to `log-sa`
4. Update Pod `log-collector` to use ServiceAccount `log-sa` (delete and recreate if needed)

---

## Question 4 | Fix Broken Pod with Correct ServiceAccount

| | |
|---|---|
| **Points** | 4/88 (5%) |
| **Namespace** | `delta` |
| **Resources** | Pod `metrics-pod`, ServiceAccounts, Roles, RoleBindings |
| **Files** | - |

### Task

In namespace `delta`, Pod `metrics-pod` is using ServiceAccount `wrong-sa` and receiving authorization errors.

Multiple ServiceAccounts, Roles, and RoleBindings already exist in the namespace:

- ServiceAccounts: `monitor-sa`, `wrong-sa`, `admin-sa`
- Roles: `metrics-reader`, `full-access`, `view-only`
- RoleBindings: `monitor-binding`, `admin-binding`

Your tasks:

1. Identify which ServiceAccount/Role/RoleBinding combination has the correct permissions
2. Update Pod `metrics-pod` to use the correct ServiceAccount
3. Verify the Pod stops showing authorization errors

**Hint:** Check existing RoleBindings to see which ServiceAccount is bound to which Role.

---

## Question 5 | Build Container Image and Save as Tarball

| | |
|---|---|
| **Points** | 8/88 (9%) |
| **Namespace** | N/A (host system) |
| **Resources** | Container image `my-app:1.0` |
| **Files** | `./exam/course/5/image/Dockerfile` |

### Task

Directory `./exam/course/5/image/` contains a valid `Dockerfile`.

Your tasks:

1. Build a container image using Docker with name **`my-app:1.0`** using `./exam/course/5/image/` as build context
2. Save the image as a tarball to **`./exam/course/5/my-app.tar`**

---

## Question 6 | Canary Deployment with Manual Traffic Split

| | |
|---|---|
| **Points** | 8/88 (9%) |
| **Namespace** | `default` |
| **Resources** | Deployment `web-app`, Deployment `web-app-canary`, Service `web-service` |
| **Files** | - |

### Task

In namespace `default`, the following resources exist:

- Deployment `web-app` with 5 replicas, labels `app=webapp, version=v1`
- Service `web-service` with selector `app=webapp`

Your tasks:

1. Scale Deployment `web-app` to **8 replicas** (80% of 10 total)
2. Create a new Deployment **`web-app-canary`** with **2 replicas**, labels `app=webapp, version=v2`
3. Both Deployments should be selected by `web-service`

**Note:** This is a manual canary pattern where traffic is split based on replica counts.

---

## Question 7 | Fix NetworkPolicy by Updating Pod Labels

| | |
|---|---|
| **Points** | 8/88 (9%) |
| **Namespace** | `spring` |
| **Resources** | Pods `frontend`, `backend`, `database`, NetworkPolicies |
| **Files** | - |

### Task

In namespace `spring`, three Pods exist:

- `frontend` with label `role=wrong-frontend`
- `backend` with label `role=wrong-backend`
- `database` with label `role=wrong-db`

Three NetworkPolicies exist:

- `deny-all` (default deny)
- `allow-frontend-to-backend` (allows traffic from `role=frontend` to `role=backend`)
- `allow-backend-to-db` (allows traffic from `role=backend` to `role=db`)

Your task:

Update the **Pod labels** (do NOT modify NetworkPolicies) to enable the communication chain:

`frontend` → `backend` → `database`

**Time Saver Tip:** Use `kubectl label` instead of editing YAML.

---

## Question 8 | Fix Broken Deployment YAML

| | |
|---|---|
| **Points** | 4/88 (5%) |
| **Namespace** | `default` |
| **Resources** | Deployment `broken-app` |
| **Files** | `./exam/course/8/broken-deploy.yaml` |

### Task

File `./exam/course/8/broken-deploy.yaml` contains a Deployment manifest that fails to apply.

The file has the following issues:

1. Uses deprecated API version
2. Missing required `selector` field
3. Selector doesn't match template labels

Your tasks:

1. Fix the YAML file to use `apiVersion: apps/v1`
2. Add a proper `selector` field that matches the template labels
3. Apply the fixed manifest and ensure the Deployment is running

---

## Question 9 | Perform Rolling Update and Rollback

| | |
|---|---|
| **Points** | 8/88 (9%) |
| **Namespace** | `brook` |
| **Resources** | Deployment `app-v1` |
| **Files** | `./exam/course/9/rollback-revision.txt` |

### Task

In namespace `brook`, Deployment `app-v1` exists with image `nginx:1.20`.

Your tasks:

1. Update the Deployment to use image **`nginx:1.25`**
2. Verify the rolling update completes successfully
3. Rollback to the **previous revision**
4. Verify the rollback completed
5. Save the current revision number to **`./exam/course/9/rollback-revision.txt`**

---

## Question 10 | Add Readiness Probe to Deployment

| | |
|---|---|
| **Points** | 4/88 (5%) |
| **Namespace** | `rapids` |
| **Resources** | Deployment `api-deploy` |
| **Files** | - |

### Task

In namespace `rapids`, Deployment `api-deploy` exists with a container listening on port `8080`.

Your task:

Add a readiness probe to the Deployment with:

- HTTP GET on path `/ready`
- Port `8080`
- `initialDelaySeconds: 5`
- `periodSeconds: 10`

Ensure the Deployment rolls out successfully.

---

## Question 11 | Configure Pod and Container Security Context

| | |
|---|---|
| **Points** | 6/88 (7%) |
| **Namespace** | `cascade` |
| **Resources** | Deployment `secure-app` |
| **Files** | - |

### Task

In namespace `cascade`, Deployment `secure-app` exists without any security context.

Your tasks:

1. Set Pod-level **`runAsUser: 1000`**
2. Add container-level capability **`NET_ADMIN`** to the container named `app`

**Note:** Capabilities are set at the container level, not the Pod level.

---

## Question 12 | Fix Service Selector

| | |
|---|---|
| **Points** | 2/88 (2%) |
| **Namespace** | `shoal` |
| **Resources** | Deployment `web-app`, Service `web-svc` |
| **Files** | - |

### Task

In namespace `shoal`, Deployment `web-app` exists with Pods labeled `app=webapp, tier=frontend`.

Service `web-svc` exists but has incorrect selector `app=wrongapp`.

Your task:

Update Service `web-svc` to correctly select Pods from Deployment `web-app`.

---

## Question 13 | Create NodePort Service

| | |
|---|---|
| **Points** | 4/88 (5%) |
| **Namespace** | `default` |
| **Resources** | Deployment `api-server`, Service `api-nodeport` |
| **Files** | - |

### Task

In namespace `default`, Deployment `api-server` exists with Pods labeled `app=api` and container port `9090`.

Your task:

Create a Service named **`api-nodeport`** that:

- Type: `NodePort`
- Selects Pods with label `app=api`
- Exposes Service port **`80`** mapping to target port **`9090`**

---

## Question 14 | Create Ingress Resource

| | |
|---|---|
| **Points** | 4/88 (5%) |
| **Namespace** | `eddy` |
| **Resources** | Ingress `web-ingress`, Service `web-svc` |
| **Files** | - |

### Task

In namespace `eddy`, the following resources exist:

- Deployment `web-deploy` with Pods labeled `app=web`
- Service `web-svc` with selector `app=web` on port `8080`

Your task:

Create an Ingress named **`web-ingress`** that:

- Routes host **`web.example.com`**
- Path `/` with `pathType: Prefix`
- Backend Service `web-svc` on port `8080`
- Uses API version `networking.k8s.io/v1`

---

## Question 15 | Fix Ingress PathType

| | |
|---|---|
| **Points** | 4/88 (5%) |
| **Namespace** | `default` |
| **Resources** | Ingress `api-ingress`, Service `api-svc` |
| **Files** | `./exam/course/15/fix-ingress.yaml` |

### Task

File `./exam/course/15/fix-ingress.yaml` contains an Ingress manifest that fails to apply due to an invalid `pathType` value.

Your tasks:

1. Apply the file and note the error
2. Fix the `pathType` to a valid value (`Prefix`, `Exact`, or `ImplementationSpecific`)
3. Ensure the Ingress routes path `/api` to Service `api-svc` on port `8080`
4. Apply the fixed manifest successfully

---

## Question 16 | Add Resource Requests and Limits to Pod

| | |
|---|---|
| **Points** | 4/88 (5%) |
| **Namespace** | `pond` |
| **Resources** | ResourceQuota, Pod `resource-pod` |
| **Files** | - |

### Task

In namespace `pond`, a ResourceQuota exists that sets resource limits for the namespace.

Your tasks:

1. Check the ResourceQuota for namespace `pond` to see the limits set
2. Create a Pod named **`resource-pod`** with:
   - Image: `nginx:latest`
   - Container name: `web`
   - Set the CPU and memory limits to **half** of the limits set in the ResourceQuota
   - Set appropriate requests (at least `100m` CPU and `128Mi` memory)

---

## Preview Question 1 | Pod Topology Spread Constraints

| | |
|---|---|
| **Points** | 3 (bonus) |
| **Namespace** | `eddy` |
| **Resources** | Pod `spread-pod` |
| **Files** | - |

### Task

Create a Pod named **`spread-pod`** in namespace `eddy` with:

- Image: `nginx`
- Topology spread constraint that spreads across nodes with `maxSkew: 1`
- Use `topologyKey: kubernetes.io/hostname`
- `whenUnsatisfiable: DoNotSchedule`

**Note:** This is a preview question for advanced topics.
