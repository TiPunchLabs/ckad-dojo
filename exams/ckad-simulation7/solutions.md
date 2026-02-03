# CKAD Simulation 7 - Solutions (Dojo Tanuki 🦝)

> **Total Score**: 100 points | **Passing Score**: ~66% (66 points)
>
> **Original Questions**: Adapted from [CKAD-exercises](https://github.com/dgkanatsios/CKAD-exercises) by [@dgkanatsios](https://github.com/dgkanatsios)

---

## Question 1 | Pod with Exposed Port (4 points)

### Solution

```bash
kubectl run nginx --image=nginx --restart=Never --port=80 --expose -n grove
```

This creates both a Pod and a ClusterIP Service.

Verify:

```bash
kubectl get pod nginx -n grove
kubectl get svc nginx -n grove
kubectl get ep nginx -n grove
```

---

## Question 2 | Get Pod IP and Test Connectivity (5 points)

### Solution

```bash
# Create the Pod
kubectl run web --image=nginx --restart=Never -n thicket

# Get the Pod IP and save to file
mkdir -p ./exam/course/2
kubectl get pod web -n thicket -o jsonpath='{.status.podIP}' > ./exam/course/2/pod-ip.txt

# Test connectivity
IP=$(cat ./exam/course/2/pod-ip.txt)
kubectl run busybox --rm -it --restart=Never --image=busybox -n thicket -- wget -O- $IP:80
```

---

## Question 3 | Pod Logs (4 points)

### Solution

```bash
# Create the Pod
kubectl run logger --image=busybox --restart=Never -n glade -- /bin/sh -c 'i=0; while true; do echo "$i: $(date)"; i=$((i+1)); sleep 1; done'

# Wait for Pod to start
kubectl wait --for=condition=Ready pod/logger -n glade --timeout=30s

# Save logs (first 10 lines)
mkdir -p ./exam/course/3
kubectl logs logger -n glade | head -10 > ./exam/course/3/logs.txt
```

---

## Question 4 | Debug Pod with Error (5 points)

### Solution

```bash
# Create the Pod with error command
kubectl run debug-pod --image=busybox --restart=Never -n meadow -- ls /notexist

# Wait a moment for the Pod to complete
sleep 2

# Get logs and save
mkdir -p ./exam/course/4
kubectl logs debug-pod -n meadow > ./exam/course/4/error.txt 2>&1
```

---

## Question 5 | Pod with Node Selector (6 points)

### Solution

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: gpu-pod
  namespace: fern
spec:
  nodeSelector:
    accelerator: nvidia
  containers:
  - name: nginx
    image: nginx
```

```bash
kubectl apply -f gpu-pod.yaml
```

---

## Question 6 | Pod with Tolerations (6 points)

### Solution

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: tolerate-pod
  namespace: moss
spec:
  containers:
  - name: nginx
    image: nginx
  tolerations:
  - key: "tier"
    operator: "Equal"
    value: "frontend"
    effect: "NoSchedule"
```

```bash
kubectl apply -f tolerate-pod.yaml
```

---

## Question 7 | Deployment with Replicas (5 points)

### Solution

```bash
kubectl create deployment app-deploy --image=nginx:1.18.0 --replicas=3 --port=80 -n root
```

Or using YAML:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-deploy
  namespace: root
spec:
  replicas: 3
  selector:
    matchLabels:
      app: app-deploy
  template:
    metadata:
      labels:
        app: app-deploy
    spec:
      containers:
      - name: nginx
        image: nginx:1.18.0
        ports:
        - containerPort: 80
```

---

## Question 8 | Scale Deployment (4 points)

### Solution

```bash
kubectl scale deployment app-deploy --replicas=5 -n root
```

Verify:

```bash
kubectl get deployment app-deploy -n root
kubectl get pods -n root -l app=app-deploy
```

---

## Question 9 | Horizontal Pod Autoscaler (6 points)

### Solution

```bash
kubectl autoscale deployment app-deploy --min=5 --max=10 --cpu-percent=80 -n root
```

Verify:

```bash
kubectl get hpa app-deploy -n root
```

---

## Question 10 | Deployment Rollout Pause and Resume (6 points)

### Solution

```bash
# Pause the rollout
kubectl rollout pause deployment/pause-deploy -n bark

# Update the image
kubectl set image deployment/pause-deploy nginx=nginx:1.19.0 -n bark

# Check rollout history (no new revision should appear)
kubectl rollout history deployment/pause-deploy -n bark

# Resume the rollout
kubectl rollout resume deployment/pause-deploy -n bark

# Verify the image
kubectl describe deployment pause-deploy -n bark | grep Image
```

---

## Question 11 | Job with Parallelism (5 points)

### Solution

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: parallel-job
  namespace: canopy
spec:
  parallelism: 5
  template:
    spec:
      containers:
      - name: busybox
        image: busybox
        command: ["/bin/sh", "-c", "echo hello; sleep 5; echo world"]
      restartPolicy: Never
```

```bash
kubectl apply -f parallel-job.yaml
```

---

## Question 12 | Job with Active Deadline (5 points)

### Solution

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: deadline-job
  namespace: hollow
spec:
  activeDeadlineSeconds: 30
  template:
    spec:
      containers:
      - name: busybox
        image: busybox
        command: ["/bin/sh", "-c", "while true; do echo hello; sleep 10; done"]
      restartPolicy: Never
```

```bash
kubectl apply -f deadline-job.yaml
```

---

## Question 13 | CronJob with Starting Deadline (5 points)

### Solution

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: deadline-cron
  namespace: grove
spec:
  schedule: "* * * * *"
  startingDeadlineSeconds: 17
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: busybox
            image: busybox
            command: ["/bin/sh", "-c", "date; echo Hello from CronJob"]
          restartPolicy: Never
```

```bash
kubectl apply -f deadline-cron.yaml
```

---

## Question 14 | Create Job from CronJob (4 points)

### Solution

```bash
# Create the CronJob
kubectl create cronjob source-cron --image=busybox --schedule="*/5 * * * *" -n thicket -- echo "source job"

# Create a Job from the CronJob
kubectl create job manual-job --from=cronjob/source-cron -n thicket
```

---

## Question 15 | ConfigMap from File (5 points)

### Solution

```bash
# Create the file
mkdir -p ./exam/course/15
echo -e "foo3=lili\nfoo4=lele" > ./exam/course/15/config.txt

# Create ConfigMap from file
kubectl create configmap file-config --from-file=./exam/course/15/config.txt -n glade
```

Verify:

```bash
kubectl get configmap file-config -n glade -o yaml
```

---

## Question 16 | ConfigMap with envFrom (5 points)

### Solution

```bash
# Create ConfigMap
kubectl create configmap env-config --from-literal=var6=val6 --from-literal=var7=val7 -n meadow
```

```yaml
# Create Pod
apiVersion: v1
kind: Pod
metadata:
  name: env-pod
  namespace: meadow
spec:
  containers:
  - name: nginx
    image: nginx
    envFrom:
    - configMapRef:
        name: env-config
```

```bash
kubectl apply -f env-pod.yaml
kubectl exec -n meadow env-pod -- env | grep var
```

---

## Question 17 | Secret from File (5 points)

### Solution

```bash
# Create the file
mkdir -p ./exam/course/17
echo -n "admin" > ./exam/course/17/username

# Create Secret from file
kubectl create secret generic file-secret --from-file=./exam/course/17/username -n fern
```

Verify:

```bash
kubectl get secret file-secret -n fern -o yaml
```

---

## Question 18 | Secret as Environment Variable (5 points)

### Solution

```bash
# Create Secret
kubectl create secret generic api-secret --from-literal=API_KEY=LmLHbYhsgWZwNifiqaRorH8T -n moss
```

```yaml
# Create Pod
apiVersion: v1
kind: Pod
metadata:
  name: api-pod
  namespace: moss
spec:
  containers:
  - name: nginx
    image: nginx
    env:
    - name: API_KEY
      valueFrom:
        secretKeyRef:
          name: api-secret
          key: API_KEY
```

```bash
kubectl apply -f api-pod.yaml
kubectl exec -n moss api-pod -- env | grep API_KEY
```

---

## Question 19 | ServiceAccount and Pod (5 points)

### Solution

```bash
# Create ServiceAccount
kubectl create serviceaccount app-sa -n root
```

```yaml
# Create Pod
apiVersion: v1
kind: Pod
metadata:
  name: sa-pod
  namespace: root
spec:
  serviceAccountName: app-sa
  containers:
  - name: nginx
    image: nginx
```

```bash
kubectl apply -f sa-pod.yaml
kubectl get pod sa-pod -n root -o jsonpath='{.spec.serviceAccountName}'
```

---

## Question 20 | Copy File from Pod (5 points)

### Solution

```bash
# Create Pod
kubectl run copy-pod --image=busybox --restart=Never -n bark -- sleep 3600

# Wait for Pod to be ready
kubectl wait --for=condition=Ready pod/copy-pod -n bark --timeout=30s

# Copy file from Pod
mkdir -p ./exam/course/20
kubectl cp bark/copy-pod:/etc/passwd ./exam/course/20/passwd
```

Verify:

```bash
cat ./exam/course/20/passwd
```
