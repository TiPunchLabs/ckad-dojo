# CKAD Exam Simulator - Dojo Inari 🦊

> **Total Score**: 104 points | **Passing Score**: ~66% (69 points)
>
> *「稲荷は豊穣を祝う」 - Inari célèbre l'abondance*
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

## Question 1 | Service ClusterIP and Endpoints

| | |
|---|---|
| **Points** | 5 |
| **Namespace** | `harvest` |
| **Resources** | Pod `web`, Service `web` |

### Task

1. Create a Pod named `web` with image `nginx` in namespace `harvest`, exposing port `80`
2. Create a ClusterIP Service named `web` that exposes the Pod on port `80`
3. Verify the Service has endpoints

**Hint**: Use `kubectl run --expose` or create resources separately.

---

## Question 2 | Convert Service to NodePort

| | |
|---|---|
| **Points** | 5 |
| **Namespace** | `grain` |
| **Resources** | Service `app-svc` |

### Task

A ClusterIP Service `app-svc` exists in namespace `grain`.

Convert this Service to a `NodePort` type.

**Hint**: Use `kubectl edit` or `kubectl patch`.

---

## Question 3 | Deployment with Service

| | |
|---|---|
| **Points** | 6 |
| **Namespace** | `rice` |
| **Resources** | Deployment `backend`, Service `backend` |

### Task

1. Create a Deployment named `backend` in namespace `rice` with image `nginx` and 3 replicas, exposing port `8080`
2. Create a Service named `backend` that exposes the Deployment on port `6262` targeting port `8080`

**Hint**: Use `kubectl create deployment` and `kubectl expose`.

---

## Question 4 | Readiness Probe HTTP

| | |
|---|---|
| **Points** | 5 |
| **Namespace** | `field` |
| **Resources** | Pod `ready-pod` |

### Task

Create a Pod named `ready-pod` in namespace `field` with image `nginx` that includes:

- Container port: `80`
- HTTP readiness probe on path `/` on port `80`

**Hint**: Use `spec.containers[].readinessProbe.httpGet`.

---

## Question 5 | Liveness Probe with Delay

| | |
|---|---|
| **Points** | 5 |
| **Namespace** | `shrine` |
| **Resources** | Pod `live-pod` |

### Task

Create a Pod named `live-pod` in namespace `shrine` with image `nginx` that includes:

- Liveness probe that executes the command `ls`
- Initial delay: `5` seconds
- Period: `10` seconds

**Hint**: Use `spec.containers[].livenessProbe.exec`.

---

## Question 6 | LimitRange for Namespace

| | |
|---|---|
| **Points** | 6 |
| **Namespace** | `blessing` |
| **Resources** | LimitRange `pod-limits` |

### Task

Create a LimitRange named `pod-limits` in namespace `blessing` that limits Pod memory to:

- Maximum: `500Mi`
- Minimum: `100Mi`

**Hint**: Use `kind: LimitRange` with `spec.limits` of `type: Pod`.

---

## Question 7 | ResourceQuota with Requests and Limits

| | |
|---|---|
| **Points** | 6 |
| **Namespace** | `fortune` |
| **Resources** | ResourceQuota `compute-quota` |

### Task

Create a ResourceQuota named `compute-quota` in namespace `fortune` with:

- Hard requests: `cpu=1`, `memory=1Gi`
- Hard limits: `cpu=2`, `memory=2Gi`

**Hint**: Use `requests.cpu`, `requests.memory`, `limits.cpu`, `limits.memory`.

---

## Question 8 | Pod within ResourceQuota

| | |
|---|---|
| **Points** | 5 |
| **Namespace** | `fortune` |
| **Resources** | Pod `quota-pod` |

### Task

In namespace `fortune` (which has a ResourceQuota), create a Pod named `quota-pod` with:

- Image: `nginx`
- Resource requests: `cpu=0.5`, `memory=512Mi`
- Resource limits: `cpu=1`, `memory=1Gi`

**Hint**: ResourceQuota requires Pods to specify requests and limits.

---

## Question 9 | Security Context with Capabilities

| | |
|---|---|
| **Points** | 6 |
| **Namespace** | `golden` |
| **Resources** | Pod `cap-pod` |

### Task

Create a Pod named `cap-pod` in namespace `golden` with image `nginx` that adds the capabilities:

- `NET_ADMIN`
- `SYS_TIME`

**Hint**: Use `securityContext.capabilities.add` at the container level.

---

## Question 10 | Shared Volume Between Containers

| | |
|---|---|
| **Points** | 6 |
| **Namespace** | `bounty` |
| **Resources** | Pod `shared-pod` |

### Task

Create a Pod named `shared-pod` in namespace `bounty` with two containers:

**Container 1:**

- Name: `writer`
- Image: `busybox`
- Command: `sleep 3600`
- Mount emptyDir volume at `/data`

**Container 2:**

- Name: `reader`
- Image: `busybox`
- Command: `sleep 3600`
- Mount same emptyDir volume at `/data`

Both containers should share the same `emptyDir` volume named `shared-data`.

**Hint**: Use `spec.volumes` and `volumeMounts` in each container.

---

## Question 11 | Annotations

| | |
|---|---|
| **Points** | 4 |
| **Namespace** | `prosperity` |
| **Resources** | Pod `annotated-pod` |

### Task

1. Create a Pod named `annotated-pod` with image `nginx` in namespace `prosperity`
2. Add the annotation `owner=marketing` to the Pod

**Hint**: Use `kubectl annotate` or add `metadata.annotations` in YAML.

---

## Question 12 | Labels Selection

| | |
|---|---|
| **Points** | 5 |
| **Namespace** | `harvest` |
| **Resources** | Pods, file `./exam/course/12/pods.txt` |

### Task

1. Create 3 Pods in namespace `harvest`: `pod1`, `pod2`, `pod3` all with image `nginx`
2. Label `pod1` and `pod2` with `env=prod`
3. Label `pod3` with `env=dev`
4. List all Pods with label `env=prod` and save the output to `./exam/course/12/pods.txt`

**Hint**: Use `kubectl get pods -l env=prod`.

---

## Question 13 | Helm Add Repository

| | |
|---|---|
| **Points** | 4 |
| **Namespace** | N/A |
| **Resources** | Helm repo `bitnami` |

### Task

Add the Bitnami Helm repository to your Helm configuration:

- Name: `bitnami`
- URL: `https://charts.bitnami.com/bitnami`

**Hint**: Use `helm repo add`.

---

## Question 14 | Helm Show Values

| | |
|---|---|
| **Points** | 5 |
| **Namespace** | N/A |
| **Resources** | file `./exam/course/14/values.txt` |

### Task

Get the values of the `bitnami/nginx` Helm chart and save them to `./exam/course/14/values.txt`.

Only save the first 50 lines.

**Hint**: Use `helm show values`.

---

## Question 15 | Helm List Releases

| | |
|---|---|
| **Points** | 4 |
| **Namespace** | N/A |
| **Resources** | file `./exam/course/15/releases.txt` |

### Task

List all Helm releases across all namespaces and save to `./exam/course/15/releases.txt`.

**Hint**: Use `helm list -A`.

---

## Question 16 | Canary Deployment Setup

| | |
|---|---|
| **Points** | 6 |
| **Namespace** | `grain` |
| **Resources** | Deployments `app-v1`, `app-v2`, Service `app` |

### Task

Set up a canary deployment in namespace `grain`:

1. Create Deployment `app-v1` with image `nginx:1.18.0`, 3 replicas, label `app=myapp` and `version=v1`
2. Create Deployment `app-v2` with image `nginx:1.19.0`, 1 replica, label `app=myapp` and `version=v2`
3. Create a Service `app` that selects Pods with label `app=myapp` (both versions)

This achieves a 75%-25% traffic split.

**Hint**: The Service selector should only match on `app=myapp`, not version.

---

## Question 17 | emptyDir Volume for Data Sharing

| | |
|---|---|
| **Points** | 5 |
| **Namespace** | `rice` |
| **Resources** | Pod `data-pod` |

### Task

Create a Pod named `data-pod` in namespace `rice` with:

- Two containers: `producer` and `consumer`
- Both use image `busybox` with command `sleep 3600`
- Both mount an emptyDir volume at `/shared`
- Volume name: `data-volume`

**Hint**: Use `spec.volumes` with `emptyDir: {}`.

---

## Question 18 | Pod DNS Resolution

| | |
|---|---|
| **Points** | 5 |
| **Namespace** | `field` |
| **Resources** | file `./exam/course/18/dns.txt` |

### Task

A Service named `web-svc` exists in namespace `field`.

From a temporary busybox Pod, resolve the DNS name of this Service and save the IP to `./exam/course/18/dns.txt`.

**Hint**: Use `nslookup web-svc.field.svc.cluster.local`.

---

## Question 19 | Network Policy Allow Specific Label

| | |
|---|---|
| **Points** | 6 |
| **Namespace** | `shrine` |
| **Resources** | NetworkPolicy `db-policy` |

### Task

Create a NetworkPolicy named `db-policy` in namespace `shrine` that:

- Applies to Pods with label `app=db`
- Only allows ingress traffic from Pods with label `access=true`

**Hint**: Use `spec.podSelector` and `spec.ingress.from.podSelector`.

---

## Question 20 | Generate API Token for ServiceAccount

| | |
|---|---|
| **Points** | 5 |
| **Namespace** | `blessing` |
| **Resources** | ServiceAccount `token-sa`, file `./exam/course/20/token.txt` |

### Task

1. Create a ServiceAccount named `token-sa` in namespace `blessing`
2. Generate an API token for this ServiceAccount and save it to `./exam/course/20/token.txt`

**Hint**: Use `kubectl create token`.
