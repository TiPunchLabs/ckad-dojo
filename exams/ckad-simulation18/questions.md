# CKAD Exam Simulator - Dojo Izanagi ✨

> **Total Score**: 118 points | **Passing Score**: ~66% (77 points)
>
> *「イザナギは世界を創る」- Izanagi creates the world*
>
> **Local Simulator Adaptations**:
>
> | Original                   | Local Simulator                |
> | -------------------------- | ------------------------------ |
> | `/opt/course/N/`         | `./exam/course/N/`           |
> | Original registry          | `localhost:5000`             |
> | SSH to different instances | Single cluster (no SSH needed) |

---

## Question 1 | Multi-Stage Dockerfile Build

|                          |                                   |
| ------------------------ | --------------------------------- |
| **Points** | 6 |
| **CNCF Domain** | Application Design and Build |
| **CNCF Weight** | 20% |
| **Namespace** | `genesis` |
| **Resources** | Pod, Image |

### Task

There is a skeleton Dockerfile located at `./exam/course/1/Dockerfile`.

1. Modify the `Dockerfile` to use a non-root user. Add an instruction to create a user named `izanagi` with UID `1000` and switch to this user.
2. Build the Docker image from this `Dockerfile` and tag it as `localhost:5000/genesis-app:v1`.
3. Push the image to the local registry at `localhost:5000`.
4. Create a Pod named `genesis-pod` in the `genesis` namespace using this image `localhost:5000/genesis-app:v1`. Ensure it executes the default command defined in the Dockerfile.

---

## Question 2 | Adapter Pattern Sidecar

|                          |                                   |
| ------------------------ | --------------------------------- |
| **Points** | 6 |
| **CNCF Domain** | Application Design and Build |
| **CNCF Weight** | 20% |
| **Namespace** | `origin` |
| **Resources** | Pod, Adapter |

### Task

Create a Pod named `data-transformer` in the `origin` namespace implementing the Adapter pattern.

- The Pod should have an `emptyDir` volume named `shared-data`.
- Main container:
  - Name: `app-container`
  - Image: `busybox:1.32`
  - Command: `sh`, `-c`, `while true; do echo "$(date) - DATA" >> /var/log/app.log; sleep 5; done`
  - Volume mount: Mount `shared-data` at `/var/log`
- Adapter container:
  - Name: `adapter-container`
  - Image: `busybox:1.32`
  - Command: `sh`, `-c`, `tail -f /var/log/app.log | sed 's/DATA/TRANSFORMED_DATA/g' > /var/log/transformed.log`
  - Volume mount: Mount `shared-data` at `/var/log`

---

## Question 3 | Parallel Job with Completions

|                          |                                   |
| ------------------------ | --------------------------------- |
| **Points** | 5 |
| **CNCF Domain** | Application Design and Build |
| **CNCF Weight** | 20% |
| **Namespace** | `primal` |
| **Resources** | Job |

### Task

Create a Job named `index-processor` in the `primal` namespace.

- Configure it to use Indexed completion mode (`completionMode: Indexed`).
- It should run a total of `5` completions.
- It should run up to `2` pods in parallel.
- The container should use the `busybox:1.32` image and run the command: `sh`, `-c`, `echo "Processing item $JOB_COMPLETION_INDEX"`

---

## Question 4 | Pod Lifecycle PreStop Hook

|                          |                                   |
| ------------------------ | --------------------------------- |
| **Points** | 6 |
| **CNCF Domain** | Application Design and Build |
| **CNCF Weight** | 20% |
| **Namespace** | `ancient` |
| **Resources** | Pod |

### Task

Create a Pod named `graceful-shutdown` in the `ancient` namespace.

- Image: `nginx:1.21`
- Set the `terminationGracePeriodSeconds` to `45`.
- Configure a `preStop` hook using `exec` that runs the command: `sh`, `-c`, `sleep 10 && nginx -s quit`

---

## Question 5 | Helm Release Values Override

|                          |                                   |
| ------------------------ | --------------------------------- |
| **Points** | 6 |
| **CNCF Domain** | Application Deployment |
| **CNCF Weight** | 20% |
| **Namespace** | `nexus` |
| **Resources** | Helm Release |

### Task

A Helm release named `genesis-web` is deployed in the `nexus` namespace.

1. Inspect the chart values currently deployed.
2. Upgrade the release to change the `replicaCount` to `3` without altering any other custom values that were previously set (use `--reuse-values`).
3. You can find the chart source at `./exam/course/5/genesis-web-chart` if needed, but you only need to modify the deployed release.

---

## Question 6 | Deployment Canary Split

|                          |                                   |
| ------------------------ | --------------------------------- |
| **Points** | 6 |
| **CNCF Domain** | Application Deployment |
| **CNCF Weight** | 20% |
| **Namespace** | `terra` |
| **Resources** | Deployment, PDB |

### Task

1. Create a Deployment named `terra-web` in the `terra` namespace with `4` replicas using the `nginx:1.21` image.
2. Create a PodDisruptionBudget named `terra-pdb` in the same namespace targeting the pods of the `terra-web` Deployment.
3. Configure the PDB to require a `minAvailable` of `75%`.

---

## Question 7 | Deployment Rollback

|                          |                                   |
| ------------------------ | --------------------------------- |
| **Points** | 6 |
| **CNCF Domain** | Application Deployment |
| **CNCF Weight** | 20% |
| **Namespace** | `eden` |
| **Resources** | Deployment |

### Task

A Deployment named `eden-api` exists in the `eden` namespace.

1. Update the Deployment's image from `nginx:1.20` to `nginx:1.21`.
2. Ensure that the change is recorded in the rollout history by setting the revision annotation on the Deployment resource.
3. Ensure the Deployment uses a rolling update strategy with `maxSurge` set to `2` and `maxUnavailable` set to `0`.

---

## Question 8 | Kustomize ConfigMap Generator

|                          |                                   |
| ------------------------ | --------------------------------- |
| **Points** | 6 |
| **CNCF Domain** | Application Deployment |
| **CNCF Weight** | 20% |
| **Namespace** | `matrix` |
| **Resources** | Kustomize, Secret |

### Task

In `./exam/course/8/kustomize`, there is a `kustomization.yaml` file.

1. Add a `secretGenerator` to the `kustomization.yaml` to generate a secret named `matrix-secret`.
2. The secret should contain a literal `db-password=supersecret`.
3. Configure `generatorOptions` to disable the suffix hash (`disableNameSuffixHash: true`).
4. Apply the kustomization to the `matrix` namespace.

---

## Question 9 | Init Container Failure Debug

|                          |                                   |
| ------------------------ | --------------------------------- |
| **Points** | 6 |
| **CNCF Domain** | Application Observability and Maintenance |
| **CNCF Weight** | 15% |
| **Namespace** | `cosmos` |
| **Resources** | Pod Troubleshooting |

### Task

A Pod named `stuck-pod` in the `cosmos` namespace is stuck in the `Init:Error` state.

1. Identify the reason why the init container is failing.
2. Fix the pod so that it reaches the `Running` state. You may recreate the pod if necessary. Note: The init container is supposed to successfully run a shell command and exit.

---

## Question 10 | Namespace Events Export

|                          |                                   |
| ------------------------ | --------------------------------- |
| **Points** | 5 |
| **CNCF Domain** | Application Observability and Maintenance |
| **CNCF Weight** | 15% |
| **Namespace** | `zenith` |
| **Resources** | kubectl output |

### Task

Extract the latest events from the `zenith` namespace and output them to a file at `./exam/course/10/events.txt`.
Use `custom-columns` output format to display only the event `TYPE`, `REASON`, and `MESSAGE`.
Ensure the output has the exact headers `TYPE`, `REASON`, and `MESSAGE`.

---

## Question 11 | Service Internal Traffic Policy

|                          |                                   |
| ------------------------ | --------------------------------- |
| **Points** | 6 |
| **CNCF Domain** | Application Observability and Maintenance |
| **CNCF Weight** | 15% |
| **Namespace** | `genesis` |
| **Resources** | Port-forward |

### Task

There is a deployment `backend-api` in the `genesis` namespace that is exposing an API internally on port `8080`.

1. Create a script at `./exam/course/11/check.sh` that sets up a temporary port-forwarding to the `backend-api` service on local port `9999` mapping to the service port `8080`.
2. The script should use `curl` to fetch `http://localhost:9999/health`, append the output to `./exam/course/11/health.log`, and then terminate the port-forward process.

*(You don't need to actually run the script in the background for grading, but ensure it contains the correct commands to perform this sequence).*

---

## Question 12 | Projected ServiceAccount Token

|                          |                                   |
| ------------------------ | --------------------------------- |
| **Points** | 7 |
| **CNCF Domain** | Application Environment, Configuration and Security |
| **CNCF Weight** | 25% |
| **Namespace** | `origin` |
| **Resources** | Projected Volume |

### Task

Create a Pod named `projected-pod` in the `origin` namespace using the `nginx:alpine` image.
Use a single `projected` volume mounted at `/var/run/projected` to expose all of the following sources:

1. A Secret named `my-secret` (already exists in the namespace) - expose the `username` key.
2. A ConfigMap named `my-config` (already exists) - expose all its keys.
3. DownwardAPI - expose the pod's `metadata.labels` as a file named `labels`.
4. A ServiceAccountToken with audience `vault` and expiration of `3600` seconds, exposed as a file named `token`.

---

## Question 13 | Secret stringData Entry

|                          |                                   |
| ------------------------ | --------------------------------- |
| **Points** | 5 |
| **CNCF Domain** | Application Environment, Configuration and Security |
| **CNCF Weight** | 25% |
| **Namespace** | `primal` |
| **Resources** | Secret |

### Task

Create a Secret named `static-creds` in the `primal` namespace.

- It should contain the literal `api-key=12345ABC`.
- Make the Secret immutable so its contents cannot be modified.

---

## Question 14 | Pod with ReadOnlyRootFilesystem

|                          |                                   |
| ------------------------ | --------------------------------- |
| **Points** | 7 |
| **CNCF Domain** | Application Environment, Configuration and Security |
| **CNCF Weight** | 25% |
| **Namespace** | `ancient` |
| **Resources** | SecurityContext |

### Task

Create a Pod named `secure-pod` in the `ancient` namespace using the `nginx:alpine` image.
Configure the container's security context with the following hardening settings:

- It must run as a non-root user (e.g., `runAsNonRoot: true`, `runAsUser: 1000`).
- The root filesystem must be read-only.
- Drop ALL capabilities.
- Privilege escalation must not be allowed (`allowPrivilegeEscalation: false`).
*(Note: You will need to add an `emptyDir` volume mounted at `/var/cache/nginx` and `/var/run` so nginx can start up with a read-only root filesystem).*

---

## Question 15 | ClusterRole and ClusterRoleBinding

|                          |                                   |
| ------------------------ | --------------------------------- |
| **Points** | 6 |
| **CNCF Domain** | Application Environment, Configuration and Security |
| **CNCF Weight** | 25% |
| **Namespace** | `terra` |
| **Resources** | RBAC |

### Task

Create a ClusterRole named `monitor-viewer`.

1. It should have permissions to `get`, `list`, and `watch` all `pods` and `services` cluster-wide.
2. Create another ClusterRole named `aggregated-monitor` that uses aggregation labels to automatically inherit the rules from `monitor-viewer`.
3. Add the required label to `monitor-viewer` so it gets aggregated into `aggregated-monitor`.

---

## Question 16 | ResourceQuota for Namespace

|                          |                                   |
| ------------------------ | --------------------------------- |
| **Points** | 6 |
| **CNCF Domain** | Application Environment, Configuration and Security |
| **CNCF Weight** | 25% |
| **Namespace** | `eden` |
| **Resources** | ResourceQuota |

### Task

Create a ResourceQuota named `priority-quota` in the `eden` namespace.

1. Configure it to limit the total number of pods to `5` and total requests.cpu to `2`.
2. Apply a scope selector so that this quota ONLY applies to Pods that have the `PriorityClass` of `high-priority` (assume such PriorityClass exists or match by `PriorityClassIn` scope selector). Use the scope `PriorityClassIn` with values `high-priority`.

---

## Question 17 | NetworkPolicy Named Port

|                          |                                   |
| ------------------------ | --------------------------------- |
| **Points** | 6 |
| **CNCF Domain** | Services and Networking |
| **CNCF Weight** | 20% |
| **Namespace** | `matrix` |
| **Resources** | NetworkPolicy |

### Task

Create a NetworkPolicy named `allow-named-port` in the `matrix` namespace.

- It should apply to pods with the label `role=backend`.
- It should allow incoming TCP traffic on the named port `api-port`.
- It should only allow this traffic from pods in the `matrix` namespace with the label `role=frontend`.

---

## Question 18 | Ingress Default Backend

|                          |                                   |
| ------------------------ | --------------------------------- |
| **Points** | 5 |
| **CNCF Domain** | Services and Networking |
| **CNCF Weight** | 20% |
| **Namespace** | `cosmos` |
| **Resources** | Ingress |

### Task

An Ingress named `cosmos-ingress` exists in the `cosmos` namespace.
Update this Ingress to explicitly use the IngressClass named `nginx` by setting the `ingressClassName` field.
Ensure the routing rule points traffic for `cosmos.local` to the service `cosmos-svc` on port `80`.

---

## Question 19 | Service Endpoint Inspection

|                          |                                   |
| ------------------------ | --------------------------------- |
| **Points** | 6 |
| **CNCF Domain** | Services and Networking |
| **CNCF Weight** | 20% |
| **Namespace** | `zenith` |
| **Resources** | DNS/Services |

### Task

There is a service named `data-svc` in the `ancient` namespace.
Create a Pod named `dns-tester` in the `zenith` namespace using the `busybox:1.32` image.
It should run a sleep command (`sleep 3600`).
Create a file at `./exam/course/19/fqdn.txt` containing the Fully Qualified Domain Name (FQDN) that the `dns-tester` pod can use to reach the `data-svc` service in the `ancient` namespace.

---

## Question 20 | Namespace Isolation NetworkPolicy

|                          |                                   |
| ------------------------ | --------------------------------- |
| **Points** | 6 |
| **CNCF Domain** | Services and Networking |
| **CNCF Weight** | 20% |
| **Namespace** | `nexus` |
| **Resources** | NetworkPolicy |

### Task

Create a NetworkPolicy named `isolate-namespace` in the `nexus` namespace.

- It should apply to ALL pods in the `nexus` namespace.
- It should allow all incoming traffic from pods within the `nexus` namespace.
- It should explicitly block all incoming traffic from pods in ANY OTHER namespace.
- It should allow all outgoing (egress) traffic.

---
