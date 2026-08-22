# CKAD Exam Simulator - Dojo Musashi 🏆

> **Total Score**: 122 points | **Passing Score**: ~66% (80 points)
> 「武蔵は二刀を極める」- Musashi masters the two swords

---

## Question 1

| Points | CNCF Domain | CNCF Weight | Namespace | Resources | Files to create |
|--------|-------------|-------------|-----------|-----------|-----------------|
| 6 | Application Design and Build | 20% | apex | Dockerfile, Pod | `./exam/course/1/Dockerfile`<br>`./exam/course/1/pod.yaml` |

### Task
Create an optimized Dockerfile that builds a Go application using multi-stage builds. Use the source code provided in `./exam/course/1/main.go`. The final image should be based on `alpine:latest` and run as a non-root user (UID 1000). Tag the image as `localhost:5000/musashi-app:v1`.
Then create a pod named `musashi-pod` in the `apex` namespace using this image.

---

## Question 2

| Points | CNCF Domain | CNCF Weight | Namespace | Resources | Files to create |
|--------|-------------|-------------|-----------|-----------|-----------------|
| 6 | Application Design and Build | 20% | summit | Pod | `./exam/course/2/multi-pod.yaml` |

### Task
Create a multi-container pod named `tri-blade` in the `summit` namespace with three containers:
1. `main`: image `nginx:1.24`, mounts a shared emptyDir volume at `/var/log/nginx`
2. `sidecar`: image `busybox`, writes current time to `/shared/time.log` every 5 seconds (volume mounted at `/shared`)
3. `adapter`: image `fluentd`, tails `/var/log/shared/time.log` (volume mounted at `/var/log/shared`)

---

## Question 3

| Points | CNCF Domain | CNCF Weight | Namespace | Resources | Files to create |
|--------|-------------|-------------|-----------|-----------|-----------------|
| 6 | Application Design and Build | 20% | pinnacle | Job | `./exam/course/3/job.yaml` |

### Task
Create a Job named `data-processor` in the `pinnacle` namespace.
The job should calculate the value of pi using the `perl` image: `perl -Mbignum=bpi -wle 'print bpi(2000)'`.
Configure the Job to complete 3 successful pods, with 2 running in parallel.

---

## Question 4

| Points | CNCF Domain | CNCF Weight | Namespace | Resources | Files to create |
|--------|-------------|-------------|-----------|-----------|-----------------|
| 6 | Application Design and Build | 20% | zenith | CronJob | `./exam/course/4/cronjob.yaml` |

### Task
Create a CronJob named `db-backup` in the `zenith` namespace.
Schedule: every 15 minutes (`*/15 * * * *`).
Image: `postgres:15`.
Command: `pg_dump -U admin mydb`.
Retain 3 successful jobs and 1 failed job.

---

## Question 5

| Points | CNCF Domain | CNCF Weight | Namespace | Resources | Files to create |
|--------|-------------|-------------|-----------|-----------|-----------------|
| 6 | Application Deployment | 20% | crown | Helm | `./exam/course/5/values.yaml` |

### Task
Create a Helm chart named `my-chart` from scratch in `./exam/course/5/my-chart`.
Create a `values.yaml` in `./exam/course/5/` that overrides the replica count to 3 and the image repository to `nginx` and tag to `alpine`.
Install the chart into the `crown` namespace with the release name `crown-release`.

---

## Question 6

| Points | CNCF Domain | CNCF Weight | Namespace | Resources | Files to create |
|--------|-------------|-------------|-----------|-----------|-----------------|
| 6 | Application Deployment | 20% | glory | Deployment | `./exam/course/6/deploy.yaml` |

### Task
A deployment `glory-deploy` exists in the `glory` namespace.
Update its image to `nginx:1.25` and record the change.
Then rollback the deployment to the previous revision.
Finally, scale it to 5 replicas.

---

## Question 7

| Points | CNCF Domain | CNCF Weight | Namespace | Resources | Files to create |
|--------|-------------|-------------|-----------|-----------|-----------------|
| 6 | Application Deployment | 20% | legacy | Deployment | `./exam/course/7/canary.yaml` |

### Task
Implement a canary deployment in the `legacy` namespace.
Create a new deployment `legacy-canary` alongside the existing `legacy-main` deployment.
The canary should have 1 replica using `httpd:2.4`, while the main has 4. Ensure they both have the label `app=legacy-web` so the existing service routes 20% of traffic to the canary.

---

## Question 8

| Points | CNCF Domain | CNCF Weight | Namespace | Resources | Files to create |
|--------|-------------|-------------|-----------|-----------|-----------------|
| 6 | Application Deployment | 20% | mastery | Kustomize | `./exam/course/8/kustomization.yaml` |

### Task
Use Kustomize in `./exam/course/8/`.
Base exists in `./exam/course/8/base`. Create a production overlay in `./exam/course/8/prod`.
The overlay should:
- Add a label `env=prod`
- Change replica count to 4
- Apply the generated resources to the `mastery` namespace.

---

## Question 9

| Points | CNCF Domain | CNCF Weight | Namespace | Resources | Files to create |
|--------|-------------|-------------|-----------|-----------|-----------------|
| 6 | Application Observability and Maintenance | 15% | ascend | Pods | None |

### Task
There are 3 broken pods in the `ascend` namespace: `bug-1`, `bug-2`, and `bug-3`.
Troubleshoot and fix them. (You may delete and recreate if necessary, or edit them in place).

---

## Question 10

| Points | CNCF Domain | CNCF Weight | Namespace | Resources | Files to create |
|--------|-------------|-------------|-----------|-----------|-----------------|
| 6 | Application Observability and Maintenance | 15% | triumph | Pod, Log | `./exam/course/10/logs.txt` |

### Task
Extract the logs from the `triumph-app` pod in the `triumph` namespace.
Find all lines containing "ERROR" and save them to `./exam/course/10/logs.txt`.

---

## Question 11

| Points | CNCF Domain | CNCF Weight | Namespace | Resources | Files to create |
|--------|-------------|-------------|-----------|-----------|-----------------|
| 6 | Application Observability and Maintenance | 15% | apex | Debug | None |

### Task
Use an ephemeral debug container to troubleshoot `distroless-pod` in the `apex` namespace.
Attach an ephemeral container using the `busybox` image and run `nslookup kubernetes.default`.

---

## Question 12

| Points | CNCF Domain | CNCF Weight | Namespace | Resources | Files to create |
|--------|-------------|-------------|-----------|-----------|-----------------|
| 6 | Application Environment, Configuration and Security | 25% | summit | SecurityContext | `./exam/course/12/secure-pod.yaml` |

### Task
Create a pod `secure-pod` in the `summit` namespace.
Image: `nginx`.
Container security context: `runAsUser: 2000`, `allowPrivilegeEscalation: false`, drop `ALL` capabilities, add `NET_BIND_SERVICE`.

---

## Question 13

| Points | CNCF Domain | CNCF Weight | Namespace | Resources | Files to create |
|--------|-------------|-------------|-----------|-----------|-----------------|
| 6 | Application Environment, Configuration and Security | 25% | pinnacle | RBAC | `./exam/course/13/rbac.yaml` |

### Task
Create a ServiceAccount `sword-master` in `pinnacle`.
Create a Role `blade-reader` that can get, list, watch pods and configmaps.
Create a RoleBinding `master-binding` binding the role to the service account.

---

## Question 14

| Points | CNCF Domain | CNCF Weight | Namespace | Resources | Files to create |
|--------|-------------|-------------|-----------|-----------|-----------------|
| 6 | Application Environment, Configuration and Security | 25% | zenith | ConfigMap, Secret, Pod | `./exam/course/14/inject.yaml` |

### Task
Create a ConfigMap `app-config` with `THEME=dark`.
Create a Secret `app-secret` with `API_KEY=musashi123`.
Create a pod `inject-pod` in `zenith` that uses `app-config` as environment variables and mounts `app-secret` at `/etc/secret/`.

---

## Question 15

| Points | CNCF Domain | CNCF Weight | Namespace | Resources | Files to create |
|--------|-------------|-------------|-----------|-----------|-----------------|
| 6 | Application Environment, Configuration and Security | 25% | crown | LimitRange, ResourceQuota | `./exam/course/15/quota.yaml` |

### Task
Create a LimitRange `cpu-limits` in `crown`: default 500m, defaultRequest 200m for CPU.
Create a ResourceQuota `compute-quota` in `crown`: max 4 pods, max 2 CPU, max 4Gi memory.

---

## Question 16

| Points | CNCF Domain | CNCF Weight | Namespace | Resources | Files to create |
|--------|-------------|-------------|-----------|-----------|-----------------|
| 6 | Application Environment, Configuration and Security | 25% | glory | PersistentVolume, PVC, Pod | `./exam/course/16/storage.yaml` |

### Task
Create a PV `glory-pv` (1Gi, hostPath `/data/glory`, ReadWriteOnce).
Create a PVC `glory-pvc` (500Mi, ReadWriteOnce) in `glory`.
Create a pod `glory-pod` that mounts this PVC at `/var/data`.

---

## Question 17

| Points | CNCF Domain | CNCF Weight | Namespace | Resources | Files to create |
|--------|-------------|-------------|-----------|-----------|-----------------|
| 7 | Services and Networking | 20% | legacy | NetworkPolicy | `./exam/course/17/netpol.yaml` |

### Task
In the `legacy` namespace, create a default deny-all NetworkPolicy.
Then create a NetworkPolicy `allow-web` that allows ingress traffic to pods with `app=web` ONLY from pods with `app=api` on port 80.

---

## Question 18

| Points | CNCF Domain | CNCF Weight | Namespace | Resources | Files to create |
|--------|-------------|-------------|-----------|-----------|-----------------|
| 7 | Services and Networking | 20% | mastery | Ingress | `./exam/course/18/ingress.yaml` |

### Task
Create an Ingress `mastery-ing` in `mastery`.
Rule: Host `musashi.com`, path `/api` (prefix) routes to service `api-svc` on port 8080.
Path `/web` (prefix) routes to service `web-svc` on port 80.

---

## Question 19

| Points | CNCF Domain | CNCF Weight | Namespace | Resources | Files to create |
|--------|-------------|-------------|-----------|-----------|-----------------|
| 6 | Services and Networking | 20% | ascend | Service | `./exam/course/19/svc.yaml` |

### Task
Create a NodePort service `ascend-svc` in `ascend` exposing port 80, targetPort 80, nodePort 30080. It should select pods with `app=ascend-app`.

---

## Question 20

| Points | CNCF Domain | CNCF Weight | Namespace | Resources | Files to create |
|--------|-------------|-------------|-----------|-----------|-----------------|
| 6 | Services and Networking | 20% | triumph | DNS | `./exam/course/20/dns.yaml` |

### Task
Create a pod `dns-test` in `triumph`. Run a command to lookup the SRV record for the `kubernetes.default` service and save the output to `./exam/course/20/dns-output.txt`.

