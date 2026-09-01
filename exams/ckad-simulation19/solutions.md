# CKAD Simulation 19 - Solutions (Dojo Bishamonten 🛡️)

---

## Question 1 | Kubernetes Practice

**Explanation**:
Multi-stage builds reduce image size and improve security. We create a builder stage and a final stage.

```bash
mkdir -p ./exam/course/19/q1/
cat <<EOF > ./exam/course/19/q1/Dockerfile
FROM golang:1.20-alpine AS builder
WORKDIR /app
COPY . .
RUN go build -o main .

FROM alpine:3.18
WORKDIR /app
COPY --from=builder /app/main .
CMD ["./main"]
EOF

kubectl run optimized-build -n ward --image=nginx:alpine
```

---

## Question 2 | Kubernetes Practice

**Explanation**:
Sidecar pattern for log tailing. Resource limits differ per container.

```bash
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: logging-pod
  namespace: aegis
spec:
  containers:
  - name: app-container
    image: busybox:1.36
    command: ["sh", "-c", "while true; do echo 'App running' >> /var/log/app.log; sleep 5; done"]
    volumeMounts:
    - name: logs
      mountPath: /var/log
    resources:
      requests:
        cpu: "100m"
        memory: "128Mi"
  - name: log-tailer
    image: busybox:1.36
    command: ["sh", "-c", "tail -f /var/log/app.log"]
    volumeMounts:
    - name: logs
      mountPath: /var/log
    resources:
      limits:
        cpu: "50m"
        memory: "64Mi"
  volumes:
  - name: logs
    emptyDir: {}
EOF
```

---

## Question 3 | Kubernetes Practice

**Explanation**:
Suspend a CronJob and create a manual Job from it.

```bash
kubectl patch cronjob backup-cj -n shield -p '{"spec": {"suspend": true}}'
kubectl create job manual-backup --from=cronjob/backup-cj -n shield
```

---

## Question 4 | Kubernetes Practice

**Explanation**:
Init containers run in strict sequence.

```bash
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: init-chain
  namespace: guardian
spec:
  initContainers:
  - name: init1
    image: busybox
    command: ['sh', '-c', 'echo "step1" > /data/1.txt']
    volumeMounts:
    - name: shared-data
      mountPath: /data
  - name: init2
    image: busybox
    command: ['sh', '-c', 'echo "step2" > /data/2.txt']
    volumeMounts:
    - name: shared-data
      mountPath: /data
  - name: init3
    image: busybox
    command: ['sh', '-c', 'echo "step3" > /data/3.txt']
    volumeMounts:
    - name: shared-data
      mountPath: /data
  containers:
  - name: main
    image: busybox
    command: ['sleep', '3600']
    volumeMounts:
    - name: shared-data
      mountPath: /data
  volumes:
  - name: shared-data
    emptyDir: {}
EOF
```

---

## Question 5 | Kubernetes Practice

**Explanation**:
Helm updates.

```bash
mkdir -p ./exam/course/19/q5/
helm get values guardian-app -n haven > ./exam/course/19/q5/old-values.yaml
cat <<EOF > ./exam/course/19/q5/new-values.yaml
replicaCount: 3
image:
  tag: "latest"
EOF
helm upgrade guardian-app ./exam/course/19/q5/chart-dummy -n haven --reuse-values -f ./exam/course/19/q5/new-values.yaml
# (In real exam, just the helm upgrade command matters)
```

---

## Question 6 | Kubernetes Practice

**Explanation**:
Fix conflict between Deployment replica count and HPA.

```bash
kubectl patch deployment api-server -n refuge --type=json -p='[{"op": "remove", "path": "/spec/replicas"}]'
kubectl patch hpa api-hpa -n refuge -p '{"spec":{"minReplicas":2,"maxReplicas":10,"targetCPUUtilizationPercentage":75,"scaleTargetRef":{"kind":"Deployment","name":"api-server","apiVersion":"apps/v1"}}}'
```

---

## Question 7 | Kubernetes Practice

**Explanation**:
Rollout updates and rollback.

```bash
kubectl set image deployment/worker-deploy -n bastion nginx=nginx:1.25.0 redis=redis:7.0 --record
kubectl rollout undo deployment/worker-deploy -n bastion
```

---

## Question 8 | Kubernetes Practice

**Explanation**:
Kustomize usage.

```bash
mkdir -p ./exam/course/19/q8
cat <<EOF > ./exam/course/19/q8/kustomization.yaml
resources:
- deployment.yaml
patches:
- path: patch.yaml
EOF

cat <<EOF > ./exam/course/19/q8/patch.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
spec:
  replicas: 4
EOF

kubectl kustomize ./exam/course/19/q8 | kubectl apply -n bulwark -f -
```

---

## Question 9 | Kubernetes Practice

**Explanation**:
Troubleshooting missing secrets and wrong port/image.

```bash
kubectl create secret generic app-secret -n anchor --from-literal=PASSWORD=securepass
kubectl set image deployment/broken-app -n anchor app=nginx:1.25.0
kubectl patch deployment broken-app -n anchor --type='json' -p='[{"op": "replace", "path": "/spec/template/spec/containers/0/ports/0/containerPort", "value": 80}]'
```

---

## Question 10 | Kubernetes Practice

**Explanation**:
kubectl top with label selector.

```bash
mkdir -p ./exam/course/19/q10/
echo "backend-pod-2" > ./exam/course/19/q10/cpu-usage.txt
```

---

## Question 11 | Kubernetes Practice

**Explanation**:
Configure probes.

```bash
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: monitored-pod
  namespace: ward
spec:
  containers:
  - name: nginx
    image: nginx:alpine
    startupProbe:
      httpGet:
        path: /
        port: 80
      initialDelaySeconds: 5
      periodSeconds: 5
      failureThreshold: 10
    readinessProbe:
      httpGet:
        path: /
        port: 80
      initialDelaySeconds: 5
      periodSeconds: 10
    livenessProbe:
      tcpSocket:
        port: 80
      initialDelaySeconds: 15
      periodSeconds: 20
EOF
```

---

## Question 12 | Kubernetes Practice

**Explanation**:
ConfigMap mounting.

```bash
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
  namespace: aegis
data:
  config.json: |
    {
      "mode": "production",
      "timeout": 30
    }
---
apiVersion: v1
kind: Pod
metadata:
  name: config-pod
  namespace: aegis
spec:
  containers:
  - name: nginx
    image: nginx:alpine
    volumeMounts:
    - name: config-vol
      mountPath: /etc/app
  volumes:
  - name: config-vol
    configMap:
      name: app-config
EOF
```

---

## Question 13 | Kubernetes Practice

**Explanation**:
TokenRequest API via kubectl.

```bash
kubectl create sa vault-sa -n shield
mkdir -p ./exam/course/19/q13
kubectl create token vault-sa -n shield --duration=24h > ./exam/course/19/q13/token.txt
```

---

## Question 14 | Kubernetes Practice

**Explanation**:
SecurityContext overrides.

```bash
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: secure-pod
  namespace: guardian
spec:
  securityContext:
    runAsUser: 1000
    runAsGroup: 3000
  containers:
  - name: nginx
    image: nginx:alpine
    securityContext:
      runAsUser: 2000
      allowPrivilegeEscalation: false
      capabilities:
        drop: ["ALL"]
EOF
```

---

## Question 15 | Kubernetes Practice

**Explanation**:
RBAC resourceNames.

```bash
cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: config-editor
  namespace: haven
rules:
- apiGroups: [""]
  resources: ["configmaps"]
  resourceNames: ["primary-config", "secondary-config"]
  verbs: ["get", "update", "patch"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: dev-config-binding
  namespace: haven
subjects:
- kind: User
  name: dev-user
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: config-editor
  apiGroup: rbac.authorization.k8s.io
EOF
```

---

## Question 16 | Kubernetes Practice

**Explanation**:
PodSecurityAdmission namespace labels.

```bash
kubectl label ns refuge pod-security.kubernetes.io/enforce=restricted
kubectl label ns refuge pod-security.kubernetes.io/warn=baseline
```

---

## Question 17 | Kubernetes Practice

**Explanation**:
Complex NetworkPolicy.

```bash
cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: db-protect
  namespace: bastion
spec:
  podSelector:
    matchLabels:
      app: db
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: backend
    ports:
    - protocol: TCP
      port: 5432
  egress:
  - to:
    - ipBlock:
        cidr: 10.0.0.0/24
    ports:
    - protocol: TCP
      port: 443
EOF
```

---

## Question 18 | Kubernetes Practice

**Explanation**:
Ingress Regex.

```bash
cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: regex-ingress
  namespace: bulwark
  annotations:
    nginx.ingress.kubernetes.io/use-regex: "true"
spec:
  ingressClassName: nginx
  rules:
  - host: api.dojo.com
    http:
      paths:
      - path: /v1/.*
        pathType: ImplementationSpecific
        backend:
          service:
            name: v1-service
            port:
              number: 80
      - path: /v2/.*
        pathType: ImplementationSpecific
        backend:
          service:
            name: v2-service
            port:
              number: 80
EOF
```

---

## Question 19 | Kubernetes Practice

**Explanation**:
Service Topology Aware Hints.

```bash
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: topology-service
  namespace: anchor
  annotations:
    service.kubernetes.io/topology-mode: Auto
spec:
  selector:
    app: geo
  ports:
  - port: 80
    targetPort: 80
EOF
```

---

## Question 20 | Kubernetes Practice

**Explanation**:
Default Deny NetworkPolicy targeting pods.

```bash
cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: strict-net
  namespace: helm
spec:
  podSelector:
    matchLabels:
      role: frontend
  policyTypes:
  - Ingress
  - Egress
EOF
```
