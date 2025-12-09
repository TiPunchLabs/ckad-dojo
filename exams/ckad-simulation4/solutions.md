# CKAD Simulation 4 - Solutions

> **Total Score**: 115 points | **Passing Score**: ~66% (76 points)

---

## Question 1 | Multi-Container Pod (5 points)

### Solution

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: ravens-pod
  namespace: odin
spec:
  containers:
  - name: huginn
    image: nginx:1.21-alpine
    ports:
    - containerPort: 80
    volumeMounts:
    - name: shared-logs
      mountPath: /var/log
  - name: muninn
    image: busybox:1.35
    command: ["/bin/sh", "-c"]
    args: ["while true; do wget -qO- http://localhost:80 >> /var/log/raven.log; sleep 5; done"]
    volumeMounts:
    - name: shared-logs
      mountPath: /var/log
  volumes:
  - name: shared-logs
    emptyDir: {}
```

```bash
kubectl apply -f ./exam/course/1/ravens-pod.yaml
kubectl get pod ravens-pod -n odin
```

---

## Question 2 | Job (5 points)

### Solution

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: mjolnir-forge
  namespace: thor
spec:
  completions: 4
  parallelism: 2
  template:
    metadata:
      labels:
        dwarf: brokkr
    spec:
      containers:
      - name: forge-container
        image: busybox:1.35
        command: ["/bin/sh", "-c", "echo 'Forging Mjolnir...' && sleep 3 && echo 'Mjolnir complete!'"]
      restartPolicy: Never
```

```bash
kubectl apply -f ./exam/course/2/job.yaml
kubectl get jobs -n thor
kubectl get pods -n thor -l dwarf=brokkr
```

---

## Question 3 | Init Container (5 points)

### Solution

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: shapeshifter
  namespace: loki
spec:
  initContainers:
  - name: prepare-disguise
    image: busybox:1.35
    command: ["/bin/sh", "-c", "echo 'Preparing disguise...' && sleep 5 && echo ready > /shared/status"]
    volumeMounts:
    - name: shared-data
      mountPath: /shared
  containers:
  - name: loki-main
    image: nginx:1.21-alpine
    volumeMounts:
    - name: shared-data
      mountPath: /shared
  volumes:
  - name: shared-data
    emptyDir: {}
```

```bash
kubectl apply -f shapeshifter.yaml
kubectl get pod shapeshifter -n loki
kubectl logs shapeshifter -n loki -c prepare-disguise
```

---

## Question 4 | CronJob (5 points)

### Solution

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: blessing-ritual
  namespace: freya
spec:
  schedule: "*/15 * * * *"
  successfulJobsHistoryLimit: 3
  failedJobsHistoryLimit: 1
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: ritual-container
            image: busybox:1.35
            command: ["/bin/sh", "-c", "echo \"Freya's blessing at $(date)\""]
          restartPolicy: OnFailure
```

```bash
kubectl apply -f ./exam/course/4/cronjob.yaml
kubectl get cronjobs -n freya
```

---

## Question 5 | PersistentVolume and PVC (6 points)

### Solution

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: bifrost-storage
spec:
  capacity:
    storage: 500Mi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: /data/bifrost
  storageClassName: manual
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: bifrost-claim
  namespace: heimdall
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 200Mi
  storageClassName: manual
```

```bash
kubectl apply -f ./exam/course/5/pv-pvc.yaml
kubectl get pv bifrost-storage
kubectl get pvc bifrost-claim -n heimdall
```

---

## Question 6 | StorageClass (4 points)

### Solution

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: light-storage
provisioner: kubernetes.io/no-provisioner
volumeBindingMode: WaitForFirstConsumer
reclaimPolicy: Retain
parameters:
  type: local
```

```bash
kubectl apply -f ./exam/course/6/storageclass.yaml
kubectl get storageclass light-storage
```

---

## Question 7 | Deployment with Strategy (5 points)

### Solution

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: warrior-legion
  namespace: tyr
spec:
  replicas: 4
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 1
  selector:
    matchLabels:
      legion: einherjar
  template:
    metadata:
      labels:
        legion: einherjar
    spec:
      containers:
      - name: warrior
        image: nginx:1.21-alpine
        ports:
        - containerPort: 80
```

```bash
kubectl apply -f ./exam/course/7/deployment.yaml
kubectl get deployment warrior-legion -n tyr
kubectl get pods -n tyr -l legion=einherjar
```

---

## Question 8 | Scale Deployment (5 points)

### Solution

```bash
# Scale the deployment
kubectl scale deployment sea-fleet -n njord --replicas=5

# Save command to file
echo 'kubectl scale deployment sea-fleet -n njord --replicas=5' > ./exam/course/8/scale-command.sh

# Verify
kubectl get deployment sea-fleet -n njord
kubectl get pods -n njord -l app=sea-fleet
```

---

## Question 9 | Deployment Rollback (6 points)

### Solution

```bash
# Check rollout history
kubectl rollout history deployment voyage-app -n njord

# Rollback to previous revision
kubectl rollout undo deployment voyage-app -n njord

# Save command to file
echo 'kubectl rollout undo deployment voyage-app -n njord' > ./exam/course/9/rollback-command.sh

# Verify
kubectl get deployment voyage-app -n njord
kubectl rollout status deployment voyage-app -n njord
```

**Error explanation**: The broken image `nginx:broken-voyage` doesn't exist, causing ImagePullBackOff errors.

---

## Question 10 | Helm Management (5 points)

### Solution

```bash
# 1. Delete asgard-web-v1
helm uninstall asgard-web-v1 -n asgard

# 2. Upgrade asgard-web-v2
helm upgrade asgard-web-v2 bitnami/nginx -n asgard

# 3. Install asgard-gateway with 2 replicas
helm install asgard-gateway bitnami/apache -n asgard --set replicaCount=2

# 4. Find and delete broken release
helm list -n asgard -a  # Find pending-install release
helm uninstall broken-release -n asgard
```

---

## Question 11 | ClusterIP Service (5 points)

### Solution

```yaml
apiVersion: v1
kind: Service
metadata:
  name: thunder-svc
  namespace: thor
spec:
  type: ClusterIP
  selector:
    app: lightning
  ports:
  - port: 8080
    targetPort: 80
    protocol: TCP
```

```bash
kubectl apply -f ./exam/course/11/service.yaml
kubectl get svc thunder-svc -n thor
kubectl get endpoints thunder-svc -n thor
```

---

## Question 12 | NetworkPolicy (6 points)

### Solution

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: love-protection
  namespace: freya
spec:
  podSelector:
    matchLabels:
      role: lover
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          role: protector
    ports:
    - protocol: TCP
      port: 80
  egress:
  - to:
    - podSelector: {}
    ports:
    - protocol: UDP
      port: 53
  - to:
    - podSelector:
        matchLabels:
          role: protector
    ports:
    - protocol: TCP
      port: 443
```

```bash
kubectl apply -f ./exam/course/12/networkpolicy.yaml
kubectl get networkpolicy love-protection -n freya
```

---

## Question 13 | Ingress (5 points)

### Solution

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: light-gateway
  namespace: baldur
spec:
  ingressClassName: nginx
  rules:
  - host: baldur.asgard.local
    http:
      paths:
      - path: /shine
        pathType: Prefix
        backend:
          service:
            name: radiance-svc
            port:
              number: 80
```

```bash
kubectl apply -f ./exam/course/13/ingress.yaml
kubectl get ingress light-gateway -n baldur
```

---

## Question 14 | NodePort Service (5 points)

### Solution

```yaml
apiVersion: v1
kind: Service
metadata:
  name: realm-gateway
  namespace: asgard
spec:
  type: NodePort
  selector:
    app: bifrost
  ports:
  - port: 80
    targetPort: 80
    nodePort: 30080
```

```bash
kubectl apply -f ./exam/course/14/nodeport-service.yaml
kubectl get svc realm-gateway -n asgard
```

---

## Question 15 | RBAC Role and RoleBinding (5 points)

### Solution

```bash
# Create ServiceAccount
kubectl create serviceaccount mimir-sa -n odin

# Create Role
kubectl create role wisdom-role -n odin \
  --verb=get,list,watch --resource=pods \
  --verb=get,list --resource=secrets

# Create RoleBinding
kubectl create rolebinding wisdom-binding -n odin \
  --role=wisdom-role --serviceaccount=odin:mimir-sa
```

Or with YAML:

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: mimir-sa
  namespace: odin
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: wisdom-role
  namespace: odin
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list", "watch"]
- apiGroups: [""]
  resources: ["secrets"]
  verbs: ["get", "list"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: wisdom-binding
  namespace: odin
subjects:
- kind: ServiceAccount
  name: mimir-sa
  namespace: odin
roleRef:
  kind: Role
  name: wisdom-role
  apiGroup: rbac.authorization.k8s.io
```

---

## Question 16 | Secret (5 points)

### Solution

```bash
# Create Secret
kubectl create secret generic trick-secret -n loki \
  --from-literal=username=loki-trickster \
  --from-literal=password=shapeshift123
```

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: trickster-pod
  namespace: loki
spec:
  containers:
  - name: trickster
    image: nginx:1.21-alpine
    env:
    - name: TRICK_USER
      valueFrom:
        secretKeyRef:
          name: trick-secret
          key: username
    volumeMounts:
    - name: trick-volume
      mountPath: /etc/tricks
      readOnly: true
  volumes:
  - name: trick-volume
    secret:
      secretName: trick-secret
```

---

## Question 17 | SecurityContext (6 points)

### Solution

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: guardian-pod
  namespace: heimdall
spec:
  containers:
  - name: guardian
    image: nginx:1.21-alpine
    securityContext:
      runAsUser: 1000
      runAsGroup: 3000
      allowPrivilegeEscalation: false
      capabilities:
        add:
        - NET_BIND_SERVICE
        drop:
        - ALL
```

```bash
kubectl apply -f ./exam/course/17/secure-pod.yaml
kubectl get pod guardian-pod -n heimdall
```

---

## Question 18 | ResourceQuota (5 points)

### Solution

```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: war-limits
  namespace: tyr
spec:
  hard:
    pods: "10"
    requests.cpu: "2"
    requests.memory: 2Gi
    limits.cpu: "4"
    limits.memory: 4Gi
```

```bash
kubectl apply -f ./exam/course/18/quota.yaml
kubectl get resourcequota war-limits -n tyr
kubectl describe resourcequota war-limits -n tyr
```

---

## Question 19 | ConfigMap (5 points)

### Solution

```bash
# Create ConfigMap
kubectl create configmap navigation-config -n njord \
  --from-literal=destination=midgard \
  --from-literal=route=coastal \
  --from-literal=speed=fast
```

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: navigator-pod
  namespace: njord
spec:
  containers:
  - name: navigator
    image: busybox:1.35
    command: ["sh", "-c", "env && sleep 3600"]
    envFrom:
    - configMapRef:
        name: navigation-config
```

```bash
kubectl apply -f navigator-pod.yaml
kubectl get pod navigator-pod -n njord
kubectl exec navigator-pod -n njord -- env | grep -E 'destination|route|speed'
```

---

## Question 20 | Probes (6 points)

### Solution

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: watchman-pod
  namespace: asgard
spec:
  containers:
  - name: watchman
    image: nginx:1.21-alpine
    ports:
    - containerPort: 80
    readinessProbe:
      httpGet:
        path: /
        port: 80
      initialDelaySeconds: 5
      periodSeconds: 10
    livenessProbe:
      httpGet:
        path: /
        port: 80
      initialDelaySeconds: 15
      periodSeconds: 20
```

```bash
kubectl apply -f ./exam/course/20/probe-pod.yaml
kubectl get pod watchman-pod -n asgard
kubectl describe pod watchman-pod -n asgard | grep -A5 "Readiness\|Liveness"
```

---

## Question 21 | Debug Pod (5 points)

### Solution

```bash
# Get logs
kubectl logs broken-valkyrie -n asgard > ./exam/course/21/logs.txt

# Describe pod to identify issue
kubectl describe pod broken-valkyrie -n asgard

# Write fix explanation
echo "The pod is failing because the image 'nginx:nonexistent-tag' does not exist. The image tag should be changed to a valid tag like 'nginx:1.21-alpine'." > ./exam/course/21/fix.txt

# Fix the pod
kubectl delete pod broken-valkyrie -n asgard

# Create fixed pod
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: broken-valkyrie
  namespace: asgard
spec:
  containers:
  - name: valkyrie
    image: nginx:1.21-alpine
    ports:
    - containerPort: 80
EOF
```

---

## Question 22 | Container Image Build (6 points)

### Solution

```bash
# Navigate to image directory
cd ./exam/course/22/image

# Build the image
docker build -t localhost:5000/runescript:v1 .

# Push to local registry
docker push localhost:5000/runescript:v1

# Create the pod
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: runescript-pod
  namespace: asgard
spec:
  containers:
  - name: runescript
    image: localhost:5000/runescript:v1
EOF

# Verify
kubectl get pod runescript-pod -n asgard
kubectl logs runescript-pod -n asgard
```
