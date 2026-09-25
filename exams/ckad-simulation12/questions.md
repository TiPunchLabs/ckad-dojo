# CKAD Exam Simulator - Dojo Tsukuyomi 🌙

> **Total Score**: 108 points | **Passing Score**: ~66% (71 points)
>
> *「月読は闇を照らす」- Tsukuyomi illuminates the darkness*
>
> **Local Simulator Adaptations**:
>
> | Original                   | Local Simulator                |
> | -------------------------- | ------------------------------ |
> | `/opt/course/N/`         | `./exam/course/N/`           |
> | Original registry          | `localhost:5000`             |
> | SSH to different instances | Single cluster (no SSH needed) |

---

## Question 1 | Image Save and Load

|                          |                                   |
| ------------------------ | --------------------------------- |
| **Points** | 6 |
| **CNCF Domain** | Application Design and Build |
| **CNCF Weight** | 20% |
| **Resources** | `Dockerfile` |
| **Files to create** | `./exam/course/1/lunar-app.tar`, `./exam/course/1/run-output.txt` |

### Task

A multi-stage Dockerfile and a `main.go` program are provided in `./exam/course/1/`.

1. Build an image from this Dockerfile and tag it `lunar-app:v1.0`.
2. Save the image as a tar archive to `./exam/course/1/lunar-app.tar`.
3. Load the archive back into the local image store, and make the loaded image available under the tag `lunar-app:v1.0-verified`, without rebuilding it.
4. Run a container from `lunar-app:v1.0-verified` and write its output to `./exam/course/1/run-output.txt`.

---

## Question 2 | ConfigMap subPath Mount

|                          |                                   |
| ------------------------ | --------------------------------- |
| **Points** | 5 |
| **CNCF Domain** | Application Environment, Configuration and Security |
| **CNCF Weight** | 25% |
| **Namespace** | `crescent` |
| **Resources** | `Pod`, `ConfigMap` |
| **Files to create** | `./exam/course/2/before.txt`, `./exam/course/2/after-no-restart.txt`, `./exam/course/2/after-restart.txt` |

### Task

The Pod `config-pod` in the `crescent` namespace mounts the whole ConfigMap `app-config` as a directory at `/etc/app`.

Change the Pod so that only the `app.conf` key is mounted, at the exact path `/etc/app/app.conf`, using `subPath`.

Once the Pod is running with this change, capture the content of `/etc/app/app.conf` inside the Pod three times, each into its own file:

1. Before any ConfigMap change → `./exam/course/2/before.txt`
2. Update the `app.conf` key of `app-config` to `mode=staging`. Wait about 90 seconds **without** restarting the Pod, then capture again → `./exam/course/2/after-no-restart.txt`
3. Delete and recreate the Pod (same manifest), then capture again → `./exam/course/2/after-restart.txt`

All captures must come from `kubectl exec` output against the running Pod — do not edit the files by hand.

---

## Question 3 | CronJob with Manual Trigger

|                          |                                   |
| ------------------------ | --------------------------------- |
| **Points** | 5 |
| **CNCF Domain** | Application Design and Build |
| **CNCF Weight** | 20% |
| **Namespace** | `twilight` |
| **Resources** | `CronJob`, `Job` |

### Task

In the `twilight` namespace, create a CronJob named `nightly-backup`:

- Runs every 10 minutes.
- Container image: `busybox:1.36`.
- Command: `sh -c 'sleep 30'`.
- A new run must never start while a previous one is still running.

Then check that the CronJob works without waiting for its schedule: trigger one Job from it manually and make sure that Job completes successfully.

---

## Question 4 | Log Streaming Sidecar

|                          |                                   |
| ------------------------ | --------------------------------- |
| **Points** | 6 |
| **CNCF Domain** | Application Design and Build |
| **CNCF Weight** | 20% |
| **Namespace** | `eclipse` |
| **Resources** | `Pod` |

### Task

Create a Pod named `log-aggregator` in the `eclipse` namespace with two containers sharing the `/var/log` directory through an `emptyDir` volume:

1. Main container `app`, image `nginx:1.25`, port 80. It writes to `/var/log/app.log` with:
   `sh -c 'while true; do echo "Request processed" >> /var/log/app.log; sleep 5; done'`
2. Sidecar container `log-tailer`, image `busybox:1.36`. It streams that file to its stdout with:
   `sh -c 'tail -f /var/log/app.log'`

`kubectl logs log-aggregator -c log-tailer -n eclipse` must show the `Request processed` lines.

---

## Question 5 | Helm Release Rollback

|                          |                                   |
| ------------------------ | --------------------------------- |
| **Points** | 5 |
| **CNCF Domain** | Application Deployment |
| **CNCF Weight** | 20% |
| **Namespace** | `nebula` |
| **Resources** | `Helm` |

### Task

A Helm release named `api-release` exists in the `nebula` namespace.
It was recently upgraded to a broken version, resulting in failed deployments.
Roll back the `api-release` release to its previous revision (revision 1).

---

## Question 6 | Rolling Update Strategy

|                          |                                   |
| ------------------------ | --------------------------------- |
| **Points** | 5 |
| **CNCF Domain** | Application Deployment |
| **CNCF Weight** | 20% |
| **Namespace** | `shadow` |
| **Resources** | `Deployment` |

### Task

Create a Deployment named `slow-start-app` in the `shadow` namespace, running 4 replicas of `nginx:1.24`.

This application takes time to initialize after its container starts, so a Pod reporting `Running` is not necessarily ready to serve. Configure the Deployment so that:

- During a rolling update, at most one extra Pod is ever created above the desired replica count.
- A rolling update never reduces capacity below 4 available Pods.
- A Pod must stay ready for 20 seconds before it is counted as available.

---

## Question 7 | Paused Rollout

|                          |                                   |
| ------------------------ | --------------------------------- |
| **Points** | 5 |
| **CNCF Domain** | Application Deployment |
| **CNCF Weight** | 20% |
| **Namespace** | `nightfall` |
| **Resources** | `Deployment`, `ReplicaSet` |
| **Files to create** | `./exam/course/7/before-pause.txt`, `./exam/course/7/during-pause.txt`, `./exam/course/7/after-resume.txt` |

### Task

A Deployment named `critical-processor` exists in the `nightfall` namespace.
Use `kubectl get rs -n nightfall -o wide` for every capture below.

1. Before changing anything, save the ReplicaSets to `./exam/course/7/before-pause.txt`.
2. Pause the rollout of `critical-processor`.
3. While it is paused, change the container image to `nginx:1.26`, then save the ReplicaSets to `./exam/course/7/during-pause.txt`.
4. Resume the rollout. Once it has completed, save the ReplicaSets to `./exam/course/7/after-resume.txt`.

---

## Question 8 | Kustomize JSON Patch

|                          |                                   |
| ------------------------ | --------------------------------- |
| **Points** | 6 |
| **CNCF Domain** | Application Deployment |
| **CNCF Weight** | 20% |
| **Namespace** | `dusk` |
| **Resources** | `Kustomization` |
| **File to create** | `./exam/course/8/patch.json` |

### Task

In `./exam/course/8/`, there is a base deployment file `deployment.yaml` and a `kustomization.yaml`.
Create a JSON patch file named `patch.json` in the same directory.
The patch should add an environment variable `MODE=production` to the container named `web` in the Deployment `frontend`.

Then, update the `kustomization.yaml` to include this JSON patch targeting the Deployment `frontend`.
You do not need to apply the Kustomization, just set up the files.

---

## Question 9 | Fix a Failing Pod

|                          |                                   |
| ------------------------ | --------------------------------- |
| **Points** | 5 |
| **CNCF Domain** | Application Observability and Maintenance |
| **CNCF Weight** | 15% |
| **Namespace** | `starlight` |
| **Resources** | `Pod` |

### Task

A Pod named `metrics-gatherer` in the `starlight` namespace is failing to start.
Identify the issue and fix it. The pod should be running smoothly.

**Hint**: Look at the Pod events.

---

## Question 10 | Top CPU Consumer

|                          |                                   |
| ------------------------ | --------------------------------- |
| **Points** | 5 |
| **CNCF Domain** | Application Observability and Maintenance |
| **CNCF Weight** | 15% |
| **Namespace** | `kube-system` |
| **Resources** | `Metrics` |
| **File to create** | `./exam/course/10/cpu-usage.txt` |

### Task

Find the Pod in the `kube-system` namespace that is consuming the most CPU.
Write the name of the Pod into the file `./exam/course/10/cpu-usage.txt`.
(If multiple pods are similar, just record the top one based on `kubectl top`).

**Note**: `kubectl top` needs metrics-server. Without it the command returns an error; scoring does not depend on live metrics. To install it: on minikube run `minikube addons enable metrics-server`; on kubeadm or kind apply https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml and add `--kubelet-insecure-tls` to the container args if the kubelet uses self-signed certificates.

---

## Question 11 | Broken Deployment Manifest

|                          |                                   |
| ------------------------ | --------------------------------- |
| **Points** | 6 |
| **CNCF Domain** | Application Observability and Maintenance |
| **CNCF Weight** | 15% |
| **Namespace** | `lunar` |
| **Resources** | `Deployment` |
| **File to fix** | `./exam/course/11/broken-deploy.yaml` |

### Task

The manifest `./exam/course/11/broken-deploy.yaml` defines a Deployment named `broken-app` for the `lunar` namespace.
It currently fails to apply, and even once applied its Pods never become Ready.

Fix the manifest file in place and apply it, so that:

- `kubectl apply -f ./exam/course/11/broken-deploy.yaml` succeeds with no validation error.
- All `broken-app` Pods become Ready, with the readiness probe kept in place.

---

## Question 12 | Read a Mounted Secret

|                          |                                   |
| ------------------------ | --------------------------------- |
| **Points** | 6 |
| **CNCF Domain** | Application Environment, Configuration and Security |
| **CNCF Weight** | 25% |
| **Namespace** | `crescent` |
| **Resources** | `Pod`, `Secret` |
| **File to create** | `./exam/course/12/password.txt` |

### Task

A Secret named `db-credentials` exists in the `crescent` namespace.

1. Create a Pod named `secret-reader` in `crescent`, image `busybox:1.36`, that mounts this Secret as a volume at `/etc/secrets` and runs:
   `sh -c 'cat /etc/secrets/*; sleep 3600'`
2. Write the decoded value of the `password` key of `db-credentials` to `./exam/course/12/password.txt`.

---

## Question 13 | Container Capabilities

|                          |                                   |
| ------------------------ | --------------------------------- |
| **Points** | 4 |
| **CNCF Domain** | Application Environment, Configuration and Security |
| **CNCF Weight** | 25% |
| **Namespace** | `twilight` |
| **Resources** | `Pod` |

### Task

Modify the Pod `secure-runner` in the `twilight` namespace so that its container:

- Runs as user ID `2000` (not root).
- Drops all Linux capabilities.
- Adds back only the `NET_ADMIN` capability.

Security context fields cannot be changed on a running Pod, so deleting and recreating the Pod is expected.

---

## Question 14 | Hardened Pod Security Context

|                          |                                   |
| ------------------------ | --------------------------------- |
| **Points** | 6 |
| **CNCF Domain** | Application Environment, Configuration and Security |
| **CNCF Weight** | 25% |
| **Namespace** | `eclipse` |
| **Resources** | `Pod` |

### Task

Create a Pod named `secure-pod` in the `eclipse` namespace using the `nginx:alpine` image.
Apply the following security constraints:

1. The pod must run as user ID `1000`.
2. The container must NOT allow privilege escalation (`allowPrivilegeEscalation: false`).
3. The container must have a read-only root filesystem.
(You may need to mount an emptyDir to `/var/cache/nginx` and `/var/run` to make nginx work with read-only rootfs).

---

## Question 15 | Rotate a Mounted Secret

|                          |                                   |
| ------------------------ | --------------------------------- |
| **Points** | 5 |
| **CNCF Domain** | Application Environment, Configuration and Security |
| **CNCF Weight** | 25% |
| **Namespace** | `shadow` |
| **Resources** | `Secret`, `Pod` |
| **Files to create** | `./exam/course/15/before.txt`, `./exam/course/15/after.txt` |

### Task

A Secret named `legacy-token` in the `shadow` namespace is compromised.
The Pod `token-reader` in the same namespace mounts it at `/etc/secret`.

1. Save the content of `/etc/secret/token` as seen inside `token-reader` to `./exam/course/15/before.txt`.
2. Update the Secret so that the `token` key holds `super-secret-v2`.
3. Delete and recreate the `token-reader` Pod.
4. Save the content of `/etc/secret/token` as seen inside the new Pod to `./exam/course/15/after.txt`.

---

## Question 16 | ResourceQuota

|                          |                                   |
| ------------------------ | --------------------------------- |
| **Points** | 6 |
| **CNCF Domain** | Application Environment, Configuration and Security |
| **CNCF Weight** | 25% |
| **Namespace** | `dusk` |
| **Resources** | `ResourceQuota` |

### Task

Create a ResourceQuota named `compute-quota` in the `dusk` namespace.
Enforce the following limits:

- Hard limit of `4` Pods.
- Hard limit of `2` CPU requests.
- Hard limit of `4Gi` Memory limits.

---

## Question 17 | Restrict Ingress with a NetworkPolicy

|                          |                                   |
| ------------------------ | --------------------------------- |
| **Points** | 5 |
| **CNCF Domain** | Services and Networking |
| **CNCF Weight** | 20% |
| **Namespace** | `dusk` |
| **Resources** | `NetworkPolicy` |

### Task

Create a NetworkPolicy named `frontend-policy` in the `dusk` namespace:

- It applies to Pods with label `app=frontend`.
- Only Pods with label `app=backend` in the same namespace may reach them.
- All other incoming traffic to those Pods is denied.
- Their outgoing traffic must not be restricted.

---

## Question 18 | Path-Based Ingress

|                          |                                   |
| ------------------------ | --------------------------------- |
| **Points** | 6 |
| **CNCF Domain** | Services and Networking |
| **CNCF Weight** | 20% |
| **Namespace** | `starlight` |
| **Resources** | `Ingress` |

### Task

Create an Ingress named `star-ingress` in the `starlight` namespace, with ingress class `nginx`:

- It only handles requests for the host `star.local`.
- Requests whose path starts with `/api` go to Service `api-svc` on port 8080.
- Requests whose path starts with `/web` go to Service `web-svc` on port 80.
- Path matching must follow path segments: `/api/users` goes to `api-svc`, but `/apiary` does not.

---

## Question 19 | ExternalName Service

|                          |                                   |
| ------------------------ | --------------------------------- |
| **Points** | 5 |
| **CNCF Domain** | Services and Networking |
| **CNCF Weight** | 20% |
| **Namespace** | `nebula` |
| **Resources** | `Service` |

### Task

Create an ExternalName Service named `db-ext-svc` in the `nebula` namespace.
It should map to the external name `database.external.example.com`.

---

## Question 20 | Canary Deployment

|                          |                                   |
| ------------------------ | --------------------------------- |
| **Points** | 6 |
| **CNCF Domain** | Services and Networking |
| **CNCF Weight** | 20% |
| **Namespace** | `void` |
| **Resources** | `Deployment`, `Service` |

### Task

The Deployment `api-deploy` in the `void` namespace is exposed by the Service `void-svc`.

1. Create a canary Deployment named `api-deploy-canary` in `void`: 1 replica, same image as `api-deploy`, and its Pods carry the label `version=canary`.
2. `void-svc` must send traffic to **both** the `api-deploy` Pods and the canary Pods.

Do not modify the `api-deploy` Deployment.

---
