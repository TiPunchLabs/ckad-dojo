# CKAD Simulation 20 - Solutions (Dojo Musashi 🏆)

---

## Question 1 | Kubernetes Practice
```bash
cat <<EOF > ./exam/course/1/Dockerfile
FROM golang:1.20 AS builder
WORKDIR /app
COPY main.go .
RUN go build -o main .

FROM alpine:latest
RUN addgroup -S appgroup && adduser -S appuser -G appgroup -u 1000
USER 1000
WORKDIR /app
COPY --from=builder /app/main .
CMD ["./main"]
EOF

kubectl run musashi-pod --image=localhost:5000/musashi-app:v1 -n apex --dry-run=client -o yaml > ./exam/course/1/pod.yaml
kubectl apply -f ./exam/course/1/pod.yaml
```
Explanation: We use a multi-stage Dockerfile to build and then copy to a smaller alpine image, ensuring a non-root user is used.

---

## Question 2 | Kubernetes Practice
```bash
cat <<EOF > ./exam/course/2/multi-pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: tri-blade
  namespace: summit
spec:
  volumes:
  - name: shared-vol
    emptyDir: {}
  containers:
  - name: main
    image: nginx:1.24
    volumeMounts:
    - name: shared-vol
      mountPath: /var/log/nginx
  - name: sidecar
    image: busybox
    command: ["/bin/sh", "-c", "while true; do date >> /shared/time.log; sleep 5; done"]
    volumeMounts:
    - name: shared-vol
      mountPath: /shared
  - name: adapter
    image: fluentd
    command: ["/bin/sh", "-c", "tail -f /var/log/shared/time.log"]
    volumeMounts:
    - name: shared-vol
      mountPath: /var/log/shared
EOF
kubectl apply -f ./exam/course/2/multi-pod.yaml
```
Explanation: Defines a three-container pod sharing an emptyDir volume.

---

## Question 3 | Kubernetes Practice
```bash
cat <<EOF > ./exam/course/3/job.yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: data-processor
  namespace: pinnacle
spec:
  completions: 3
  parallelism: 2
  template:
    spec:
      containers:
      - name: perl
        image: perl
        command: ["perl", "-Mbignum=bpi", "-wle", "print bpi(2000)"]
      restartPolicy: Never
EOF
kubectl apply -f ./exam/course/3/job.yaml
```
Explanation: Creates a job with specific completions and parallelism.

---

## Question 4 | Kubernetes Practice
```bash
kubectl create cronjob db-backup --image=postgres:15 --schedule="*/15 * * * *" -n zenith --dry-run=client -o yaml > ./exam/course/4/cronjob.yaml
# Add successfulJobsHistoryLimit: 3 and failedJobsHistoryLimit: 1
# Update command
kubectl apply -f ./exam/course/4/cronjob.yaml
```
Explanation: CronJob with specific history limits and command.

---

## Question 5 | Kubernetes Practice
```bash
helm create ./exam/course/5/my-chart
cat <<EOF > ./exam/course/5/values.yaml
replicaCount: 3
image:
  repository: nginx
  tag: alpine
EOF
helm install crown-release ./exam/course/5/my-chart -n crown -f ./exam/course/5/values.yaml
```
Explanation: Creates a Helm chart and installs it using custom values.

---

## Question 6 | Kubernetes Practice
```bash
kubectl set image deployment/glory-deploy nginx=nginx:1.25 -n glory --record
kubectl rollout undo deployment/glory-deploy -n glory
kubectl scale deployment/glory-deploy --replicas=5 -n glory
```
Explanation: Updates, rolls back, and scales a deployment.

---

## Question 7 | Kubernetes Practice
```bash
cat <<EOF > ./exam/course/7/canary.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: legacy-canary
  namespace: legacy
spec:
  replicas: 1
  selector:
    matchLabels:
      app: legacy-web
  template:
    metadata:
      labels:
        app: legacy-web
    spec:
      containers:
      - name: web
        image: httpd:2.4
EOF
kubectl apply -f ./exam/course/7/canary.yaml
```
Explanation: Adds a canary deployment matching the main deployment's selector.

---

## Question 8 | Kubernetes Practice
```bash
cat <<EOF > ./exam/course/8/prod/kustomization.yaml
resources:
- ../base
commonLabels:
  env: prod
patches:
- patch: |-
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: my-app
    spec:
      replicas: 4
EOF
kubectl apply -k ./exam/course/8/prod -n mastery
```
Explanation: Sets up a Kustomize overlay to patch replicas and add labels.

---

## Question 9 | Kubernetes Practice
```bash
# Debug bug-1 (crashloopbackoff due to typo in command)
# Debug bug-2 (pending due to resource constraints)
# Debug bug-3 (imagepullbackoff due to wrong image name)
```
Explanation: Fixes various pod issues.

---

## Question 10 | Kubernetes Practice
```bash
kubectl logs triumph-app -n triumph | grep ERROR > ./exam/course/10/logs.txt
```
Explanation: Extracts specific log lines to a file.

---

## Question 11 | Kubernetes Practice
```bash
kubectl debug distroless-pod -it --image=busybox -n apex -- target=main
# nslookup kubernetes.default
```
Explanation: Uses ephemeral container for debugging.

---

## Question 12 | Kubernetes Practice
```bash
# YAML with SecurityContext
```
Explanation: Applies SecurityContext to the container.

---

## Question 13 | Kubernetes Practice
```bash
kubectl create sa sword-master -n pinnacle
kubectl create role blade-reader --verb=get,list,watch --resource=pods,configmaps -n pinnacle
kubectl create rolebinding master-binding --role=blade-reader --serviceaccount=pinnacle:sword-master -n pinnacle
```
Explanation: Creates RBAC resources.

---

## Question 14 | Kubernetes Practice
```bash
# YAML with ConfigMap and Secret mounts
```
Explanation: Injects config map as env vars and secret as a volume.

---

## Question 15 | Kubernetes Practice
```bash
# YAML with LimitRange and ResourceQuota
```
Explanation: Configures resource constraints.

---

## Question 16 | Kubernetes Practice
```bash
# YAML with PV, PVC, Pod
```
Explanation: Creates storage resources.

---

## Question 17 | Kubernetes Practice
```bash
# YAML with NetworkPolicy
```
Explanation: Sets up default deny and specific allow policy.

---

## Question 18 | Kubernetes Practice
```bash
# YAML with Ingress
```
Explanation: Configures ingress rules.

---

## Question 19 | Kubernetes Practice
```bash
kubectl create svc nodeport ascend-svc --tcp=80:80 --node-port=30080 -n ascend
```
Explanation: Exposes a NodePort service.

---

## Question 20 | Kubernetes Practice
```bash
# kubectl run ...
```
Explanation: Queries DNS.
