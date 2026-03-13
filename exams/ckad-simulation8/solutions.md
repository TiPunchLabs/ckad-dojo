# CKAD Simulation 8 - Solutions (Dojo Inari 🦊)

> **Total Score**: 104 points | **Passing Score**: ~66% (69 points)
>
> **Original Questions**: Adapted from [CKAD-exercises](https://github.com/dgkanatsios/CKAD-exercises) by [@dgkanatsios](https://github.com/dgkanatsios)

---

## Question 1 | Service ClusterIP and Endpoints (5 points)

### Solution

```bash
kubectl run web --image=nginx:1.25 --restart=Never --port=80 --expose -n harvest
```

Or separately:

```bash
kubectl run web --image=nginx:1.25 --restart=Never --port=80 -n harvest
kubectl expose pod web --port=80 -n harvest
```

Verify:

```bash
kubectl get svc web -n harvest
kubectl get ep web -n harvest
```

---

## Question 2 | Convert Service to NodePort (5 points)

### Solution

```bash
kubectl patch svc app-svc -n grain -p '{"spec":{"type":"NodePort"}}'
```

Or use edit:

```bash
kubectl edit svc app-svc -n grain
# Change spec.type from ClusterIP to NodePort
```

---

## Question 3 | Deployment with Service (6 points)

### Solution

```bash
# Create Deployment
kubectl create deployment backend --image=nginx:1.25 --replicas=3 --port=8080 -n rice

# Expose Deployment
kubectl expose deployment backend --port=6262 --target-port=8080 -n rice
```

---

## Question 4 | Readiness Probe HTTP (5 points)

### Solution

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: ready-pod
  namespace: field
spec:
  containers:
  - name: nginx
    image: nginx:1.25
    ports:
    - containerPort: 80
    readinessProbe:
      httpGet:
        path: /
        port: 80
```

---

## Question 5 | Liveness Probe with Delay (5 points)

### Solution

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: live-pod
  namespace: shrine
spec:
  containers:
  - name: nginx
    image: nginx:1.25
    livenessProbe:
      exec:
        command:
        - ls
      initialDelaySeconds: 5
      periodSeconds: 10
```

---

## Question 6 | LimitRange for Namespace (6 points)

### Solution

```yaml
apiVersion: v1
kind: LimitRange
metadata:
  name: pod-limits
  namespace: blessing
spec:
  limits:
  - max:
      memory: "500Mi"
    min:
      memory: "100Mi"
    type: Pod
```

---

## Question 7 | ResourceQuota with Requests and Limits (6 points)

### Solution

```bash
kubectl create quota compute-quota -n fortune \
  --hard=requests.cpu=1,requests.memory=1Gi,limits.cpu=2,limits.memory=2Gi
```

Or YAML:

```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: compute-quota
  namespace: fortune
spec:
  hard:
    requests.cpu: "1"
    requests.memory: 1Gi
    limits.cpu: "2"
    limits.memory: 2Gi
```

---

## Question 8 | Pod within ResourceQuota (5 points)

### Solution

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: quota-pod
  namespace: fortune
spec:
  containers:
  - name: nginx
    image: nginx:1.25
    resources:
      requests:
        cpu: "0.5"
        memory: "512Mi"
      limits:
        cpu: "1"
        memory: "1Gi"
```

---

## Question 9 | Security Context with Capabilities (6 points)

### Solution

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: cap-pod
  namespace: golden
spec:
  containers:
  - name: nginx
    image: nginx:1.25
    securityContext:
      capabilities:
        add:
        - NET_ADMIN
        - SYS_TIME
```

---

## Question 10 | Shared Volume Between Containers (6 points)

### Solution

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: shared-pod
  namespace: bounty
spec:
  containers:
  - name: writer
    image: busybox:1.36
    command: ["sleep", "3600"]
    volumeMounts:
    - name: shared-data
      mountPath: /data
  - name: reader
    image: busybox:1.36
    command: ["sleep", "3600"]
    volumeMounts:
    - name: shared-data
      mountPath: /data
  volumes:
  - name: shared-data
    emptyDir: {}
```

---

## Question 11 | Annotations (4 points)

### Solution

```bash
kubectl run annotated-pod --image=nginx:1.25 --restart=Never -n prosperity
kubectl annotate pod annotated-pod owner=marketing -n prosperity
```

---

## Question 12 | Labels Selection (5 points)

### Solution

```bash
# Create pods
kubectl run pod1 --image=nginx:1.25 --restart=Never -n harvest
kubectl run pod2 --image=nginx:1.25 --restart=Never -n harvest
kubectl run pod3 --image=nginx:1.25 --restart=Never -n harvest

# Label pods
kubectl label pod pod1 pod2 env=prod -n harvest
kubectl label pod pod3 env=dev -n harvest

# List and save
mkdir -p ./exam/course/12
kubectl get pods -n harvest -l env=prod > ./exam/course/12/pods.txt
```

---

## Question 13 | Helm Add Repository (4 points)

### Solution

```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
```

---

## Question 14 | Helm Show Values (5 points)

### Solution

```bash
mkdir -p ./exam/course/14
helm show values bitnami/nginx | head -50 > ./exam/course/14/values.txt
```

---

## Question 15 | Helm List Releases (4 points)

### Solution

```bash
mkdir -p ./exam/course/15
helm list -A > ./exam/course/15/releases.txt
```

---

## Question 16 | Canary Deployment Setup (6 points)

### Solution

```yaml
# app-v1 Deployment
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-v1
  namespace: grain
spec:
  replicas: 3
  selector:
    matchLabels:
      app: myapp
      version: v1
  template:
    metadata:
      labels:
        app: myapp
        version: v1
    spec:
      containers:
      - name: nginx
        image: nginx:1.18.0
        ports:
        - containerPort: 80
---
# app-v2 Deployment
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-v2
  namespace: grain
spec:
  replicas: 1
  selector:
    matchLabels:
      app: myapp
      version: v2
  template:
    metadata:
      labels:
        app: myapp
        version: v2
    spec:
      containers:
      - name: nginx
        image: nginx:1.19.0
        ports:
        - containerPort: 80
---
# Service selecting both versions
apiVersion: v1
kind: Service
metadata:
  name: app
  namespace: grain
spec:
  selector:
    app: myapp  # Only select on app label, not version
  ports:
  - port: 80
    targetPort: 80
```

---

## Question 17 | emptyDir Volume for Data Sharing (5 points)

### Solution

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: data-pod
  namespace: rice
spec:
  containers:
  - name: producer
    image: busybox:1.36
    command: ["sleep", "3600"]
    volumeMounts:
    - name: data-volume
      mountPath: /shared
  - name: consumer
    image: busybox:1.36
    command: ["sleep", "3600"]
    volumeMounts:
    - name: data-volume
      mountPath: /shared
  volumes:
  - name: data-volume
    emptyDir: {}
```

---

## Question 18 | Pod DNS Resolution (5 points)

### Solution

```bash
mkdir -p ./exam/course/18
kubectl run busybox --rm -it --restart=Never --image=busybox:1.36 -n field -- nslookup web-svc.field.svc.cluster.local | grep -A1 "Name:" | tail -1 | awk '{print $2}' > ./exam/course/18/dns.txt
```

Or:

```bash
kubectl run busybox --rm -it --restart=Never --image=busybox:1.36 -n field -- sh -c 'nslookup web-svc' > ./exam/course/18/dns.txt
```

---

## Question 19 | Network Policy Allow Specific Label (6 points)

### Solution

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: db-policy
  namespace: shrine
spec:
  podSelector:
    matchLabels:
      app: db
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          access: "true"
```

---

## Question 20 | Generate API Token for ServiceAccount (5 points)

### Solution

```bash
# Create ServiceAccount
kubectl create serviceaccount token-sa -n blessing

# Generate token and save
mkdir -p ./exam/course/20
kubectl create token token-sa -n blessing > ./exam/course/20/token.txt
```
