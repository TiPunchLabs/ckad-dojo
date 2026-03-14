# CKAD Simulation 10 - Solutions (Dojo Oni 👹)

> **Total Score**: 102 points | **Passing Score**: ~66% (68 points)
>
> **Focus**: Debugging and fixing real workloads — the core of the CKAD exam.

---

## Question 1 | Secrets & Environment Variables (5 points)

### Solution

Inspect the existing Pod:

```bash
kubectl get pod webapp -n fortress -o yaml | grep -A 10 env
```

The Pod has `DB_USER=admin` and `DB_PASS=secret123`.

Create the Secret:

```bash
kubectl create secret generic db-credentials \
  --from-literal=DB_USER=admin \
  --from-literal=DB_PASS=secret123 \
  -n fortress
```

Delete the existing Pod:

```bash
kubectl delete pod webapp -n fortress
```

Recreate the Pod with secretKeyRef:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: webapp
  namespace: fortress
spec:
  containers:
  - name: webapp
    image: nginx:1.25
    ports:
    - containerPort: 80
    env:
    - name: DB_USER
      valueFrom:
        secretKeyRef:
          name: db-credentials
          key: DB_USER
    - name: DB_PASS
      valueFrom:
        secretKeyRef:
          name: db-credentials
          key: DB_PASS
```

```bash
kubectl apply -f webapp-fixed.yaml
```

---

## Question 2 | Fix a Broken Ingress (6 points)

### Solution

Inspect the Service:

```bash
kubectl get svc frontend-svc -n bastion
# NAME           TYPE        CLUSTER-IP     PORT(S)   AGE
# frontend-svc   ClusterIP   10.96.x.x     80/TCP    ...
```

Inspect the broken Ingress:

```bash
kubectl get ingress frontend-ingress -n bastion -o yaml
```

The problems are:

- Service name is `frontend` instead of `frontend-svc`
- Port is `8080` instead of `80`
- `pathType` is missing

Fix the Ingress:

```bash
kubectl edit ingress frontend-ingress -n bastion
```

Corrected spec:

```yaml
spec:
  rules:
  - host: frontend.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: frontend-svc
            port:
              number: 80
```

---

## Question 3 | Create a New Ingress (5 points)

### Solution

```bash
kubectl create ingress api-ingress \
  --rule="api.example.com/app=api-svc:80" \
  --annotation="nginx.ingress.kubernetes.io/rewrite-target=/" \
  -n citadel
```

Or YAML:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: api-ingress
  namespace: citadel
spec:
  rules:
  - host: api.example.com
    http:
      paths:
      - path: /app
        pathType: Prefix
        backend:
          service:
            name: api-svc
            port:
              number: 80
```

```bash
kubectl apply -f api-ingress.yaml
```

---

## Question 4 | NetworkPolicy — Label Pods for Communication (6 points)

### Solution

Inspect the NetworkPolicies:

```bash
kubectl describe networkpolicy -n rampart
```

The policies use these selectors:

- `allow-frontend-to-backend`: ingress on port 80 to pods with `tier=backend`, from pods with `tier=frontend`
- `allow-backend-to-db`: ingress on port 5432 to pods with `tier=database`, from pods with `tier=backend`
- `default-deny`: denies all ingress by default

Label the pods:

```bash
kubectl label pod frontend tier=frontend -n rampart
kubectl label pod backend tier=backend -n rampart
kubectl label pod database tier=database -n rampart
```

Verify:

```bash
kubectl get pods -n rampart --show-labels
```

---

## Question 5 | Resource Requests and Limits (5 points)

### Solution

```bash
kubectl set resources deployment compute-app -n tower \
  --requests=cpu=100m,memory=128Mi \
  --limits=cpu=200m,memory=256Mi
```

Or edit directly:

```bash
kubectl edit deployment compute-app -n tower
```

Add under the container spec:

```yaml
resources:
  requests:
    cpu: "100m"
    memory: "128Mi"
  limits:
    cpu: "200m"
    memory: "256Mi"
```

Verify:

```bash
kubectl get pods -n tower
kubectl get deployment compute-app -n tower -o jsonpath='{.spec.template.spec.containers[0].resources}'
```

---

## Question 6 | Fix ResourceQuota Issue (5 points)

### Solution

Check the quota:

```bash
kubectl describe quota compute-quota -n garrison
# Hard limits: requests.cpu=500m, requests.memory=512Mi
```

Check current deployment resources:

```bash
kubectl get deployment quota-app -n garrison -o jsonpath='{.spec.template.spec.containers[0].resources}'
# requests.cpu=1, requests.memory=1Gi — exceeds the quota
```

Reduce resources to fit within quota:

```bash
kubectl set resources deployment quota-app -n garrison \
  --requests=cpu=250m,memory=256Mi \
  --limits=cpu=500m,memory=512Mi
```

Verify Pods are now running:

```bash
kubectl get pods -n garrison
```

---

## Question 7 | Docker Image Build and Save (5 points)

### Solution

```bash
# Build the image
docker build -t localhost:5000/oni-app:1.0 ./exam/course/7/image/

# Save as tar archive
docker save -o ./exam/course/7/oni-app.tar localhost:5000/oni-app:1.0

# Push to local registry
docker push localhost:5000/oni-app:1.0
```

Verify:

```bash
docker images | grep oni-app
ls -la ./exam/course/7/oni-app.tar
```

---

## Question 8 | Canary Deployment (6 points)

### Solution

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: canary-app
  namespace: bulwark
spec:
  replicas: 1
  selector:
    matchLabels:
      app: webapp
      version: v2
  template:
    metadata:
      labels:
        app: webapp
        version: v2
    spec:
      containers:
      - name: webapp
        image: nginx:1.25
        ports:
        - containerPort: 80
```

```bash
kubectl apply -f canary-app.yaml
```

Verify both deployments are selected by the Service:

```bash
kubectl get ep app-svc -n bulwark
# Should show IPs from both stable-app and canary-app pods
```

---

## Question 9 | Fix Service Selector Mismatch (4 points)

### Solution

Check Pod labels:

```bash
kubectl get pods -n parapet --show-labels
# app=backend-api
```

Check Service selector:

```bash
kubectl get svc backend-svc -n parapet -o jsonpath='{.spec.selector}'
# {"app":"backend-wrong"}
```

Fix the selector:

```bash
kubectl patch svc backend-svc -n parapet -p '{"spec":{"selector":{"app":"backend-api"}}}'
```

Or edit:

```bash
kubectl edit svc backend-svc -n parapet
# Change selector.app from "backend-wrong" to "backend-api"
```

Verify:

```bash
kubectl get endpoints backend-svc -n parapet
# Should now show Pod IPs
```

---

## Question 10 | CronJob with Proper Exit (5 points)

### Solution

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: cleanup-job
  namespace: stronghold
spec:
  schedule: "*/5 * * * *"
  jobTemplate:
    spec:
      activeDeadlineSeconds: 30
      template:
        spec:
          containers:
          - name: cleanup
            image: busybox:1.36
            command: ["sh", "-c", "echo \"Cleanup completed at $(date)\""]
          restartPolicy: Never
```

```bash
kubectl apply -f cleanup-job.yaml
```

Or one-liner:

```bash
kubectl create cronjob cleanup-job \
  --image=busybox:1.36 \
  --schedule="*/5 * * * *" \
  --restart=Never \
  -n stronghold \
  -- sh -c 'echo "Cleanup completed at $(date)"'

# Then edit to add activeDeadlineSeconds:
kubectl edit cronjob cleanup-job -n stronghold
```

---

## Question 11 | SecurityContext — Merge Settings (5 points)

### Solution

```bash
kubectl edit deployment secure-app -n fortress
```

The existing securityContext:

```yaml
securityContext:
  readOnlyRootFilesystem: true
  allowPrivilegeEscalation: false
```

Add `runAsUser: 10000` at the same level:

```yaml
securityContext:
  readOnlyRootFilesystem: true
  allowPrivilegeEscalation: false
  runAsUser: 10000
```

Verify:

```bash
kubectl get pods -n fortress -l app=secure-app
kubectl get deployment secure-app -n fortress -o jsonpath='{.spec.template.spec.containers[0].securityContext}'
```

---

## Question 12 | RBAC — Fix Forbidden Error (7 points)

### Solution

Create the Role:

```bash
kubectl create role pod-reader-role \
  --verb=get,list,watch \
  --resource=pods \
  -n bastion
```

Create the RoleBinding:

```bash
kubectl create rolebinding pod-reader-binding \
  --role=pod-reader-role \
  --serviceaccount=bastion:pod-reader-sa \
  -n bastion
```

Verify:

```bash
kubectl auth can-i list pods -n bastion --as=system:serviceaccount:bastion:pod-reader-sa
# yes
```

Restart the Pod to pick up the new permissions:

```bash
kubectl rollout restart deployment pod-reader -n bastion
```

---

## Question 13 | Deployment Rollback (5 points)

### Solution

Check rollout history:

```bash
kubectl rollout history deployment web-server -n citadel
```

Save history to file:

```bash
kubectl rollout history deployment web-server -n citadel > ./exam/course/13/rollout-history.txt
```

Roll back to the working revision:

```bash
kubectl rollout undo deployment web-server -n citadel
```

Or if you need a specific revision:

```bash
kubectl rollout undo deployment web-server -n citadel --to-revision=2
```

Verify:

```bash
kubectl rollout status deployment web-server -n citadel
kubectl get deployment web-server -n citadel -o jsonpath='{.spec.template.spec.containers[0].image}'
# Should show nginx:1.25
```

---

## Question 14 | Fix Deprecated API Version (4 points)

### Solution

Edit the file `./exam/course/14/broken-deploy.yaml`:

1. Change `apiVersion: extensions/v1beta1` to `apiVersion: apps/v1`
2. Remove the `spec.rollbackTo` field entirely
3. Add `spec.selector.matchLabels` matching the Pod template labels

Fixed manifest:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: legacy-app
  namespace: rampart
spec:
  replicas: 2
  selector:
    matchLabels:
      app: legacy-app
  template:
    metadata:
      labels:
        app: legacy-app
    spec:
      containers:
      - name: legacy-app
        image: nginx:1.25
        ports:
        - containerPort: 80
```

Apply:

```bash
kubectl apply -f ./exam/course/14/broken-deploy.yaml
```

---

## Question 15 | Troubleshoot Failing Deployment (5 points)

### Solution

Investigate the failing Pods:

```bash
kubectl describe pod -l app=health-app -n tower
```

Look at the liveness probe configuration — it's checking port `8080` but the container only exposes port `80`.

Write root cause:

```bash
echo "Liveness probe configured on port 8080 but container listens on port 80" > ./exam/course/15/root-cause.txt
```

Fix the Deployment:

```bash
kubectl edit deployment health-app -n tower
```

Change the liveness probe port from `8080` to `80`:

```yaml
livenessProbe:
  httpGet:
    path: /
    port: 80
  initialDelaySeconds: 5
  periodSeconds: 10
```

Verify:

```bash
kubectl get pods -n tower -l app=health-app
# Should show Running status
```

---

## Question 16 | ConfigMap as Environment Variables (5 points)

### Solution

Create the ConfigMap:

```bash
kubectl create configmap app-config \
  --from-literal=APP_ENV=production \
  --from-literal=APP_DEBUG=false \
  -n gate
```

Create the Pod:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: config-app
  namespace: gate
spec:
  containers:
  - name: config-app
    image: nginx:1.25
    envFrom:
    - configMapRef:
        name: app-config
```

```bash
kubectl apply -f config-app.yaml
```

Verify:

```bash
kubectl exec config-app -n gate -- env | grep APP_
# APP_ENV=production
# APP_DEBUG=false
```

---

## Question 17 | Create ClusterIP Service (4 points)

### Solution

```bash
kubectl expose deployment backend-app \
  --name=backend-svc \
  --port=80 \
  --target-port=80 \
  -n gate
```

Or YAML:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: backend-svc
  namespace: gate
spec:
  type: ClusterIP
  selector:
    app: backend-app
  ports:
  - port: 80
    targetPort: 80
```

Verify:

```bash
kubectl get svc backend-svc -n gate
kubectl get ep backend-svc -n gate
```

---

## Question 18 | Job with Completions and Parallelism (5 points)

### Solution

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: batch-processor
  namespace: bulwark
spec:
  completions: 6
  parallelism: 2
  template:
    spec:
      containers:
      - name: processor
        image: busybox:1.36
        command: ["sh", "-c", "echo 'Processing batch item'"]
      restartPolicy: Never
```

```bash
kubectl apply -f batch-processor.yaml
```

Verify:

```bash
kubectl get job batch-processor -n bulwark
# COMPLETIONS should eventually show 6/6
```

---

## Question 19 | Deployment Rolling Update Strategy (5 points)

### Solution

```bash
kubectl edit deployment rolling-app -n parapet
```

Or patch:

```bash
kubectl patch deployment rolling-app -n parapet -p '
{
  "spec": {
    "strategy": {
      "type": "RollingUpdate",
      "rollingUpdate": {
        "maxSurge": 1,
        "maxUnavailable": 0
      }
    }
  }
}'
```

Verify:

```bash
kubectl get deployment rolling-app -n parapet -o jsonpath='{.spec.strategy}'
```

---

## Question 20 | Multi-container Pod with Shared Volume (5 points)

### Solution

Complete the template at `./exam/course/20/sidecar-pod.yaml`:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: logger-app
  namespace: stronghold
spec:
  containers:
  - name: app
    image: busybox:1.36
    command: ["sh", "-c", "while true; do echo \"$(date) - App running\" >> /var/log/app.log; sleep 5; done"]
    volumeMounts:
    - name: shared-logs
      mountPath: /var/log
  - name: log-reader
    image: busybox:1.36
    command: ["sh", "-c", "tail -f /var/log/app.log"]
    volumeMounts:
    - name: shared-logs
      mountPath: /var/log
  volumes:
  - name: shared-logs
    emptyDir: {}
```

```bash
kubectl apply -f ./exam/course/20/sidecar-pod.yaml
```

Verify:

```bash
kubectl get pod logger-app -n stronghold
kubectl logs logger-app -c log-reader -n stronghold
```
