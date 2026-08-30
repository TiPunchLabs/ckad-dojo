# CKAD Exam Simulator - Dojo Susanoo 🌊

> **Total Score**: 110 points | **Passing Score**: ~66% (72 points)
>
> *「スサノオは海を支配する」- Susanoo commands the seas*
>
> **Local Simulator Adaptations**:
>
> | Original                   | Local Simulator                |
> | -------------------------- | ------------------------------ |
> | `/opt/course/N/`         | `./exam/course/N/`           |
> | Original registry          | `localhost:5000`             |
> | SSH to different instances | Single cluster (no SSH needed) |

---

## Question 1 | Multi-Stage Dockerfile

|                          |                                   |
| ------------------------ | --------------------------------- |
| **Points** | 5 |
| **CNCF Domain** | Application Design and Build |
| **CNCF Weight** | 20% |
| **Namespace** | `ocean` |
| **File to create** | `./exam/course/15/q1/Dockerfile` |

### Task

There is a `Dockerfile` located at `./exam/course/15/q1/Dockerfile` that builds a simple Go application. Currently, it uses a single-stage build resulting in a large image.

Modify the `Dockerfile` to use a multi-stage build to reduce the final image size:
1. Use `golang:1.20-alpine` as the builder stage and name the stage `builder`.
2. Build the go application with `go build -o app main.go` inside the builder stage.
3. Use `alpine:3.18` as the final image stage.
4. Copy the built `app` binary from the `builder` stage to `/app/app` in the final image.
5. Set the working directory to `/app` and the command to run `./app`.

---

## Question 2 | Ambassador Proxy Sidecar

|                          |                                   |
| ------------------------ | --------------------------------- |
| **Points** | 6 |
| **CNCF Domain** | Application Design and Build |
| **CNCF Weight** | 20% |
| **Namespace** | `tide` |
| **Resources** | Pod `log-generator` |

### Task

Create a Pod named `log-generator` in the `tide` namespace that implements the sidecar pattern for log forwarding.

1. The main container should be named `app`, use the `busybox` image, and run the command: `sh -c 'while true; do echo "$(date) - Application log" >> /var/log/app/app.log; sleep 5; done'`.
2. The sidecar container should be named `sidecar`, use the `busybox` image, and run the command: `sh -c 'tail -f /var/log/app/app.log'`.
3. Use an `emptyDir` volume named `shared-logs` to share the `/var/log/app` directory between the two containers.

---

## Question 3 | CronJob with Concurrency Policy

|                          |                                   |
| ------------------------ | --------------------------------- |
| **Points** | 5 |
| **CNCF Domain** | Application Design and Build |
| **CNCF Weight** | 20% |
| **Namespace** | `coral` |
| **Resources** | CronJob `data-sync` |

### Task

Create a CronJob named `data-sync` in the `coral` namespace.

1. The job should run a container named `sync` using the `busybox` image.
2. The container should execute the command: `echo "Syncing data..."`.
3. Schedule the CronJob to run every 10 minutes (`*/10 * * * *`).
4. Set the `failedJobsHistoryLimit` to `5`.
5. Create the CronJob in a `suspend`ed state (so it doesn't run immediately).

---

## Question 4 | Init Container File Dependency

|                          |                                   |
| ------------------------ | --------------------------------- |
| **Points** | 6 |
| **CNCF Domain** | Application Design and Build |
| **CNCF Weight** | 20% |
| **Namespace** | `abyss` |
| **Resources** | Pod `batch-worker` |

### Task

Create a Pod named `batch-worker` in the `abyss` namespace designed for a batch processing task.

1. The Pod should have a single container named `worker` using the `busybox` image.
2. The container should execute: `sh -c 'echo "Processing batch"; exit 1'`.
3. Set the Pod's `restartPolicy` to `OnFailure`.
4. Ensure the Pod gets scheduled.

---

## Question 5 | Helm Dry Run and Upgrade

|                          |                                   |
| ------------------------ | --------------------------------- |
| **Points** | 4 |
| **CNCF Domain** | Application Deployment |
| **CNCF Weight** | 20% |
| **Namespace** | `current` |
| **Resources** | Helm Release `ocean-api` |

### Task

A Helm release named `ocean-api` was deployed in the `current` namespace. However, it is failing and no longer needed.

Uninstall the Helm release `ocean-api` from the `current` namespace and ensure that all its resources and history are completely purged.

---

## Question 6 | Deployment with maxSurge Strategy

|                          |                                   |
| ------------------------ | --------------------------------- |
| **Points** | 6 |
| **CNCF Domain** | Application Deployment |
| **CNCF Weight** | 20% |
| **Namespace** | `reef` |
| **Resources** | Deployment `web-deploy` |

### Task

Create a Deployment named `web-deploy` in the `reef` namespace.

1. The Deployment should have `4` replicas.
2. Use the `nginx:1.23` image.
3. Configure the rolling update strategy:
   - `maxSurge` should be set to `50%`.
   - `maxUnavailable` should be set to `25%`.

---

## Question 7 | Deployment Rollback

|                          |                                   |
| ------------------------ | --------------------------------- |
| **Points** | 5 |
| **CNCF Domain** | Application Deployment |
| **CNCF Weight** | 20% |
| **Namespace** | `lagoon` |
| **Resources** | Deployment `api-server` |

### Task

There is an existing Deployment named `api-server` in the `lagoon` namespace.

1. Record the rollout history for this Deployment by updating its image to `nginx:1.24` and then `nginx:1.25`. Make sure the cause of the rollout is recorded in the history.
2. Roll back the Deployment to the specific revision that was using the `nginx:1.24` image.

---

## Question 8 | Kustomize Strategic Merge Patch

|                          |                                   |
| ------------------------ | --------------------------------- |
| **Points** | 7 |
| **CNCF Domain** | Application Deployment |
| **CNCF Weight** | 20% |
| **Namespace** | `trench` |
| **File to create** | `./exam/course/15/q8/kustomization.yaml` |

### Task

Create a Kustomize configuration in `./exam/course/15/q8/` to generate a Deployment and a Service.

1. Create a basic Deployment named `app-deploy` and a Service named `app-svc` in separate YAML files within the directory.
2. In the `kustomization.yaml` file, add `commonLabels`:
   - `env: production`
   - `team: alpha`
3. Add `commonAnnotations`:
   - `release: v1.0.0`
4. Apply the Kustomize directory to the `trench` namespace.

---

## Question 9 | Pending Pod Troubleshooting

|                          |                                   |
| ------------------------ | --------------------------------- |
| **Points** | 5 |
| **CNCF Domain** | Application Observability and Maintenance |
| **CNCF Weight** | 15% |
| **Namespace** | `wave` |
| **Resources** | Pod `backend-pod` |

### Task

There is a Pod named `backend-pod` in the `wave` namespace that is stuck in `ErrImagePull` or `ImagePullBackOff`.

Troubleshoot and fix the issue. The Pod is attempting to pull an image from an incorrect registry. Update the Pod to pull the correct image `nginx:alpine` from the standard Docker Hub registry. Note: You may need to recreate the pod to fix it.

---

## Question 10 | Metrics API Raw Query

|                          |                                   |
| ------------------------ | --------------------------------- |
| **Points** | 5 |
| **CNCF Domain** | Application Observability and Maintenance |
| **CNCF Weight** | 15% |
| **Namespace** | `depths` |
| **File to create** | `./exam/course/15/q10/events.txt` |

### Task

Analyze the cluster events in the `depths` namespace.

1. Extract all Warning events in the `depths` namespace.
2. Save the output of the events to the file `./exam/course/15/q10/events.txt`.
3. The format of the output should be standard `kubectl get events` output.

---

## Question 11 | All Three Probes

|                          |                                   |
| ------------------------ | --------------------------------- |
| **Points** | 6 |
| **CNCF Domain** | Application Observability and Maintenance |
| **CNCF Weight** | 15% |
| **Namespace** | `ocean` |
| **Resources** | Pod `grpc-checker` |

### Task

Create a Pod named `grpc-checker` in the `ocean` namespace.

1. Use the `registry.k8s.io/grpc-echo-server` image (or similar if testing locally). For the exam simulator, use `busybox` with a simulated gRPC check if real gRPC server isn't available, but standard CKAD supports grpc probes. For this simulation, assume standard Kubernetes >= 1.24 supports it. Use image `nginx:1.24` and configure a gRPC liveness probe (this will naturally fail as nginx doesn't run grpc on port 80, but configure it anyway for the syntax).
2. Configure a `livenessProbe` of type `grpc` on port `8080`.
3. Set the `initialDelaySeconds` to `5` and `periodSeconds` to `10`.

---

## Question 12 | Projected Volume

|                          |                                   |
| ------------------------ | --------------------------------- |
| **Points** | 5 |
| **CNCF Domain** | Application Environment, Configuration and Security |
| **CNCF Weight** | 25% |
| **Namespace** | `tide` |
| **File to create** | `./exam/course/15/q12/` |

### Task

1. A directory `./exam/course/15/q12/config-files/` contains some configuration files.
2. Create a ConfigMap named `app-config-dir` in the `tide` namespace from this directory.
3. Create a Pod named `config-consumer` using the `alpine` image in the `tide` namespace.
4. Mount the ConfigMap `app-config-dir` to the path `/etc/config` within the Pod.
5. Set the Pod command to `sleep 3600`.

---

## Question 13 | Secret from Binary File

|                          |                                   |
| ------------------------ | --------------------------------- |
| **Points** | 5 |
| **CNCF Domain** | Application Environment, Configuration and Security |
| **CNCF Weight** | 25% |
| **Namespace** | `coral` |
| **Resources** | Secret `db-credentials` |

### Task

Create a generic Secret named `db-credentials` in the `coral` namespace.

1. The secret should contain two key-value pairs:
   - `username`: `admin`
   - `password`: `supersecretpassword`
2. Create a Pod named `secret-env-pod` in the `coral` namespace using the `nginx` image.
3. Expose the `username` as an environment variable `DB_USER` and `password` as `DB_PASS` in the Pod.

---

## Question 14 | SELinux SecurityContext

|                          |                                   |
| ------------------------ | --------------------------------- |
| **Points** | 7 |
| **CNCF Domain** | Application Environment, Configuration and Security |
| **CNCF Weight** | 25% |
| **Namespace** | `abyss` |
| **Resources** | Pod `secure-pod`, NetworkPolicy `secure-policy` |

### Task

1. Create a Pod named `secure-pod` in the `abyss` namespace using the `busybox` image and command `sleep 3600`.
2. Configure the Pod's `securityContext` so that it runs as `runAsUser: 1000` and `runAsGroup: 3000`.
3. Ensure `allowPrivilegeEscalation` is set to `false` for the container.
4. Create a NetworkPolicy named `secure-policy` in the `abyss` namespace that selects the `secure-pod` (via a label `app: secure`) and denies all ingress traffic to it, but allows all egress traffic. You must add the label `app: secure` to the pod.

---

## Question 15 | ServiceAccount Token Projection

|                          |                                   |
| ------------------------ | --------------------------------- |
| **Points** | 5 |
| **CNCF Domain** | Application Environment, Configuration and Security |
| **CNCF Weight** | 25% |
| **Namespace** | `reef` |
| **Resources** | Pod `target-pod` |

### Task

There is a Pod named `target-pod` in the `reef` namespace running a simple web server.

1. Attach an ephemeral container named `debug-container` to the `target-pod`.
2. Use the `busybox` image for the ephemeral container.
3. Ensure the ephemeral container is successfully attached and running (it doesn't need to run indefinitely, just be added).

---

## Question 16 | NetworkPolicy Port Range

|                          |                                   |
| ------------------------ | --------------------------------- |
| **Points** | 6 |
| **CNCF Domain** | Application Environment, Configuration and Security |
| **CNCF Weight** | 25% |
| **Namespace** | `lagoon` |
| **Resources** | Deployment `critical-app`, PodDisruptionBudget `critical-pdb` |

### Task

1. Create a Deployment named `critical-app` in the `lagoon` namespace using `nginx` with `3` replicas and label `tier: critical`.
2. Create a PodDisruptionBudget named `critical-pdb` in the `lagoon` namespace.
3. Configure the PDB to target the pods of the `critical-app` deployment.
4. Ensure that at least `2` pods are always available during voluntary disruptions (`minAvailable: 2`).

---

## Question 17 | Egress NetworkPolicy

|                          |                                   |
| ------------------------ | --------------------------------- |
| **Points** | 6 |
| **CNCF Domain** | Services and Networking |
| **CNCF Weight** | 20% |
| **Namespace** | `trench` |
| **Resources** | NetworkPolicy `deny-all`, NetworkPolicy `allow-web` |

### Task

1. Create a default deny-all NetworkPolicy named `deny-all` in the `trench` namespace that blocks all Ingress and Egress traffic for all pods in the namespace.
2. Create another NetworkPolicy named `allow-web` in the `trench` namespace that selects pods with label `role: web` and allows Ingress traffic to them on TCP port `80` from any source, and allows all Egress traffic from them.

---

## Question 18 | Multi-TLS Ingress

|                          |                                   |
| ------------------------ | --------------------------------- |
| **Points** | 5 |
| **CNCF Domain** | Services and Networking |
| **CNCF Weight** | 20% |
| **Namespace** | `wave` |
| **Resources** | Service `mesh-service` |

### Task

There is a Service named `mesh-service` in the `wave` namespace, but it has no endpoints.

Troubleshoot the issue and fix the Service or its corresponding pods so that `mesh-service` has at least one active endpoint. The intended pod `mesh-pod` is in the same namespace but the service selector does not match the pod labels. Fix the service selector to match the pod's label `app: mesh-app`.

---

## Question 19 | EndpointSlice Inspection

|                          |                                   |
| ------------------------ | --------------------------------- |
| **Points** | 5 |
| **CNCF Domain** | Services and Networking |
| **CNCF Weight** | 20% |
| **Namespace** | `depths` |
| **Resources** | Service `multi-port-svc` |

### Task

Create a Service named `multi-port-svc` in the `depths` namespace.

1. The service should expose two ports.
2. Port 1: Name `http`, Port `80`, TargetPort `8080`, Protocol `TCP`.
3. Port 2: Name `dns`, Port `53`, TargetPort `5353`, Protocol `UDP`.
4. The service should select pods with the label `app: multi-app`.

---

## Question 20 | Local Registry Deployment

|                          |                                   |
| ------------------------ | --------------------------------- |
| **Points** | 6 |
| **CNCF Domain** | Services and Networking |
| **CNCF Weight** | 20% |
| **Namespace** | `ocean` |
| **Resources** | Ingress `rewrite-ingress` |

### Task

Create an Ingress named `rewrite-ingress` in the `ocean` namespace.

1. Route requests for host `susanoo.com` and path `/api(/|$)(.*)` to the service `api-service` on port `80`.
2. Use the `nginx` ingress class.
3. Add the necessary NGINX Ingress Controller annotation to rewrite the target URL path. The path should be rewritten to `/$2`.

---
