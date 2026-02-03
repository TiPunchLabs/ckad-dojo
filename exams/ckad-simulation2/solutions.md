# CKAD Simulation 2 - Dojo Byakko 🐯 - Solutions

*「白虎は精密に打つ」 - Le tigre frappe avec précision*

This document contains the solutions for all 20 questions in CKAD Simulation 2.

---

## Question 1 | Pod with Anti-Affinity

**Solution:**

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: titan-alpha
  namespace: zeus
  labels:
    app: titan
spec:
  affinity:
    podAntiAffinity:
      preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 100
        podAffinityTerm:
          labelSelector:
            matchLabels:
              app: titan
          topologyKey: kubernetes.io/hostname
  containers:
  - name: nginx
    image: nginx:1.21
```

```bash
kubectl apply -f titan-alpha.yaml
```

---

## Question 2 | ConfigMap from Multiple Sources

**Solution:**

```bash
# Create ConfigMap with literals
kubectl create configmap app-config -n athena \
  --from-literal=LOG_LEVEL=debug \
  --from-literal=MAX_CONNECTIONS=100

# Create Pod that mounts ConfigMap
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: config-reader
  namespace: athena
spec:
  containers:
  - name: reader
    image: busybox:1.36
    command: ["sleep", "3600"]
    volumeMounts:
    - name: config-volume
      mountPath: /etc/config
  volumes:
  - name: config-volume
    configMap:
      name: app-config
EOF
```

---

## Question 3 | ExternalName Service

**Solution:**

```yaml
apiVersion: v1
kind: Service
metadata:
  name: external-api
  namespace: hermes
spec:
  type: ExternalName
  externalName: api.external-service.com
```

```bash
kubectl apply -f external-api.yaml
```

---

## Question 4 | LimitRange Configuration

**Solution:**

```yaml
# LimitRange
apiVersion: v1
kind: LimitRange
metadata:
  name: resource-limits
  namespace: apollo
spec:
  limits:
  - type: Container
    default:
      cpu: 500m
      memory: 256Mi
    defaultRequest:
      cpu: 100m
      memory: 64Mi
---
# Pod (will get defaults from LimitRange)
apiVersion: v1
kind: Pod
metadata:
  name: limited-pod
  namespace: apollo
spec:
  containers:
  - name: app
    image: nginx:1.21
```

```bash
kubectl apply -f limitrange.yaml
```

---

## Question 5 | SecurityContext - Read-Only Root Filesystem

**Solution:**

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: secure-app
  namespace: hades
spec:
  containers:
  - name: nginx
    image: nginx:1.21
    securityContext:
      readOnlyRootFilesystem: true
    volumeMounts:
    - name: tmp
      mountPath: /tmp
    - name: cache
      mountPath: /var/cache/nginx
    - name: run
      mountPath: /var/run
  volumes:
  - name: tmp
    emptyDir: {}
  - name: cache
    emptyDir: {}
  - name: run
    emptyDir: {}
```

---

## Question 6 | Pod with Multiple Init Containers

**Solution:**

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: multi-init
  namespace: poseidon
spec:
  initContainers:
  - name: init-config
    image: busybox:1.36
    command: ["sh", "-c", "echo 'initialized' > /work/config.txt"]
    volumeMounts:
    - name: workdir
      mountPath: /work
  - name: init-permissions
    image: busybox:1.36
    command: ["chmod", "644", "/work/config.txt"]
    volumeMounts:
    - name: workdir
      mountPath: /work
  containers:
  - name: app
    image: nginx:1.21
    volumeMounts:
    - name: workdir
      mountPath: /work
  volumes:
  - name: workdir
    emptyDir: {}
```

---

## Question 7 | Deployment with Pause/Resume

**Solution:**

```bash
# Update the image
kubectl set image deployment/battle-app nginx=nginx:1.21 -n ares

# Pause the rollout immediately
kubectl rollout pause deployment/battle-app -n ares

# Save rollout status
kubectl rollout status deployment/battle-app -n ares > ./exam/course/7/rollout-status.txt
```

---

## Question 8 | Ambassador Pattern - Sidecar Proxy

**Solution:**

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: ambassador-pod
  namespace: olympus
spec:
  containers:
  - name: app
    image: nginx:1.21
    ports:
    - containerPort: 80
  - name: proxy
    image: envoyproxy/envoy:v1.28-latest
    env:
    - name: ENVOY_UID
      value: "0"
```

---

## Question 9 | Job with Backoff Limit

**Solution:**

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: retry-job
  namespace: artemis
spec:
  backoffLimit: 3
  template:
    spec:
      containers:
      - name: job
        image: busybox:1.36
        command: ["sh", "-c", "exit 1"]
      restartPolicy: Never
```

---

## Question 10 | Secret Types - Docker Registry

**Solution:**

```bash
# Create docker-registry secret
kubectl create secret docker-registry registry-creds -n hera \
  --docker-server=docker.io \
  --docker-username=myuser \
  --docker-password=mypassword \
  --docker-email=user@example.com

# Create pod with imagePullSecret
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: private-app
  namespace: hera
spec:
  containers:
  - name: app
    image: nginx:1.21
  imagePullSecrets:
  - name: registry-creds
EOF
```

---

## Question 11 | Adapter Pattern - Log Transformer

**Solution:**

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: adapter-pod
  namespace: zeus
spec:
  containers:
  - name: app
    image: busybox:1.36
    command: ["sh", "-c", "while true; do echo $(date): log message >> /var/log/app.log; sleep 5; done"]
    volumeMounts:
    - name: logs
      mountPath: /var/log
  - name: log-adapter
    image: busybox:1.36
    command: ["sh", "-c", "tail -f /var/log/app.log | sed 's/^/[ADAPTED] /'"]
    volumeMounts:
    - name: logs
      mountPath: /var/log
  volumes:
  - name: logs
    emptyDir: {}
```

---

## Question 12 | Network Policy - Egress Rules

**Solution:**

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: egress-policy
  namespace: athena
spec:
  podSelector:
    matchLabels:
      app: restricted
  policyTypes:
  - Egress
  egress:
  - to:
    - podSelector:
        matchLabels:
          app: database
    ports:
    - protocol: TCP
      port: 5432
  - to:
    - ipBlock:
        cidr: 10.0.0.0/8
    ports:
    - protocol: TCP
      port: 443
```

---

## Question 13 | RBAC - Service Account Permissions

**Solution:**

```bash
# Create ServiceAccount
kubectl create serviceaccount deployment-manager -n hermes

# Create Role
cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: deploy-role
  namespace: hermes
rules:
- apiGroups: ["apps"]
  resources: ["deployments"]
  verbs: ["get", "list", "watch", "create", "update", "delete"]
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list"]
EOF

# Create RoleBinding
kubectl create rolebinding deploy-binding -n hermes \
  --role=deploy-role \
  --serviceaccount=hermes:deployment-manager
```

---

## Question 14 | Deployment Rolling Update Strategy

**Solution:**

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: rolling-app
  namespace: apollo
spec:
  replicas: 4
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 25%
      maxUnavailable: 1
  selector:
    matchLabels:
      app: rolling-app
  template:
    metadata:
      labels:
        app: rolling-app
        version: v1
    spec:
      containers:
      - name: web
        image: nginx:1.21
```

---

## Question 15 | Ingress with Path-Based Routing

**Solution:**

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: path-ingress
  namespace: poseidon
spec:
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

---

## Question 16 | Pod with Token Projection

**Solution:**

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: token-pod
  namespace: hades
spec:
  containers:
  - name: app
    image: nginx:1.21
    volumeMounts:
    - name: token-volume
      mountPath: /var/run/secrets/tokens
  volumes:
  - name: token-volume
    projected:
      sources:
      - serviceAccountToken:
          audience: api
          expirationSeconds: 3600
          path: token
```

---

## Question 17 | CronJob with Concurrency Policy

**Solution:**

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: scheduled-task
  namespace: ares
spec:
  schedule: "*/5 * * * *"
  concurrencyPolicy: Forbid
  successfulJobsHistoryLimit: 3
  failedJobsHistoryLimit: 1
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: task
            image: busybox:1.36
            command: ["sh", "-c", "echo Task executed at $(date)"]
          restartPolicy: OnFailure
```

---

## Question 18 | Pod Disruption Budget

**Solution:**

```yaml
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: app-pdb
  namespace: hera
spec:
  minAvailable: 2
  selector:
    matchLabels:
      app: critical
```

---

## Question 19 | Deployment with Annotations

**Solution:**

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: annotated-app
  namespace: olympus
  annotations:
    kubernetes.io/change-cause: "Initial deployment"
spec:
  replicas: 2
  selector:
    matchLabels:
      app: annotated-app
  template:
    metadata:
      labels:
        app: annotated-app
      annotations:
        prometheus.io/scrape: "true"
    spec:
      containers:
      - name: web
        image: nginx:1.21
```

---

## Question 20 | Multi-Container Pod with Shared Process Namespace

**Solution:**

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: shared-pid
  namespace: artemis
spec:
  shareProcessNamespace: true
  containers:
  - name: app
    image: nginx:1.21
  - name: debug
    image: busybox:1.36
    command: ["sleep", "3600"]
```

**Verification:**

```bash
kubectl exec -n artemis shared-pid -c debug -- ps aux
# Should show nginx processes from the app container
```

---
