# CKAD Simulation 2 - Dojo Suzaku 🔥 - Solutions

*「朱雀は灰から蘇る」 - Le phénix renaît de ses cendres*

This document contains the solutions for all 21 questions in CKAD Simulation 2.

---

## Question 1 | API Resources

**Solution:**

```bash
# List all API resources and save to file
kubectl api-resources > ./exam/course/1/api-resources
```

**Explanation:** The `kubectl api-resources` command lists all available API resources in the cluster, including their shortnames, API group, and whether they are namespaced. This is useful for discovering what resources are available.

---

## Question 2 | Deployment Recreate Strategy

**Solution:**

```bash
# Create the deployment with Recreate strategy
cat <<EOF > ./exam/course/2/fire-app.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: fire-app
  namespace: blaze
spec:
  replicas: 3
  strategy:
    type: Recreate
  selector:
    matchLabels:
      app: fire-app
  template:
    metadata:
      labels:
        app: fire-app
    spec:
      containers:
      - name: fire-container
        image: nginx:1.21
        ports:
        - containerPort: 80
EOF

kubectl apply -f ./exam/course/2/fire-app.yaml
```

**Explanation:** The Recreate strategy terminates all existing pods before creating new ones. This is useful when you can't have multiple versions running simultaneously (unlike RollingUpdate which maintains availability during updates).

---

## Question 3 | Job with Timeout

**Solution:**

```bash
# Copy template and modify
cp ./exam/course/3/job.yaml ./exam/course/3/job.yaml.bak

# Edit the job to add activeDeadlineSeconds
cat <<EOF > ./exam/course/3/job.yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: data-processor
  namespace: spark
spec:
  activeDeadlineSeconds: 60
  backoffLimit: 2
  template:
    spec:
      containers:
      - name: processor
        image: busybox:1.36
        command: ["sh", "-c", "echo 'Processing data...' && sleep 30 && echo 'Done'"]
      restartPolicy: Never
EOF

kubectl apply -f ./exam/course/3/job.yaml
```

**Explanation:** `activeDeadlineSeconds` sets the maximum duration for a Job. If the Job runs longer than this, it will be terminated. This prevents runaway jobs from consuming resources indefinitely.

---

## Question 4 | Helm Template Debug

**Solution:**

```bash
# Get the values from the installed release and render templates
helm get values phoenix-web -n flare -o yaml > /tmp/phoenix-values.yaml
helm template phoenix-web bitnami/nginx -n flare -f /tmp/phoenix-values.yaml > ./exam/course/4/rendered.yaml

# Alternative: use helm get manifest for already installed release
helm get manifest phoenix-web -n flare > ./exam/course/4/rendered.yaml
```

**Explanation:** `helm template` renders chart templates locally without installing. `helm get manifest` retrieves the rendered manifests from an installed release. Both are useful for debugging Helm deployments.

---

## Question 5 | Fix CrashLoopBackOff

**Solution:**

```bash
# Check the pod status and logs
kubectl describe pod crash-app -n ember
kubectl logs crash-app -n ember

# The issue is the command "sleepx" which doesn't exist - should be "sleep"
# Delete and recreate with correct command
kubectl delete pod crash-app -n ember

kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: crash-app
  namespace: ember
  labels:
    app: crash-app
spec:
  containers:
  - name: app
    image: busybox:1.36
    command: ["sleep", "3600"]
    resources:
      requests:
        memory: "32Mi"
        cpu: "50m"
      limits:
        memory: "64Mi"
        cpu: "100m"
EOF

# Verify
kubectl get pod crash-app -n ember
```

**Explanation:** CrashLoopBackOff indicates the container is crashing repeatedly. In this case, the command `sleepx` doesn't exist. The fix is to use the correct command `sleep`.

---

## Question 6 | ConfigMap Items Mount

**Solution:**

```bash
# Create pod with selective ConfigMap mount
kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: config-reader
  namespace: flame
spec:
  containers:
  - name: reader
    image: busybox:1.36
    command: ["sleep", "3600"]
    volumeMounts:
    - name: config-volume
      mountPath: /config
  volumes:
  - name: config-volume
    configMap:
      name: app-settings
      items:
      - key: database.host
        path: database.host
      - key: database.port
        path: database.port
EOF
```

**Explanation:** Using `items` in a ConfigMap volume mount allows you to selectively mount specific keys rather than all keys. Each item maps a key to a file path within the mount directory.

---

## Question 7 | Secret from File

**Solution:**

```bash
# Create the password file (without trailing newline)
mkdir -p ./exam/course/7
echo -n 'FirePhoenix2024!' > ./exam/course/7/password.txt

# Create secret from file
kubectl create secret generic db-credentials \
  --from-file=password.txt=./exam/course/7/password.txt \
  -n magma
```

**Explanation:** `kubectl create secret generic --from-file` creates a secret from a file. The key in the secret will be the filename (or the specified key name). Using `echo -n` avoids adding a trailing newline.

---

## Question 8 | Headless Service

**Solution:**

```bash
kubectl apply -f - <<EOF
apiVersion: v1
kind: Service
metadata:
  name: backend-headless
  namespace: corona
spec:
  clusterIP: None
  selector:
    app: backend
  ports:
  - port: 80
    protocol: TCP
    targetPort: 80
EOF
```

**Explanation:** A headless service (clusterIP: None) doesn't allocate a cluster IP. Instead, DNS returns the IP addresses of all pods matching the selector. This is commonly used with StatefulSets for direct pod addressing.

---

## Question 9 | Canary Deployment

**Solution:**

```bash
# Create canary deployment
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: canary-v2
  namespace: blaze
spec:
  replicas: 1
  selector:
    matchLabels:
      app: web-frontend
      version: v2
  template:
    metadata:
      labels:
        app: web-frontend
        version: v2
    spec:
      containers:
      - name: nginx
        image: nginx:1.22
        ports:
        - containerPort: 80
EOF

# Create service that routes to both stable and canary
kubectl apply -f - <<EOF
apiVersion: v1
kind: Service
metadata:
  name: frontend-svc
  namespace: blaze
spec:
  type: ClusterIP
  selector:
    app: web-frontend
  ports:
  - port: 80
    targetPort: 80
EOF
```

**Explanation:** Canary deployment introduces a new version alongside the stable version. The service selector (app: web-frontend) matches both deployments. With 3 stable replicas and 1 canary replica, traffic is split approximately 75%/25%.

---

## Question 10 | Sidecar Data Processing

**Solution:**

```bash
kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: data-transform
  namespace: phoenix
spec:
  containers:
  - name: producer
    image: busybox:1.36
    command: ["sh", "-c", "while true; do echo \$(date) >> /data/input.log; sleep 5; done"]
    volumeMounts:
    - name: shared-data
      mountPath: /data
  - name: transformer
    image: busybox:1.36
    command: ["sh", "-c", "tail -f /data/input.log | while read line; do echo \"PROCESSED: \$line\" >> /data/output.log; done"]
    volumeMounts:
    - name: shared-data
      mountPath: /data
  volumes:
  - name: shared-data
    emptyDir: {}
EOF
```

**Explanation:** The sidecar pattern uses multiple containers in a pod sharing a volume. The producer writes data, and the transformer processes it. emptyDir provides ephemeral storage that exists for the pod's lifetime.

---

## Question 11 | Cross-Namespace NetworkPolicy

**Solution:**

```bash
# First, label the flame namespace
kubectl label namespace flame name=flame --overwrite

# Create the NetworkPolicy
kubectl apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-from-flame
  namespace: corona
spec:
  podSelector:
    matchLabels:
      app: backend
  policyTypes:
  - Ingress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: flame
    ports:
    - protocol: TCP
      port: 80
EOF
```

**Explanation:** To allow traffic from a specific namespace, use `namespaceSelector`. The namespace must have a label that the selector can match. This policy allows ingress only from pods in the flame namespace on port 80.

---

## Question 12 | Docker Build with ARG

**Solution:**

```bash
# Copy template
mkdir -p ./exam/course/12
cp ./templates/q12-image/* ./exam/course/12/

# Modify Dockerfile
cat <<EOF > ./exam/course/12/Dockerfile
FROM nginx:1.21

ARG APP_VERSION=1.0.0
LABEL version=\${APP_VERSION}

COPY index.html /usr/share/nginx/html/index.html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
EOF

# Build with custom ARG value
cd ./exam/course/12
sudo docker build --build-arg APP_VERSION=2.0.0 -t localhost:5000/phoenix-app:2.0.0 .

# Push to registry
sudo docker push localhost:5000/phoenix-app:2.0.0
```

**Explanation:** ARG defines build-time variables. They can have default values and be overridden with `--build-arg`. LABEL adds metadata to the image. Using `${ARG_NAME}` in LABEL allows dynamic labeling during build.

---

## Question 13 | Helm Values File

**Solution:**

```bash
# Copy values template
mkdir -p ./exam/course/13
cp ./templates/q13-values.yaml ./exam/course/13/values.yaml

# Install with values file
helm install phoenix-api bitnami/nginx \
  -n flare \
  -f ./exam/course/13/values.yaml
```

**Explanation:** Helm values files override default chart values. Using `-f` applies values from a file, which is more maintainable than multiple `--set` flags and allows version control of configuration.

---

## Question 14 | PostStart Lifecycle Hook

**Solution:**

```bash
kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: lifecycle-pod
  namespace: phoenix
spec:
  containers:
  - name: main
    image: nginx:1.21
    ports:
    - containerPort: 80
    lifecycle:
      postStart:
        exec:
          command: ["/bin/sh", "-c", "echo 'Started at \$(date)' > /usr/share/nginx/html/started.txt"]
EOF
```

**Explanation:** postStart hooks execute immediately after a container is created (but not necessarily before the container's entrypoint). They're useful for initialization tasks. The hook runs in parallel with the container's main process.

---

## Question 15 | Guaranteed QoS Class

**Solution:**

```bash
kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: qos-guaranteed
  namespace: spark
spec:
  containers:
  - name: web
    image: nginx:1.21
    resources:
      requests:
        memory: "128Mi"
        cpu: "100m"
      limits:
        memory: "128Mi"
        cpu: "100m"
EOF
```

**Explanation:** Guaranteed QoS requires that every container has both memory and CPU requests AND limits set, and requests must equal limits. This ensures the pod gets exactly the resources it requests, making it less likely to be evicted.

---

## Question 16 | ServiceAccount Projected Token

**Solution:**

```bash
kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: token-pod
  namespace: magma
spec:
  serviceAccountName: fire-sa
  containers:
  - name: app
    image: busybox:1.36
    command: ["sleep", "3600"]
    volumeMounts:
    - name: fire-token
      mountPath: /var/run/secrets/fire-token
      readOnly: true
  volumes:
  - name: fire-token
    projected:
      sources:
      - serviceAccountToken:
          path: token
          expirationSeconds: 3600
          audience: api
EOF
```

**Explanation:** Projected volumes allow mounting ServiceAccount tokens with configurable expiration and audience. This is more secure than the default token mounting as tokens expire and can be scoped to specific audiences.

---

## Question 17 | TCP Liveness Probe

**Solution:**

```bash
kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: tcp-health
  namespace: ember
spec:
  containers:
  - name: web
    image: nginx:1.21
    ports:
    - containerPort: 80
    livenessProbe:
      tcpSocket:
        port: 80
      initialDelaySeconds: 10
      periodSeconds: 5
EOF
```

**Explanation:** TCP socket probes check if a port is open and accepting connections. They're useful when HTTP probes aren't appropriate (e.g., non-HTTP services). The probe succeeds if the TCP connection is established.

---

## Question 18 | Service with Named Ports

**Solution:**

```bash
kubectl apply -f - <<EOF
apiVersion: v1
kind: Service
metadata:
  name: web-svc
  namespace: flame
spec:
  type: ClusterIP
  selector:
    app: web-app
  ports:
  - name: http
    port: 80
    targetPort: http-web
    protocol: TCP
  - name: https
    port: 443
    targetPort: https-web
    protocol: TCP
EOF
```

**Explanation:** Named ports allow services to reference ports by name rather than number. This makes configuration more readable and allows pods to change their port numbers without updating service definitions.

---

## Question 19 | Topology Spread Constraints

**Solution:**

```bash
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: spread-deploy
  namespace: blaze
spec:
  replicas: 4
  selector:
    matchLabels:
      app: spread-app
  template:
    metadata:
      labels:
        app: spread-app
    spec:
      topologySpreadConstraints:
      - maxSkew: 1
        topologyKey: kubernetes.io/hostname
        whenUnsatisfiable: ScheduleAnyway
        labelSelector:
          matchLabels:
            app: spread-app
      containers:
      - name: web
        image: nginx:1.21
        ports:
        - containerPort: 80
EOF
```

**Explanation:** Topology spread constraints control how pods are distributed across topology domains (nodes, zones). `maxSkew: 1` means the difference in pod count between nodes should be at most 1. `ScheduleAnyway` allows scheduling even if constraints can't be fully satisfied.

---

## Question 20 | Field Selectors

**Solution:**

```bash
# Use field selector to find running pods
kubectl get pods --all-namespaces --field-selector=status.phase=Running \
  -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}' > ./exam/course/20/running-pods.txt
```

**Explanation:** Field selectors filter resources based on resource fields (like status, metadata) rather than labels. `--field-selector=status.phase=Running` finds all pods in Running phase across all namespaces.

---

## Question 21 | Node Drain

**Solution:**

```bash
# Write the drain command to file (do not execute)
mkdir -p ./exam/course/21
cat <<'EOF' > ./exam/course/21/drain-command.sh
kubectl drain worker-node-1 \
  --ignore-daemonsets \
  --delete-emptydir-data \
  --force \
  --timeout=60s
EOF
```

**Explanation:** `kubectl drain` safely evicts pods from a node for maintenance. Key flags:
- `--ignore-daemonsets`: Don't fail if DaemonSet pods exist
- `--delete-emptydir-data`: Delete pods with emptyDir volumes
- `--force`: Force deletion of pods not managed by controllers
- `--timeout`: Maximum time to wait for eviction

---
