# CKAD Simulation 12 - Solutions (Dojo Tsukuyomi 🌙)

## Question 1 | Multi-stage Dockerfile

```dockerfile
# /opt/course/12/q1/Dockerfile
FROM golang:1.20-alpine AS builder
COPY main.go /app/
RUN go build -o /app/server /app/main.go

FROM alpine:3.18
COPY --from=builder /app/server /opt/server
ENTRYPOINT ["/opt/server"]
```

Explanation: Multi-stage builds are a key Docker concept. We use `AS builder` to name the first stage, compile the binary, and then `COPY --from=builder` in the second minimal alpine stage.

---

## Question 2 | Init containers with dependencies

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: data-processor
  namespace: crescent
spec:
  initContainers:
  - name: wait-for-service
    image: busybox:1.36
    command: ['sh', '-c', 'sleep 5 && echo "Dependencies ready"']
  containers:
  - name: main-app
    image: nginx:alpine
```

Explanation: Init containers run to completion before the main app containers start. They are useful for delaying startup until dependencies are ready.

---

## Question 3 | CronJob with concurrencyPolicy

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: nightly-backup
  namespace: twilight
spec:
  schedule: "*/10 * * * *"
  concurrencyPolicy: Forbid
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: backup
            image: busybox:1.36
            command: ["sh", "-c", "sleep 30"]
          restartPolicy: OnFailure
```

Explanation: We set `concurrencyPolicy: Forbid` so that if the previous job hasn't finished, the next one is skipped.

---

## Question 4 | Multi-container ambassador pattern

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: legacy-app
  namespace: eclipse
spec:
  containers:
  - name: backend
    image: nginx:1.25
    ports:
    - containerPort: 80
  - name: proxy
    image: haproxy:2.8-alpine
```

Explanation: The Ambassador pattern involves a sidecar container proxying connections to/from the main container over localhost.

---

## Question 5 | Helm rollback

```bash
helm rollback api-release 1 -n nebula
```

Explanation: The `helm rollback` command takes the release name and the target revision.

---

## Question 6 | Deployment with minReadySeconds

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: slow-start-app
  namespace: shadow
spec:
  replicas: 3
  selector:
    matchLabels:
      app: slow-start-app
  minReadySeconds: 20
  template:
    metadata:
      labels:
        app: slow-start-app
    spec:
      containers:
      - name: nginx
        image: nginx:1.24
```

Explanation: `minReadySeconds: 20` specifies the minimum number of seconds for which a newly created pod should be ready without any of its container crashing, for it to be considered available.

---

## Question 7 | Rollout pause/resume

```bash
kubectl rollout pause deployment critical-processor -n nightfall
```

Explanation: Pausing a deployment rollout halts the update process, giving you time to investigate potential issues without rolling out further broken pods.

---

## Question 8 | Kustomize with JSON patch

```json
# /opt/course/12/q8/patch.json
[
  {
    "op": "add",
    "path": "/spec/template/spec/containers/0/env",
    "value": [
      {
        "name": "MODE",
        "value": "production"
      }
    ]
  }
]
```

```yaml
# /opt/course/12/q8/kustomization.yaml
resources:
  - deployment.yaml

patches:
  - target:
      kind: Deployment
      name: frontend
    path: patch.json
```

Explanation: JSON patching in Kustomize allows fine-grained manipulation of manifests without inline editing.

---

## Question 9 | Debug ImagePullBackOff

```bash
# Find the pod
kubectl get pods -n starlight
# Edit the pod (or rather, the deployment/pod manifest) to fix the image name
kubectl edit pod metrics-gatherer -n starlight
# Change the image to a valid one, e.g., nginx:alpine
```

Explanation: A misspelled image name triggers ImagePullBackOff because the node cannot pull the non-existent image from the registry.

---

## Question 10 | Container resource metrics

```bash
kubectl top pods -n kube-system --sort-by=cpu
# Assuming 'kube-apiserver-...' is the highest
echo "kube-apiserver-minikube" > /opt/course/12/q10/cpu-usage.txt
```

Explanation: `kubectl top pods` retrieves current metrics from the Metrics Server.

---

## Question 11 | Define custom log aggregation

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: logger
  namespace: lunar
spec:
  volumes:
  - name: log-volume
    emptyDir: {}
  containers:
  - name: app
    image: busybox:1.36
    command: ['sh', '-c', 'while true; do echo "App is running" >> /var/log/app.log; sleep 5; done']
    volumeMounts:
    - name: log-volume
      mountPath: /var/log
  - name: log-tailer
    image: busybox:1.36
    command: ['sh', '-c', 'tail -f /var/log/app.log']
    volumeMounts:
    - name: log-volume
      mountPath: /var/log
```

Explanation: Using an `emptyDir` volume to share a filesystem between the main app and a logging sidecar container.

---

## Question 12 | Projected volumes combining secrets+configmap

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: combined-app
  namespace: crescent
spec:
  containers:
  - name: app
    image: nginx:alpine
    volumeMounts:
    - name: all-in-one
      mountPath: /opt/config
  volumes:
  - name: all-in-one
    projected:
      sources:
      - secret:
          name: db-creds
      - configMap:
          name: app-config
```

Explanation: Projected volumes allow multiple volume sources to be combined into a single directory.

---

## Question 13 | Immutable ConfigMap

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: static-config
  namespace: twilight
data:
  version: v2.1.0
immutable: true
```

Explanation: Setting `immutable: true` prevents accidental updates to ConfigMaps (and Secrets) which can provide safety and slight performance improvements.

---

## Question 14 | Pod with multiple security constraints

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: secure-pod
  namespace: eclipse
spec:
  securityContext:
    runAsUser: 1000
  containers:
  - name: nginx
    image: nginx:alpine
    securityContext:
      allowPrivilegeEscalation: false
      readOnlyRootFilesystem: true
    volumeMounts:
    - name: nginx-cache
      mountPath: /var/cache/nginx
    - name: nginx-run
      mountPath: /var/run
  volumes:
  - name: nginx-cache
    emptyDir: {}
  - name: nginx-run
    emptyDir: {}
```

Explanation: When `readOnlyRootFilesystem` is `true`, standard nginx images crash because they try to write to `/var/cache/nginx` and `/var/run`. Providing temporary `emptyDir` mounts resolves this.

---

## Question 15 | Secret rotation scenario

```bash
kubectl create secret generic legacy-token -n shadow --from-literal=token=super-secret-v2 --dry-run=client -o yaml | kubectl apply -f -
```

Explanation: We can update the secret using `kubectl apply` or `kubectl edit`. Because it is mounted as a volume in the pod, kubelet will eventually update the file in the pod.

---

## Question 16 | ResourceQuota enforcement

```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: compute-quota
  namespace: nightfall
spec:
  hard:
    pods: "4"
    requests.cpu: "2"
    limits.memory: "4Gi"
```

Explanation: ResourceQuota objects enforce hard limits per namespace on the amount of resources that can be requested or defined.

---

## Question 17 | NetworkPolicy egress rules

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-external
  namespace: dusk
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - {} # allow all ingress
  egress:
  - ports:
    - protocol: UDP
      port: 53
```

Explanation: Egress rules can be restricted while keeping internal DNS (UDP 53) open so pods can still resolve service names.

---

## Question 18 | Multi-path Ingress

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: star-ingress
  namespace: starlight
spec:
  ingressClassName: nginx
  rules:
  - http:
      paths:
      - path: /api
        pathType: Prefix
        backend:
          service:
            name: api-svc
            port:
              number: 8080
      - path: /web
        pathType: Prefix
        backend:
          service:
            name: web-svc
            port:
              number: 80
```

Explanation: Using multiple paths in a single Ingress rule routes different URI prefixes to different backend services.

---

## Question 19 | ExternalName service

```yaml
apiVersion: v1
kind: Service
metadata:
  name: db-ext-svc
  namespace: nebula
spec:
  type: ExternalName
  externalName: database.external.example.com
```

Explanation: ExternalName services return a CNAME record so that pods can use internal K8s DNS to resolve to an external endpoint without needing IP addresses.

---

## Question 20 | DNS debugging

```bash
kubectl exec -it dns-tester -n void -- nslookup kubernetes.default.svc.cluster.local > /opt/course/12/q20/nslookup.txt
```

Explanation: `nslookup` provides verification that CoreDNS is functioning properly within the cluster.
