# CKAD Simulation 11 - Solutions (Dojo Amaterasu ☀️)

> **Total Score**: 102 points | **Passing Score**: ~66% (67 points)

---

## Question 1 | Multi-stage Dockerfile Build (6 points)

### Solution

Edit `./exam/course/1/image/Dockerfile` to use multi-stage:

```dockerfile
# Stage 1: Build
FROM golang:1.21-alpine AS builder
WORKDIR /app
COPY main.go .
RUN go build -o server main.go

# Stage 2: Runtime
FROM alpine:3.19
COPY --from=builder /app/server /server
EXPOSE 8080
CMD ["/server"]
```

```bash
# Build the image
cd ./exam/course/1/image
docker build -t multi-app:1.0 .

# Save as tarball
docker save -o ../multi-app.tar multi-app:1.0

# Verify
docker images multi-app:1.0
ls -lh ../multi-app.tar
```

---

## Question 2 | Create ReplicaSet (4 points)

### Solution

```bash
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: web-rs
  namespace: solar
spec:
  replicas: 3
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
        - name: web
          image: nginx:1.25
          ports:
            - containerPort: 80
EOF

# Verify
kubectl get rs web-rs -n solar
kubectl get pods -n solar -l app=web
```

---

## Question 3 | Adapter Pattern Multi-container Pod (6 points)

### Solution

```bash
kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: log-adapter
  namespace: corona
spec:
  volumes:
    - name: log-volume
      emptyDir: {}
  containers:
    - name: app
      image: busybox:1.36
      command: ["/bin/sh", "-c"]
      args: ["while true; do echo \"\$(date +%s) INFO request processed\" >> /var/log/app/raw.log; sleep 5; done"]
      volumeMounts:
        - name: log-volume
          mountPath: /var/log/app
    - name: adapter
      image: busybox:1.36
      command: ["/bin/sh", "-c"]
      args: ["tail -f /var/log/app/raw.log | sed 's/^/[FORMATTED] /'"]
      volumeMounts:
        - name: log-volume
          mountPath: /var/log/app
EOF

# Verify
kubectl get pod log-adapter -n corona
kubectl logs log-adapter -n corona -c adapter
```

---

## Question 4 | Pod with hostPath Volume (4 points)

### Solution

```bash
kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: cache-pod
  namespace: aurora
spec:
  containers:
    - name: web
      image: nginx:1.25
      volumeMounts:
        - name: cache-vol
          mountPath: /cache
  volumes:
    - name: cache-vol
      hostPath:
        path: /data/cache
        type: DirectoryOrCreate
EOF

# Verify
kubectl get pod cache-pod -n aurora
kubectl describe pod cache-pod -n aurora | grep -A5 Volumes
```

---

## Question 5 | Blue/Green Deployment (8 points)

### Solution

```bash
# Step 1: Create green deployment
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-green
  namespace: flare
spec:
  replicas: 3
  selector:
    matchLabels:
      app: webapp
      version: green
  template:
    metadata:
      labels:
        app: webapp
        version: green
    spec:
      containers:
        - name: web
          image: nginx:1.26
          ports:
            - containerPort: 80
EOF

# Step 2: Wait for green to be ready
kubectl rollout status deploy app-green -n flare

# Step 3: Switch service to green
kubectl patch svc webapp-svc -n flare -p '{"spec":{"selector":{"app":"webapp","version":"green"}}}'

# Step 4: Scale down blue
kubectl scale deploy app-blue -n flare --replicas=0

# Verify
kubectl get endpoints webapp-svc -n flare
kubectl get deploy -n flare
```

---

## Question 6 | Configure Rolling Update Strategy (6 points)

### Solution

```bash
kubectl edit deploy api-app -n dawn
```

Add/modify the strategy section:

```yaml
spec:
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
```

Then update the image:

```bash
kubectl set image deploy/api-app api=nginx:1.26 -n dawn

# Verify
kubectl rollout status deploy api-app -n dawn
kubectl get deploy api-app -n dawn -o jsonpath='{.spec.strategy}'
```

---

## Question 7 | Deploy with Kustomize (6 points)

### Solution

Create `./exam/course/7/kustomization.yaml`:

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - deployment.yaml
  - service.yaml

namePrefix: prod-

patches:
  - target:
      kind: Deployment
      name: web-app
    patch: |-
      - op: replace
        path: /spec/replicas
        value: 3
```

```bash
# Preview
kubectl kustomize ./exam/course/7/

# Apply
kubectl apply -k ./exam/course/7/

# Verify
kubectl get deploy prod-web-app -n zenith
kubectl get svc prod-web-svc -n zenith
```

---

## Question 8 | Helm Upgrade with Custom Values (4 points)

### Solution

```bash
# Inspect current values
helm get values web-release -n radiance

# Upgrade with new replica count
helm upgrade web-release bitnami/nginx -n radiance --set replicaCount=3 --reuse-values

# Verify
helm list -n radiance -f web-release
helm history web-release -n radiance
```

---

## Question 9 | Add Startup Probe (4 points)

### Solution

```bash
kubectl edit deploy slow-app -n eclipse
```

Add startup probe to the container:

```yaml
spec:
  template:
    spec:
      containers:
        - name: app
          startupProbe:
            httpGet:
              path: /healthz
              port: 8080
            failureThreshold: 30
            periodSeconds: 10
```

```bash
# Verify
kubectl rollout status deploy slow-app -n eclipse
kubectl describe deploy slow-app -n eclipse | grep -A5 Startup
```

---

## Question 10 | Troubleshoot Pending Pod (6 points)

### Solution

```bash
# Step 1: Identify the issue
kubectl describe pod stuck-pod -n solar
# Events show: "didn't match Pod's node affinity/selector"

# Step 2: Save the reason
echo "disktype" > ./exam/course/10/pending-reason.txt

# Step 3: Fix - Option A: Label a node
kubectl get nodes --show-labels
kubectl label node <node-name> disktype=ssd

# Step 3: Fix - Option B: Remove nodeSelector (delete and recreate)
kubectl get pod stuck-pod -n solar -o yaml > /tmp/stuck-pod.yaml
# Remove the nodeSelector section
kubectl delete pod stuck-pod -n solar
kubectl apply -f /tmp/stuck-pod.yaml

# Verify
kubectl get pod stuck-pod -n solar
```

---

## Question 11 | Extract Logs from Multi-container Pod (4 points)

### Solution

```bash
# Extract sidecar logs
kubectl logs multi-logger -n corona -c sidecar --tail=20 > ./exam/course/11/sidecar-logs.txt

# Verify
cat ./exam/course/11/sidecar-logs.txt
```

---

## Question 12 | Discover and Use Custom Resource Definition (6 points)

### Solution

```bash
# Step 1: Discover the CRD
kubectl get crd | grep backup
# Output: backups.ckad.example.com

# Step 2: Save the group
echo "ckad.example.com" > ./exam/course/12/crd-group.txt

# Step 3: Create a Backup custom resource
kubectl apply -f - <<EOF
apiVersion: ckad.example.com/v1
kind: Backup
metadata:
  name: daily-backup
  namespace: aurora
spec:
  schedule: "0 2 * * *"
  retentionDays: 30
  storageLocation: "s3://backups/daily"
EOF

# Verify
kubectl get backup daily-backup -n aurora
kubectl describe backup daily-backup -n aurora
```

---

## Question 13 | Create TLS Secret (4 points)

### Solution

```bash
kubectl create secret tls web-tls \
  --cert=./exam/course/13/tls.crt \
  --key=./exam/course/13/tls.key \
  -n flare

# Verify
kubectl get secret web-tls -n flare
kubectl describe secret web-tls -n flare
```

---

## Question 14 | SecurityContext with seccompProfile (4 points)

### Solution

```bash
kubectl edit deploy hardened-app -n dawn
```

Add seccompProfile under pod-level security context:

```yaml
spec:
  template:
    spec:
      securityContext:
        seccompProfile:
          type: RuntimeDefault
```

```bash
# Verify
kubectl rollout status deploy hardened-app -n dawn
kubectl get deploy hardened-app -n dawn -o jsonpath='{.spec.template.spec.securityContext.seccompProfile.type}'
```

---

## Question 15 | ServiceAccount with Token Projection (6 points)

### Solution

```bash
# Step 1: Create ServiceAccount
kubectl create sa app-sa -n zenith

# Step 2: Create Pod with projected token
kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: token-pod
  namespace: zenith
spec:
  serviceAccountName: app-sa
  containers:
    - name: web
      image: nginx:1.25
      volumeMounts:
        - name: token-vol
          mountPath: /var/run/secrets/tokens
  volumes:
    - name: token-vol
      projected:
        sources:
          - serviceAccountToken:
              path: app-token
              expirationSeconds: 3600
EOF

# Verify
kubectl get pod token-pod -n zenith
kubectl exec token-pod -n zenith -- ls /var/run/secrets/tokens/
```

---

## Question 16 | ConfigMap from env-file (4 points)

### Solution

```bash
# Step 1: Create ConfigMap from env file
kubectl create configmap app-config --from-env-file=./exam/course/16/app.env -n eclipse

# Step 2: Create Pod with envFrom
kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: config-pod
  namespace: eclipse
spec:
  containers:
    - name: web
      image: nginx:1.25
      envFrom:
        - configMapRef:
            name: app-config
EOF

# Verify
kubectl get configmap app-config -n eclipse -o yaml
kubectl exec config-pod -n eclipse -- env | grep APP_
```

---

## Question 17 | Create docker-registry Secret (4 points)

### Solution

```bash
kubectl create secret docker-registry registry-creds \
  --docker-server=registry.example.com \
  --docker-username=admin \
  --docker-password=s3cur3P@ss \
  -n radiance

# Verify
kubectl get secret registry-creds -n radiance
kubectl get secret registry-creds -n radiance -o jsonpath='{.type}'
```

---

## Question 18 | NetworkPolicy with ipBlock (6 points)

### Solution

```bash
kubectl apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: api-allow
  namespace: sunbeam
spec:
  podSelector:
    matchLabels:
      app: api
  policyTypes:
    - Ingress
  ingress:
    - from:
        - podSelector:
            matchLabels:
              role: frontend
        - ipBlock:
            cidr: 10.0.0.0/24
      ports:
        - protocol: TCP
          port: 80
EOF

# Verify
kubectl get networkpolicy api-allow -n sunbeam
kubectl describe networkpolicy api-allow -n sunbeam
```

---

## Question 19 | Ingress with TLS Termination (6 points)

### Solution

```bash
kubectl apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: secure-ingress
  namespace: solstice
spec:
  tls:
    - hosts:
        - secure.example.com
      secretName: secure-tls
  rules:
    - host: secure.example.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: secure-svc
                port:
                  number: 443
EOF

# Verify
kubectl get ingress secure-ingress -n solstice
kubectl describe ingress secure-ingress -n solstice
```

---

## Question 20 | Fix Service and Verify DNS Resolution (4 points)

### Solution

```bash
# Step 1: Check current state
kubectl get endpoints dns-svc -n sunbeam
# No endpoints — selector is wrong

# Step 2: Fix selector
kubectl patch svc dns-svc -n sunbeam -p '{"spec":{"selector":{"app":"dns-app"}}}'

# Step 3: Verify endpoints
kubectl get endpoints dns-svc -n sunbeam

# Step 4: Test DNS and save output
kubectl run tmp-dns --rm -i --restart=Never --image=busybox:1.36 -n sunbeam \
  -- nslookup dns-svc.sunbeam.svc.cluster.local > ./exam/course/20/dns-output.txt

# Verify
cat ./exam/course/20/dns-output.txt
```
