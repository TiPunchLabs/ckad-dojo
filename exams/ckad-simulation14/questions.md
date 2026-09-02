# CKAD Exam Simulator - Dojo Raijin ⚡

> **Total Score**: 112 points | **Passing Score**: ~66% (73 points)
>
> *「雷神は天を裂く」- Raijin splits the heavens*
>
> **Local Simulator Adaptations**:
>
> | Original                   | Local Simulator                |
> | -------------------------- | ------------------------------ |
> | `/opt/course/N/`         | `./exam/course/N/`           |
> | Original registry          | `localhost:5000`             |
> | SSH to different instances | Single cluster (no SSH needed) |

---

## Question 1 | Container Image with Healthcheck

|                          |                                   |
| ------------------------ | --------------------------------- |
| **Points** | 4 |
| **CNCF Domain** | Application Design and Build |
| **CNCF Weight** | 20% |
| **Namespace** | - |
| **Resources** | Dockerfile |

### Task

Create a Dockerfile in `./exam/course/14/q1/` that fulfills the following requirements:

- Use `nginx:1.23-alpine` as the base image.
- Add a `HEALTHCHECK` instruction that tests if the web server is responding.
- The check should run the command `curl -f http://localhost/ || exit 1`.
- Set the interval to `10s`, timeout to `3s`, and retries to `3`.
- You do NOT need to build the image.

---

## Question 2 | Sidecar Logging and Filtering

|                          |                                   |
| ------------------------ | --------------------------------- |
| **Points** | 6 |
| **CNCF Domain** | Application Design and Build |
| **CNCF Weight** | 20% |
| **Namespace** | `thunder` |
| **Resources** | Pod |

### Task

Create a Pod named `thunder-logger` in the `thunder` namespace.

- The main container should be named `app-container`, using the `busybox` image, and run the command: `sh -c 'while true; do echo "INFO: Processing request"; sleep 2; echo "ERROR: Connection timeout"; sleep 3; done > /var/log/app.log'`
- Mount an `emptyDir` volume at `/var/log` for the main container.
- Add a sidecar container named `error-tailer`, using the `busybox` image.
- The sidecar should mount the same volume and run a command to tail the log file but ONLY output lines containing `ERROR`. (e.g., `sh -c 'tail -f /var/log/app.log | grep ERROR'`).

---

## Question 3 | Advanced CronJob

|                          |                                   |
| ------------------------ | --------------------------------- |
| **Points** | 6 |
| **CNCF Domain** | Application Design and Build |
| **CNCF Weight** | 20% |
| **Namespace** | `bolt` |
| **Resources** | CronJob |

### Task

Create a CronJob named `lightning-strike` in the `bolt` namespace.

- It should run every 5 minutes (`*/5 * * * *`).
- The job should use the `busybox` image and run the command `echo "Strike!"`.
- Configure `startingDeadlineSeconds` to `15` seconds.
- Configure `successfulJobsHistoryLimit` to `2`.

---

## Question 4 | Init Container Dependency

|                          |                                   |
| ------------------------ | --------------------------------- |
| **Points** | 6 |
| **CNCF Domain** | Application Design and Build |
| **CNCF Weight** | 20% |
| **Namespace** | `storm` |
| **Resources** | Pod |

### Task

A Service named `database-svc` will be created in the `storm` namespace in the future.
Create a Pod named `app-with-wait` in the `storm` namespace:

- Main container: name `main-app`, image `nginx:alpine`.
- Init container: name `wait-for-db`, image `busybox`.
- The init container should run a command that repeatedly checks if `database-svc` is resolvable or reachable (e.g., using `nslookup database-svc` or `wget -qO- http://database-svc`), looping until it succeeds before the main container starts. (Use a simple shell loop with a sleep).

---

## Question 5 | Helm Template Overrides

|                          |                                   |
| ------------------------ | --------------------------------- |
| **Points** | 5 |
| **CNCF Domain** | Application Deployment |
| **CNCF Weight** | 20% |
| **Namespace** | `surge` |
| **Resources** | File |

### Task

A helm chart is located at `/opt/course/14/q5/chart`.
Render the helm templates using the release name `thunder-web` and namespace `surge`.
Override the following values:

- `replicaCount` to `3`
- `image.tag` to `latest`
Save the rendered output to `./exam/course/14/q5/output.yaml`.
Do NOT install the helm chart.

---

## Question 6 | Deployment Rollback

|                          |                                   |
| ------------------------ | --------------------------------- |
| **Points** | 5 |
| **CNCF Domain** | Application Deployment |
| **CNCF Weight** | 20% |
| **Namespace** | `voltage` |
| **Resources** | Deployment |

### Task

There is a Deployment named `api-gateway` in the `voltage` namespace that has been updated a few times, and the current version is broken.
Roll back the Deployment to revision `1`.
Ensure the Deployment is successfully rolled back and running.

---

## Question 7 | Canary Deployment

|                          |                                   |
| ------------------------ | --------------------------------- |
| **Points** | 7 |
| **CNCF Domain** | Application Deployment |
| **CNCF Weight** | 20% |
| **Namespace** | `spark` |
| **Resources** | Deployments, Service |

### Task

In the `spark` namespace, a Service named `backend-svc` exists, routing traffic to a Deployment named `backend-v1` (with 4 replicas).
You need to introduce a canary version:

- Create a new Deployment named `backend-v2` in the `spark` namespace with `1` replica, using the `nginx:1.23` image.
- Ensure the `backend-svc` distributes traffic to BOTH `backend-v1` and `backend-v2`. (Hint: check the labels of the existing service and deployment).
- The traffic split should essentially be 4:1 (since v1 has 4 replicas and v2 has 1).

---

## Question 8 | Kustomize Strategic Merge Patch

|                          |                                   |
| ------------------------ | --------------------------------- |
| **Points** | 6 |
| **CNCF Domain** | Application Deployment |
| **CNCF Weight** | 20% |
| **Namespace** | `charge` |
| **Resources** | File |

### Task

In `./exam/course/14/q8/`, there is a base deployment file `deployment.yaml`.
Create a `kustomization.yaml` file in the same directory.
Configure it to include `deployment.yaml` as a resource.
Add a strategic merge patch (either inline or as a separate file) that adds the environment variable `APP_ENV=production` to the `worker` container of the deployment.
Apply the kustomization to the `charge` namespace using `kubectl apply -k`.

---

## Question 9 | Troubleshoot CrashLoopBackOff

|                          |                                   |
| ------------------------ | --------------------------------- |
| **Points** | 5 |
| **CNCF Domain** | Application Observability and Maintenance |
| **CNCF Weight** | 15% |
| **Namespace** | `flash` |
| **Resources** | Pod |

### Task

A Pod named `data-processor` in the `flash` namespace is stuck in a `CrashLoopBackOff`.
Find the cause and fix it. The pod should be running successfully.
(Hint: The application expects a specific configuration to listen on the correct port, or the probe might be misconfigured).

---

## Question 10 | Kubectl Events

|                          |                                   |
| ------------------------ | --------------------------------- |
| **Points** | 5 |
| **CNCF Domain** | Application Observability and Maintenance |
| **CNCF Weight** | 15% |
| **Namespace** | `strike` |
| **Resources** | File |

### Task

List all events in the `strike` namespace, sorted by their creation timestamp (oldest first).
Save the output (which should include at least the time, type, reason, and object name) to `./exam/course/14/q10/events.txt`.

---

## Question 11 | All Three Probes

|                          |                                   |
| ------------------------ | --------------------------------- |
| **Points** | 7 |
| **CNCF Domain** | Application Observability and Maintenance |
| **CNCF Weight** | 15% |
| **Namespace** | `plasma` |
| **Resources** | Pod |

### Task

Create a Pod named `complex-app` in the `plasma` namespace using the `nginx:alpine` image.
Configure all three probe types for the container on port `80`:

- **Startup Probe**: HTTP GET on `/`, wait for up to 30 seconds (e.g. failureThreshold: 30, periodSeconds: 1).
- **Liveness Probe**: TCP Socket on port `80`, periodSeconds 10.
- **Readiness Probe**: HTTP GET on `/`, periodSeconds 5, initialDelaySeconds 5.

---

## Question 12 | Downward API

|                          |                                   |
| ------------------------ | --------------------------------- |
| **Points** | 5 |
| **CNCF Domain** | Application Environment, Configuration and Security |
| **CNCF Weight** | 25% |
| **Namespace** | `thunder` |
| **Resources** | Pod |

### Task

Create a Pod named `env-info` in the `thunder` namespace using the `busybox` image.
It should run the command `sleep 3600`.
Use the Downward API to inject the following environment variables:

- `POD_NAME`: the name of the pod (`metadata.name`)
- `POD_NAMESPACE`: the namespace of the pod (`metadata.namespace`)

---

## Question 13 | SecurityContext Capabilities

|                          |                                   |
| ------------------------ | --------------------------------- |
| **Points** | 6 |
| **CNCF Domain** | Application Environment, Configuration and Security |
| **CNCF Weight** | 25% |
| **Namespace** | `bolt` |
| **Resources** | Pod |

### Task

Create a Pod named `secure-net` in the `bolt` namespace using the `alpine` image, running `sleep 1d`.
Configure the container's `securityContext` to:

- Drop `ALL` capabilities.
- Add the `NET_ADMIN` capability.

---

## Question 14 | Secret with stringData

|                          |                                   |
| ------------------------ | --------------------------------- |
| **Points** | 5 |
| **CNCF Domain** | Application Environment, Configuration and Security |
| **CNCF Weight** | 25% |
| **Namespace** | `storm` |
| **Resources** | Secret |

### Task

Create a YAML manifest for a Secret named `db-credentials` in the `storm` namespace.
Use the `stringData` field to define the following key-value pairs (do not use base64 encoding in the manifest):

- `username`: `admin`
- `password`: `supersecret123`
Apply the YAML file to create the Secret.

---

## Question 15 | ConfigMap as Command Args

|                          |                                   |
| ------------------------ | --------------------------------- |
| **Points** | 5 |
| **CNCF Domain** | Application Environment, Configuration and Security |
| **CNCF Weight** | 25% |
| **Namespace** | `voltage` |
| **Resources** | Pod, ConfigMap |

### Task

Create a ConfigMap named `app-args` in the `voltage` namespace with a key `mode` and value `verbose`.
Create a Pod named `arg-reader` in the `voltage` namespace using the `busybox` image.
The pod should run the command: `echo`
And its argument should be derived from the ConfigMap `app-args` (key `mode`), so the pod essentially runs `echo verbose`.
Use environment variables mapped from the ConfigMap to pass it to the `args` field.

---

## Question 16 | ClusterRole and Binding

|                          |                                   |
| ------------------------ | --------------------------------- |
| **Points** | 7 |
| **CNCF Domain** | Application Environment, Configuration and Security |
| **CNCF Weight** | 25% |
| **Namespace** | `spark` |
| **Resources** | ClusterRole, ClusterRoleBinding |

### Task

Create a ClusterRole named `secret-reader` that can `get`, `watch`, and `list` resources of type `secrets`.
Create a ClusterRoleBinding named `secret-reader-binding` to bind the `secret-reader` ClusterRole to a ServiceAccount named `app-sa` in the `spark` namespace. (You may need to create the ServiceAccount if it doesn't exist).

---

## Question 17 | NetworkPolicy AND Logic

|                          |                                   |
| ------------------------ | --------------------------------- |
| **Points** | 6 |
| **CNCF Domain** | Services and Networking |
| **CNCF Weight** | 20% |
| **Namespace** | `charge` |
| **Resources** | NetworkPolicy |

### Task

Create a NetworkPolicy named `strict-ingress` in the `charge` namespace.
It should apply to pods with the label `role=db` in the `charge` namespace.
Allow ingress traffic on TCP port `3306` ONLY if the traffic comes from:

- Pods with the label `role=api` AND
- The pods must be in a namespace with the label `env=prod`.
(Ensure you use the correct syntax for AND logic in `from` rules).

---

## Question 18 | Ingress Default Backend

|                          |                                   |
| ------------------------ | --------------------------------- |
| **Points** | 5 |
| **CNCF Domain** | Services and Networking |
| **CNCF Weight** | 20% |
| **Namespace** | `surge` |
| **Resources** | Ingress |

### Task

Create an Ingress named `default-ing` in the `surge` namespace.
Configure it with a `defaultBackend` that routes all unmatched traffic to a service named `fallback-svc` on port `8080`.
There should be NO host or path rules defined.

---

## Question 19 | Service Session Affinity

|                          |                                   |
| ------------------------ | --------------------------------- |
| **Points** | 5 |
| **CNCF Domain** | Services and Networking |
| **CNCF Weight** | 20% |
| **Namespace** | `flash` |
| **Resources** | Service |

### Task

Create a Service named `sticky-svc` in the `flash` namespace that exposes port `80` and targets TCP port `8080`.
The selector should be `app=sticky`.
Configure the service to use `ClientIP` session affinity.
Set the session affinity timeout to `10800` seconds (3 hours).

---

## Question 20 | Port Forwarding

|                          |                                   |
| ------------------------ | --------------------------------- |
| **Points** | 6 |
| **CNCF Domain** | Services and Networking |
| **CNCF Weight** | 20% |
| **Namespace** | `strike` |
| **Resources** | File |

### Task

There is a Pod named `hidden-api` running in the `strike` namespace, listening on port `8080`.
Use port-forwarding to forward local port `9090` to the pod's port `8080`.
While the port-forward is running, use `curl` to fetch `http://localhost:9090/status`.
Save the exact response body to `./exam/course/14/q20/response.txt`.
(Ensure you kill the port-forward process after obtaining the response).
