# CKAD Simulation 3 - Dojo Byakko 🐯 - Solutions

*「白虎は精密に狩る」 - Le tigre blanc chasse avec précision*

This document contains the solutions for all 20 questions in CKAD Simulation 3.

---

## Question 1 | kubectl explain

**Solution:**

```bash
# Navigate the API documentation
kubectl explain pod.spec.containers.resources

# Save to file
kubectl explain pod.spec.containers.resources --recursive > ./exam/course/1/pod-spec-fields.txt
```

**Explanation:** `kubectl explain` provides built-in documentation for Kubernetes API resources. Use dot notation to navigate nested fields. The `--recursive` flag shows all sub-fields.

---

## Question 2 | Pod Anti-Affinity

**Solution:**

```bash
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: spread-pods
  namespace: tiger
spec:
  replicas: 3
  selector:
    matchLabels:
      app: spread-pods
  template:
    metadata:
      labels:
        app: spread-pods
    spec:
      affinity:
        podAntiAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
          - labelSelector:
              matchExpressions:
              - key: app
                operator: In
                values:
                - spread-pods
            topologyKey: kubernetes.io/hostname
      containers:
      - name: web
        image: nginx:1.21
        ports:
        - containerPort: 80
EOF
```

**Explanation:** Pod anti-affinity with `requiredDuringSchedulingIgnoredDuringExecution` enforces hard constraints. The topology key `kubernetes.io/hostname` ensures pods are scheduled on different nodes. If there aren't enough nodes, pods will remain Pending.

---

## Question 3 | Blue-Green Deployment

**Solution:**

```bash
# Step 1: Create the green deployment
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: stable-green
  namespace: stripe
spec:
  replicas: 3
  selector:
    matchLabels:
      app: web-app
      version: green
  template:
    metadata:
      labels:
        app: web-app
        version: green
    spec:
      containers:
      - name: nginx
        image: nginx:1.22
        ports:
        - containerPort: 80
EOF

# Step 2: Wait for green pods to be ready
kubectl rollout status deployment/stable-green -n stripe

# Step 3: Switch the service to green
kubectl patch service web-service -n stripe -p '{"spec":{"selector":{"version":"green"}}}'

# Verify
kubectl get endpoints web-service -n stripe
```

**Explanation:** Blue-Green deployment maintains two identical environments. Unlike canary (gradual rollout), Blue-Green is a complete switch. The service selector change routes 100% of traffic to the new version instantly.

---

## Question 4 | CronJob Advanced

**Solution:**

```bash
# Suspend the CronJob first
kubectl patch cronjob data-sync -n prowl -p '{"spec":{"suspend":true}}'

# Add startingDeadlineSeconds and concurrencyPolicy
kubectl patch cronjob data-sync -n prowl -p '{
  "spec": {
    "startingDeadlineSeconds": 200,
    "concurrencyPolicy": "Forbid"
  }
}'

# Resume the CronJob
kubectl patch cronjob data-sync -n prowl -p '{"spec":{"suspend":false}}'

# Verify
kubectl get cronjob data-sync -n prowl -o yaml | grep -E "suspend|startingDeadline|concurrency"
```

**Explanation:**

- `suspend: true` pauses scheduling without deleting the CronJob
- `startingDeadlineSeconds` sets a deadline for starting jobs if missed
- `concurrencyPolicy: Forbid` prevents concurrent job executions

---

## Question 5 | Immutable ConfigMap

**Solution:**

```bash
kubectl apply -f - <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: locked-config
  namespace: hunt
data:
  DB_HOST: postgres.hunt.svc
  DB_PORT: "5432"
  LOG_LEVEL: info
immutable: true
EOF

# Try to modify (should fail)
# kubectl patch configmap locked-config -n hunt -p '{"data":{"LOG_LEVEL":"debug"}}'
# Error: ConfigMap is immutable
```

**Explanation:** Immutable ConfigMaps cannot be modified after creation. This improves cluster performance (no watches needed) and prevents accidental changes. To update, delete and recreate.

---

## Question 6 | Projected Volume

**Solution:**

```bash
kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: config-aggregator
  namespace: hunt
spec:
  serviceAccountName: hunt-sa
  containers:
  - name: aggregator
    image: busybox:1.36
    command: ["sleep", "3600"]
    volumeMounts:
    - name: combined-config
      mountPath: /etc/config
  volumes:
  - name: combined-config
    projected:
      sources:
      - serviceAccountToken:
          path: token
          expirationSeconds: 3600
      - configMap:
          name: app-config
EOF
```

**Explanation:** Projected volumes combine multiple sources into a single volume mount. This allows mounting a ServiceAccount token with custom expiration alongside a ConfigMap in the same directory.

---

## Question 7 | PodDisruptionBudget

**Solution:**

```bash
kubectl apply -f - <<EOF
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: critical-pdb
  namespace: jungle
spec:
  minAvailable: 3
  selector:
    matchLabels:
      app: critical-app
EOF

# Verify
kubectl get pdb critical-pdb -n jungle
```

**Explanation:** PodDisruptionBudgets protect applications during voluntary disruptions (node drains, cluster upgrades). With `minAvailable: 3` on a 5-replica deployment, only 2 pods can be evicted at a time.

---

## Question 8 | Service ExternalName

**Solution:**

```bash
kubectl apply -f - <<EOF
apiVersion: v1
kind: Service
metadata:
  name: external-api
  namespace: fang
spec:
  type: ExternalName
  externalName: api.external-service.com
EOF

# Test DNS resolution from a pod
# nslookup external-api.fang.svc.cluster.local
```

**Explanation:** ExternalName services create CNAME DNS records pointing to external hostnames. No proxying occurs - it's purely DNS aliasing. Useful for referencing external services with internal names.

---

## Question 9 | LimitRange

**Solution:**

```bash
kubectl apply -f - <<EOF
apiVersion: v1
kind: LimitRange
metadata:
  name: container-limits
  namespace: pounce
spec:
  limits:
  - type: Container
    default:
      cpu: "500m"
      memory: "256Mi"
    defaultRequest:
      cpu: "100m"
      memory: "64Mi"
    min:
      cpu: "50m"
      memory: "32Mi"
    max:
      cpu: "1"
      memory: "512Mi"
EOF

# Verify
kubectl describe limitrange container-limits -n pounce
```

**Explanation:** LimitRanges enforce resource constraints at namespace level. Containers without explicit resources get defaults. Min/max prevent over or under-provisioning.

---

## Question 10 | Pod Security Context

**Solution:**

```bash
kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: secure-pod
  namespace: stalker
spec:
  securityContext:
    runAsUser: 1000
    runAsGroup: 3000
    fsGroup: 2000
  containers:
  - name: secure-nginx
    image: nginx:1.21
    securityContext:
      readOnlyRootFilesystem: true
      allowPrivilegeEscalation: false
    volumeMounts:
    - name: tmp-volume
      mountPath: /tmp
    - name: cache-volume
      mountPath: /var/cache/nginx
    - name: run-volume
      mountPath: /var/run
  volumes:
  - name: tmp-volume
    emptyDir: {}
  - name: cache-volume
    emptyDir: {}
  - name: run-volume
    emptyDir: {}
EOF
```

**Explanation:** Security contexts control pod/container privileges. `runAsUser/Group` sets the user identity. `fsGroup` sets group ownership for volumes. `readOnlyRootFilesystem` prevents writes to the container filesystem (requires writable volumes for temp files).

---

## Question 11 | Deployment Rollout Control

**Solution:**

```bash
# Step 1: Pause the rollout
kubectl rollout pause deployment/rolling-app -n pounce

# Step 2: Update the image
kubectl set image deployment/rolling-app app=nginx:1.22 -n pounce

# Step 3: Set revisionHistoryLimit
kubectl patch deployment rolling-app -n pounce -p '{"spec":{"revisionHistoryLimit":5}}'

# Step 4: Resume the rollout
kubectl rollout resume deployment/rolling-app -n pounce

# Verify
kubectl rollout status deployment/rolling-app -n pounce
```

**Explanation:** Pausing a rollout allows batching multiple changes before triggering an update. `revisionHistoryLimit` controls how many ReplicaSets are kept for rollback.

---

## Question 12 | kubectl exec Troubleshooting

**Solution:**

```bash
# Read the nginx config
kubectl exec config-pod -n stalker -- cat /etc/nginx/conf.d/custom.conf > ./exam/course/12/nginx-config.txt

# Test the config works on port 8080
kubectl exec config-pod -n stalker -- curl -s localhost:8080
```

**Explanation:** `kubectl exec` runs commands inside containers for debugging. Use `--` to separate kubectl arguments from the command to run.

---

## Question 13 | Resource Metrics

**Solution:**

```bash
# Get pod metrics (requires metrics-server)
kubectl top pods -n jungle > ./exam/course/13/pod-resources.txt 2>&1

# Find top CPU consumer
kubectl top pods -n jungle --sort-by=cpu 2>/dev/null | head -2 | tail -1 | awk '{print $1}' > ./exam/course/13/top-cpu-pod.txt

# If metrics-server not available, document it
if ! kubectl top pods -n jungle 2>/dev/null; then
  echo "Metrics server not available" > ./exam/course/13/pod-resources.txt
  echo "unknown" > ./exam/course/13/top-cpu-pod.txt
fi
```

**Explanation:** `kubectl top` requires metrics-server to be installed. It shows real-time CPU and memory usage. The `--sort-by` flag orders results.

---

## Question 14 | Downward API

**Solution:**

```bash
kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: metadata-pod
  namespace: claw
spec:
  containers:
  - name: info
    image: busybox:1.36
    command: ["sh", "-c", "env | grep POD && env | grep NODE && sleep 3600"]
    env:
    - name: POD_NAME
      valueFrom:
        fieldRef:
          fieldPath: metadata.name
    - name: POD_NAMESPACE
      valueFrom:
        fieldRef:
          fieldPath: metadata.namespace
    - name: POD_IP
      valueFrom:
        fieldRef:
          fieldPath: status.podIP
    - name: NODE_NAME
      valueFrom:
        fieldRef:
          fieldPath: spec.nodeName
EOF
```

**Explanation:** The Downward API exposes pod and container metadata to running containers. Use `fieldRef` for pod fields and `resourceFieldRef` for resource fields.

---

## Question 15 | Job TTL

**Solution:**

```bash
kubectl apply -f - <<EOF
apiVersion: batch/v1
kind: Job
metadata:
  name: cleanup-job
  namespace: stripe
spec:
  ttlSecondsAfterFinished: 60
  backoffLimit: 2
  template:
    spec:
      containers:
      - name: cleanup
        image: busybox:1.36
        command: ["sh", "-c", "echo 'Cleanup complete' && sleep 5"]
      restartPolicy: Never
EOF

# Watch the job (it will be deleted 60 seconds after completion)
kubectl get jobs -n stripe -w
```

**Explanation:** `ttlSecondsAfterFinished` automatically cleans up completed Jobs. This prevents resource accumulation from many short-lived jobs. The job and its pods are deleted after the TTL expires.

---

## Question 16 | Container Capabilities

**Solution:**

```bash
kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: hardened-pod
  namespace: predator
spec:
  containers:
  - name: secure-app
    image: nginx:1.21
    securityContext:
      runAsNonRoot: true
      runAsUser: 101
      capabilities:
        drop:
        - ALL
        add:
        - NET_BIND_SERVICE
EOF
```

**Explanation:** Linux capabilities provide fine-grained privilege control. Dropping ALL capabilities and adding only what's needed follows the principle of least privilege. `NET_BIND_SERVICE` allows binding to privileged ports (<1024) without full root.

---

## Question 17 | Service Session Affinity

**Solution:**

```bash
# Patch the existing service
kubectl patch service backend-svc -n claw -p '{
  "spec": {
    "sessionAffinity": "ClientIP",
    "sessionAffinityConfig": {
      "clientIP": {
        "timeoutSeconds": 3600
      }
    }
  }
}'

# Verify
kubectl get service backend-svc -n claw -o yaml | grep -A5 sessionAffinity
```

**Explanation:** Session affinity (sticky sessions) routes requests from the same client IP to the same pod. The timeout (1 hour) defines how long the affinity persists. Useful for stateful applications.

---

## Question 18 | Deployment Safe Rollout

**Solution:**

```bash
# Configure safe rollout settings
kubectl patch deployment safe-deploy -n fang -p '{
  "spec": {
    "minReadySeconds": 30,
    "progressDeadlineSeconds": 120
  }
}'

# Update the image
kubectl set image deployment/safe-deploy app=nginx:1.22 -n fang

# Watch the rollout (should take at least 30 seconds per pod)
kubectl rollout status deployment/safe-deploy -n fang
```

**Explanation:**

- `minReadySeconds`: New pods must be ready for this duration before being considered available
- `progressDeadlineSeconds`: Maximum time for a rollout to progress before it's considered failed

These settings slow down rollouts to catch issues early.

---

## Question 19 | Container Lifecycle Hook

**Solution:**

```bash
kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: graceful-pod
  namespace: tiger
spec:
  terminationGracePeriodSeconds: 30
  containers:
  - name: main
    image: nginx:1.21
    ports:
    - containerPort: 80
    lifecycle:
      preStop:
        exec:
          command: ["/bin/sh", "-c", "nginx -s quit && sleep 5"]
EOF
```

**Explanation:** preStop hooks run before container termination. `nginx -s quit` gracefully shuts down nginx, allowing in-flight requests to complete. The sleep ensures the hook completes before SIGKILL.

---

## Question 20 | NetworkPolicy Default Deny

**Solution:**

```bash
# Step 1: Create default deny-all policy
kubectl apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-all
  namespace: predator
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
EOF

# Step 2: Create allow policy for frontend to backend
kubectl apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-frontend-to-api
  namespace: predator
spec:
  podSelector:
    matchLabels:
      tier: backend
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          tier: frontend
    ports:
    - protocol: TCP
      port: 80
  egress:
  - to: []
    ports:
    - protocol: UDP
      port: 53
    - protocol: TCP
      port: 53
EOF

# Test connectivity
# kubectl exec -n predator <frontend-pod> -- curl api-svc:80
```

**Explanation:** The "default deny" pattern first blocks all traffic, then explicitly allows only necessary connections. Empty `podSelector: {}` matches all pods. DNS egress (port 53) is essential for service discovery.

---
