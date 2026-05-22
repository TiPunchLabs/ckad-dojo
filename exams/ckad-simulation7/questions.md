# CKAD Exam Simulator - Dojo Tanuki 🦝

> **Total Score**: 100 points | **Passing Score**: ~66% (66 points)
>
> *「狸は森に潜む」 - Le tanuki se cache dans la forêt*
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

## Question 1 | Pod with Exposed Port

| | |
|---|---|
| **Points** | 4 |
| **CNCF Domain** | Services and Networking |
| **CNCF Weight** | 20% |
| **Namespace** | `grove` |
| **Resources** | Pod `nginx`, Service `nginx` |

### Task

Create a Pod with image `nginx:1.25` called `nginx` in namespace `grove` and expose its port `80`.

The `--expose` flag should create both the Pod and a ClusterIP Service.

**Hint**: Use `kubectl run` with `--port` and `--expose` flags.

---

## Question 2 | Get Pod IP and Test Connectivity

| | |
|---|---|
| **Points** | 5 |
| **CNCF Domain** | Services and Networking |
| **CNCF Weight** | 20% |
| **Namespace** | `thicket` |
| **Resources** | Pod `web`, file `./exam/course/2/pod-ip.txt` |

### Task

1. Create a Pod named `web` with image `nginx:1.25` in namespace `thicket`
2. Get the Pod's IP address and save it to `./exam/course/2/pod-ip.txt`
3. Verify connectivity by running a temporary `busybox:1.36` Pod that wget's the IP

**Hint**: Use `kubectl get pod -o wide` or `-o jsonpath` to get the IP.

---

## Question 3 | Pod Logs

| | |
|---|---|
| **Points** | 4 |
| **CNCF Domain** | Application Observability and Maintenance |
| **CNCF Weight** | 15% |
| **Namespace** | `glade` |
| **Resources** | Pod `logger`, file `./exam/course/3/logs.txt` |

### Task

Create a Pod named `logger` in namespace `glade` with image `busybox:1.36` that runs the command:

```
i=0; while true; do echo "$i: $(date)"; i=$((i+1)); sleep 1; done
```

After the Pod is running, save the first 10 lines of logs to `./exam/course/3/logs.txt`.

**Hint**: Use `kubectl logs` to get Pod logs.

---

## Question 4 | Debug Pod with Error

| | |
|---|---|
| **Points** | 5 |
| **CNCF Domain** | Application Observability and Maintenance |
| **CNCF Weight** | 15% |
| **Namespace** | `meadow` |
| **Resources** | Pod `debug-pod`, file `./exam/course/4/error.txt` |

### Task

Create a Pod named `debug-pod` in namespace `meadow` with image `busybox:1.36` that runs the command `ls /notexist`.

1. Get the Pod's logs and save to `./exam/course/4/error.txt`
2. The file should contain the error message

**Hint**: Use `kubectl logs` to see the error output.

---

## Question 5 | Pod with Node Selector

| | |
|---|---|
| **Points** | 6 |
| **CNCF Domain** | Application Design and Build |
| **CNCF Weight** | 20% |
| **Namespace** | `fern` |
| **Resources** | Pod `gpu-pod` |

### Task

Create a Pod named `gpu-pod` in namespace `fern` with image `nginx:1.25` that will be scheduled on a Node with the label `accelerator=nvidia`.

Use `nodeSelector` to achieve this.

**Note**: The Pod may remain Pending if no node has this label - that's expected.

**Hint**: Use `spec.nodeSelector` in the Pod YAML.

---

## Question 6 | Pod with Tolerations

| | |
|---|---|
| **Points** | 6 |
| **CNCF Domain** | Application Design and Build |
| **CNCF Weight** | 20% |
| **Namespace** | `moss` |
| **Resources** | Pod `tolerate-pod` |

### Task

Create a Pod named `tolerate-pod` in namespace `moss` with image `nginx:1.25` that tolerates the taint `tier=frontend:NoSchedule`.

The Pod should have:

- Toleration key: `tier`
- Toleration value: `frontend`
- Toleration effect: `NoSchedule`
- Toleration operator: `Equal`

**Hint**: Use `spec.tolerations` in the Pod YAML.

---

## Question 7 | Deployment with Replicas

| | |
|---|---|
| **Points** | 5 |
| **CNCF Domain** | Application Design and Build |
| **CNCF Weight** | 20% |
| **Namespace** | `root` |
| **Resources** | Deployment `app-deploy` |

### Task

Create a Deployment named `app-deploy` in namespace `root` with:

- Image: `nginx:1.18.0`
- Replicas: `3`
- Container port: `80`
- Label: `app=app-deploy`

Do NOT create a Service.

**Hint**: Use `kubectl create deployment` command.

---

## Question 8 | Scale Deployment

| | |
|---|---|
| **Points** | 4 |
| **CNCF Domain** | Application Deployment |
| **CNCF Weight** | 20% |
| **Namespace** | `root` |
| **Resources** | Deployment `app-deploy` |

### Task

The Deployment `app-deploy` from Question 7 exists in namespace `root`.

Scale the Deployment to `5` replicas.

**Hint**: Use `kubectl scale` command.

---

## Question 9 | Horizontal Pod Autoscaler

| | |
|---|---|
| **Points** | 6 |
| **CNCF Domain** | Application Deployment |
| **CNCF Weight** | 20% |
| **Namespace** | `root` |
| **Resources** | HorizontalPodAutoscaler `app-deploy` |

### Task

Create a HorizontalPodAutoscaler for Deployment `app-deploy` in namespace `root` with:

- Minimum replicas: `5`
- Maximum replicas: `10`
- Target CPU utilization: `80%`

**Hint**: Use `kubectl autoscale deployment` command.

---

## Question 10 | Deployment Rollout Pause and Resume

| | |
|---|---|
| **Points** | 6 |
| **CNCF Domain** | Application Deployment |
| **CNCF Weight** | 20% |
| **Namespace** | `bark` |
| **Resources** | Deployment `pause-deploy` |

### Task

A Deployment `pause-deploy` exists in namespace `bark` with image `nginx:1.18.0`.

1. Pause the rollout of the Deployment
2. Update the image to `nginx:1.19.0`
3. Verify that no new rollout started (check rollout history)
4. Resume the rollout
5. Verify the image was updated to `nginx:1.19.0`

**Hint**: Use `kubectl rollout pause` and `kubectl rollout resume`.

---

## Question 11 | Job with Parallelism

| | |
|---|---|
| **Points** | 5 |
| **CNCF Domain** | Application Design and Build |
| **CNCF Weight** | 20% |
| **Namespace** | `canopy` |
| **Resources** | Job `parallel-job` |

### Task

Create a Job named `parallel-job` in namespace `canopy` that:

- Uses image `busybox:1.36`
- Runs the command: `echo hello; sleep 5; echo world`
- Runs `5` Pods in parallel (parallelism)

**Hint**: Use `spec.parallelism` field.

---

## Question 12 | Job with Active Deadline

| | |
|---|---|
| **Points** | 5 |
| **CNCF Domain** | Application Design and Build |
| **CNCF Weight** | 20% |
| **Namespace** | `hollow` |
| **Resources** | Job `deadline-job` |

### Task

Create a Job named `deadline-job` in namespace `hollow` that:

- Uses image `busybox:1.36`
- Runs the command: `while true; do echo hello; sleep 10; done`
- Should be automatically terminated if it takes more than `30` seconds

**Hint**: Use `spec.activeDeadlineSeconds` field.

---

## Question 13 | CronJob with Starting Deadline

| | |
|---|---|
| **Points** | 5 |
| **CNCF Domain** | Application Design and Build |
| **CNCF Weight** | 20% |
| **Namespace** | `grove` |
| **Resources** | CronJob `deadline-cron` |

### Task

Create a CronJob named `deadline-cron` in namespace `grove` that:

- Uses image `busybox:1.36`
- Runs every minute (`* * * * *`)
- Executes: `date; echo Hello from CronJob`
- Should be terminated if it takes more than `17` seconds to start after its scheduled time

**Hint**: Use `spec.startingDeadlineSeconds` field.

---

## Question 14 | Create Job from CronJob

| | |
|---|---|
| **Points** | 4 |
| **CNCF Domain** | Application Design and Build |
| **CNCF Weight** | 20% |
| **Namespace** | `thicket` |
| **Resources** | CronJob `source-cron`, Job `manual-job` |

### Task

1. Create a CronJob named `source-cron` in namespace `thicket` with image `busybox:1.36`, schedule `*/5 * * * *`, command `echo "source job"`
2. Create a Job named `manual-job` from this CronJob

**Hint**: Use `kubectl create job --from=cronjob/NAME`.

---

## Question 15 | ConfigMap from File

| | |
|---|---|
| **Points** | 5 |
| **CNCF Domain** | Application Environment, Configuration & Security |
| **CNCF Weight** | 25% |
| **Namespace** | `glade` |
| **Resources** | ConfigMap `file-config`, file `./exam/course/15/config.txt` |

### Task

1. Create a file `./exam/course/15/config.txt` with content:

   ```
   foo3=lili
   foo4=lele
   ```

2. Create a ConfigMap named `file-config` in namespace `glade` from this file

**Hint**: Use `kubectl create configmap --from-file`.

---

## Question 16 | ConfigMap with envFrom

| | |
|---|---|
| **Points** | 5 |
| **CNCF Domain** | Application Environment, Configuration & Security |
| **CNCF Weight** | 25% |
| **Namespace** | `meadow` |
| **Resources** | ConfigMap `env-config`, Pod `env-pod` |

### Task

1. Create a ConfigMap named `env-config` in namespace `meadow` with values `var6=val6` and `var7=val7`
2. Create a Pod named `env-pod` with image `nginx:1.25` that loads ALL keys from this ConfigMap as environment variables (use `envFrom`)

**Hint**: Use `envFrom.configMapRef` in the Pod spec.

---

## Question 17 | Secret from File

| | |
|---|---|
| **Points** | 5 |
| **CNCF Domain** | Application Environment, Configuration & Security |
| **CNCF Weight** | 25% |
| **Namespace** | `fern` |
| **Resources** | Secret `file-secret`, file `./exam/course/17/username` |

### Task

1. Create a file `./exam/course/17/username` with content `admin`
2. Create a Secret named `file-secret` in namespace `fern` from this file

**Hint**: Use `kubectl create secret generic --from-file`.

---

## Question 18 | Secret as Environment Variable

| | |
|---|---|
| **Points** | 5 |
| **CNCF Domain** | Application Environment, Configuration & Security |
| **CNCF Weight** | 25% |
| **Namespace** | `moss` |
| **Resources** | Secret `api-secret`, Pod `api-pod` |

### Task

1. Create a Secret named `api-secret` in namespace `moss` with key `API_KEY=LmLHbYhsgWZwNifiqaRorH8T`
2. Create a Pod named `api-pod` with image `nginx:1.25` that loads this key into an environment variable called `API_KEY`

**Hint**: Use `env.valueFrom.secretKeyRef` in the Pod spec.

---

## Question 19 | ServiceAccount and Pod

| | |
|---|---|
| **Points** | 5 |
| **CNCF Domain** | Application Environment, Configuration & Security |
| **CNCF Weight** | 25% |
| **Namespace** | `root` |
| **Resources** | ServiceAccount `app-sa`, Pod `sa-pod` |

### Task

1. Create a ServiceAccount named `app-sa` in namespace `root`
2. Create a Pod named `sa-pod` with image `nginx:1.25` that uses this ServiceAccount

**Hint**: Use `spec.serviceAccountName` in the Pod spec.

---

## Question 20 | Copy File from Pod

| | |
|---|---|
| **Points** | 5 |
| **CNCF Domain** | Application Observability and Maintenance |
| **CNCF Weight** | 15% |
| **Namespace** | `bark` |
| **Resources** | Pod `copy-pod`, file `./exam/course/20/passwd` |

### Task

1. Create a Pod named `copy-pod` in namespace `bark` with image `busybox:1.36` and command `sleep 3600`
2. Copy `/etc/passwd` from the Pod to `./exam/course/20/passwd`

**Hint**: Use `kubectl cp` command.
