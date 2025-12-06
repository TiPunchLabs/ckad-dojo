# CKAD Simulation 2 - Solutions

This document contains the solutions for all questions in CKAD Simulation 2.

---

## Question 1 | Namespaces

**Solution:**

```bash
# List all namespaces and save to file
kubectl get namespaces > ./exam/course/1/namespaces
```

**Explanation:** The `kubectl get namespaces` command lists all namespaces in the cluster. The output includes the NAME, STATUS, and AGE columns by default.

---

## Question 2 | Multi-container Pod

**Solution:**

```bash
# Create the multi-container pod
kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: multi-container-pod
  namespace: andromeda
spec:
  containers:
  - name: nginx
    image: nginx:1.21-alpine
    ports:
    - containerPort: 80
  - name: busybox
    image: busybox:1.35
    command: ["sleep", "3600"]
EOF
```

**Explanation:** Multi-container pods share the same network namespace, so containers can communicate via localhost. The nginx container serves web content while the busybox container runs as a sidecar.

---

## Question 3 | CronJob

**Solution:**

```bash
# Create the CronJob
kubectl apply -f - <<EOF
apiVersion: batch/v1
kind: CronJob
metadata:
  name: galaxy-backup
  namespace: orion
spec:
  schedule: "*/5 * * * *"
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: backup
            image: busybox:1.35
            command: ["/bin/sh", "-c", "echo Backup check completed at \$(date)"]
          restartPolicy: OnFailure
EOF

# Save to file
kubectl get cronjob galaxy-backup -n orion -o yaml > ./exam/course/3/cronjob.yaml
```

**Explanation:** CronJobs run on a schedule using cron syntax. `*/5 * * * *` means every 5 minutes. The job creates pods that execute the backup check command.

---

## Question 4 | Deployment Scaling

**Solution:**

```bash
# Scale the deployment to 5 replicas
kubectl scale deployment star-app -n pegasus --replicas=5

# Save the command to file
echo 'kubectl scale deployment star-app -n pegasus --replicas=5' > ./exam/course/4/scale-command.sh

# Verify
kubectl get deployment star-app -n pegasus
```

**Explanation:** The `kubectl scale` command adjusts the replica count of a deployment. The deployment controller automatically creates or removes pods to match the desired replica count.

---

## Question 5 | Deployment Troubleshooting

**Solution:**

```bash
# Investigate the issue
kubectl describe deployment broken-app -n cygnus
kubectl get pods -n cygnus

# The issue is a typo in the image name: "ngnix" instead of "nginx"
# Fix by editing the deployment
kubectl set image deployment/broken-app web=nginx:1.21-alpine -n cygnus

# Or edit directly
kubectl edit deployment broken-app -n cygnus
# Change image from "ngnix:1.21-alpine" to "nginx:1.21-alpine"

# Document the fix
echo "The image name had a typo: 'ngnix' instead of 'nginx'. Fixed by correcting the image name to nginx:1.21-alpine" > ./exam/course/5/fix-reason.txt

# Verify rollout
kubectl rollout status deployment/broken-app -n cygnus
```

**Explanation:** Common deployment issues include typos in image names, incorrect ports, or missing resources. Always check pod events with `kubectl describe pod` and deployment status.

---

## Question 6 | ConfigMap Volume Mount

**Solution:**

```bash
# Create the ConfigMap
kubectl create configmap app-config -n lyra \
  --from-literal=app.properties='database.host=galaxy-db.lyra
database.port=5432
app.name=GalaxyApp'

# Or using a file approach
cat > /tmp/app.properties <<EOF
database.host=galaxy-db.lyra
database.port=5432
app.name=GalaxyApp
EOF
kubectl create configmap app-config -n lyra --from-file=app.properties=/tmp/app.properties

# Create the Pod with ConfigMap volume
kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: config-pod
  namespace: lyra
spec:
  containers:
  - name: nginx
    image: nginx:1.21-alpine
    volumeMounts:
    - name: config-volume
      mountPath: /etc/config
  volumes:
  - name: config-volume
    configMap:
      name: app-config
EOF

# Verify
kubectl exec config-pod -n lyra -- cat /etc/config/app.properties
```

**Explanation:** ConfigMaps store non-sensitive configuration data. When mounted as a volume, each key becomes a file. This allows applications to read configuration from files without rebuilding images.

---

## Question 7 | Secret Environment Variables

**Solution:**

```bash
# Create the Secret
kubectl create secret generic db-credentials -n aquila \
  --from-literal=DB_USER=admin \
  --from-literal=DB_PASSWORD=galaxy-secret-2024

# Create the Pod with Secret environment variables
kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: secret-pod
  namespace: aquila
spec:
  containers:
  - name: busybox
    image: busybox:1.35
    command: ["sleep", "3600"]
    env:
    - name: DB_USER
      valueFrom:
        secretKeyRef:
          name: db-credentials
          key: DB_USER
    - name: DB_PASSWORD
      valueFrom:
        secretKeyRef:
          name: db-credentials
          key: DB_PASSWORD
EOF

# Verify
kubectl exec secret-pod -n aquila -- env | grep DB_
```

**Explanation:** Secrets store sensitive data like passwords. Using `secretKeyRef` injects secret values as environment variables without exposing them in pod specs.

---

## Question 8 | Service NodePort

**Solution:**

```bash
# Create the NodePort Service
kubectl apply -f - <<EOF
apiVersion: v1
kind: Service
metadata:
  name: web-service
  namespace: draco
spec:
  type: NodePort
  selector:
    app: web-app
  ports:
  - port: 80
    targetPort: 80
EOF

# Or using kubectl expose
kubectl expose deployment web-app -n draco --name=web-service --type=NodePort --port=80

# Verify
kubectl get svc web-service -n draco
```

**Explanation:** NodePort services expose pods on a port on every node in the cluster (30000-32767 range). This allows external access without a load balancer.

---

## Question 9 | Pod to Deployment Conversion

**Solution:**

```bash
# First, export the existing pod as a template
kubectl get pod galaxy-api -n phoenix -o yaml > /tmp/pod.yaml

# Create the Deployment
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: galaxy-api
  namespace: phoenix
spec:
  replicas: 3
  selector:
    matchLabels:
      app: galaxy-api
  template:
    metadata:
      labels:
        app: galaxy-api
    spec:
      containers:
      - name: api
        image: nginx:1.21-alpine
        ports:
        - containerPort: 80
        securityContext:
          allowPrivilegeEscalation: false
          privileged: false
EOF

# Delete the original pod
kubectl delete pod galaxy-api -n phoenix

# Save the deployment YAML
kubectl get deployment galaxy-api -n phoenix -o yaml > ./exam/course/9/galaxy-api-deployment.yaml

# Verify
kubectl get deployment galaxy-api -n phoenix
kubectl get pods -n phoenix -l app=galaxy-api
```

**Explanation:** Converting a Pod to a Deployment adds self-healing and scaling capabilities. The security context settings enhance container security by preventing privilege escalation.

---

## Question 10 | PV/PVC Creation

**Solution:**

```bash
# Create the PersistentVolume
kubectl apply -f - <<EOF
apiVersion: v1
kind: PersistentVolume
metadata:
  name: galaxy-pv
spec:
  capacity:
    storage: 1Gi
  accessModes:
  - ReadWriteOnce
  hostPath:
    path: /data/galaxy
  storageClassName: manual
EOF

# Create the PersistentVolumeClaim
kubectl apply -f - <<EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: galaxy-pvc
  namespace: hydra
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
  storageClassName: manual
EOF

# Create the Pod with PVC
kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: storage-pod
  namespace: hydra
spec:
  containers:
  - name: nginx
    image: nginx:1.21-alpine
    volumeMounts:
    - name: storage
      mountPath: /usr/share/nginx/html
  volumes:
  - name: storage
    persistentVolumeClaim:
      claimName: galaxy-pvc
EOF

# Verify
kubectl get pv galaxy-pv
kubectl get pvc galaxy-pvc -n hydra
```

**Explanation:** PersistentVolumes provide storage abstraction. The PVC requests storage from available PVs matching its requirements. The storageClassName must match between PV and PVC.

---

## Question 11 | NetworkPolicy

**Solution:**

```bash
# Create the NetworkPolicy
kubectl apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-internal
  namespace: centaurus
spec:
  podSelector:
    matchLabels:
      app: backend
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: frontend
EOF

# Save to file
kubectl get networkpolicy allow-internal -n centaurus -o yaml > ./exam/course/11/networkpolicy.yaml
```

**Explanation:** NetworkPolicies control traffic flow between pods. Without a policy, all traffic is allowed. Once a policy is applied, only explicitly allowed traffic is permitted.

---

## Question 12 | Container Image Build

**Solution:**

```bash
# Navigate to the image directory
cd ./exam/course/12/image/

# Build the image with Docker
sudo docker build -t localhost:5000/galaxy-app:v1 .

# Push to local registry
sudo docker push localhost:5000/galaxy-app:v1

# Create the Pod
kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: image-test-pod
  namespace: cassiopeia
spec:
  containers:
  - name: galaxy-app
    image: localhost:5000/galaxy-app:v1
    ports:
    - containerPort: 8080
EOF

# Wait for pod to be running
kubectl wait --for=condition=Ready pod/image-test-pod -n cassiopeia --timeout=60s

# Get logs
kubectl logs image-test-pod -n cassiopeia > ./exam/course/12/logs
```

**Explanation:** Building custom images is essential for deploying applications. The local registry at localhost:5000 allows pushing and pulling images without internet access.

---

## Question 13 | Helm Operations

**Solution:**

```bash
# Delete the release galaxy-nginx-v1
helm uninstall galaxy-nginx-v1 -n andromeda

# Upgrade galaxy-nginx-v2
helm repo update
helm upgrade galaxy-nginx-v2 bitnami/nginx -n andromeda

# Install galaxy-redis with 2 replicas
helm install galaxy-redis bitnami/redis -n andromeda \
  --set replica.replicaCount=2

# Find and delete broken release
helm list -n andromeda -a  # Find releases in pending-install state
helm uninstall <broken-release-name> -n andromeda

# Verify
helm list -n andromeda
```

**Explanation:** Helm manages Kubernetes applications as charts. Use `helm list -a` to see all releases including failed ones. Values can be set during install with `--set`.

---

## Question 14 | InitContainer

**Solution:**

```bash
# Apply the deployment with InitContainer
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: init-app
  namespace: orion
spec:
  replicas: 1
  selector:
    matchLabels:
      app: init-app
  template:
    metadata:
      labels:
        app: init-app
    spec:
      initContainers:
      - name: init-data
        image: busybox:1.35
        command: ['sh', '-c', 'echo "Welcome to Galaxy!" > /data/index.html']
        volumeMounts:
        - name: data-volume
          mountPath: /data
      containers:
      - name: nginx
        image: nginx:1.21-alpine
        ports:
        - containerPort: 80
        volumeMounts:
        - name: data-volume
          mountPath: /usr/share/nginx/html
      volumes:
      - name: data-volume
        emptyDir: {}
EOF

# Verify
kubectl get pods -n orion -l app=init-app
kubectl exec -n orion deploy/init-app -- cat /usr/share/nginx/html/index.html
```

**Explanation:** InitContainers run before the main container starts. They're useful for initialization tasks like populating data, waiting for services, or setting up configurations.

---

## Question 15 | Sidecar Logging

**Solution:**

```bash
# Update the deployment with sidecar
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: logger-app
  namespace: pegasus
spec:
  replicas: 1
  selector:
    matchLabels:
      app: logger-app
  template:
    metadata:
      labels:
        app: logger-app
    spec:
      containers:
      - name: app
        image: busybox:1.35
        command: ["/bin/sh", "-c"]
        args:
        - |
          while true; do
            echo "\$(date): Application log entry" >> /var/log/app.log
            sleep 5
          done
        volumeMounts:
        - name: log-volume
          mountPath: /var/log
      - name: log-sidecar
        image: busybox:1.35
        command: ["tail", "-f", "/var/log/app.log"]
        volumeMounts:
        - name: log-volume
          mountPath: /var/log
      volumes:
      - name: log-volume
        emptyDir: {}
EOF

# Save YAML
kubectl get deployment logger-app -n pegasus -o yaml > ./exam/course/15/logger-app.yaml

# View logs
kubectl logs -n pegasus deploy/logger-app -c log-sidecar
```

**Explanation:** Sidecar containers complement the main container. A logging sidecar streams log files to stdout, making them accessible via `kubectl logs`.

---

## Question 16 | ServiceAccount Token

**Solution:**

```bash
# Get the ServiceAccount's secret
SA_SECRET=$(kubectl get serviceaccount galaxy-sa -n cygnus -o jsonpath='{.secrets[0].name}')

# If using Kubernetes 1.24+, create a token
kubectl create token galaxy-sa -n cygnus > ./exam/course/16/token

# Or for older versions, get from secret
kubectl get secret galaxy-sa-token -n cygnus -o jsonpath='{.data.token}' | base64 -d > ./exam/course/16/token
```

**Explanation:** ServiceAccount tokens authenticate pods to the Kubernetes API. In Kubernetes 1.24+, tokens are no longer automatically created as secrets; use `kubectl create token` instead.

---

## Question 17 | Liveness Probe

**Solution:**

```bash
# Create the Pod with liveness probe
kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: liveness-pod
  namespace: lyra
spec:
  containers:
  - name: nginx
    image: nginx:1.21-alpine
    ports:
    - containerPort: 80
    livenessProbe:
      httpGet:
        path: /
        port: 80
      initialDelaySeconds: 10
      periodSeconds: 5
EOF

# Verify
kubectl get pod liveness-pod -n lyra
kubectl describe pod liveness-pod -n lyra | grep -A5 Liveness
```

**Explanation:** Liveness probes detect when a container is unhealthy. If the probe fails, Kubernetes restarts the container. HTTP probes check if the application responds to requests.

---

## Question 18 | Readiness Probe

**Solution:**

```bash
# Create the Pod with readiness probe
kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: readiness-pod
  namespace: aquila
spec:
  containers:
  - name: busybox
    image: busybox:1.35
    command: ["sh", "-c", "touch /tmp/ready && sleep 3600"]
    readinessProbe:
      exec:
        command: ["cat", "/tmp/ready"]
      initialDelaySeconds: 5
      periodSeconds: 10
EOF

# Verify
kubectl get pod readiness-pod -n aquila
kubectl describe pod readiness-pod -n aquila | grep -A5 Readiness
```

**Explanation:** Readiness probes determine when a pod is ready to receive traffic. Unlike liveness probes, failed readiness probes remove the pod from service endpoints but don't restart it.

---

## Question 19 | Resource Limits

**Solution:**

```bash
# Update the deployment with resource limits
kubectl patch deployment resource-app -n draco --type='json' -p='[
  {"op": "add", "path": "/spec/template/spec/containers/0/resources", "value": {
    "requests": {"memory": "64Mi", "cpu": "100m"},
    "limits": {"memory": "128Mi", "cpu": "200m"}
  }}
]'

# Or edit directly
kubectl edit deployment resource-app -n draco
# Add the resources section under containers

# Verify
kubectl get deployment resource-app -n draco -o jsonpath='{.spec.template.spec.containers[0].resources}'
```

**Explanation:** Resource requests guarantee minimum resources for scheduling. Limits cap maximum usage. Setting both helps with capacity planning and prevents resource starvation.

---

## Question 20 | Labels and Selectors

**Solution:**

```bash
# Create the labeled pod
kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: labeled-pod
  namespace: phoenix
  labels:
    app: galaxy
    tier: frontend
    version: v1
spec:
  containers:
  - name: nginx
    image: nginx:1.21-alpine
EOF

# Find all pods with app=galaxy label
kubectl get pods --all-namespaces -l app=galaxy > ./exam/course/20/selected-pods.txt

# Verify
cat ./exam/course/20/selected-pods.txt
```

**Explanation:** Labels are key-value pairs for organizing resources. Selectors filter resources by labels. Use `-l key=value` with kubectl to select resources by label.

---

## Question 21 | Rollback Deployment

**Solution:**

```bash
# Check rollout history
kubectl rollout history deployment/rollback-app -n hydra

# Rollback to previous revision
kubectl rollout undo deployment/rollback-app -n hydra

# Or rollback to specific revision
kubectl rollout undo deployment/rollback-app -n hydra --to-revision=1

# Verify
kubectl rollout status deployment/rollback-app -n hydra
kubectl get deployment rollback-app -n hydra -o jsonpath='{.spec.template.spec.containers[0].image}'
```

**Explanation:** Kubernetes maintains deployment revision history. Use `rollout undo` to revert to a previous working version. The `--to-revision` flag allows rollback to any specific revision.

---

## Preview Question 1 | Startup Probe

**Solution:**

```bash
# Create the Pod with startup probe
kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: startup-pod
  namespace: centaurus
spec:
  containers:
  - name: nginx
    image: nginx:1.21-alpine
    ports:
    - containerPort: 80
    startupProbe:
      httpGet:
        path: /
        port: 80
      failureThreshold: 30
      periodSeconds: 10
EOF

# Verify
kubectl get pod startup-pod -n centaurus
kubectl describe pod startup-pod -n centaurus | grep -A5 Startup
```

**Explanation:** Startup probes are for slow-starting containers. They disable liveness/readiness probes until the container starts. With failureThreshold=30 and periodSeconds=10, the container has 5 minutes to start.

---
