# CKAD Simulation 14 - Solutions (Dojo Raijin ⚡)

---

## Question 1 | Kubernetes Practice

```bash
mkdir -p ./exam/course/14/q1
cat <<EOF > ./exam/course/14/q1/Dockerfile
FROM nginx:1.23-alpine
HEALTHCHECK --interval=10s --timeout=3s --retries=3 \
  CMD curl -f http://localhost/ || exit 1
EOF
```

---

## Question 2 | Kubernetes Practice

```bash
mkdir -p ./exam/course/14/q2
cat <<EOF > ./exam/course/14/q2/pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: thunder-logger
  namespace: thunder
spec:
  containers:
  - name: app-container
    image: busybox
    command: ['sh', '-c', 'while true; do echo "INFO: Processing request"; sleep 2; echo "ERROR: Connection timeout"; sleep 3; done > /var/log/app.log']
    volumeMounts:
    - name: log-volume
      mountPath: /var/log
  - name: error-tailer
    image: busybox
    command: ['sh', '-c', 'tail -f /var/log/app.log | grep ERROR']
    volumeMounts:
    - name: log-volume
      mountPath: /var/log
  volumes:
  - name: log-volume
    emptyDir: {}
EOF
kubectl apply -f ./exam/course/14/q2/pod.yaml
```

---

## Question 3 | Kubernetes Practice

```bash
mkdir -p ./exam/course/14/q3
kubectl create cronjob lightning-strike -n bolt --image=busybox --schedule="*/5 * * * *" --dry-run=client -o yaml -- echo "Strike!" > ./exam/course/14/q3/cronjob.yaml
```

Modify `./exam/course/14/q3/cronjob.yaml` to add `startingDeadlineSeconds` and `successfulJobsHistoryLimit`:

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: lightning-strike
  namespace: bolt
spec:
  startingDeadlineSeconds: 15
  successfulJobsHistoryLimit: 2
  schedule: "*/5 * * * *"
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: lightning-strike
            image: busybox
            command:
            - echo
            - "Strike!"
          restartPolicy: OnFailure
```

```bash
kubectl apply -f ./exam/course/14/q3/cronjob.yaml
```

---

## Question 4 | Kubernetes Practice

```bash
mkdir -p ./exam/course/14/q4
cat <<EOF > ./exam/course/14/q4/pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: app-with-wait
  namespace: storm
spec:
  initContainers:
  - name: wait-for-db
    image: busybox
    command: ['sh', '-c', 'until nslookup database-svc; do echo waiting for database; sleep 2; done;']
  containers:
  - name: main-app
    image: nginx:alpine
EOF
kubectl apply -f ./exam/course/14/q4/pod.yaml
```

---

## Question 5 | Kubernetes Practice

```bash
mkdir -p ./exam/course/14/q5
helm template thunder-web /opt/course/14/q5/chart --namespace surge --set replicaCount=3 --set image.tag=latest > ./exam/course/14/q5/output.yaml
```

---

## Question 6 | Kubernetes Practice

```bash
kubectl rollout undo deployment api-gateway -n voltage --to-revision=1
```

---

## Question 7 | Kubernetes Practice

```bash
mkdir -p ./exam/course/14/q7
kubectl get deployment backend-v1 -n spark -o yaml > ./exam/course/14/q7/backend-v2.yaml
```

Modify `./exam/course/14/q7/backend-v2.yaml` to change name, replicas to 1, and pod template image to `nginx:1.23`. Keep the labels identical so the service matches it.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend-v2
  namespace: spark
spec:
  replicas: 1
  selector:
    matchLabels:
      app: backend
  template:
    metadata:
      labels:
        app: backend
    spec:
      containers:
      - name: nginx
        image: nginx:1.23
```

```bash
kubectl apply -f ./exam/course/14/q7/backend-v2.yaml
```

---

## Question 8 | Kubernetes Practice

```bash
cat <<EOF > ./exam/course/14/q8/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
- deployment.yaml
patchesStrategicMerge:
- patch.yaml
EOF

cat <<EOF > ./exam/course/14/q8/patch.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-worker
spec:
  template:
    spec:
      containers:
      - name: worker
        env:
        - name: APP_ENV
          value: production
EOF

kubectl apply -k ./exam/course/14/q8/ -n charge
```

---

## Question 9 | Kubernetes Practice

Find out why the pod is crashing:

```bash
kubectl get pod data-processor -n flash
kubectl describe pod data-processor -n flash
kubectl logs data-processor -n flash
```

Edit the pod or deployment to fix the error (e.g. correct the command/args or fix the readiness/liveness probe port).

```bash
kubectl edit pod data-processor -n flash
```

---

## Question 10 | Kubernetes Practice

```bash
mkdir -p ./exam/course/14/q10
kubectl get events -n strike --sort-by='.metadata.creationTimestamp' > ./exam/course/14/q10/events.txt
```

---

## Question 11 | Kubernetes Practice

```bash
mkdir -p ./exam/course/14/q11
cat <<EOF > ./exam/course/14/q11/pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: complex-app
  namespace: plasma
spec:
  containers:
  - name: complex-app
    image: nginx:alpine
    ports:
    - containerPort: 80
    startupProbe:
      httpGet:
        path: /
        port: 80
      failureThreshold: 30
      periodSeconds: 1
    livenessProbe:
      tcpSocket:
        port: 80
      periodSeconds: 10
    readinessProbe:
      httpGet:
        path: /
        port: 80
      periodSeconds: 5
      initialDelaySeconds: 5
EOF
kubectl apply -f ./exam/course/14/q11/pod.yaml
```

---

## Question 12 | Kubernetes Practice

```bash
mkdir -p ./exam/course/14/q12
cat <<EOF > ./exam/course/14/q12/pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: env-info
  namespace: thunder
spec:
  containers:
  - name: env-info
    image: busybox
    command: ['sleep', '3600']
    env:
    - name: POD_NAME
      valueFrom:
        fieldRef:
          fieldPath: metadata.name
    - name: POD_NAMESPACE
      valueFrom:
        fieldRef:
          fieldPath: metadata.namespace
EOF
kubectl apply -f ./exam/course/14/q12/pod.yaml
```

---

## Question 13 | Kubernetes Practice

```bash
mkdir -p ./exam/course/14/q13
cat <<EOF > ./exam/course/14/q13/pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: secure-net
  namespace: bolt
spec:
  containers:
  - name: secure-net
    image: alpine
    command: ["sleep", "1d"]
    securityContext:
      capabilities:
        add: ["NET_ADMIN"]
        drop: ["ALL"]
EOF
kubectl apply -f ./exam/course/14/q13/pod.yaml
```

---

## Question 14 | Kubernetes Practice

```bash
mkdir -p ./exam/course/14/q14
cat <<EOF > ./exam/course/14/q14/secret.yaml
apiVersion: v1
kind: Secret
metadata:
  name: db-credentials
  namespace: storm
type: Opaque
stringData:
  username: admin
  password: supersecret123
EOF
kubectl apply -f ./exam/course/14/q14/secret.yaml
```

---

## Question 15 | Kubernetes Practice

```bash
mkdir -p ./exam/course/14/q15
kubectl create configmap app-args --from-literal=mode=verbose -n voltage
cat <<EOF > ./exam/course/14/q15/pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: arg-reader
  namespace: voltage
spec:
  containers:
  - name: arg-reader
    image: busybox
    command: ["echo"]
    args: ["\$(MODE)"]
    env:
    - name: MODE
      valueFrom:
        configMapKeyRef:
          name: app-args
          key: mode
  restartPolicy: Never
EOF
kubectl apply -f ./exam/course/14/q15/pod.yaml
```

---

## Question 16 | Kubernetes Practice

```bash
kubectl create serviceaccount app-sa -n spark
kubectl create clusterrole secret-reader --verb=get,watch,list --resource=secrets
kubectl create clusterrolebinding secret-reader-binding --clusterrole=secret-reader --serviceaccount=spark:app-sa
```

---

## Question 17 | Kubernetes Practice

```bash
mkdir -p ./exam/course/14/q17
cat <<EOF > ./exam/course/14/q17/netpol.yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: strict-ingress
  namespace: charge
spec:
  podSelector:
    matchLabels:
      role: db
  policyTypes:
  - Ingress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          env: prod
      podSelector:
        matchLabels:
          role: api
    ports:
    - protocol: TCP
      port: 3306
EOF
kubectl apply -f ./exam/course/14/q17/netpol.yaml
```

---

## Question 18 | Kubernetes Practice

```bash
mkdir -p ./exam/course/14/q18
cat <<EOF > ./exam/course/14/q18/ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: default-ing
  namespace: surge
spec:
  defaultBackend:
    service:
      name: fallback-svc
      port:
        number: 8080
EOF
kubectl apply -f ./exam/course/14/q18/ingress.yaml
```

---

## Question 19 | Kubernetes Practice

```bash
mkdir -p ./exam/course/14/q19
cat <<EOF > ./exam/course/14/q19/svc.yaml
apiVersion: v1
kind: Service
metadata:
  name: sticky-svc
  namespace: flash
spec:
  selector:
    app: sticky
  ports:
    - protocol: TCP
      port: 80
      targetPort: 8080
  sessionAffinity: ClientIP
  sessionAffinityConfig:
    clientIP:
      timeoutSeconds: 10800
EOF
kubectl apply -f ./exam/course/14/q19/svc.yaml
```

---

## Question 20 | Kubernetes Practice

```bash
mkdir -p ./exam/course/14/q20
kubectl port-forward pod/hidden-api 9090:8080 -n strike &
sleep 2
curl http://localhost:9090/status > ./exam/course/14/q20/response.txt
fg
# Use Ctrl+C to kill the port-forward process
```
