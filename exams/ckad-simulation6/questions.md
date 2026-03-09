# CKAD Exam Simulator - Dojo Tengu 👺

> **Total Score**: 100 points | **Passing Score**: ~66% (66 points)
>
> *「天狗は山を守る」 - Le tengu protège la montagne*
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

## Question 1 | Namespace and Pod Creation

| | |
|---|---|
| **Points** | 4 |
| **Namespace** | `mynamespace` |
| **Resources** | Namespace `mynamespace`, Pod `nginx` |

### Task

Create a namespace called `mynamespace` and a Pod with image `nginx:1.25` called `nginx` in this namespace.

The Pod should:

- Use the `nginx:1.25` image
- Have `restartPolicy: Never`

**Hint**: Use `kubectl create namespace` and `kubectl run` commands.

---

## Question 2 | Pod with Environment Variables

| | |
|---|---|
| **Points** | 5 |
| **Namespace** | `summit` |
| **Resources** | Pod `envpod` |

### Task

Create a Pod named `envpod` in namespace `summit` with the following specifications:

- Image: `busybox:1.36`
- Command: `env` (to print environment variables)
- Environment variable: `VAR1=value1`
- `restartPolicy: Never`

**Hint**: Use `--env` flag with `kubectl run`.

---

## Question 3 | ResourceQuota

| | |
|---|---|
| **Points** | 6 |
| **Namespace** | `cliff` |
| **Resources** | ResourceQuota `cliff-quota` |

### Task

Create a ResourceQuota named `cliff-quota` in namespace `cliff` with the following hard limits:

| Resource | Limit |
|----------|-------|
| CPU | `1` |
| Memory | `1G` |
| Pods | `2` |

**Hint**: Use `kubectl create quota` command.

---

## Question 4 | Labels and Selectors

| | |
|---|---|
| **Points** | 5 |
| **Namespace** | `ridge` |
| **Resources** | Pods `nginx1`, `nginx2`, `nginx3` |

### Task

In namespace `ridge`:

1. Create 3 Pods with names `nginx1`, `nginx2`, `nginx3` using image `nginx:1.25`. All of them should have the label `app=v1`
2. Change the label of Pod `nginx2` to `app=v2`
3. Add a new label `tier=web` to all Pods having label `app=v1`

**Hint**: Use `kubectl run` with `--labels` and `kubectl label` commands.

---

## Question 5 | Deployment Creation

| | |
|---|---|
| **Points** | 6 |
| **Namespace** | `valley` |
| **Resources** | Deployment `nginx-deploy` |

### Task

Create a Deployment named `nginx-deploy` in namespace `valley` with:

- Image: `nginx:1.18.0`
- Replicas: `2`
- Container port: `80`

Do NOT create a Service for this Deployment.

**Hint**: Use `kubectl create deployment` command.

---

## Question 6 | Deployment Rollout

| | |
|---|---|
| **Points** | 5 |
| **Namespace** | `valley` |
| **Resources** | Deployment `nginx-deploy` |

### Task

The Deployment `nginx-deploy` from Question 5 exists in namespace `valley`.

1. Update the image to `nginx:1.19.8`
2. Verify the rollout completed successfully
3. Check the rollout history

**Hint**: Use `kubectl set image` and `kubectl rollout` commands.

---

## Question 7 | Deployment Rollback

| | |
|---|---|
| **Points** | 5 |
| **Namespace** | `cave` |
| **Resources** | Deployment `rollback-deploy` |

### Task

A Deployment `rollback-deploy` exists in namespace `cave` with a wrong image `nginx:1.91` causing pods to fail.

1. Identify that the rollout has failed
2. Rollback to the previous working revision
3. Verify the rollback was successful and pods are running

**Hint**: Use `kubectl rollout undo` command.

---

## Question 8 | Job with Completions

| | |
|---|---|
| **Points** | 5 |
| **Namespace** | `stone` |
| **Resources** | Job `echo-job` |

### Task

Create a Job named `echo-job` in namespace `stone` that:

- Uses image `busybox:1.36`
- Runs the command: `echo hello; sleep 5; echo world`
- Should complete `5` times sequentially (one after the other)

**Hint**: Use `spec.completions` field.

---

## Question 9 | CronJob

| | |
|---|---|
| **Points** | 5 |
| **Namespace** | `mist` |
| **Resources** | CronJob `date-job` |

### Task

Create a CronJob named `date-job` in namespace `mist` that:

- Uses image `busybox:1.36`
- Runs every minute (`*/1 * * * *`)
- Executes the command: `date; echo Hello from Kubernetes`

**Hint**: Use `kubectl create cronjob` command.

---

## Question 10 | Multi-Container Pod

| | |
|---|---|
| **Points** | 6 |
| **Namespace** | `alpine` |
| **Resources** | Pod `multi-container` |

### Task

Create a Pod named `multi-container` in namespace `alpine` with two containers:

**Container 1:**

- Name: `container1`
- Image: `busybox:1.36`
- Command: `echo hello; sleep 3600`

**Container 2:**

- Name: `container2`
- Image: `busybox:1.36`
- Command: `echo hello; sleep 3600`

**Hint**: Generate YAML with `--dry-run=client -o yaml` and add the second container.

---

## Question 11 | Init Container

| | |
|---|---|
| **Points** | 6 |
| **Namespace** | `crest` |
| **Resources** | Pod `init-pod` |

### Task

Create a Pod named `init-pod` in namespace `crest` with:

**Main container:**

- Name: `nginx`
- Image: `nginx:1.25`
- Port: `80`
- Volume mount: `/usr/share/nginx/html`

**Init container:**

- Name: `init`
- Image: `busybox:1.36`
- Command: `echo "Initialized" > /work-dir/index.html`
- Volume mount: `/work-dir`

Both containers should share an `emptyDir` volume.

**Hint**: Use `initContainers` field in the Pod spec.

---

## Question 12 | ConfigMap from Literals

| | |
|---|---|
| **Points** | 4 |
| **Namespace** | `peak` |
| **Resources** | ConfigMap `app-config` |

### Task

Create a ConfigMap named `app-config` in namespace `peak` with the following key-value pairs:

- `foo=lala`
- `foo2=lolo`

**Hint**: Use `kubectl create configmap --from-literal`.

---

## Question 13 | ConfigMap as Environment Variable

| | |
|---|---|
| **Points** | 5 |
| **Namespace** | `summit` |
| **Resources** | ConfigMap `options`, Pod `config-pod` |

### Task

1. Create a ConfigMap named `options` in namespace `summit` with value `var5=val5`
2. Create a Pod named `config-pod` with image `nginx:1.25` that loads the value from key `var5` into an environment variable called `OPTION`

**Hint**: Use `valueFrom.configMapKeyRef` in the Pod spec.

---

## Question 14 | ConfigMap as Volume

| | |
|---|---|
| **Points** | 5 |
| **Namespace** | `cliff` |
| **Resources** | ConfigMap `cmvolume`, Pod `vol-pod` |

### Task

1. Create a ConfigMap named `cmvolume` in namespace `cliff` with values `var8=val8` and `var9=val9`
2. Create a Pod named `vol-pod` with image `nginx:1.25` that mounts this ConfigMap as a volume at `/etc/lala`

**Hint**: Use `volumes` and `volumeMounts` in the Pod spec.

---

## Question 15 | Secret Creation and Usage

| | |
|---|---|
| **Points** | 5 |
| **Namespace** | `ridge` |
| **Resources** | Secret `mysecret`, Pod `secret-pod` |

### Task

1. Create a Secret named `mysecret` in namespace `ridge` with value `password=mypass`
2. Create a Pod named `secret-pod` with image `nginx:1.25` that mounts the Secret as a volume at `/etc/foo`

**Hint**: Use `kubectl create secret generic` and mount it as a volume.

---

## Question 16 | SecurityContext

| | |
|---|---|
| **Points** | 5 |
| **Namespace** | `valley` |
| **Resources** | Pod `secure-pod` |

### Task

Create a Pod named `secure-pod` in namespace `valley` with:

- Image: `busybox:1.36`
- Command: `sleep 3600`
- Run as user ID: `101`
- `restartPolicy: Never`

**Hint**: Use `spec.securityContext.runAsUser`.

---

## Question 17 | Resource Requests and Limits

| | |
|---|---|
| **Points** | 5 |
| **Namespace** | `cave` |
| **Resources** | Pod `resource-pod` |

### Task

Create a Pod named `resource-pod` in namespace `cave` with:

- Image: `nginx:1.25`
- Resource requests: `cpu=100m`, `memory=256Mi`
- Resource limits: `cpu=200m`, `memory=512Mi`

**Hint**: Use `spec.containers[].resources`.

---

## Question 18 | Liveness Probe

| | |
|---|---|
| **Points** | 5 |
| **Namespace** | `stone` |
| **Resources** | Pod `liveness-pod` |

### Task

Create a Pod named `liveness-pod` in namespace `stone` with:

- Image: `nginx:1.25`
- Liveness probe that executes the command `ls`
- Initial delay: `5` seconds
- Period: `5` seconds

**Hint**: Use `spec.containers[].livenessProbe.exec`.

---

## Question 19 | Service and NetworkPolicy

| | |
|---|---|
| **Points** | 6 |
| **Namespace** | `mist` |
| **Resources** | Deployment `web`, Service `web`, NetworkPolicy `web-policy` |

### Task

1. Create a Deployment named `web` in namespace `mist` with image `nginx:1.25` and 2 replicas
2. Expose it via a ClusterIP Service named `web` on port `80`
3. Create a NetworkPolicy named `web-policy` that only allows ingress traffic to this Deployment from Pods with label `access=granted`

**Hint**: Use `kubectl create deployment`, `kubectl expose`, and create a NetworkPolicy YAML.

---

## Question 20 | PersistentVolume and PersistentVolumeClaim

| | |
|---|---|
| **Points** | 8 |
| **Namespace** | `alpine` |
| **Resources** | PV `myvolume`, PVC `mypvc`, Pod `pv-pod` |

### Task

1. Create a PersistentVolume named `myvolume` with:
   - Capacity: `10Gi`
   - Access modes: `ReadWriteOnce`, `ReadWriteMany`
   - Storage class: `normal`
   - Host path: `/etc/foo`

2. Create a PersistentVolumeClaim named `mypvc` in namespace `alpine` with:
   - Request: `4Gi`
   - Access mode: `ReadWriteOnce`
   - Storage class: `normal`

3. Create a Pod named `pv-pod` in namespace `alpine` that uses the PVC and mounts it at `/etc/foo`

**Hint**: PersistentVolumes are cluster-scoped (no namespace).
