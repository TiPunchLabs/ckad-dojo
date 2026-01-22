# CKAD Simulation 4 - Solutions (Dojo Genbu 🐢)

> **Total Score**: 105 points | **Passing Score**: ~66% (69 points)

---

## Question 1 | ResourceQuota (5 points)

### Solution

```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: namespace-limits
  namespace: shell
spec:
  hard:
    pods: "10"
    requests.cpu: "4"
    requests.memory: 4Gi
    limits.cpu: "8"
    limits.memory: 8Gi
    configmaps: "10"
    secrets: "10"
```

```bash
kubectl apply -f resourcequota.yaml
kubectl describe quota namespace-limits -n shell
```

---

## Question 2 | HorizontalPodAutoscaler (6 points)

### Solution

**Using kubectl autoscale:**

```bash
kubectl autoscale deployment web-app -n ocean \
  --name=web-app-hpa \
  --min=2 \
  --max=10 \
  --cpu-percent=70
```

**Or using manifest:**

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: web-app-hpa
  namespace: ocean
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: web-app
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
```

```bash
kubectl get hpa -n ocean
```

---

## Question 3 | StatefulSet (8 points)

### Solution

```yaml
apiVersion: v1
kind: Service
metadata:
  name: db-headless
  namespace: reef
spec:
  clusterIP: None
  selector:
    app: db-cluster
  ports:
  - port: 6379
    targetPort: 6379
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: db-cluster
  namespace: reef
spec:
  serviceName: db-headless
  replicas: 3
  selector:
    matchLabels:
      app: db-cluster
  template:
    metadata:
      labels:
        app: db-cluster
    spec:
      containers:
      - name: redis
        image: redis:7-alpine
        ports:
        - containerPort: 6379
        volumeMounts:
        - name: data
          mountPath: /data
  volumeClaimTemplates:
  - metadata:
      name: data
    spec:
      accessModes: ["ReadWriteOnce"]
      resources:
        requests:
          storage: 100Mi
```

```bash
kubectl apply -f statefulset.yaml
kubectl get statefulset db-cluster -n reef
kubectl get pods -n reef -l app=db-cluster
```

---

## Question 4 | DaemonSet (6 points)

### Solution

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: node-monitor
  namespace: deep
spec:
  selector:
    matchLabels:
      app: node-monitor
  template:
    metadata:
      labels:
        app: node-monitor
    spec:
      tolerations:
      - key: node-role.kubernetes.io/control-plane
        operator: Exists
        effect: NoSchedule
      containers:
      - name: monitor
        image: busybox:1.36
        command: ["sh", "-c", "while true; do echo Node: $NODE_NAME; sleep 60; done"]
        env:
        - name: NODE_NAME
          valueFrom:
            fieldRef:
              fieldPath: spec.nodeName
```

```bash
kubectl apply -f daemonset.yaml
kubectl get daemonset node-monitor -n deep
kubectl get pods -n deep -o wide
```

---

## Question 5 | PriorityClass (5 points)

### Solution

```yaml
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: critical-priority
value: 1000000
globalDefault: false
description: "Critical workloads priority"
---
apiVersion: v1
kind: Pod
metadata:
  name: critical-pod
  namespace: tide
spec:
  priorityClassName: critical-priority
  containers:
  - name: nginx
    image: nginx:1.21
```

```bash
kubectl apply -f priorityclass.yaml
kubectl get priorityclass critical-priority
kubectl get pod critical-pod -n tide -o yaml | grep priority
```

---

## Question 6 | startupProbe (5 points)

### Solution

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: slow-starter
  namespace: wave
spec:
  containers:
  - name: app
    image: nginx:1.21
    ports:
    - containerPort: 80
    startupProbe:
      httpGet:
        path: /
        port: 80
      failureThreshold: 30
      periodSeconds: 10
    livenessProbe:
      httpGet:
        path: /
        port: 80
```

```bash
kubectl apply -f slow-starter.yaml
kubectl get pod slow-starter -n wave
kubectl describe pod slow-starter -n wave | grep -A5 "Startup"
```

---

## Question 7 | Pod Affinity (6 points)

### Solution

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-frontend
  namespace: coral
spec:
  replicas: 3
  selector:
    matchLabels:
      app: web-frontend
  template:
    metadata:
      labels:
        app: web-frontend
        tier: frontend
    spec:
      affinity:
        podAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 100
            podAffinityTerm:
              labelSelector:
                matchLabels:
                  app: cache
              topologyKey: kubernetes.io/hostname
      containers:
      - name: frontend
        image: nginx:1.21
```

```bash
kubectl apply -f web-frontend.yaml
kubectl get deployment web-frontend -n coral
kubectl get pods -n coral -o wide
```

---

## Question 8 | Ingress with Path Routing (6 points)

### Solution

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: api-routing
  namespace: lagoon
spec:
  ingressClassName: nginx
  rules:
  - host: api.lagoon.local
    http:
      paths:
      - path: /v1
        pathType: Prefix
        backend:
          service:
            name: api-v1-svc
            port:
              number: 80
      - path: /v2
        pathType: Prefix
        backend:
          service:
            name: api-v2-svc
            port:
              number: 80
```

```bash
kubectl apply -f ingress.yaml
kubectl get ingress api-routing -n lagoon
kubectl describe ingress api-routing -n lagoon
```

---

## Question 9 | Job with Completions and Parallelism (5 points)

### Solution

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: parallel-processor
  namespace: current
spec:
  completions: 6
  parallelism: 3
  backoffLimit: 4
  template:
    spec:
      containers:
      - name: processor
        image: busybox:1.36
        command: ["sh", "-c", "echo Processing batch $RANDOM && sleep 5"]
      restartPolicy: Never
```

```bash
kubectl apply -f job.yaml
kubectl get jobs -n current
kubectl get pods -n current -l job-name=parallel-processor
```

---

## Question 10 | kubectl debug (4 points)

### Solution

**Using ephemeral containers (K8s 1.25+):**

```bash
kubectl debug troubled-app -n anchor -it --image=busybox:1.36 --target=app -c debugger -- sh

# Inside the container
ls -la /data > /tmp/output.txt
exit
```

**Alternative using copy-to:**

```bash
kubectl debug troubled-app -n anchor -it --copy-to=troubled-app-debug --image=busybox:1.36 -- sh
ls -la /data
```

**Save output:**

```bash
kubectl exec troubled-app -n anchor -- ls -la /data > ./exam/course/10/debug-output.txt
```

---

## Question 11 | EndpointSlice (3 points)

### Solution

```bash
# List EndpointSlices for the service
kubectl get endpointslices -n shell -l kubernetes.io/service-name=backend-svc

# Get detailed information
kubectl describe endpointslice -n shell -l kubernetes.io/service-name=backend-svc

# Save to file
cat > ./exam/course/11/endpoints-info.txt << 'EOF'
EndpointSlice: backend-svc-xxxxx
Number of endpoints: 3
IP addresses:
  - 10.244.0.10
  - 10.244.0.11
  - 10.244.0.12
Ports: 80/TCP
EOF
```

---

## Question 12 | Service internalTrafficPolicy (4 points)

### Solution

```bash
kubectl patch service local-svc -n ocean \
  -p '{"spec":{"internalTrafficPolicy":"Local"}}'
```

**Or edit directly:**

```bash
kubectl edit svc local-svc -n ocean
# Add: internalTrafficPolicy: Local
```

**Verification:**

```bash
kubectl get svc local-svc -n ocean -o yaml | grep internalTrafficPolicy
```

---

## Question 13 | EmptyDir with sizeLimit (4 points)

### Solution

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: cache-pod
  namespace: reef
spec:
  containers:
  - name: cache
    image: redis:7-alpine
    volumeMounts:
    - name: cache-volume
      mountPath: /cache
  volumes:
  - name: cache-volume
    emptyDir:
      medium: Memory
      sizeLimit: 100Mi
```

```bash
kubectl apply -f cache-pod.yaml
kubectl get pod cache-pod -n reef
kubectl describe pod cache-pod -n reef | grep -A5 "Volumes"
```

---

## Question 14 | Secret with stringData (4 points)

### Solution

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: app-credentials
  namespace: deep
immutable: true
stringData:
  api-key: super-secret-key-12345
  db-password: postgres@secure!
---
apiVersion: v1
kind: Pod
metadata:
  name: secret-consumer
  namespace: deep
spec:
  containers:
  - name: consumer
    image: busybox:1.36
    command: ["sh", "-c", "cat /secrets/api-key && sleep 3600"]
    volumeMounts:
    - name: secret-volume
      mountPath: /secrets
      readOnly: true
  volumes:
  - name: secret-volume
    secret:
      secretName: app-credentials
```

```bash
kubectl apply -f secret.yaml
kubectl get secret app-credentials -n deep -o yaml
kubectl exec secret-consumer -n deep -- cat /secrets/api-key
```

---

## Question 15 | kubectl patch (5 points)

### Solution

**patch-commands.sh:**

```bash
#!/bin/bash

# 1. Strategic merge patch - Update image
kubectl patch deployment patch-demo -n tide \
  -p '{"spec":{"template":{"spec":{"containers":[{"name":"nginx","image":"nginx:1.22"}]}}}}'

# 2. JSON patch - Add environment variable
kubectl patch deployment patch-demo -n tide --type='json' \
  -p='[{"op":"add","path":"/spec/template/spec/containers/0/env/0","value":{"name":"ENV_MODE","value":"production"}}]'

# 3. JSON patch - Update replicas
kubectl patch deployment patch-demo -n tide --type='json' \
  -p='[{"op":"replace","path":"/spec/replicas","value":4}]'
```

```bash
chmod +x ./exam/course/15/patch-commands.sh
./exam/course/15/patch-commands.sh
kubectl describe deployment patch-demo -n tide
```

---

## Question 16 | NetworkPolicy with IPBlock (8 points)

### Solution

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: external-access
  namespace: wave
spec:
  podSelector:
    matchLabels:
      tier: api
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          tier: client
    - ipBlock:
        cidr: 10.0.0.0/8
        except:
        - 10.0.1.0/24
    ports:
    - protocol: TCP
      port: 80
  egress:
  - to: []
    ports:
    - protocol: UDP
      port: 53
    - protocol: TCP
      port: 53
  - to:
    - ipBlock:
        cidr: 0.0.0.0/0
    ports:
    - protocol: TCP
      port: 443
```

```bash
kubectl apply -f networkpolicy.yaml
kubectl get networkpolicy external-access -n wave
kubectl describe networkpolicy external-access -n wave
```

---

## Question 17 | Pod with hostNetwork (5 points)

### Solution

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: network-diagnostic
  namespace: coral
spec:
  hostNetwork: true
  hostPID: true
  containers:
  - name: netshoot
    image: nicolaka/netshoot:latest
    command: ["sleep", "3600"]
    securityContext:
      privileged: true
```

```bash
kubectl apply -f network-diagnostic.yaml
kubectl get pod network-diagnostic -n coral
kubectl exec network-diagnostic -n coral -- ip addr
kubectl exec network-diagnostic -n coral -- ps aux | head
```

---

## Question 18 | ClusterRole and ClusterRoleBinding (6 points)

### Solution

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: node-monitor-sa
  namespace: lagoon
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: node-reader
rules:
- apiGroups: [""]
  resources: ["nodes"]
  verbs: ["get", "list", "watch"]
- apiGroups: [""]
  resources: ["nodes/status"]
  verbs: ["get"]
- apiGroups: [""]
  resources: ["namespaces"]
  verbs: ["get", "list"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: node-reader-binding
subjects:
- kind: ServiceAccount
  name: node-monitor-sa
  namespace: lagoon
roleRef:
  kind: ClusterRole
  name: node-reader
  apiGroup: rbac.authorization.k8s.io
```

```bash
kubectl apply -f rbac.yaml
kubectl auth can-i list nodes --as=system:serviceaccount:lagoon:node-monitor-sa
```

---

## Question 19 | kubectl auth can-i (4 points)

### Solution

```bash
# Check permissions for app-deployer ServiceAccount
SA="system:serviceaccount:current:app-deployer"

kubectl auth can-i create deployments -n current --as=$SA
kubectl auth can-i delete deployments -n current --as=$SA
kubectl auth can-i create pods -n current --as=$SA
kubectl auth can-i delete secrets -n current --as=$SA
kubectl auth can-i list nodes --as=$SA

# Save results
cat > ./exam/course/19/permissions.txt << 'EOF'
create deployments: yes
delete deployments: no
create pods: no
delete secrets: no
list nodes: no
EOF
```

---

## Question 20 | Multi-Container with Shared Volume (6 points)

### Solution

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: data-pipeline
  namespace: anchor
spec:
  containers:
  - name: producer
    image: busybox:1.36
    command: ["sh", "-c", "while true; do date >> /data/log.txt; sleep 5; done"]
    volumeMounts:
    - name: shared-data
      mountPath: /data
  - name: consumer
    image: busybox:1.36
    command: ["sh", "-c", "tail -f /data/log.txt"]
    volumeMounts:
    - name: shared-data
      mountPath: /data
  - name: monitor
    image: busybox:1.36
    command: ["sh", "-c", "while true; do wc -l /data/log.txt; sleep 10; done"]
    volumeMounts:
    - name: shared-data
      mountPath: /data
  volumes:
  - name: shared-data
    emptyDir: {}
```

```bash
kubectl apply -f data-pipeline.yaml
kubectl get pod data-pipeline -n anchor
kubectl logs data-pipeline -n anchor -c consumer
kubectl logs data-pipeline -n anchor -c monitor
```

---
