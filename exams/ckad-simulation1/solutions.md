# CKAD Simulation 1 - Solutions

This document contains the solutions for all questions in CKAD Simulation 1.

---

## Question 1 | Namespaces

**Solution:**

```bash
# List all namespaces and save to file
kubectl get namespaces > ./exam/course/1/namespaces
```

**Explanation:** The `kubectl get namespaces` command lists all namespaces in the cluster with NAME, STATUS, and AGE columns.

---

## Question 2 | Pods

**Solution:**

```bash
# Create the Pod
kubectl run pod1 --image=httpd:2.4.41-alpine -n default \
  --dry-run=client -o yaml | sed 's/name: pod1/name: pod1\n    - name: pod1-container/' | kubectl apply -f -

# Or use YAML directly
kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: pod1
  namespace: default
spec:
  containers:
  - name: pod1-container
    image: httpd:2.4.41-alpine
EOF

# Create the status command script
echo 'kubectl get pod pod1 -n default -o wide' > ./exam/course/2/pod1-status-command.sh
chmod +x ./exam/course/2/pod1-status-command.sh
```

**Explanation:** The `--dry-run=client -o yaml` flag generates YAML without creating the resource. Customize container names in the YAML before applying.

---

## Question 3 | Job

**Solution:**

```bash
# Create the Job
kubectl apply -f - <<EOF
apiVersion: batch/v1
kind: Job
metadata:
  name: neb-new-job
  namespace: neptune
spec:
  completions: 3
  parallelism: 2
  template:
    metadata:
      labels:
        id: awesome-job
    spec:
      containers:
      - name: neb-new-job-container
        image: busybox:1.31.0
        command: ["/bin/sh", "-c", "sleep 2 && echo done"]
      restartPolicy: Never
EOF

# Save to file
kubectl get job neb-new-job -n neptune -o yaml > ./exam/course/3/job.yaml
```

**Explanation:** `completions: 3` means run 3 successful pods. `parallelism: 2` allows 2 pods to run at once. Labels on the pod template apply to created pods.

---

## Question 4 | Helm Management

**Solution:**

```bash
# 1. Delete release
helm uninstall internal-issue-report-apiv1 -n mercury

# 2. Upgrade release
helm repo update
helm upgrade internal-issue-report-apiv2 bitnami/nginx -n mercury

# 3. Install new release with 2 replicas
helm install internal-issue-report-apache bitnami/apache -n mercury \
  --set replicaCount=2

# 4. Find and delete broken release
helm list -n mercury -a  # Find pending-install releases
helm uninstall <broken-release> -n mercury
```

**Explanation:** Helm manages application releases. Use `helm list -a` to see all releases including failed ones. Set values with `--set key=value`.

---

## Question 5 | ServiceAccount, Secret

**Solution:**

```bash
# Get the token from the ServiceAccount's secret
# For Kubernetes 1.24+:
kubectl create token neptune-sa-v2 -n neptune > ./exam/course/5/token

# For older versions:
SECRET_NAME=$(kubectl get sa neptune-sa-v2 -n neptune -o jsonpath='{.secrets[0].name}')
kubectl get secret $SECRET_NAME -n neptune -o jsonpath='{.data.token}' | base64 -d > ./exam/course/5/token
```

**Explanation:** ServiceAccount tokens authenticate pods to the API server. In Kubernetes 1.24+, use `kubectl create token` as tokens are no longer stored in secrets.

---

## Question 6 | ReadinessProbe

**Solution:**

```bash
kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: pod6
  namespace: default
spec:
  containers:
  - name: pod6-container
    image: busybox:1.31.0
    command: ["sh", "-c", "touch /tmp/ready && sleep 1d"]
    readinessProbe:
      exec:
        command: ["cat", "/tmp/ready"]
      initialDelaySeconds: 5
      periodSeconds: 10
EOF
```

**Explanation:** Readiness probes determine when a pod can receive traffic. The probe checks if `/tmp/ready` exists. The container creates this file at startup.

---

## Question 7 | Pods, Namespaces

**Solution:**

```bash
# Find the pod with my-happy-shop label or annotation
kubectl get pods -n saturn --show-labels | grep -i happy
# Or
kubectl get pods -n saturn -o wide

# The pod is webserver-sat-003
# Export its YAML
kubectl get pod webserver-sat-003 -n saturn -o yaml > /tmp/pod.yaml

# Edit the namespace in the YAML file
sed -i 's/namespace: saturn/namespace: neptune/' /tmp/pod.yaml

# Delete from saturn
kubectl delete pod webserver-sat-003 -n saturn

# Create in neptune
kubectl apply -f /tmp/pod.yaml
```

**Explanation:** Moving a pod between namespaces requires exporting its definition, modifying the namespace, deleting the original, and recreating it.

---

## Question 8 | Deployment, Rollouts

**Solution:**

```bash
# Check rollout history
kubectl rollout history deployment api-new-c32 -n neptune

# Check what's wrong with current revision
kubectl describe deployment api-new-c32 -n neptune
kubectl get pods -n neptune -l app=api-new-c32

# Rollback to previous working revision
kubectl rollout undo deployment api-new-c32 -n neptune

# Verify
kubectl rollout status deployment api-new-c32 -n neptune
```

**Explanation:** Use `rollout history` to see revisions and `rollout undo` to revert. Common issues include bad images or misconfigured resources.

---

## Question 9 | Pod → Deployment

**Solution:**

```bash
# Create deployment from pod template
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: holy-api
  namespace: pluto
spec:
  replicas: 3
  selector:
    matchLabels:
      app: holy-api
  template:
    metadata:
      labels:
        app: holy-api
    spec:
      containers:
      - name: holy-api-container
        image: nginx:1.17.3-alpine
        securityContext:
          allowPrivilegeEscalation: false
          privileged: false
EOF

# Delete original pod
kubectl delete pod holy-api -n pluto

# Save deployment YAML
kubectl get deployment holy-api -n pluto -o yaml > ./exam/course/9/holy-api-deployment.yaml
```

**Explanation:** Converting pods to deployments adds self-healing and scaling. The security context prevents privilege escalation for better container security.

---

## Question 10 | Service, Logs

**Solution:**

```bash
# Create the Pod
kubectl run project-plt-6cc-api --image=nginx:1.17.3-alpine -n pluto \
  --labels="project=plt-6cc-api"

# Create the Service
kubectl apply -f - <<EOF
apiVersion: v1
kind: Service
metadata:
  name: project-plt-6cc-svc
  namespace: pluto
spec:
  selector:
    project: plt-6cc-api
  ports:
  - port: 3333
    targetPort: 80
EOF

# Test the service
kubectl run tmp --image=nginx:alpine --rm -it --restart=Never -n pluto -- \
  curl -s project-plt-6cc-svc:3333 > ./exam/course/10/service_test.html

# Get logs
kubectl logs project-plt-6cc-api -n pluto > ./exam/course/10/service_test.log
```

**Explanation:** ClusterIP services expose pods internally. The selector must match pod labels. Use temporary pods to test service connectivity.

---

## Question 11 | Working with Containers

**Solution:**

```bash
# Modify Dockerfile to add ENV
cd ./exam/course/11/image/
echo 'ENV SUN_CIPHER_ID=5b9c1065-e39d-4a43-a04a-e59bcea3e03f' >> Dockerfile

# Build with Docker
sudo docker build -t localhost:5000/sun-cipher:v1-docker .
sudo docker push localhost:5000/sun-cipher:v1-docker

# Build with Podman
sudo podman build -t localhost:5000/sun-cipher:v1-podman .
sudo podman push localhost:5000/sun-cipher:v1-podman

# Run container
sudo podman run -d --name sun-cipher localhost:5000/sun-cipher:v1-podman

# Get logs
sudo podman logs sun-cipher > ./exam/course/11/logs
```

**Explanation:** Docker and Podman have similar commands. ENV variables set environment in containers. Push to localhost:5000 registry for cluster access.

---

## Question 12 | Storage, PV, PVC, Pod volume

**Solution:**

```bash
# Create PV
kubectl apply -f - <<EOF
apiVersion: v1
kind: PersistentVolume
metadata:
  name: earth-project-earthflower-pv
spec:
  capacity:
    storage: 2Gi
  accessModes:
  - ReadWriteOnce
  hostPath:
    path: /Volumes/Data
EOF

# Create PVC
kubectl apply -f - <<EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: earth-project-earthflower-pvc
  namespace: earth
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 2Gi
EOF

# Create Deployment
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: project-earthflower
  namespace: earth
spec:
  replicas: 1
  selector:
    matchLabels:
      app: project-earthflower
  template:
    metadata:
      labels:
        app: project-earthflower
    spec:
      containers:
      - name: httpd
        image: httpd:2.4.41-alpine
        volumeMounts:
        - name: data
          mountPath: /tmp/project-data
      volumes:
      - name: data
        persistentVolumeClaim:
          claimName: earth-project-earthflower-pvc
EOF
```

**Explanation:** PVs provide storage abstraction. Without storageClassName, PVs and PVCs are matched by capacity and access modes.

---

## Question 13 | Storage, StorageClass, PVC

**Solution:**

```bash
# Create StorageClass
kubectl apply -f - <<EOF
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: moon-retain
provisioner: moon-retainer
reclaimPolicy: Retain
EOF

# Create PVC
kubectl apply -f - <<EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: moon-pvc-126
  namespace: moon
spec:
  storageClassName: moon-retain
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 3Gi
EOF

# Get PVC events
kubectl describe pvc moon-pvc-126 -n moon | grep -A5 Events > ./exam/course/13/pvc-126-reason
```

**Explanation:** StorageClasses define provisioners and reclaim policies. The PVC will be Pending because the moon-retainer provisioner doesn't exist.

---

## Question 14 | Secret, Secret-Volume, Secret-Env

**Solution:**

```bash
# Create secret1
kubectl create secret generic secret1 -n moon \
  --from-literal=user=test \
  --from-literal=pass=pwd

# Create secret2 from template
kubectl apply -f ./exam/course/14/secret2.yaml

# Update secret-handler pod
kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: secret-handler
  namespace: moon
spec:
  containers:
  - name: secret-handler
    image: bash:5.0.11
    command: ["sleep", "1d"]
    env:
    - name: SECRET1_USER
      valueFrom:
        secretKeyRef:
          name: secret1
          key: user
    - name: SECRET1_PASS
      valueFrom:
        secretKeyRef:
          name: secret1
          key: pass
    volumeMounts:
    - name: secret2-volume
      mountPath: /tmp/secret2
  volumes:
  - name: secret2-volume
    secret:
      secretName: secret2
EOF

# Save YAML
kubectl get pod secret-handler -n moon -o yaml > ./exam/course/14/secret-handler-new.yaml
```

**Explanation:** Secrets can be mounted as volumes or exposed as environment variables. Use secretKeyRef for individual keys or envFrom for all keys.

---

## Question 15 | ConfigMap, Configmap-Volume

**Solution:**

```bash
# Create ConfigMap from file
kubectl create configmap configmap-web-moon-html -n moon \
  --from-file=index.html=./exam/course/15/web-moon.html

# Verify the deployment uses it
kubectl get deployment web-moon -n moon -o yaml

# Test with curl
kubectl run tmp --image=nginx:alpine --rm -it --restart=Never -n moon -- \
  curl -s web-moon
```

**Explanation:** ConfigMaps store configuration data. The `--from-file` flag creates a key named after the file. The deployment should already be configured to mount this ConfigMap.

---

## Question 16 | Logging sidecar

**Solution:**

```bash
# Get the current deployment
kubectl get deployment cleaner -n mercury -o yaml > ./exam/course/16/cleaner.yaml

# Add sidecar to deployment
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: cleaner
  namespace: mercury
spec:
  selector:
    matchLabels:
      app: cleaner
  template:
    metadata:
      labels:
        app: cleaner
    spec:
      containers:
      - name: cleaner-con
        image: busybox:1.31.0
        command: ["sh", "-c", "while true; do echo cleaning >> /var/log/cleaner/cleaner.log; sleep 5; done"]
        volumeMounts:
        - name: log-volume
          mountPath: /var/log/cleaner
      - name: logger-con
        image: busybox:1.31.0
        command: ["tail", "-f", "/var/log/cleaner/cleaner.log"]
        volumeMounts:
        - name: log-volume
          mountPath: /var/log/cleaner
      volumes:
      - name: log-volume
        emptyDir: {}
EOF

# Save new YAML
kubectl get deployment cleaner -n mercury -o yaml > ./exam/course/16/cleaner-new.yaml

# View logs
kubectl logs -n mercury deploy/cleaner -c logger-con
```

**Explanation:** Sidecar containers share volumes with the main container. The logging sidecar streams log files to stdout for `kubectl logs` access.

---

## Question 17 | InitContainer

**Solution:**

```bash
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: test-init-container
  namespace: mars
spec:
  replicas: 1
  selector:
    matchLabels:
      app: test-init-container
  template:
    metadata:
      labels:
        app: test-init-container
    spec:
      initContainers:
      - name: init-con
        image: busybox:1.31.0
        command: ["sh", "-c", "echo 'check this out!' > /workdir/index.html"]
        volumeMounts:
        - name: workdir
          mountPath: /workdir
      containers:
      - name: nginx
        image: nginx:1.17.3-alpine
        volumeMounts:
        - name: workdir
          mountPath: /usr/share/nginx/html
      volumes:
      - name: workdir
        emptyDir: {}
EOF

# Test
kubectl run tmp --image=nginx:alpine --rm -it --restart=Never -n mars -- \
  curl -s test-init-container
```

**Explanation:** InitContainers run before main containers and must complete successfully. They're useful for setup tasks like populating data volumes.

---

## Question 18 | Service misconfiguration

**Solution:**

```bash
# Check service and deployment labels
kubectl describe svc manager-api-svc -n mars
kubectl describe deployment manager-api-deployment -n mars

# The issue is usually a selector mismatch
# Fix the service selector to match deployment pod labels
kubectl patch svc manager-api-svc -n mars -p '{"spec":{"selector":{"app":"manager-api"}}}'

# Or edit the service
kubectl edit svc manager-api-svc -n mars

# Test
kubectl run tmp --image=nginx:alpine --rm -it --restart=Never -n mars -- \
  curl -s manager-api-svc.mars:4444
```

**Explanation:** Service selectors must match pod labels exactly. Use `kubectl describe` to compare labels and selectors.

---

## Question 19 | Service ClusterIP → NodePort

**Solution:**

```bash
# Change service type to NodePort with specific port
kubectl patch svc jupiter-crew-svc -n jupiter -p '{"spec":{"type":"NodePort","ports":[{"port":80,"nodePort":30100}]}}'

# Or edit directly
kubectl edit svc jupiter-crew-svc -n jupiter
# Change type: ClusterIP to type: NodePort
# Add nodePort: 30100

# Test from node
kubectl get nodes -o wide  # Get node IPs
curl <node-ip>:30100
```

**Explanation:** NodePort services expose pods on all nodes. The nodePort must be in range 30000-32767. The service is reachable on all nodes, regardless of where pods run.

---

## Question 20 | NetworkPolicy

**Solution:**

```bash
kubectl apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: np1
  namespace: venus
spec:
  podSelector:
    matchLabels:
      app: frontend
  policyTypes:
  - Egress
  egress:
  # Allow DNS
  - to: []
    ports:
    - port: 53
      protocol: UDP
    - port: 53
      protocol: TCP
  # Allow to api deployment
  - to:
    - podSelector:
        matchLabels:
          app: api
    ports:
    - port: 2222
EOF

# Test
kubectl exec -n venus deploy/frontend -- wget -O- -T2 api:2222  # Should work
kubectl exec -n venus deploy/frontend -- wget -O- -T2 www.google.com  # Should fail
```

**Explanation:** NetworkPolicies filter traffic by pod selectors. Always allow DNS (port 53) for name resolution. Egress policies control outbound traffic.

---

## Question 21 | Requests and Limits, ServiceAccount

**Solution:**

```bash
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: neptune-10ab
  namespace: neptune
spec:
  replicas: 3
  selector:
    matchLabels:
      app: neptune-10ab
  template:
    metadata:
      labels:
        app: neptune-10ab
    spec:
      serviceAccountName: neptune-sa-v2
      containers:
      - name: neptune-pod-10ab
        image: httpd:2.4-alpine
        resources:
          requests:
            memory: "20Mi"
          limits:
            memory: "50Mi"
EOF
```

**Explanation:** Resource requests affect scheduling; limits cap usage. The serviceAccountName specifies which ServiceAccount the pod uses for API authentication.

---

## Question 22 | Labels, Annotations

**Solution:**

```bash
# Add label to pods with type=worker or type=runner
kubectl label pods -n sun -l type=worker protected=true
kubectl label pods -n sun -l type=runner protected=true

# Add annotation to pods with protected=true
kubectl annotate pods -n sun -l protected=true "protected=do not delete this pod"

# Verify
kubectl get pods -n sun -l protected=true --show-labels
```

**Explanation:** Labels organize resources; annotations store metadata. Use `-l` selector to filter resources for bulk operations.

---

## Preview Question 1 | Liveness Probe

**Solution:**

```bash
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: project-23-api
  namespace: shell-intern
spec:
  replicas: 1
  selector:
    matchLabels:
      app: project-23-api
  template:
    metadata:
      labels:
        app: project-23-api
    spec:
      containers:
      - name: nginx
        image: nginx:1.17.3-alpine
        livenessProbe:
          httpGet:
            path: /health
            port: 80
          initialDelaySeconds: 15
          periodSeconds: 10
EOF
```

**Explanation:** Liveness probes detect unhealthy containers. If the probe fails repeatedly, the container is restarted. HTTP probes check specific endpoints.

---

## Preview Question 2 | CronJob

**Solution:**

```bash
kubectl apply -f - <<EOF
apiVersion: batch/v1
kind: CronJob
metadata:
  name: hello
  namespace: default
spec:
  schedule: "* * * * *"
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: hello
            image: busybox:1.28
            command: ["/bin/sh", "-c", "echo Hello from Kubernetes cluster"]
          restartPolicy: OnFailure
EOF
```

**Explanation:** CronJobs run jobs on a schedule. `* * * * *` means every minute. Each job creates a pod that runs the command.

---

## Preview Question 3 | Multi-container Pod

**Solution:**

```bash
kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: multi-container-pod
  namespace: default
spec:
  containers:
  - name: nginx-container
    image: nginx:1.17.6-alpine
  - name: redis-container
    image: redis:5.0.4-alpine
EOF
```

**Explanation:** Multi-container pods share network namespace (localhost communication) and can share volumes. Containers should work together as a single unit.

---
