# CKAD Simulation 17 - Solutions (Dojo Hachiman ⚔️)

---

### Question 1

```bash
kubectl run entry-override -n fortress --image=nginx:alpine --dry-run=client -o yaml --command -- sleep 3600 > ./exam/course/1/pod.yaml
# Ensure command and args are separated if needed, but --command puts it into `command`.
```

Explanation:
To override the Entrypoint, we use the `command` field in Kubernetes. The arguments go into `args`. By passing `--command` to `kubectl run`, it populates the `command` field.

---

### Question 2

```bash
# Create ConfigMap
kubectl create configmap init-script-cm -n fortress --from-literal=setup.sh="#!/bin/sh
echo \"Initialization successful!\" > /work-dir/index.html"

# Create Pod template
kubectl run web-setup -n fortress --image=nginx:alpine --dry-run=client -o yaml > ./exam/course/2/init-pod.yaml

# Edit ./exam/course/2/init-pod.yaml to add volumes and initContainers
```

Explanation:
Init containers run to completion before the main containers start. Shared emptyDir volumes are the standard way to pass data from an init container to a main container.

---

### Question 3

```bash
kubectl create cronjob siege-report -n siege --image=busybox:1.36 --schedule="30 * * * *" --dry-run=client -o yaml -- /bin/sh -c "date; echo Hello from siege" > ./exam/course/3/cronjob.yaml

# Edit ./exam/course/3/cronjob.yaml and add `timeZone: "Asia/Tokyo"` to the spec
```

Explanation:
CronJobs support a `timeZone` field (since 1.27) directly under `spec`.

---

### Question 4

```bash
# Create pod template
kubectl run process-monitor -n bastion --image=nginx:alpine --dry-run=client -o yaml > ./exam/course/4/shared-pid.yaml
# Edit the file to add shareProcessNamespace: true and the second container.
```

Explanation:
Setting `shareProcessNamespace: true` at the pod `spec` level allows containers in the pod to view each other's processes, useful for sidecar monitoring.

---

### Question 5

```bash
helm upgrade battle-web ./exam/course/5/battle-chart/ -n garrison --atomic --timeout 1m --set replicaCount=3
```

Explanation:
The `--atomic` flag ensures that if the deployment does not become ready within the `--timeout` period, Helm will automatically roll back to the previous release.

---

### Question 6

```bash
kubectl create deployment citadel-guard -n citadel --image=nginx:1.24.0-alpine --dry-run=client -o yaml > ./exam/course/6/deploy.yaml
# Edit deploy.yaml and add `progressDeadlineSeconds: 15` under `spec`
kubectl apply -f ./exam/course/6/deploy.yaml
```

Explanation:
`progressDeadlineSeconds` causes the deployment to transition to a `Progressing=False` condition if it doesn't finish rolling out in the specified time.

---

### Question 7

```bash
# Create green deployment
kubectl create deployment api-server-green -n rampart --image=nginx:1.25.0-alpine --replicas=2
# Edit the service
kubectl patch svc api-svc -n rampart -p '{"spec":{"selector":{"app":"api-server-green"}}}'
```

Explanation:
Blue/Green deployments involve deploying a new version alongside the old one and simply switching the Service's selector to point to the new version's labels.

---

### Question 8

```yaml
# In ./exam/course/8/kustomization.yaml
resources:
  - deployment.yaml
images:
  - name: nginx
    newName: nginx
    newTag: 1.23.0-alpine
patches:
  - target:
      kind: Deployment
      name: vanguard-web
    patch: |-
      - op: replace
        path: /spec/replicas
        value: 5
```
```bash
kubectl kustomize ./exam/course/8/ > ./exam/course/8/kustomize-output.yaml
kubectl apply -f ./exam/course/8/kustomize-output.yaml -n vanguard
```

Explanation:
Kustomize images transformer overrides image tags easily. Inline patches or strategic merge patches can scale resources.

---

### Question 9

```bash
# Get pod details
kubectl get pod data-processor -n sentinel -o yaml > processor.yaml
# Edit memory limit to 256Mi
# Delete old pod
kubectl delete pod data-processor -n sentinel --force
# Create new pod
kubectl apply -f processor.yaml
```

Explanation:
OOMKilled means the container tried to use more memory than its limit. We fix it by increasing the limit. Pod resource limits generally require recreating the pod (unless using in-place updates, which is alpha/beta).

---

### Question 10

```bash
kubectl debug -it secure-app -n outpost --image=busybox:1.36 --target=secure-app -- custom-debugger -- sh
```

Explanation:
`kubectl debug` adds an ephemeral container to a running pod, which is especially useful for distroless images that have no shell.

---

### Question 11

```bash
# Check why pods are pending/not created
kubectl describe rs -n armory
kubectl describe quota armory-quota -n armory
# Edit deployment to set requests
kubectl edit deploy weapon-smith -n armory
# Set resources.requests.cpu="100m" and resources.requests.memory="128Mi"
kubectl scale deploy weapon-smith -n armory --replicas=3
```

Explanation:
ResourceQuotas enforce limits on aggregate resource consumption. If a namespace has a quota for compute resources, pods must specify requests/limits that comply with the quota.

---

### Question 12

```bash
# Define env vars using valueFrom: resourceFieldRef
```

Explanation:
The Downward API can expose pod and container fields (like requests/limits) to the container as environment variables.

---

### Question 13

```yaml
# Edit service account
automountServiceAccountToken: false
# In Pod, define volume:
volumes:
- name: custom-token
  projected:
    sources:
    - serviceAccountToken:
        path: custom-token
```

Explanation:
Disabling automount improves security. If a token is needed, it can be mounted manually using a projected volume.

---

### Question 14

```yaml
# Under pod spec.securityContext:
runAsUser: 1000
runAsNonRoot: true
seccompProfile:
  type: RuntimeDefault
```

Explanation:
The SecurityContext applies security settings. `RuntimeDefault` enforces the default seccomp profile of the container runtime.

---

### Question 15

```yaml
volumes:
- name: db-creds
  secret:
    secretName: db-credentials
    items:
    - key: password
      path: db-pass.txt
```

Explanation:
The `items` array in a secret volume projection allows you to selectively mount specific keys as specific files.

---

### Question 16

```bash
# Create limitrange
# Create pod
kubectl run default-pod -n rampart --image=nginx:alpine
```

Explanation:
LimitRanges automatically inject default requests and limits into pods that don't specify them.

---

### Question 17

```yaml
# podSelector: matchLabels: role: db
# ingress:
# - from:
#   - podSelector: matchLabels: role: backend
#   - namespaceSelector: matchLabels: kubernetes.io/metadata.name: bastion
#   ports:
#   - port: 5432
```

Explanation:
NetworkPolicies use selectors to allow traffic. Using `namespaceSelector` relies on the implicit labels on namespaces.

---

### Question 18

```yaml
# annotations:
#   nginx.ingress.kubernetes.io/canary: "true"
#   nginx.ingress.kubernetes.io/canary-weight: "20"
```

Explanation:
Canary Ingresses allow splitting traffic by percentages, headers, or cookies using specific annotations.

---

### Question 19

```bash
# Create service without selector
# Create Endpoints with matching name
```

Explanation:
Services without selectors don't automatically create Endpoints. You must create the Endpoints object manually to route traffic to external IPs.

---

### Question 20

```yaml
# Edit configmap coredns in kube-system
# Add `rewrite name exact hachiman.local hachiman.garrison.svc.cluster.local` before `kubernetes`
```

Explanation:
CoreDNS configuration is managed via a ConfigMap. The `rewrite` plugin can alias internal or external DNS names.
