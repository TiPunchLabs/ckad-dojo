# CKAD Exam Simulator - Dojo Fujin 🌬️

> **Total Score**: 110 points | **Passing Score**: ~66% (72 points)
>
> *「風神は嵐を呼ぶ」- Fujin summons the storm*
>
> **Local Simulator Adaptations**:
>
> | Original                   | Local Simulator                |
> | -------------------------- | ------------------------------ |
> | `/opt/course/N/`         | `./exam/course/N/`           |
> | Original registry          | `localhost:5000`             |
> | SSH to different instances | Single cluster (no SSH needed) |

---

## Question 1 | Docker Image Build and Push

|                          |                                   |
| ------------------------ | --------------------------------- |
| **Points** | 5 |
| **CNCF Domain** | Application Design and Build |
| **CNCF Weight** | 20% |
| **Namespace** | - |
| **Resources** | Docker Image |

### Task
There is a Dockerfile located at `./exam/course/13/q1/Dockerfile`.
Build a container image using this Dockerfile and tag it as `localhost:5000/fujin-api:v2`.
Push the built image to the local registry at `localhost:5000`.

---
## Question 2 | Sidecar Logging Container

|                          |                                   |
| ------------------------ | --------------------------------- |
| **Points** | 6 |
| **CNCF Domain** | Application Design and Build |
| **CNCF Weight** | 20% |
| **Namespace** | `gale` |
| **Resources** | Pod |

### Task
An application is running in a pod named `wind-logger` in the `gale` namespace. It generates logs in a format that is not easily parsable by our central logging system.
Modify the pod to include an adapter container using the image `busybox:1.31.1`.
The main container `app` writes logs to `/var/log/wind.log`. The adapter container should mount the same volume, tail the log file, and output each line prepended with `[WIND-LOG] ` to stdout using `tail -f /var/log/wind.log | sed 's/^/[WIND-LOG] /'`.
Make sure the adapter container is named `adapter` and both containers share a volume named `logs` mounted at `/var/log`. The pod is already created but might need to be replaced.

---
## Question 3 | Batch Job Processing

|                          |                                   |
| ------------------------ | --------------------------------- |
| **Points** | 5 |
| **CNCF Domain** | Application Design and Build |
| **CNCF Weight** | 20% |
| **Namespace** | `breeze` |
| **Resources** | Job |

### Task
Create a Job named `storm-processor` in the `breeze` namespace.
The Job should use the `busybox:1.31.1` image and execute the command: `sh -c 'sleep 2; echo "Processing storm data"'`.
Configure the Job to run a total of `6` successful completions, with `3` pods running in parallel.

---
## Question 4 | Fix Deployment CrashLoopBackOff

|                          |                                   |
| ------------------------ | --------------------------------- |
| **Points** | 6 |
| **CNCF Domain** | Application Design and Build |
| **CNCF Weight** | 20% |
| **Namespace** | `tempest` |
| **Resources** | Pod |
| **File to create** | `./exam/course/13/q4/pod.yaml` |

### Task
There is a deployment named `tempest-app` in the `tempest` namespace.
Extract its pod template and create a standalone Pod named `tempest-debug` in the `tempest` namespace.
The `tempest-debug` Pod should have the exact same container specifications (image, ports, env vars) as the deployment's pod template, but change the container's command to `['sleep', '3600']`.
Save the YAML definition used to create this Pod at `./exam/course/13/q4/pod.yaml`.

---
## Question 5 | Helm Release Upgrade

|                          |                                   |
| ------------------------ | --------------------------------- |
| **Points** | 5 |
| **CNCF Domain** | Application Deployment |
| **CNCF Weight** | 20% |
| **Namespace** | `typhoon` |
| **Resources** | Helm Release |

### Task
A Helm chart has been deployed to the `typhoon` namespace with the release name `storm-app`.
Update the release `storm-app` using the chart located at `./exam/course/13/q5/storm-chart`.
Override the replica count to `3` and change the image tag to `v2.0.0` during the upgrade.

---
## Question 6 | Rolling Update Strategy

|                          |                                   |
| ------------------------ | --------------------------------- |
| **Points** | 5 |
| **CNCF Domain** | Application Deployment |
| **CNCF Weight** | 20% |
| **Namespace** | `cyclone` |
| **Resources** | Deployment |

### Task
Update the existing deployment named `cyclone-web` in the `cyclone` namespace.
Change its `revisionHistoryLimit` to `2`.
Then perform a rolling update to change the image of the container to `nginx:1.23.1`.

---
## Question 7 | Blue-Green Deployment Switch

|                          |                                   |
| ------------------------ | --------------------------------- |
| **Points** | 6 |
| **CNCF Domain** | Application Deployment |
| **CNCF Weight** | 20% |
| **Namespace** | `zephyr` |
| **Resources** | Service, Deployment |

### Task
In the `zephyr` namespace, a blue-green deployment is currently active. The service `zephyr-svc` is routing traffic to the `blue` deployment.
Switch the traffic to the `green` deployment by updating the service's selector.
Ensure that the `zephyr-svc` routes all traffic to pods with the label `version: green`.

---
## Question 8 | Kustomize Apply

|                          |                                   |
| ------------------------ | --------------------------------- |
| **Points** | 6 |
| **CNCF Domain** | Application Deployment |
| **CNCF Weight** | 20% |
| **Namespace** | `tornado` |
| **Resources** | ConfigMap, Kustomization |
| **File to create** | `./exam/course/13/q8/kustomization.yaml` |

### Task
A Kustomization directory is located at `./exam/course/13/q8/`.
Add a Kustomization file (`kustomization.yaml`) in that directory.
It should include the `deployment.yaml` file located in the same directory as a resource.
Also, generate a ConfigMap named `tornado-config` from a literal value `WIND_SPEED=150mph` using `configMapGenerator`.
Then apply the Kustomization to the `tornado` namespace.

---
## Question 9 | OOMKilled Pod Troubleshooting

|                          |                                   |
| ------------------------ | --------------------------------- |
| **Points** | 5 |
| **CNCF Domain** | Application Observability and Maintenance |
| **CNCF Weight** | 15% |
| **Namespace** | `mistral` |
| **Resources** | Pod |

### Task
A pod named `memory-hog` in the `mistral` namespace is repeatedly crashing with an `OOMKilled` status.
Investigate and fix the issue by increasing the memory limit of the container named `hog` to `256Mi`. The memory request should remain unchanged at `64Mi`.

---
## Question 10 | Top Memory-Consuming Pods

|                          |                                   |
| ------------------------ | --------------------------------- |
| **Points** | 5 |
| **CNCF Domain** | Application Observability and Maintenance |
| **CNCF Weight** | 15% |
| **Namespace** | `sirocco` |
| **Resources** | File |
| **File to create** | `./exam/course/13/q10/top-pods.txt` |

### Task
Identify the top 3 pods in the `sirocco` namespace that are consuming the most memory.
Write the names of these pods (just the pod names, one per line) to `./exam/course/13/q10/top-pods.txt`, sorted from highest memory consumption to lowest.

---
## Question 11 | Liveness and Readiness Probes

|                          |                                   |
| ------------------------ | --------------------------------- |
| **Points** | 6 |
| **CNCF Domain** | Application Observability and Maintenance |
| **CNCF Weight** | 15% |
| **Namespace** | `monsoon` |
| **Resources** | Pod |

### Task
Create a Pod named `monsoon-checker` in the `monsoon` namespace using the image `busybox:1.31.1`.
The container should run the command `sh -c 'touch /tmp/ready && sleep 3600'`.
Configure a readiness probe for the container that uses the `exec` action to run `cat /tmp/ready`.
Set the initial delay to `5` seconds and period to `10` seconds.

---
## Question 12 | Secret from File

|                          |                                   |
| ------------------------ | --------------------------------- |
| **Points** | 6 |
| **CNCF Domain** | Application Environment, Configuration and Security |
| **CNCF Weight** | 25% |
| **Namespace** | `gale` |
| **Resources** | Pod, Secret |

### Task
Create a Secret named `gale-secret` in the `gale` namespace with a key `password.txt` containing the value `super-secret-wind`.
Create a Pod named `secret-reader` in the `gale` namespace using image `alpine:3.14` and command `sleep 3600`.
Mount the Secret into the pod such that only the file `password.txt` appears at `/etc/secrets/password.txt` without deleting any other files that might exist in `/etc/secrets` (use `subPath`).

---
## Question 13 | Role and RoleBinding

|                          |                                   |
| ------------------------ | --------------------------------- |
| **Points** | 5 |
| **CNCF Domain** | Application Environment, Configuration and Security |
| **CNCF Weight** | 25% |
| **Namespace** | `breeze` |
| **Resources** | Role, RoleBinding |

### Task
Create a Role named `breeze-manager` in the `breeze` namespace that grants `create`, `delete`, `list`, and `watch` permissions on `deployments` and `statefulsets` (which are in the `apps` API group).
Create a RoleBinding named `breeze-manager-binding` in the same namespace binding this Role to a ServiceAccount named `breeze-admin` (the ServiceAccount already exists).

---
## Question 14 | Pod with Volume and SecurityContext

|                          |                                   |
| ------------------------ | --------------------------------- |
| **Points** | 5 |
| **CNCF Domain** | Application Environment, Configuration and Security |
| **CNCF Weight** | 25% |
| **Namespace** | `tempest` |
| **Resources** | Pod |

### Task
Create a Pod named `secure-storage` in the `tempest` namespace using the image `nginx:1.23.1`.
Configure the pod's security context so that all processes in the containers run with the filesystem group (`fsGroup`) set to `2000`.

---
## Question 15 | LimitRange Configuration

|                          |                                   |
| ------------------------ | --------------------------------- |
| **Points** | 6 |
| **CNCF Domain** | Application Environment, Configuration and Security |
| **CNCF Weight** | 25% |
| **Namespace** | `cyclone` |
| **Resources** | LimitRange |

### Task
Create a LimitRange named `cyclone-limits` in the `cyclone` namespace.
It should enforce the following constraints for Pods:
- Maximum memory: `500Mi`
- Minimum memory: `100Mi`
For Containers:
- Default CPU limit: `500m`
- Default CPU request: `200m`

---
## Question 16 | Disable Default ServiceAccount Automount

|                          |                                   |
| ------------------------ | --------------------------------- |
| **Points** | 5 |
| **CNCF Domain** | Application Environment, Configuration and Security |
| **CNCF Weight** | 25% |
| **Namespace** | `zephyr` |
| **Resources** | Pod |

### Task
Update the pod `zephyr-api` in the `zephyr` namespace so that it does NOT automatically mount the default ServiceAccount token. (You may need to recreate the pod).

---
## Question 17 | Egress NetworkPolicy for DNS

|                          |                                   |
| ------------------------ | --------------------------------- |
| **Points** | 6 |
| **CNCF Domain** | Services and Networking |
| **CNCF Weight** | 20% |
| **Namespace** | `typhoon` |
| **Resources** | NetworkPolicy |

### Task
Create a NetworkPolicy named `allow-dns-egress` in the `typhoon` namespace.
It should apply to pods with the label `role: worker`.
Allow egress traffic only to port `53` (TCP and UDP) on all destinations.
Ensure all other egress traffic from these pods is denied.

---
## Question 18 | Ingress with Path Routing

|                          |                                   |
| ------------------------ | --------------------------------- |
| **Points** | 6 |
| **CNCF Domain** | Services and Networking |
| **CNCF Weight** | 20% |
| **Namespace** | `tornado` |
| **Resources** | Ingress |

### Task
Create an Ingress named `tornado-ingress` in the `tornado` namespace.
It should route traffic for host `tornado.dojo.com` as follows:
- Path `/api` routes to service `api-svc` on port `8080`.
- Path `/web` routes to service `web-svc` on port `80`.
Assume path type `Prefix` for both.

---
## Question 19 | Headless Service for StatefulSet

|                          |                                   |
| ------------------------ | --------------------------------- |
| **Points** | 5 |
| **CNCF Domain** | Services and Networking |
| **CNCF Weight** | 20% |
| **Namespace** | `mistral` |
| **Resources** | Service |

### Task
There is a StatefulSet named `mistral-db` in the `mistral` namespace that expects a headless service.
Create a headless service named `mistral-db-headless` in the `mistral` namespace that targets pods with label `app: mistral-db`. The service should expose port `3306`.

---
## Question 20 | Debug Service Connectivity

|                          |                                   |
| ------------------------ | --------------------------------- |
| **Points** | 6 |
| **CNCF Domain** | Services and Networking |
| **CNCF Weight** | 20% |
| **Namespace** | `sirocco` |
| **Resources** | File |
| **File to create** | `./exam/course/13/q20/svc-env.txt` |

### Task
There is a pod named `sirocco-app` and a service named `sirocco-backend` in the `sirocco` namespace.
When the pod was started, Kubernetes automatically injected environment variables for the service.
Find the name of the environment variable that stores the IP address of the `sirocco-backend` service inside the `sirocco-app` pod.
Write the name of this environment variable (just the variable name, e.g., `SIROCCO_BACKEND_SERVICE_HOST`) into `./exam/course/13/q20/svc-env.txt`.

---
