# CKAD Exam Simulator - Dojo Ryujin 🐲 - Solutions

> **Original Questions**: Adapted from [CKAD-exercises](https://github.com/dgkanatsios/CKAD-exercises) by [@dgkanatsios](https://github.com/dgkanatsios)

---

## Question 1 | Helm Create Chart

```bash
# Create directory if needed
mkdir -p ./exam/course/1

# Create the Helm chart
cd ./exam/course/1
helm create sea-app
```

---

## Question 2 | Helm Install with Custom Values

```bash
# Add bitnami repo if not already added
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

# Install with custom values
helm install my-release bitnami/nginx -n tide --set replicaCount=2
```

---

## Question 3 | Helm Upgrade Release

```bash
# Upgrade the release with new replica count
helm upgrade my-release bitnami/nginx -n tide --set replicaCount=3
```

---

## Question 4 | Helm Rollback

```bash
# Check current revision
helm history rollback-app -n wave

# Rollback to revision 1
helm rollback rollback-app 1 -n wave
```

---

## Question 5 | PersistentVolume Creation

```bash
# Create PersistentVolume YAML
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: PersistentVolume
metadata:
  name: sea-pv
spec:
  capacity:
    storage: 5Gi
  accessModes:
    - ReadWriteOnce
  storageClassName: manual
  hostPath:
    path: /data/sea
EOF
```

---

## Question 6 | PersistentVolumeClaim

```bash
# Create PVC YAML
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: sea-pvc
  namespace: depths
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: manual
  resources:
    requests:
      storage: 2Gi
EOF
```

---

## Question 7 | Pod with PVC

```bash
# Create Pod with PVC mount
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: pvc-pod
  namespace: depths
spec:
  containers:
  - name: busybox
    image: busybox
    command: ["sleep", "3600"]
    volumeMounts:
    - name: data-volume
      mountPath: /data
  volumes:
  - name: data-volume
    persistentVolumeClaim:
      claimName: sea-pvc
EOF
```

---

## Question 8 | Pod with nodeName

```bash
# Get the first node name
NODE=$(kubectl get nodes -o jsonpath='{.items[0].metadata.name}')

# Create Pod with nodeName
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: direct-pod
  namespace: coral
spec:
  nodeName: $NODE
  containers:
  - name: nginx
    image: nginx
EOF
```

---

## Question 9 | Pod Lifecycle - Echo and Exit

```bash
# Create Pod that echoes and exits
kubectl run echo-pod -n current --image=busybox --restart=Never -- /bin/sh -c 'echo "hello world"'

# Alternatively with --rm flag (auto-delete after completion)
kubectl run echo-pod -n current --image=busybox --restart=Never --rm -it -- /bin/sh -c 'echo "hello world"'
```

---

## Question 10 | Get Pod YAML

```bash
# Create directory
mkdir -p ./exam/course/10

# Create the Pod
kubectl run inspect-pod --image=nginx -n abyss

# Export YAML
kubectl get pod inspect-pod -n abyss -o yaml > ./exam/course/10/pod.yaml
```

---

## Question 11 | Describe Pod and Find Events

```bash
# Create directory
mkdir -p ./exam/course/11

# Describe the Pod and extract Events section
kubectl describe pod problem-pod -n pearl | sed -n '/^Events:/,$p' > ./exam/course/11/events.txt
```

---

## Question 12 | Execute Command in Pod

```bash
# Create directory
mkdir -p ./exam/course/12

# Create the Pod
kubectl run exec-pod --image=nginx -n storm

# Wait for Pod to be ready
kubectl wait --for=condition=Ready pod/exec-pod -n storm --timeout=60s

# Execute hostname and save output
kubectl exec exec-pod -n storm -- hostname > ./exam/course/12/hostname.txt
```

---

## Question 13 | Get Previous Container Logs

```bash
# Create directory
mkdir -p ./exam/course/13

# Get previous container logs
kubectl logs restart-pod -n harbor --previous > ./exam/course/13/previous.txt
```

---

## Question 14 | Top Nodes

```bash
# Create directory
mkdir -p ./exam/course/14

# Get node resource utilization
kubectl top nodes > ./exam/course/14/nodes.txt
```

---

## Question 15 | ConfigMap from .env File

```bash
# Create directory
mkdir -p ./exam/course/15

# Create the .env file
cat > ./exam/course/15/config.env << 'EOF'
DB_HOST=localhost
DB_PORT=5432
EOF

# Create ConfigMap from .env file
kubectl create configmap env-config -n voyage --from-env-file=./exam/course/15/config.env
```

---

## Question 16 | Deployment Rollout to Specific Revision

```bash
# Check rollout history
kubectl rollout history deployment/web-deploy -n tide

# Rollback to revision 2
kubectl rollout undo deployment/web-deploy -n tide --to-revision=2
```

---

## Question 17 | Check Rollout History Details

```bash
# Create directory
mkdir -p ./exam/course/17

# Get details of revision 3
kubectl rollout history deployment/history-deploy -n wave --revision=3 > ./exam/course/17/revision.txt
```

---

## Question 18 | Job with Perl Image

```bash
# Create Job to calculate Pi
cat <<EOF | kubectl apply -f -
apiVersion: batch/v1
kind: Job
metadata:
  name: pi-job
  namespace: coral
spec:
  template:
    spec:
      containers:
      - name: pi
        image: perl:5.34
        command: ["perl", "-Mbignum=bpi", "-wle", "print bpi(100)"]
      restartPolicy: Never
  backoffLimit: 4
EOF

# Or using kubectl create job
kubectl create job pi-job -n coral --image=perl:5.34 -- perl -Mbignum=bpi -wle 'print bpi(100)'
```

---

## Question 19 | Multi-Container Pod with Shared Volume

```bash
# Create multi-container Pod with sidecar pattern
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: sidecar-pod
  namespace: abyss
spec:
  containers:
  - name: app
    image: busybox
    command: ["/bin/sh", "-c"]
    args: ["while true; do echo \"\$(date)\" >> /logs/app.log; sleep 5; done"]
    volumeMounts:
    - name: log-volume
      mountPath: /logs
  - name: sidecar
    image: busybox
    command: ["/bin/sh", "-c"]
    args: ["tail -f /logs/app.log"]
    volumeMounts:
    - name: log-volume
      mountPath: /logs
  volumes:
  - name: log-volume
    emptyDir: {}
EOF
```

---

## Question 20 | Resource Utilization of Pods

```bash
# Create directory
mkdir -p ./exam/course/20

# Get Pod resource utilization in storm namespace
kubectl top pods -n storm > ./exam/course/20/top-pods.txt
```
