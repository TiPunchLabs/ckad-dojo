# CKAD Exam Simulator - Dojo Tsukuyomi 🌙

> **Total Score**: 108 points | **Passing Score**: ~66% (72 points)

*「月読は闇を照らす」- Tsukuyomi illuminates the darkness*

---

## Question 1 | Application Design and Build

| Points | CNCF Domain | CNCF Weight | Namespace | Resources | Files/File to create |
|--------|-------------|-------------|-----------|-----------|----------------------|
| 6 | Application Design and Build | 20% | `lunar` | `Dockerfile` | `./exam/course/12/q1/Dockerfile` |

### Task

In the `lunar` namespace, you are tasked with creating a multi-stage Dockerfile.
A stub Dockerfile has been provided at `./exam/course/12/q1/Dockerfile` and a simple main.go program at `./exam/course/12/q1/main.go`.

Update the Dockerfile to have two stages:
1. The first stage should use `golang:1.20-alpine` as the base image. Name it `builder`.
   - Copy `main.go` into `/app/`.
   - Build it with `go build -o /app/server /app/main.go`.
2. The second stage should use `alpine:3.18`.
   - Copy the `server` binary from the `builder` stage to `/opt/server`.
   - Set the entrypoint to `/opt/server`.

You do not need to build the image, just ensure the `Dockerfile` is correctly defined.

---

## Question 2 | Application Design and Build

| Points | CNCF Domain | CNCF Weight | Namespace | Resources | Files/File to create |
|--------|-------------|-------------|-----------|-----------|----------------------|
| 5 | Application Design and Build | 20% | `crescent` | `Pod` |  |

### Task

Create a Pod named `data-processor` in the `crescent` namespace.
The Pod should run a main container using the `nginx:alpine` image named `main-app`.

The main container should only start AFTER an init container successfully completes its task.
Add an init container named `wait-for-service` using the `busybox:1.36` image. The init container should run the command: `sh -c 'sleep 5 && echo "Dependencies ready"'`.

---

## Question 3 | Application Design and Build

| Points | CNCF Domain | CNCF Weight | Namespace | Resources | Files/File to create |
|--------|-------------|-------------|-----------|-----------|----------------------|
| 5 | Application Design and Build | 20% | `twilight` | `CronJob` |  |

### Task

In the `twilight` namespace, create a CronJob named `nightly-backup`.
- Schedule: every 10 minutes (`*/10 * * * *`).
- Container image: `busybox:1.36`.
- Command: `sh -c 'sleep 30'`.
- Configure the CronJob to `Forbid` concurrent executions.

---

## Question 4 | Application Design and Build

| Points | CNCF Domain | CNCF Weight | Namespace | Resources | Files/File to create |
|--------|-------------|-------------|-----------|-----------|----------------------|
| 6 | Application Design and Build | 20% | `eclipse` | `Pod` |  |

### Task

A developer wants to use the Ambassador pattern for a legacy application.
Create a Pod named `legacy-app` in the `eclipse` namespace.

1. Main container: Name it `backend`, use image `nginx:1.25`, and expose port 80.
2. Ambassador container: Name it `proxy`, use image `haproxy:2.8-alpine`.

(Note: we are just simulating the pattern, no advanced haproxy config is needed, just defining the two containers is sufficient).

---

## Question 5 | Application Deployment

| Points | CNCF Domain | CNCF Weight | Namespace | Resources | Files/File to create |
|--------|-------------|-------------|-----------|-----------|----------------------|
| 5 | Application Deployment | 20% | `nebula` | `Helm` |  |

### Task

A Helm release named `api-release` exists in the `nebula` namespace.
It was recently upgraded to a broken version, resulting in failed deployments.
Roll back the `api-release` release to its previous revision (revision 1).

---

## Question 6 | Application Deployment

| Points | CNCF Domain | CNCF Weight | Namespace | Resources | Files/File to create |
|--------|-------------|-------------|-----------|-----------|----------------------|
| 5 | Application Deployment | 20% | `shadow` | `Deployment` |  |

### Task

Create a Deployment named `slow-start-app` in the `shadow` namespace.
- Replicas: 3
- Image: `nginx:1.24`
- To ensure no downtime during updates for this application that takes time to initialize, set `minReadySeconds` to `20`.

---

## Question 7 | Application Deployment

| Points | CNCF Domain | CNCF Weight | Namespace | Resources | Files/File to create |
|--------|-------------|-------------|-----------|-----------|----------------------|
| 5 | Application Deployment | 20% | `nightfall` | `Deployment` |  |

### Task

A Deployment named `critical-processor` exists in the `nightfall` namespace.
You have been instructed to pause the rollout of this deployment to investigate an issue.
Pause the rollout of the `critical-processor` deployment.

---

## Question 8 | Application Deployment

| Points | CNCF Domain | CNCF Weight | Namespace | Resources | Files/File to create |
|--------|-------------|-------------|-----------|-----------|----------------------|
| 6 | Application Deployment | 20% | `dusk` | `Kustomization` | `./exam/course/12/q8/` |

### Task

In `./exam/course/12/q8/`, there is a base deployment file `deployment.yaml` and a `kustomization.yaml`.
Create a JSON patch file named `patch.json` in the same directory.
The patch should add an environment variable `MODE=production` to the container named `web` in the Deployment `frontend`.

Then, update the `kustomization.yaml` to include this JSON patch targeting the Deployment `frontend`.
You do not need to apply the Kustomization, just set up the files.

---

## Question 9 | Application Observability and Maintenance

| Points | CNCF Domain | CNCF Weight | Namespace | Resources | Files/File to create |
|--------|-------------|-------------|-----------|-----------|----------------------|
| 5 | Application Observability and Maintenance | 15% | `starlight` | `Pod` |  |

### Task

A Pod named `metrics-gatherer` in the `starlight` namespace is failing to start.
Identify the issue and fix it. The pod should be running smoothly.
(Hint: The image name might be misspelled).

---

## Question 10 | Application Observability and Maintenance

| Points | CNCF Domain | CNCF Weight | Namespace | Resources | Files/File to create |
|--------|-------------|-------------|-----------|-----------|----------------------|
| 5 | Application Observability and Maintenance | 15% | `void` | `Metrics` | `./exam/course/12/q10/cpu-usage.txt` |

### Task

Find the Pod in the `kube-system` namespace that is consuming the most CPU.
Write the name of the Pod into the file `./exam/course/12/q10/cpu-usage.txt`.
(If multiple pods are similar, just record the top one based on `kubectl top`).

---

## Question 11 | Application Observability and Maintenance

| Points | CNCF Domain | CNCF Weight | Namespace | Resources | Files/File to create |
|--------|-------------|-------------|-----------|-----------|----------------------|
| 6 | Application Observability and Maintenance | 15% | `lunar` | `Pod` |  |

### Task

Create a Pod named `logger` in the `lunar` namespace.
The Pod should run a single container using the `busybox:1.36` image.
It should run a script that outputs logs to `/var/log/app.log`: `sh -c 'while true; do echo "App is running" >> /var/log/app.log; sleep 5; done'`.
Configure a sidecar container in the same pod named `log-tailer` using `busybox:1.36` that reads from `/var/log/app.log` and outputs to stdout: `sh -c 'tail -f /var/log/app.log'`.
Use an `emptyDir` volume to share the `/var/log` directory between the two containers.

---

## Question 12 | Application Environment, Configuration and Security

| Points | CNCF Domain | CNCF Weight | Namespace | Resources | Files/File to create |
|--------|-------------|-------------|-----------|-----------|----------------------|
| 6 | Application Environment, Configuration and Security | 25% | `crescent` | `Pod` |  |

### Task

In the `crescent` namespace, a Secret named `db-creds` and a ConfigMap named `app-config` exist.
Create a Pod named `combined-app` using the `nginx:alpine` image.
Use a single `projected` volume mounted at `/opt/config` to expose:
1. The `db-creds` Secret.
2. The `app-config` ConfigMap.

---

## Question 13 | Application Environment, Configuration and Security

| Points | CNCF Domain | CNCF Weight | Namespace | Resources | Files/File to create |
|--------|-------------|-------------|-----------|-----------|----------------------|
| 4 | Application Environment, Configuration and Security | 25% | `twilight` | `ConfigMap` |  |

### Task

Create a ConfigMap named `static-config` in the `twilight` namespace with the following key-value pair:
`version=v2.1.0`
Configure the ConfigMap to be immutable to prevent accidental changes.

---

## Question 14 | Application Environment, Configuration and Security

| Points | CNCF Domain | CNCF Weight | Namespace | Resources | Files/File to create |
|--------|-------------|-------------|-----------|-----------|----------------------|
| 6 | Application Environment, Configuration and Security | 25% | `eclipse` | `Pod` |  |

### Task

Create a Pod named `secure-pod` in the `eclipse` namespace using the `nginx:alpine` image.
Apply the following security constraints:
1. The pod must run as user ID `1000`.
2. The container must NOT allow privilege escalation (`allowPrivilegeEscalation: false`).
3. The container must have a read-only root filesystem.
(You may need to mount an emptyDir to `/var/cache/nginx` and `/var/run` to make nginx work with read-only rootfs).

---

## Question 15 | Application Environment, Configuration and Security

| Points | CNCF Domain | CNCF Weight | Namespace | Resources | Files/File to create |
|--------|-------------|-------------|-----------|-----------|----------------------|
| 5 | Application Environment, Configuration and Security | 25% | `shadow` | `Secret` |  |

### Task

A Secret named `legacy-token` in the `shadow` namespace is compromised.
Update the Secret to have the new value `token=super-secret-v2` (base64 encoded as needed).
A Pod named `token-reader` in the same namespace mounts this secret. No changes are required to the Pod, just update the Secret.

---

## Question 16 | Application Environment, Configuration and Security

| Points | CNCF Domain | CNCF Weight | Namespace | Resources | Files/File to create |
|--------|-------------|-------------|-----------|-----------|----------------------|
| 6 | Application Environment, Configuration and Security | 25% | `nightfall` | `ResourceQuota` |  |

### Task

Create a ResourceQuota named `compute-quota` in the `nightfall` namespace.
Enforce the following limits:
- Hard limit of `4` Pods.
- Hard limit of `2` CPU requests.
- Hard limit of `4Gi` Memory limits.

---

## Question 17 | Services and Networking

| Points | CNCF Domain | CNCF Weight | Namespace | Resources | Files/File to create |
|--------|-------------|-------------|-----------|-----------|----------------------|
| 5 | Services and Networking | 20% | `dusk` | `NetworkPolicy` |  |

### Task

Create a NetworkPolicy named `deny-external` in the `dusk` namespace.
It should apply to all pods in the `dusk` namespace.
Allow all INGRESS traffic.
DENY all EGRESS traffic, except for traffic to DNS (UDP port 53).

---

## Question 18 | Services and Networking

| Points | CNCF Domain | CNCF Weight | Namespace | Resources | Files/File to create |
|--------|-------------|-------------|-----------|-----------|----------------------|
| 6 | Services and Networking | 20% | `starlight` | `Ingress` |  |

### Task

Create an Ingress named `star-ingress` in the `starlight` namespace.
Route traffic based on paths:
- Requests to `/api(/|$)(.*)` should route to a Service named `api-svc` on port 8080 (Prefix match).
- Requests to `/web(/|$)(.*)` should route to a Service named `web-svc` on port 80 (Prefix match).
Set the ingress class to `nginx`.

---

## Question 19 | Services and Networking

| Points | CNCF Domain | CNCF Weight | Namespace | Resources | Files/File to create |
|--------|-------------|-------------|-----------|-----------|----------------------|
| 5 | Services and Networking | 20% | `nebula` | `Service` |  |

### Task

Create an ExternalName Service named `db-ext-svc` in the `nebula` namespace.
It should map to the external name `database.external.example.com`.

---

## Question 20 | Services and Networking

| Points | CNCF Domain | CNCF Weight | Namespace | Resources | Files/File to create |
|--------|-------------|-------------|-----------|-----------|----------------------|
| 6 | Services and Networking | 20% | `void` | `Pod` | `./exam/course/12/q20/nslookup.txt` |

### Task

A Pod named `dns-tester` is running in the `void` namespace.
Execute an `nslookup` command from within this Pod to look up the DNS record for the `kubernetes.default.svc.cluster.local` service.
Save the output of the command to the file `./exam/course/12/q20/nslookup.txt` on your local machine.

---
