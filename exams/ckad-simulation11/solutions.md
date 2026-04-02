# CKAD Simulation 11 - Solutions (Dojo Amaterasu ☀️)

> **Total Score**: 104 points | **Passing Score**: ~66% (69 points)

---

## Question 1 | Build Container Image and Save as Tarball (6 points)

### Solution

```bash
# Build the image
docker build -t solar-app:1.0 ./exam/course/1/image/

# Verify
docker images solar-app:1.0

# Save as tarball
docker save -o ./exam/course/1/solar-app.tar solar-app:1.0

# Verify
ls -lh ./exam/course/1/solar-app.tar
```

---

## Question 2 | Create Deployment with Labels and Annotations (4 points)

### Solution

```bash
# Generate base YAML
kubectl create deployment frontend-app --image=nginx:1.25 --replicas=3 \
  -n solar --dry-run=client -o yaml > /tmp/frontend.yaml

# Edit to add labels, annotations, and container port, then apply
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend-app
  namespace: solar
  annotations:
    kubernetes.io/change-cause: "initial deployment"
spec:
  replicas: 3
  selector:
    matchLabels:
      app: frontend
      tier: web
  template:
    metadata:
      labels:
        app: frontend
        tier: web
    spec:
      containers:
        - name: web
          image: nginx:1.25
          ports:
            - containerPort: 80
EOF

# Verify
kubectl get deploy frontend-app -n solar
kubectl get pods -n solar -l app=frontend --show-labels
```

---

## Question 3 | Sidecar Container with Shared Volume (6 points)

### Solution

```bash
kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: web-with-sidecar
  namespace: corona
spec:
  volumes:
    - name: log-volume
      emptyDir: {}
  containers:
    - name: app
      image: nginx:1.25
      volumeMounts:
        - name: log-volume
          mountPath: /var/log/nginx
    - name: log-shipper
      image: busybox:1.36
      command: ["/bin/sh", "-c"]
      args: ["tail -f /var/log/nginx/access.log 2>/dev/null || sleep 3600"]
      volumeMounts:
        - name: log-volume
          mountPath: /var/log/nginx
EOF

# Verify
kubectl get pod web-with-sidecar -n corona
kubectl describe pod web-with-sidecar -n corona | grep -A5 Containers
```

---

## Question 4 | Create PVC and Mount in Pod (6 points)

### Solution

```bash
# Step 1: Create PVC
kubectl apply -f - <<EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: app-data-pvc
  namespace: aurora
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 500Mi
EOF

# Step 2: Create Pod using the PVC
kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: data-pod
  namespace: aurora
spec:
  containers:
    - name: web
      image: nginx:1.25
      volumeMounts:
        - name: data-vol
          mountPath: /usr/share/nginx/html
  volumes:
    - name: data-vol
      persistentVolumeClaim:
        claimName: app-data-pvc
EOF

# Verify
kubectl get pvc app-data-pvc -n aurora
kubectl get pod data-pod -n aurora
```

---

## Question 5 | Blue/Green Deployment (8 points)

### Solution

```bash
# Step 1: Create green deployment
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-green
  namespace: flare
spec:
  replicas: 3
  selector:
    matchLabels:
      app: webapp
      version: green
  template:
    metadata:
      labels:
        app: webapp
        version: green
    spec:
      containers:
        - name: web
          image: nginx:1.26
          ports:
            - containerPort: 80
EOF

# Step 2: Wait for green to be ready
kubectl rollout status deploy app-green -n flare

# Step 3: Switch service to green
kubectl patch svc webapp-svc -n flare -p '{"spec":{"selector":{"app":"webapp","version":"green"}}}'

# Step 4: Scale down blue
kubectl scale deploy app-blue -n flare --replicas=0

# Verify
kubectl get endpoints webapp-svc -n flare
kubectl get deploy -n flare
```

---

## Question 6 | Configure Rolling Update Strategy (6 points)

### Solution

```bash
kubectl edit deploy api-app -n dawn
```

Add/modify the strategy section:

```yaml
spec:
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
```

Then update the image:

```bash
kubectl set image deploy/api-app api=nginx:1.26 -n dawn

# Verify
kubectl rollout status deploy api-app -n dawn
kubectl get deploy api-app -n dawn -o jsonpath='{.spec.strategy}'
```

---

## Question 7 | Deploy with Kustomize (6 points)

### Solution

Create `./exam/course/7/kustomization.yaml`:

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - deployment.yaml
  - service.yaml

namePrefix: prod-

patches:
  - target:
      kind: Deployment
      name: web-app
    patch: |-
      - op: replace
        path: /spec/replicas
        value: 3
```

```bash
# Preview
kubectl kustomize ./exam/course/7/

# Apply
kubectl apply -k ./exam/course/7/

# Verify
kubectl get deploy prod-web-app -n zenith
kubectl get svc prod-web-svc -n zenith
```

---

## Question 8 | Helm Upgrade with Custom Values (4 points)

### Solution

```bash
# Inspect current values
helm get values web-release -n radiance

# Upgrade with new replica count
helm upgrade web-release bitnami/nginx -n radiance --set replicaCount=3 --reuse-values

# Verify
helm list -n radiance -f web-release
helm history web-release -n radiance
```

---

## Question 9 | Add Startup Probe (4 points)

### Solution

```bash
kubectl edit deploy slow-app -n eclipse
```

Add startup probe to the container:

```yaml
spec:
  template:
    spec:
      containers:
        - name: app
          startupProbe:
            httpGet:
              path: /healthz
              port: 8080
            failureThreshold: 30
            periodSeconds: 10
```

```bash
# Verify
kubectl rollout status deploy slow-app -n eclipse
kubectl describe deploy slow-app -n eclipse | grep -A5 Startup
```

---

## Question 10 | Troubleshoot Pending Pod (6 points)

### Solution

```bash
# Step 1: Identify the issue
kubectl describe pod stuck-pod -n solar
# Events show: "didn't match Pod's node affinity/selector"

# Step 2: Save the reason
echo "disktype" > ./exam/course/10/pending-reason.txt

# Step 3: Fix - Option A: Label a node
kubectl get nodes --show-labels
kubectl label node <node-name> disktype=ssd

# Step 3: Fix - Option B: Remove nodeSelector (delete and recreate)
kubectl get pod stuck-pod -n solar -o yaml > /tmp/stuck-pod.yaml
# Remove the nodeSelector section
kubectl delete pod stuck-pod -n solar
kubectl apply -f /tmp/stuck-pod.yaml

# Verify
kubectl get pod stuck-pod -n solar
```

---

## Question 11 | Extract Logs from Multi-container Pod (4 points)

### Solution

```bash
# Extract sidecar logs
kubectl logs multi-logger -n corona -c sidecar --tail=20 > ./exam/course/11/sidecar-logs.txt

# Verify
cat ./exam/course/11/sidecar-logs.txt
```

---

## Question 12 | Discover and Use Custom Resource Definition (6 points)

### Solution

```bash
# Step 1: Discover the CRD
kubectl get crd | grep backup
# Output: backups.ckad.example.com

# Step 2: Save the group
echo "ckad.example.com" > ./exam/course/12/crd-group.txt

# Step 3: Create a Backup custom resource
kubectl apply -f - <<EOF
apiVersion: ckad.example.com/v1
kind: Backup
metadata:
  name: daily-backup
  namespace: aurora
spec:
  schedule: "0 2 * * *"
  retentionDays: 30
  storageLocation: "s3://backups/daily"
EOF

# Verify
kubectl get backup daily-backup -n aurora
kubectl describe backup daily-backup -n aurora
```

---

## Question 13 | Create TLS Secret (4 points)

### Solution

```bash
kubectl create secret tls web-tls \
  --cert=./exam/course/13/tls.crt \
  --key=./exam/course/13/tls.key \
  -n flare

# Verify
kubectl get secret web-tls -n flare
kubectl describe secret web-tls -n flare
```

---

## Question 14 | Harden Deployment with SecurityContext (4 points)

### Solution

```bash
kubectl edit deploy hardened-app -n dawn
```

Add security contexts:

```yaml
spec:
  template:
    spec:
      securityContext:
        runAsNonRoot: true
      containers:
        - name: app
          securityContext:
            readOnlyRootFilesystem: true
            capabilities:
              drop:
                - ALL
```

```bash
# Verify
kubectl rollout status deploy hardened-app -n dawn
kubectl get deploy hardened-app -n dawn -o yaml | grep -A 10 securityContext
```

---

## Question 15 | ServiceAccount with RBAC and Verification (6 points)

### Solution

```bash
# Step 1: Create ServiceAccount
kubectl create sa deploy-sa -n zenith

# Step 2: Create Role
kubectl create role deploy-role -n zenith \
  --verb=get,list,create,update \
  --resource=deployments

# Step 3: Create RoleBinding
kubectl create rolebinding deploy-rb -n zenith \
  --role=deploy-role \
  --serviceaccount=zenith:deploy-sa

# Step 4: Verify permissions
kubectl auth can-i list deployments \
  --as=system:serviceaccount:zenith:deploy-sa -n zenith

# Step 5: Save output to file
kubectl auth can-i list deployments \
  --as=system:serviceaccount:zenith:deploy-sa -n zenith \
  > ./exam/course/15/auth-check.txt

# Verify
cat ./exam/course/15/auth-check.txt
kubectl get sa deploy-sa -n zenith
kubectl get role deploy-role -n zenith
kubectl get rolebinding deploy-rb -n zenith
```

---

## Question 16 | ConfigMap from env-file (4 points)

### Solution

```bash
# Step 1: Create ConfigMap from env file
kubectl create configmap app-config --from-env-file=./exam/course/16/app.env -n eclipse

# Step 2: Create Pod with envFrom
kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: config-pod
  namespace: eclipse
spec:
  containers:
    - name: web
      image: nginx:1.25
      envFrom:
        - configMapRef:
            name: app-config
EOF

# Verify
kubectl get configmap app-config -n eclipse -o yaml
kubectl exec config-pod -n eclipse -- env | grep APP_
```

---

## Question 17 | Create docker-registry Secret (4 points)

### Solution

```bash
kubectl create secret docker-registry registry-creds \
  --docker-server=registry.example.com \
  --docker-username=admin \
  --docker-password=s3cur3P@ss \
  -n radiance

# Verify
kubectl get secret registry-creds -n radiance
kubectl get secret registry-creds -n radiance -o jsonpath='{.type}'
```

---

## Question 18 | NetworkPolicy with ipBlock (6 points)

### Solution

```bash
kubectl apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: api-allow
  namespace: sunbeam
spec:
  podSelector:
    matchLabels:
      app: api
  policyTypes:
    - Ingress
  ingress:
    - from:
        - podSelector:
            matchLabels:
              role: frontend
        - ipBlock:
            cidr: 10.0.0.0/24
      ports:
        - protocol: TCP
          port: 80
EOF

# Verify
kubectl get networkpolicy api-allow -n sunbeam
kubectl describe networkpolicy api-allow -n sunbeam
```

---

## Question 19 | Ingress with TLS Termination (6 points)

### Solution

```bash
kubectl apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: secure-ingress
  namespace: solstice
spec:
  tls:
    - hosts:
        - secure.example.com
      secretName: secure-tls
  rules:
    - host: secure.example.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: secure-svc
                port:
                  number: 443
EOF

# Verify
kubectl get ingress secure-ingress -n solstice
kubectl describe ingress secure-ingress -n solstice
```

---

## Question 20 | Fix Service and Verify DNS Resolution (4 points)

### Solution

```bash
# Step 1: Check current state
kubectl get endpoints dns-svc -n sunbeam
# No endpoints — selector is wrong

# Step 2: Fix selector
kubectl patch svc dns-svc -n sunbeam -p '{"spec":{"selector":{"app":"dns-app"}}}'

# Step 3: Verify endpoints
kubectl get endpoints dns-svc -n sunbeam

# Step 4: Test DNS and save output
kubectl run tmp-dns --rm -i --restart=Never --image=busybox:1.36 -n sunbeam \
  -- nslookup dns-svc.sunbeam.svc.cluster.local > ./exam/course/20/dns-output.txt

# Verify
cat ./exam/course/20/dns-output.txt
```
