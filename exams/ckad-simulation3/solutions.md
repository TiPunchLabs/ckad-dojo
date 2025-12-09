# CKAD Exam Simulator - Solutions

## Question 1 | Namespaces

**Solution:**

```bash
kubectl get ns | grep a > ./exam/course/1/namespaces
```

**Explanation:** Use `grep` to filter namespaces containing the letter "a".

---

## Question 2 | Multi-container Pod

**Solution:**

```bash
kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: wisdom-pod
  namespace: athena
spec:
  containers:
  - name: main
    image: nginx:1.21-alpine
    ports:
    - containerPort: 80
    volumeMounts:
    - name: shared-logs
      mountPath: /usr/share/nginx/html
  - name: sidecar
    image: busybox:1.35
    command: ["/bin/sh", "-c"]
    args: ["while true; do echo \"$(date) - Wisdom shared\" >> /var/log/wisdom.log; sleep 5; done"]
    volumeMounts:
    - name: shared-logs
      mountPath: /var/log
  volumes:
  - name: shared-logs
    emptyDir: {}
EOF
```

**Explanation:** Multi-container pods share volumes using emptyDir. Both containers mount the same volume at different paths.

---

## Question 3 | CronJob

**Solution:**

```bash
kubectl apply -f - <<EOF
apiVersion: batch/v1
kind: CronJob
metadata:
  name: sun-check
  namespace: apollo
spec:
  schedule: "*/15 * * * *"
  successfulJobsHistoryLimit: 3
  failedJobsHistoryLimit: 1
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: sun-check
            image: busybox:1.35
            command: ["/bin/sh", "-c", "echo \"Apollo sun check: $(date)\""]
          restartPolicy: OnFailure
EOF
```

**Explanation:** CronJobs schedule periodic tasks. The schedule "*/15 * * * *" runs every 15 minutes.

---

## Question 4 | Helm Management

**Solution:**

```bash
# Step 1: Delete release olympus-web-v1
helm uninstall olympus-web-v1 -n olympus

# Step 2: Upgrade olympus-web-v2
helm repo update
helm upgrade olympus-web-v2 bitnami/nginx -n olympus

# Step 3: Install olympus-apache with 3 replicas
helm install olympus-apache bitnami/apache -n olympus --set replicaCount=3

# Step 4: Find and delete broken release
helm list -n olympus -a  # Find pending-install releases
helm uninstall broken-release -n olympus
```

**Explanation:** Helm manages Kubernetes applications. Use `-a` flag to see all releases including failed ones.

---

## Question 5 | ConfigMap and Environment Variables

**Solution:**

```bash
# Create ConfigMap
kubectl create configmap messenger-config -n hermes \
  --from-literal=SPEED=fast \
  --from-literal=DESTINATION=olympus \
  --from-literal=MESSAGE_COUNT=100

# Create Pod with all ConfigMap keys as env vars
kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: messenger-pod
  namespace: hermes
spec:
  containers:
  - name: messenger
    image: nginx:1.21-alpine
    envFrom:
    - configMapRef:
        name: messenger-config
EOF
```

**Explanation:** Using `envFrom` with `configMapRef` imports all keys from the ConfigMap as environment variables.

---

## Question 6 | Secret Volume Mount

**Solution:**

```bash
# Create Secret
kubectl create secret generic underworld-creds -n hades \
  --from-literal=username=hades \
  --from-literal=password=3headed-dog

# Create Pod with secret volume
kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: cerberus-pod
  namespace: hades
spec:
  containers:
  - name: cerberus
    image: nginx:1.21-alpine
    volumeMounts:
    - name: secret-volume
      mountPath: /etc/secrets
      readOnly: true
  volumes:
  - name: secret-volume
    secret:
      secretName: underworld-creds
EOF
```

**Explanation:** Secrets can be mounted as volumes. The `readOnly: true` ensures the secret files cannot be modified.

---

## Question 7 | Pod with Resource Limits

**Solution:**

```bash
kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: thunder-pod
  namespace: zeus
spec:
  containers:
  - name: thunder
    image: nginx:1.21-alpine
    resources:
      requests:
        cpu: "100m"
        memory: "64Mi"
      limits:
        cpu: "200m"
        memory: "128Mi"
EOF
```

**Explanation:** Resource requests guarantee minimum resources, while limits cap maximum usage.

---

## Question 8 | Deployment Rollback

**Solution:**

```bash
# Check rollout history
kubectl rollout history deployment battle-app -n ares

# Rollback to previous revision
kubectl rollout undo deployment battle-app -n ares

# Get the current revision number
kubectl rollout history deployment battle-app -n ares | grep -v REVISION | tail -1 | awk '{print $1}' > ./exam/course/8/rollback-info.txt

# Verify deployment is running
kubectl rollout status deployment battle-app -n ares
```

**Explanation:** `kubectl rollout undo` reverts to the previous revision. Use `rollout history` to see available revisions.

---

## Question 9 | Service ClusterIP

**Solution:**

```bash
# Create Pod
kubectl run hunter-api -n artemis --image=nginx:1.21-alpine --labels=app=hunter

# Create Service
kubectl expose pod hunter-api -n artemis --name=hunter-svc --port=8080 --target-port=80

# Test service and save output
kubectl run test-curl --rm -i --restart=Never -n artemis --image=nginx:alpine -- curl -s hunter-svc:8080 > ./exam/course/9/service-test.txt
```

**Explanation:** ClusterIP services provide internal cluster connectivity. The service redirects port 8080 to container port 80.

---

## Question 10 | NetworkPolicy

**Solution:**

```bash
kubectl apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: sea-wall
  namespace: poseidon
spec:
  podSelector:
    matchLabels:
      zone: deep-sea
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          trusted: "true"
  egress:
  - to:
    - podSelector:
        matchLabels:
          zone: surface
    ports:
    - protocol: TCP
      port: 80
EOF
```

**Explanation:** NetworkPolicies control traffic flow. This policy restricts both ingress and egress based on pod labels.

---

## Question 11 | PersistentVolume and PVC

**Solution:**

```bash
# Create PV
kubectl apply -f - <<EOF
apiVersion: v1
kind: PersistentVolume
metadata:
  name: hera-pv
spec:
  capacity:
    storage: 1Gi
  accessModes:
  - ReadWriteOnce
  hostPath:
    path: /data/hera
  storageClassName: ""
EOF

# Create PVC
kubectl apply -f - <<EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: hera-pvc
  namespace: hera
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 500Mi
  storageClassName: ""
EOF

# Create Pod with PVC
kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: hera-storage-pod
  namespace: hera
spec:
  containers:
  - name: storage-container
    image: nginx:1.21-alpine
    volumeMounts:
    - name: data-volume
      mountPath: /data
  volumes:
  - name: data-volume
    persistentVolumeClaim:
      claimName: hera-pvc
EOF
```

**Explanation:** PVs provide cluster storage, PVCs request storage from PVs. Empty storageClassName binds without dynamic provisioning.

---

## Question 12 | Init Container

**Solution:**

```bash
kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: titan-init-pod
  namespace: titan
spec:
  initContainers:
  - name: init-setup
    image: busybox:1.35
    command: ["/bin/sh", "-c", "echo 'Titan awakening...' && sleep 5"]
  containers:
  - name: titan-main
    image: nginx:1.21-alpine
EOF
```

**Explanation:** Init containers run before main containers and must complete successfully. Useful for setup tasks.

---

## Question 13 | Probes (Liveness and Readiness)

**Solution:**

```bash
kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: oracle-pod
  namespace: apollo
spec:
  containers:
  - name: oracle
    image: nginx:1.21-alpine
    ports:
    - containerPort: 80
    livenessProbe:
      httpGet:
        path: /healthz
        port: 80
      initialDelaySeconds: 10
      periodSeconds: 5
    readinessProbe:
      httpGet:
        path: /ready
        port: 80
      initialDelaySeconds: 5
      periodSeconds: 3
EOF
```

**Explanation:** Liveness probes restart unhealthy containers. Readiness probes control service traffic routing.

---

## Question 14 | ServiceAccount

**Solution:**

```bash
# Create ServiceAccount
kubectl create serviceaccount messenger-sa -n hermes

# Create Pod with ServiceAccount
kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: messenger-runner
  namespace: hermes
spec:
  serviceAccountName: messenger-sa
  automountServiceAccountToken: false
  containers:
  - name: runner
    image: nginx:1.21-alpine
EOF
```

**Explanation:** ServiceAccounts provide pod identity. Setting `automountServiceAccountToken: false` prevents automatic token mounting for security.

---

## Question 15 | Labels and Selectors

**Solution:**

```bash
# Find pods with label role=god and save names
kubectl get pods -n olympus -l role=god -o jsonpath='{.items[*].metadata.name}' | tr ' ' '\n' > ./exam/course/15/gods-pods.txt

# Add label to all matching pods
kubectl label pods -n olympus -l role=god power=divine
```

**Explanation:** Labels organize resources. Use `-l` selector to filter and `kubectl label` to add labels to multiple resources.

---

## Question 16 | Deployment Scaling

**Solution:**

```bash
# Scale deployment
kubectl scale deployment warrior-squad -n ares --replicas=5

# Patch update strategy
kubectl patch deployment warrior-squad -n ares -p '{"spec":{"strategy":{"type":"RollingUpdate","rollingUpdate":{"maxSurge":2,"maxUnavailable":1}}}}'
```

**Explanation:** Scaling adjusts replica count. RollingUpdate strategy controls how updates are rolled out.

---

## Question 17 | Job with Completions

**Solution:**

```bash
kubectl apply -f - <<EOF
apiVersion: batch/v1
kind: Job
metadata:
  name: wisdom-task
  namespace: athena
spec:
  completions: 4
  parallelism: 2
  backoffLimit: 3
  template:
    metadata:
      labels:
        task: wisdom
    spec:
      containers:
      - name: wisdom-container
        image: busybox:1.35
        command: ["/bin/sh", "-c", "echo 'Task completed by Athena' && sleep 2"]
      restartPolicy: Never
EOF
```

**Explanation:** Jobs with completions run multiple times. Parallelism controls concurrent executions. BackoffLimit sets retry attempts.

---

## Question 18 | Pod Logs and Debugging

**Solution:**

```bash
# Get last 50 lines of logs
kubectl logs shadow-app -n hades --tail=50 > ./exam/course/18/shadow-logs.txt

# Count ERROR messages
kubectl logs shadow-app -n hades | grep -c "ERROR" > ./exam/course/18/error-count.txt
```

**Explanation:** Use `--tail` to limit log lines. Combine with `grep -c` to count pattern occurrences.

---

## Question 19 | Annotations

**Solution:**

```bash
kubectl annotate pod lightning-pod -n zeus \
  description="Primary lightning generator" \
  maintainer="zeus-team@olympus.io" \
  version="2.0"
```

**Explanation:** Annotations store non-identifying metadata. Unlike labels, they're not used for selection.

---

## Question 20 | Container Image Build

**Solution:**

```bash
# Step 1: Modify Dockerfile
echo 'ENV APP_VERSION=3.0.0' >> ./exam/course/20/image/Dockerfile

# Step 2: Build and push with Docker
cd ./exam/course/20/image
sudo docker build -t localhost:5000/olympus-app:v1-docker .
sudo docker push localhost:5000/olympus-app:v1-docker

# Step 3: Build and push with Podman
sudo podman build -t localhost:5000/olympus-app:v1-podman .
sudo podman push localhost:5000/olympus-app:v1-podman

# Step 4: Run container
sudo podman run -d --name olympus-runner localhost:5000/olympus-app:v1-podman

# Step 5: Get logs
sudo podman logs olympus-runner > ./exam/course/20/container-logs.txt
```

**Explanation:** Both Docker and Podman can build OCI-compliant images. The local registry at localhost:5000 stores the images.

---
