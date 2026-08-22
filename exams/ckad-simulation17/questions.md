# CKAD Exam Simulator - Dojo Hachiman ⚔️

> **Total Score**: 116 points | **Passing Score**: ~66% (77 points)
> 「八幡は戦略を練る」- Hachiman hones strategy

---

### Question 1
| Field | Value |
| --- | --- |
| **Points** | 5 |
| **CNCF Domain** | Application Design and Build |
| **CNCF Weight** | 20% |
| **Namespace** | fortress |
| **Resources** | Pod |
| **File to create** | `./exam/course/1/pod.yaml` |

### Task
Create a Pod named `entry-override` in the `fortress` namespace using the `nginx:alpine` image.
The image normally starts nginx. However, you must override both the entrypoint and the command.
Configure the Pod to run `sleep` for `3600` seconds by passing them appropriately to the container.
- Command (Entrypoint override): `["sleep"]`
- Args (CMD override): `["3600"]`
Save the manifest to `./exam/course/1/pod.yaml`.

---

### Question 2
| Field | Value |
| --- | --- |
| **Points** | 5 |
| **CNCF Domain** | Application Design and Build |
| **CNCF Weight** | 20% |
| **Namespace** | fortress |
| **Resources** | ConfigMap, Pod |
| **File to create** | `./exam/course/2/init-pod.yaml` |

### Task
Create a ConfigMap named `init-script-cm` in the `fortress` namespace containing a single key `setup.sh` with the content:
```bash
#!/bin/sh
echo "Initialization successful!" > /work-dir/index.html
```

Then create a Pod named `web-setup` using the `nginx:alpine` image.
Add an init container to the Pod using the `busybox:1.36` image named `init-setup`.
The init container should:
1. Mount the ConfigMap `init-script-cm` at `/scripts`
2. Mount an emptyDir volume named `work-vol` at `/work-dir`
3. Execute the script: `sh /scripts/setup.sh`

The main `web-setup` container should mount the same `work-vol` at `/usr/share/nginx/html`.
Save the Pod manifest to `./exam/course/2/init-pod.yaml`.

---

### Question 3
| Field | Value |
| --- | --- |
| **Points** | 5 |
| **CNCF Domain** | Application Design and Build |
| **CNCF Weight** | 20% |
| **Namespace** | siege |
| **Resources** | CronJob |
| **File to create** | `./exam/course/3/cronjob.yaml` |

### Task
Create a CronJob named `siege-report` in the `siege` namespace.
- It should run a container using the `busybox:1.36` image.
- The command should be `/bin/sh, -c, date; echo Hello from siege`.
- It should run every hour on the half hour (e.g., 00:30, 01:30).
- It must be scheduled in the `Asia/Tokyo` timezone. (Requires Kubernetes 1.27+)
Save the CronJob manifest to `./exam/course/3/cronjob.yaml`.

---

### Question 4
| Field | Value |
| --- | --- |
| **Points** | 8 |
| **CNCF Domain** | Application Design and Build |
| **CNCF Weight** | 20% |
| **Namespace** | bastion |
| **Resources** | Pod |
| **File to create** | `./exam/course/4/shared-pid.yaml` |

### Task
Create a multi-container Pod named `process-monitor` in the `bastion` namespace.
The Pod must share the PID namespace between all containers.
- Container 1: `nginx-app` using `nginx:alpine` image.
- Container 2: `monitor-app` using `busybox:1.36` image.
The `monitor-app` container should run a continuous loop listing processes every 5 seconds:
`["/bin/sh", "-c", "while true; do ps -ef; sleep 5; done"]`

Ensure `shareProcessNamespace: true` is set at the Pod level.
Save the manifest to `./exam/course/4/shared-pid.yaml`.

---

### Question 5
| Field | Value |
| --- | --- |
| **Points** | 5 |
| **CNCF Domain** | Application Deployment |
| **CNCF Weight** | 20% |
| **Namespace** | garrison |
| **Resources** | Helm |

### Task
A Helm release named `battle-web` exists in the `garrison` namespace.
Upgrade it using the chart located at `/opt/course/5/battle-chart/`.
However, the upgrade must be ATOMIC (if it fails, it rolls back automatically) and have a timeout of `1m` (1 minute).
Set the chart value `replicaCount` to `3` during the upgrade.
Note: The underlying deployment may have a failing probe if configured incorrectly, but your task is purely to execute the Helm upgrade command with the correct flags.

---

### Question 6
| Field | Value |
| --- | --- |
| **Points** | 6 |
| **CNCF Domain** | Application Deployment |
| **CNCF Weight** | 20% |
| **Namespace** | citadel |
| **Resources** | Deployment |
| **File to create** | `./exam/course/6/deploy.yaml` |

### Task
Create a Deployment named `citadel-guard` in the `citadel` namespace.
- Replicas: `4`
- Image: `nginx:1.24.0-alpine`
- Labels: `app=guard`
Configure the deployment such that if it takes more than `15` seconds to roll out, it is considered failed (progressDeadlineSeconds).
Save the manifest to `./exam/course/6/deploy.yaml` and apply it.

---

### Question 7
| Field | Value |
| --- | --- |
| **Points** | 6 |
| **CNCF Domain** | Application Deployment |
| **CNCF Weight** | 20% |
| **Namespace** | rampart |
| **Resources** | Deployment, Service |

### Task
In the `rampart` namespace, there is a deployment named `api-server-blue` and a service named `api-svc`.
Currently, `api-svc` routes traffic to the `api-server-blue` pods.
1. Create a new deployment named `api-server-green` with the image `nginx:1.25.0-alpine` and `app: api-server-green` labels. Set replicas to 2.
2. Update the `api-svc` Service to route traffic to the `api-server-green` pods instead of `blue`.
3. Do not delete the `api-server-blue` deployment.

---

### Question 8
| Field | Value |
| --- | --- |
| **Points** | 6 |
| **CNCF Domain** | Application Deployment |
| **CNCF Weight** | 20% |
| **Namespace** | vanguard |
| **Resources** | Kustomize |
| **Files** | `/opt/course/8/kustomization.yaml` |

### Task
A base kustomization structure exists at `/opt/course/8/`.
Modify the `kustomization.yaml` file in this directory to apply two transformations to the base resources:
1. Override the `nginx` image to use `nginx:1.23.0-alpine`.
2. Apply a patch to scale the `vanguard-web` deployment to `5` replicas. (You can create a patch file in the same directory or use inline patches).
Apply the customized manifests to the `vanguard` namespace.
Save your built manifests to `./exam/course/8/kustomize-output.yaml`.

---

### Question 9
| Field | Value |
| --- | --- |
| **Points** | 5 |
| **CNCF Domain** | Application Observability and Maintenance |
| **CNCF Weight** | 15% |
| **Namespace** | sentinel |
| **Resources** | Pod |

### Task
A Pod named `data-processor` in the `sentinel` namespace is crashing.
Identify the issue (it is being OOMKilled).
Modify the Pod (you may need to delete and recreate it) to increase its memory limit to `256Mi`. Keep the requests at `64Mi`.
Ensure the Pod reaches the `Running` state.

---

### Question 10
| Field | Value |
| --- | --- |
| **Points** | 6 |
| **CNCF Domain** | Application Observability and Maintenance |
| **CNCF Weight** | 15% |
| **Namespace** | outpost |
| **Resources** | Pod (Ephemeral Container) |

### Task
The Pod `secure-app` in the `outpost` namespace contains a distroless container that lacks a shell.
You need to inspect its filesystem.
Add an ephemeral container to `secure-app` using the `busybox:1.36` image.
Name the ephemeral container `debugger`.
Ensure the ephemeral container can run interactively (it must stay running so the scoring script can detect it). For example, pass `--command -- sh -c "sleep 3600"`.

---

### Question 11
| Field | Value |
| --- | --- |
| **Points** | 6 |
| **CNCF Domain** | Application Observability and Maintenance |
| **CNCF Weight** | 15% |
| **Namespace** | armory |
| **Resources** | Deployment, ResourceQuota |

### Task
A Deployment named `weapon-smith` in the `armory` namespace is failing to scale up its pods due to a `ResourceQuota` named `armory-quota`.
Troubleshoot the issue and adjust the `weapon-smith` deployment so that its pods fit within the quota constraints.
Requirements for `weapon-smith` pods:
- They must request exactly `100m` CPU and `128Mi` memory.
- You cannot modify or delete the `armory-quota` ResourceQuota itself.
Scale the deployment to `3` replicas if it's not already.

---

### Question 12
| Field | Value |
| --- | --- |
| **Points** | 5 |
| **CNCF Domain** | Application Environment, Configuration and Security |
| **CNCF Weight** | 25% |
| **Namespace** | fortress |
| **Resources** | Pod |
| **File to create** | `./exam/course/12/downward.yaml` |

### Task
Create a Pod named `resource-aware` in the `fortress` namespace using the `busybox:1.36` image.
It should run the command `sleep 3600`.
Configure the container with:
- CPU Request: `200m`
- Memory Limit: `256Mi`
Expose the Pod's CPU request and Memory limit as environment variables using the Downward API:
- `MY_CPU_REQUEST` should reflect the CPU requests.
- `MY_MEM_LIMIT` should reflect the Memory limits.
Save the manifest to `./exam/course/12/downward.yaml`.

---

### Question 13
| Field | Value |
| --- | --- |
| **Points** | 6 |
| **CNCF Domain** | Application Environment, Configuration and Security |
| **CNCF Weight** | 25% |
| **Namespace** | siege |
| **Resources** | ServiceAccount, Pod |
| **File to create** | `./exam/course/13/sa-pod.yaml` |

### Task
1. Create a ServiceAccount named `stealth-sa` in the `siege` namespace.
2. Create a Pod named `stealth-pod` in the same namespace using the `nginx:alpine` image and the `stealth-sa` ServiceAccount.
3. The pod MUST NOT automount the ServiceAccount token by default (configure `automountServiceAccountToken: false` on the Pod or ServiceAccount).
4. Instead, manually mount the ServiceAccount token (via a projected volume or secret) to `/var/run/secrets/custom-token`.
Save the manifest to `./exam/course/13/sa-pod.yaml`.

---

### Question 14
| Field | Value |
| --- | --- |
| **Points** | 5 |
| **CNCF Domain** | Application Environment, Configuration and Security |
| **CNCF Weight** | 25% |
| **Namespace** | bastion |
| **Resources** | Pod |
| **File to create** | `./exam/course/14/seccomp.yaml` |

### Task
Create a Pod named `secure-workload` in the `bastion` namespace using the `nginx:alpine` image.
Configure the Pod's SecurityContext to use the `RuntimeDefault` seccomp profile.
Ensure the container runs as a non-root user (e.g., `runAsUser: 1000` and `runAsNonRoot: true`).
Save the manifest to `./exam/course/14/seccomp.yaml`.

---

### Question 15
| Field | Value |
| --- | --- |
| **Points** | 7 |
| **CNCF Domain** | Application Environment, Configuration and Security |
| **CNCF Weight** | 25% |
| **Namespace** | citadel |
| **Resources** | Secret, Pod |
| **File to create** | `./exam/course/15/multi-secret.yaml` |

### Task
1. Create a Secret named `db-credentials` in the `citadel` namespace containing two keys: `username` (value `admin`) and `password` (value `hachiman_rocks`).
2. Create a Pod named `db-consumer` using the `alpine:3.18` image running `sleep 3600`.
3. Mount the `db-credentials` secret as a volume at `/etc/db-creds/`.
4. However, ONLY the `password` key should be mounted as a file named `db-pass.txt` inside `/etc/db-creds/`. The `username` key should not be present as a file.
Save the manifest to `./exam/course/15/multi-secret.yaml`.

---

### Question 16
| Field | Value |
| --- | --- |
| **Points** | 6 |
| **CNCF Domain** | Application Environment, Configuration and Security |
| **CNCF Weight** | 25% |
| **Namespace** | rampart |
| **Resources** | LimitRange, Pod |
| **File to create** | `./exam/course/16/limit-range.yaml` |

### Task
Create a LimitRange named `rampart-limits` in the `rampart` namespace.
It should enforce the following default limits for all new Pods:
- Default Limit: `Memory 512Mi`, `CPU 500m`
- Default Request: `Memory 256Mi`, `CPU 200m`

After creating the LimitRange, create a Pod named `default-pod` using the `nginx:alpine` image with NO explicit resource requests/limits. Let it inherit the defaults.
Save the LimitRange and Pod manifests to `./exam/course/16/limit-range.yaml`.

---

### Question 17
| Field | Value |
| --- | --- |
| **Points** | 6 |
| **CNCF Domain** | Services and Networking |
| **CNCF Weight** | 20% |
| **Namespace** | vanguard |
| **Resources** | NetworkPolicy |
| **File to create** | `./exam/course/17/netpol.yaml` |

### Task
Create a NetworkPolicy named `protect-db` in the `vanguard` namespace.
It should apply to pods with the label `role=db`.
Allow INGRESS traffic on TCP port `5432` from:
1. Pods in the `vanguard` namespace with the label `role=backend`
2. ANY pod in the `bastion` namespace (assuming `bastion` namespace has a label `kubernetes.io/metadata.name=bastion`).
Deny all other ingress traffic to pods with `role=db`.
Save the manifest to `./exam/course/17/netpol.yaml`.

---

### Question 18
| Field | Value |
| --- | --- |
| **Points** | 6 |
| **CNCF Domain** | Services and Networking |
| **CNCF Weight** | 20% |
| **Namespace** | sentinel |
| **Resources** | Ingress |
| **File to create** | `./exam/course/18/ingress.yaml` |

### Task
An Ingress named `main-ingress` exists in the `sentinel` namespace, routing traffic for `sentinel.dojo.com` to `main-svc`.
Create a new Ingress named `canary-ingress` in the `sentinel` namespace.
Configure it as a canary release routing 20% of traffic to a service named `canary-svc` (which you don't need to create) on port 80.
It should trigger on the same host: `sentinel.dojo.com`.
Add the necessary NGINX ingress canary annotations.
Save the manifest to `./exam/course/18/ingress.yaml`.

---

### Question 19
| Field | Value |
| --- | --- |
| **Points** | 6 |
| **CNCF Domain** | Services and Networking |
| **CNCF Weight** | 20% |
| **Namespace** | outpost |
| **Resources** | Service, Endpoints |
| **File to create** | `./exam/course/19/manual-svc.yaml` |

### Task
Create a Service named `external-db` in the `outpost` namespace.
It should NOT use a label selector.
Configure it to expose TCP port `3306`.
Manually create an Endpoints (or EndpointSlice) object named `external-db` that maps to the IP address `10.50.50.50` on port `3306`.
Save the manifests to `./exam/course/19/manual-svc.yaml`.

---

### Question 20
| Field | Value |
| --- | --- |
| **Points** | 6 |
| **CNCF Domain** | Services and Networking |
| **CNCF Weight** | 20% |
| **Namespace** | kube-system (investigation) |
| **Resources** | ConfigMap |
| **File to create** | `./exam/course/20/coredns.yaml` |

### Task
Investigate the `coredns` ConfigMap in the `kube-system` namespace.
You need to add a custom DNS rewrite rule.
Modify the `coredns` ConfigMap so that any DNS query for `hachiman.local` is rewritten to `hachiman.garrison.svc.cluster.local`.
(Hint: use the `rewrite name exact hachiman.local hachiman.garrison.svc.cluster.local` plugin inside the Corefile block).
Save a copy of the modified ConfigMap to `./exam/course/20/coredns.yaml`.
You DO NOT need to restart the CoreDNS pods for this question.

---
