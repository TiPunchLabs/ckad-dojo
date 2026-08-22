# CKAD Exam Simulator - Dojo Benzaiten 🎶

> **Total Score**: 114 points | **Passing Score**: ~66% (75 points)
> *「弁財天は智慧を授ける」- Benzaiten bestows wisdom*

---

### Question 1

| Points | CNCF Domain | CNCF Weight | Namespace | Resources | Files / File to create |
|--------|-------------|-------------|-----------|-----------|------------------------|
| 5 | Application Design and Build | 20% | `harmony` | Pod | `./exam/course/1/Dockerfile` |

### Task

You have been asked to build an application container image. A directory has been provided at `./exam/course/1/app` with the application source code.
Create a `Dockerfile` at `./exam/course/1/Dockerfile` to build an image named `localhost:5000/benzaiten-wisdom:v1` using `nginx:alpine` as the base image.
Copy the contents of the `app` directory into `/usr/share/nginx/html/` in the container.
Build the image and push it to the local registry.
Then create a pod named `wisdom-server` in the `harmony` namespace using this image.

---

### Question 2

| Points | CNCF Domain | CNCF Weight | Namespace | Resources | Files / File to create |
|--------|-------------|-------------|-----------|-----------|------------------------|
| 6 | Application Design and Build | 20% | `melody` | Pod | |

### Task

Create a Pod named `ambassador-pod` in the `melody` namespace.
The Pod should run a main application container using image `busybox` running `sleep 3600`.
It should also run a sidecar ambassador container using image `haproxy:2.4-alpine`.
The ambassador should proxy traffic from `localhost:8080` to an external service. A ConfigMap named `haproxy-config` has already been created in the `melody` namespace containing the HAProxy configuration. Mount this ConfigMap to `/usr/local/etc/haproxy/haproxy.cfg` in the ambassador container.

---

### Question 3

| Points | CNCF Domain | CNCF Weight | Namespace | Resources | Files / File to create |
|--------|-------------|-------------|-----------|-----------|------------------------|
| 5 | Application Design and Build | 20% | `rhythm` | Job | |

### Task

Create a Job named `data-cleanup` in the `rhythm` namespace.
The Job should run a single container using the `busybox` image and execute the command `echo "Cleaning up old records"; sleep 5`.
Configure the Job to automatically delete itself 10 seconds after it finishes successfully.

---

### Question 4

| Points | CNCF Domain | CNCF Weight | Namespace | Resources | Files / File to create |
|--------|-------------|-------------|-----------|-----------|------------------------|
| 6 | Application Design and Build | 20% | `cadence` | Pod | |

### Task

Create a Pod named `shared-process-pod` in the `cadence` namespace.
The Pod should run two containers:
1. `app-container` using image `nginx:alpine`
2. `debug-container` using image `busybox` running the command `sleep 3600`
Enable process namespace sharing between the containers in this Pod so the `debug-container` can see processes running in the `app-container`.

---

### Question 5

| Points | CNCF Domain | CNCF Weight | Namespace | Resources | Files / File to create |
|--------|-------------|-------------|-----------|-----------|------------------------|
| 6 | Application Deployment | 20% | `chorus` | Helm Release | `./exam/course/5/values.yaml` |

### Task

A Helm chart is located at `./exam/course/5/chart`. It has a dependency on a subchart.
First, update the chart dependencies.
Then, create a values file at `./exam/course/5/values.yaml` to set `replicaCount: 3` and `service.port: 8080`.
Install the chart as a release named `wisdom-app` in the `chorus` namespace using the values file.

---

### Question 6

| Points | CNCF Domain | CNCF Weight | Namespace | Resources | Files / File to create |
|--------|-------------|-------------|-----------|-----------|------------------------|
| 7 | Application Deployment | 20% | `sonata` | Deployment | |

### Task

Create a Deployment named `rolling-deploy` in the `sonata` namespace with 5 replicas using the `nginx:1.24-alpine` image.
Configure the deployment strategy to be a RollingUpdate. Set `maxSurge` to `40%` and `maxUnavailable` to `20%`.
After creation, update the image to `nginx:1.25-alpine` and record the rollout in the deployment's history.

---

### Question 7

| Points | CNCF Domain | CNCF Weight | Namespace | Resources | Files / File to create |
|--------|-------------|-------------|-----------|-----------|------------------------|
| 5 | Application Deployment | 20% | `verse` | Deployment | |

### Task

A Deployment named `legacy-app` exists in the `verse` namespace. It was updated multiple times and the latest version is failing.
Undo the rollout and rollback to exactly revision 2.

---

### Question 8

| Points | CNCF Domain | CNCF Weight | Namespace | Resources | Files / File to create |
|--------|-------------|-------------|-----------|-----------|------------------------|
| 8 | Application Deployment | 20% | `lyric` | Kustomize | `./exam/course/8/kustomization.yaml` |

### Task

A base kustomize configuration is at `./exam/course/8/base`.
Create an overlay for a `production` environment at `./exam/course/8/overlays/production`.
The overlay should:
1. Change the namespace to `lyric`
2. Apply a common label `env: production` to all resources
3. Update the replicas of the deployment `app-deploy` to 4
Apply the overlay to the cluster using Kustomize.

---

### Question 9

| Points | CNCF Domain | CNCF Weight | Namespace | Resources | Files / File to create |
|--------|-------------|-------------|-----------|-----------|------------------------|
| 5 | Application Observability and Maintenance | 15% | `tempo` | Pod | |

### Task

A Pod named `metrics-pod` exists in the `tempo` namespace but is stuck in `ContainerCreating`.
Identify the cause of the issue and fix it. The pod should be running. Do not change the image or basic pod structure, but create or fix any missing dependencies. (Hint: Missing ConfigMap).

---

### Question 10

| Points | CNCF Domain | CNCF Weight | Namespace | Resources | Files / File to create |
|--------|-------------|-------------|-----------|-----------|------------------------|
| 6 | Application Observability and Maintenance | 15% | `aria` | Metrics | `./exam/course/10/metrics.txt` |

### Task

Use the `kubectl` raw API to query the metrics API server.
Find the memory usage of the pod `heavy-worker` in the `aria` namespace.
Write the memory usage (in Ki or Mi, exactly as output by the API) to `./exam/course/10/metrics.txt`.

---

### Question 11

| Points | CNCF Domain | CNCF Weight | Namespace | Resources | Files / File to create |
|--------|-------------|-------------|-----------|-----------|------------------------|
| 6 | Application Observability and Maintenance | 15% | `harmony` | Pod | |

### Task

Create a Pod named `health-check` in the `harmony` namespace using image `nginx:alpine`.
Configure a Liveness probe that sends an HTTP GET request to `/healthz` on port 80, starting 5 seconds after the container starts, with a period of 10 seconds.
Configure a Readiness probe that sends an HTTP GET request to `/ready` on port 80, with an initial delay of 10 seconds and period of 5 seconds.

---

### Question 12

| Points | CNCF Domain | CNCF Weight | Namespace | Resources | Files / File to create |
|--------|-------------|-------------|-----------|-----------|------------------------|
| 6 | Application Environment, Configuration and Security | 25% | `melody` | Pod | |

### Task

Create a Pod named `projected-pod` in the `melody` namespace using image `busybox`, command `sleep 3600`.
Use a projected volume named `all-in-one` mounted at `/etc/projected`.
The volume should project:
1. A Downward API volume projecting the pod's labels into a file named `pod-labels.txt`
2. A ConfigMap named `info-cm` projecting its contents
3. A Secret named `info-secret` projecting its contents
(The ConfigMap and Secret already exist).

---

### Question 13

| Points | CNCF Domain | CNCF Weight | Namespace | Resources | Files / File to create |
|--------|-------------|-------------|-----------|-----------|------------------------|
| 4 | Application Environment, Configuration and Security | 25% | `rhythm` | ConfigMap | |

### Task

A binary file is provided at `./exam/course/13/data.bin`.
Create a ConfigMap named `binary-config` in the `rhythm` namespace containing this file as binary data.

---

### Question 14

| Points | CNCF Domain | CNCF Weight | Namespace | Resources | Files / File to create |
|--------|-------------|-------------|-----------|-----------|------------------------|
| 5 | Application Environment, Configuration and Security | 25% | `cadence` | Pod | |

### Task

Create a Pod named `selinux-pod` in the `cadence` namespace using image `busybox` and command `sleep 3600`.
Configure the Pod's SecurityContext to set the SELinux options:
`level: "s0:c123,c456"`

---

### Question 15

| Points | CNCF Domain | CNCF Weight | Namespace | Resources | Files / File to create |
|--------|-------------|-------------|-----------|-----------|------------------------|
| 4 | Application Environment, Configuration and Security | 25% | `sonata` | Token | `./exam/course/15/token.txt` |

### Task

Create a ServiceAccount named `vault-accessor` in the `sonata` namespace.
Create a token for this ServiceAccount with a duration of 1 hour (3600 seconds) using the TokenRequest API (via kubectl).
Save the raw token string to `./exam/course/15/token.txt`.

---

### Question 16

| Points | CNCF Domain | CNCF Weight | Namespace | Resources | Files / File to create |
|--------|-------------|-------------|-----------|-----------|------------------------|
| 7 | Application Environment, Configuration and Security | 25% | `chorus` | NetworkPolicy | |

### Task

Create a NetworkPolicy named `port-range-allow` in the `chorus` namespace.
It should apply to pods with the label `role: backend`.
Allow INGRESS traffic on TCP ports 3000 through 3010 from any pod in the `chorus` namespace.

---

### Question 17

| Points | CNCF Domain | CNCF Weight | Namespace | Resources | Files / File to create |
|--------|-------------|-------------|-----------|-----------|------------------------|
| 6 | Services and Networking | 20% | `verse` | NetworkPolicy | |

### Task

Create a NetworkPolicy named `egress-external-only` in the `verse` namespace.
It should apply to pods with the label `role: egress-app`.
Allow EGRESS traffic to the CIDR `10.0.0.0/8`, but explicitly deny/exclude traffic to the smaller CIDR `10.200.0.0/16`.
(Note: Do this using an `except` block in the policy).

---

### Question 18

| Points | CNCF Domain | CNCF Weight | Namespace | Resources | Files / File to create |
|--------|-------------|-------------|-----------|-----------|------------------------|
| 6 | Services and Networking | 20% | `lyric` | Ingress | |

### Task

Create an Ingress named `multi-tls-ingress` in the `lyric` namespace.
Route requests for `app1.benzaiten.dojo` to service `app1-svc` on port 80.
Route requests for `app2.benzaiten.dojo` to service `app2-svc` on port 80.
Configure TLS for both hosts. Use the existing secret `app1-tls` for `app1.benzaiten.dojo` and `app2-tls` for `app2.benzaiten.dojo`.
(The services and secrets already exist).

---

### Question 19

| Points | CNCF Domain | CNCF Weight | Namespace | Resources | Files / File to create |
|--------|-------------|-------------|-----------|-----------|------------------------|
| 5 | Services and Networking | 20% | `tempo` | EndpointSlice | `./exam/course/19/endpoints.txt` |

### Task

Find the EndpointSlice for the Service `external-db-svc` in the `tempo` namespace.
Extract the IPv4 addresses from this EndpointSlice and write them to `./exam/course/19/endpoints.txt`, one address per line.

---

### Question 20

| Points | CNCF Domain | CNCF Weight | Namespace | Resources | Files / File to create |
|--------|-------------|-------------|-----------|-----------|------------------------|
| 6 | Services and Networking | 20% | `aria` | Service | |

### Task

Create a Deployment named `local-app` in the `aria` namespace with 3 replicas using image `nginx:alpine`.
Create a NodePort service named `local-app-svc` exposing the deployment on port 80.
Configure the service to use `Local` for `externalTrafficPolicy` to preserve client source IPs.
