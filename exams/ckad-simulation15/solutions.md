# CKAD Simulation 15 - Solutions (Dojo Susanoo 🌊)

---

## Question 1 | Kubernetes Practice

**Explanation:**
You need to modify the `Dockerfile` to use a multi-stage build. This involves adding a second `FROM` instruction and copying the built artifact from the first stage.

**Solution:**
```bash
cat <<EOF > ./exam/course/1/Dockerfile
FROM golang:1.20-alpine AS builder
WORKDIR /app
COPY main.go .
RUN go build -o app main.go

FROM alpine:3.18
WORKDIR /app
COPY --from=builder /app/app .
CMD ["./app"]
EOF
```

---

## Question 2 | Kubernetes Practice

**Explanation:**
Create a Pod with two containers sharing an `emptyDir` volume. The main container writes logs to a file in the volume, and the sidecar container tails that file.

**Solution:**
```bash
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: log-generator
  namespace: tide
spec:
  containers:
  - name: app
    image: busybox
    command: ["sh", "-c", "while true; do echo \"\$(date) - Application log\" >> /var/log/app/app.log; sleep 5; done"]
    volumeMounts:
    - name: shared-logs
      mountPath: /var/log/app
  - name: sidecar
    image: busybox
    command: ["sh", "-c", "tail -f /var/log/app/app.log"]
    volumeMounts:
    - name: shared-logs
      mountPath: /var/log/app
  volumes:
  - name: shared-logs
    emptyDir: {}
EOF
```

---

## Question 3 | Kubernetes Practice

**Explanation:**
Create a CronJob with `failedJobsHistoryLimit` and `suspend` properties set.

**Solution:**
```bash
cat <<EOF | kubectl apply -f -
apiVersion: batch/v1
kind: CronJob
metadata:
  name: data-sync
  namespace: coral
spec:
  schedule: "*/10 * * * *"
  failedJobsHistoryLimit: 5
  suspend: true
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: sync
            image: busybox
            command:
            - echo
            - "Syncing data..."
          restartPolicy: OnFailure
EOF
```

---

## Question 4 | Kubernetes Practice

**Explanation:**
Create a Pod for a batch task. The key here is setting the `restartPolicy` to `OnFailure` instead of the default `Always`.

**Solution:**
```bash
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: batch-worker
  namespace: abyss
spec:
  restartPolicy: OnFailure
  containers:
  - name: worker
    image: busybox
    command: ["sh", "-c", "echo \"Processing batch\"; exit 1"]
EOF
```

---

## Question 5 | Kubernetes Practice

**Explanation:**
Uninstall a Helm release from a specific namespace.

**Solution:**
```bash
helm uninstall ocean-api -n current
```

---

## Question 6 | Kubernetes Practice

**Explanation:**
Create a Deployment and configure its rolling update strategy attributes.

**Solution:**
```bash
kubectl create deployment web-deploy --image=nginx:1.23 --replicas=4 -n reef --dry-run=client -o yaml > deploy.yaml
```
Edit `deploy.yaml` to add the strategy:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-deploy
  namespace: reef
spec:
  replicas: 4
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 50%
      maxUnavailable: 25%
  selector:
    matchLabels:
      app: web-deploy
  template:
    metadata:
      labels:
        app: web-deploy
    spec:
      containers:
      - name: nginx
        image: nginx:1.23
```
```bash
kubectl apply -f deploy.yaml
```

---

## Question 7 | Kubernetes Practice

**Explanation:**
Perform updates to a Deployment to generate history, then roll back to a specific revision.

**Solution:**
```bash
# Update to nginx:1.24 and record cause
kubectl set image deployment/api-server nginx=nginx:1.24 -n lagoon
kubectl annotate deployment api-server kubernetes.io/change-cause="update to 1.24" -n lagoon

# Update to nginx:1.25 and record cause
kubectl set image deployment/api-server nginx=nginx:1.25 -n lagoon
kubectl annotate deployment api-server kubernetes.io/change-cause="update to 1.25" -n lagoon

# Check history
kubectl rollout history deployment/api-server -n lagoon

# Find the revision with 1.24 (let's assume it's revision 2)
# Rollback
kubectl rollout undo deployment/api-server --to-revision=2 -n lagoon
```

---

## Question 8 | Kubernetes Practice

**Explanation:**
Create Kustomize resources with common labels and annotations.

**Solution:**
```bash
cd ./exam/course/8/
kubectl create deployment app-deploy --image=nginx --dry-run=client -o yaml > deployment.yaml
kubectl create service clusterip app-svc --tcp=80:80 --dry-run=client -o yaml > service.yaml

cat <<EOF > kustomization.yaml
resources:
- deployment.yaml
- service.yaml

commonLabels:
  env: production
  team: alpha

commonAnnotations:
  release: v1.0.0
EOF

kubectl apply -k . -n trench
```

---

## Question 9 | Kubernetes Practice

**Explanation:**
Fix the image of a Pod stuck in ErrImagePull. It's often easiest to recreate the pod.

**Solution:**
```bash
kubectl get pod backend-pod -n wave -o yaml > pod.yaml
# Edit pod.yaml to change image from wrongregistry.k8s.io/nginx:alpine to nginx:alpine
sed -i 's/wrongregistry.k8s.io\/nginx:alpine/nginx:alpine/g' pod.yaml
kubectl delete pod backend-pod -n wave
kubectl apply -f pod.yaml
```

---

## Question 10 | Kubernetes Practice

**Explanation:**
Retrieve events, filter for Warnings, and save to a file.

**Solution:**
```bash
kubectl get events -n depths --field-selector type=Warning > ./exam/course/10/events.txt
```

---

## Question 11 | Kubernetes Practice

**Explanation:**
Configure a gRPC liveness probe.

**Solution:**
```bash
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: grpc-checker
  namespace: ocean
spec:
  containers:
  - name: app
    image: nginx:1.24
    livenessProbe:
      grpc:
        port: 8080
      initialDelaySeconds: 5
      periodSeconds: 10
EOF
```

---

## Question 12 | Kubernetes Practice

**Explanation:**
Create a ConfigMap from a directory and mount it as a volume in a Pod.

**Solution:**
```bash
kubectl create configmap app-config-dir --from-file=./exam/course/12/config-files/ -n tide

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: config-consumer
  namespace: tide
spec:
  containers:
  - name: app
    image: alpine
    command: ["sleep", "3600"]
    volumeMounts:
    - name: config-vol
      mountPath: /etc/config
  volumes:
  - name: config-vol
    configMap:
      name: app-config-dir
EOF
```

---

## Question 13 | Kubernetes Practice

**Explanation:**
Create a Secret and expose its values as environment variables.

**Solution:**
```bash
kubectl create secret generic db-credentials --from-literal=username=admin --from-literal=password=supersecretpassword -n coral

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: secret-env-pod
  namespace: coral
spec:
  containers:
  - name: app
    image: nginx
    env:
    - name: DB_USER
      valueFrom:
        secretKeyRef:
          name: db-credentials
          key: username
    - name: DB_PASS
      valueFrom:
        secretKeyRef:
          name: db-credentials
          key: password
EOF
```

---

## Question 14 | Kubernetes Practice

**Explanation:**
Apply SecurityContext to a Pod and create a NetworkPolicy to deny ingress.

**Solution:**
```bash
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: secure-pod
  namespace: abyss
  labels:
    app: secure
spec:
  securityContext:
    runAsUser: 1000
    runAsGroup: 3000
  containers:
  - name: app
    image: busybox
    command: ["sleep", "3600"]
    securityContext:
      allowPrivilegeEscalation: false
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: secure-policy
  namespace: abyss
spec:
  podSelector:
    matchLabels:
      app: secure
  policyTypes:
  - Ingress
  - Egress
  egress:
  - {}
EOF
```

---

## Question 15 | Kubernetes Practice

**Explanation:**
Use `kubectl debug` to attach an ephemeral container.

**Solution:**
```bash
kubectl debug -it target-pod -n reef --image=busybox --target=web -- custom-command
# Alternatively, without interacting:
kubectl debug target-pod -n reef --image=busybox --container=debug-container
```

---

## Question 16 | Kubernetes Practice

**Explanation:**
Create a Deployment and a PodDisruptionBudget.

**Solution:**
```bash
kubectl create deployment critical-app --image=nginx --replicas=3 -n lagoon
kubectl label deployment critical-app tier=critical -n lagoon
# Label applies to pods automatically from deployment template if created this way? 
# Wait, kubectl create deployment adds app=critical-app label. To add tier=critical to pods, we need to patch or recreate.
# It's better to use YAML.

cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: critical-app
  namespace: lagoon
spec:
  replicas: 3
  selector:
    matchLabels:
      tier: critical
  template:
    metadata:
      labels:
        tier: critical
    spec:
      containers:
      - name: nginx
        image: nginx
---
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: critical-pdb
  namespace: lagoon
spec:
  minAvailable: 2
  selector:
    matchLabels:
      tier: critical
EOF
```

---

## Question 17 | Kubernetes Practice

**Explanation:**
Create a default deny-all NetworkPolicy and a specific allow NetworkPolicy.

**Solution:**
```bash
cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all
  namespace: trench
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-web
  namespace: trench
spec:
  podSelector:
    matchLabels:
      role: web
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - ports:
    - protocol: TCP
      port: 80
  egress:
  - {}
EOF
```

---

## Question 18 | Kubernetes Practice

**Explanation:**
Fix the Service selector to match the Pod's labels.

**Solution:**
```bash
kubectl edit service mesh-service -n wave
# Change selector from app: wrong-label to app: mesh-app
```

---

## Question 19 | Kubernetes Practice

**Explanation:**
Create a multi-port Service.

**Solution:**
```bash
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: multi-port-svc
  namespace: depths
spec:
  selector:
    app: multi-app
  ports:
  - name: http
    port: 80
    targetPort: 8080
    protocol: TCP
  - name: dns
    port: 53
    targetPort: 5353
    protocol: UDP
EOF
```

---

## Question 20 | Kubernetes Practice

**Explanation:**
Create an Ingress with an annotation for rewrite-target.

**Solution:**
```bash
cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: rewrite-ingress
  namespace: ocean
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /\$2
spec:
  ingressClassName: nginx
  rules:
  - host: susanoo.com
    http:
      paths:
      - path: /api(/|$)(.*)
        pathType: ImplementationSpecific
        backend:
          service:
            name: api-service
            port:
              number: 80
EOF
```
