# CKAD Simulation 16 - Solutions (Dojo Benzaiten 🎶)

---

### Question 1

```bash
mkdir -p ./exam/course/1/
cat <<EOF > ./exam/course/1/Dockerfile
FROM nginx:alpine
COPY app /usr/share/nginx/html/
EOF
docker build -t localhost:5000/benzaiten-wisdom:v1 ./exam/course/1/
docker push localhost:5000/benzaiten-wisdom:v1
kubectl run wisdom-server -n harmony --image=localhost:5000/benzaiten-wisdom:v1
```

---

### Question 2

```bash
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: ambassador-pod
  namespace: melody
spec:
  containers:
  - name: main
    image: busybox
    command: ["sleep", "3600"]
  - name: ambassador
    image: haproxy:2.4-alpine
    volumeMounts:
    - name: config
      mountPath: /usr/local/etc/haproxy/haproxy.cfg
      subPath: haproxy.cfg
  volumes:
  - name: config
    configMap:
      name: haproxy-config
EOF
```

---

### Question 3

```bash
cat <<EOF | kubectl apply -f -
apiVersion: batch/v1
kind: Job
metadata:
  name: data-cleanup
  namespace: rhythm
spec:
  ttlSecondsAfterFinished: 10
  template:
    spec:
      containers:
      - name: busybox
        image: busybox
        command: ["sh", "-c", "echo 'Cleaning up old records'; sleep 5"]
      restartPolicy: Never
EOF
```

---

### Question 4

```bash
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: shared-process-pod
  namespace: cadence
spec:
  shareProcessNamespace: true
  containers:
  - name: app-container
    image: nginx:alpine
  - name: debug-container
    image: busybox
    command: ["sleep", "3600"]
EOF
```

---

### Question 5

```bash
helm dependency update ./exam/course/5/chart
cat <<EOF > ./exam/course/5/values.yaml
replicaCount: 3
service:
  port: 8080
EOF
helm install wisdom-app ./exam/course/5/chart -n chorus -f ./exam/course/5/values.yaml
```

---

### Question 6

```bash
kubectl create deploy rolling-deploy --image=nginx:1.24-alpine --replicas=5 -n sonata --dry-run=client -o yaml > deploy.yaml
# Edit deploy.yaml to add maxSurge and maxUnavailable
# spec:
#   strategy:
#     type: RollingUpdate
#     rollingUpdate:
#       maxSurge: 40%
#       maxUnavailable: 20%
# kubectl apply -f deploy.yaml
kubectl set image deployment/rolling-deploy nginx=nginx:1.25-alpine -n sonata --record
```

---

### Question 7

```bash
kubectl rollout undo deployment legacy-app --to-revision=2 -n verse
```

---

### Question 8

```bash
mkdir -p ./exam/course/8/overlays/production
cat <<EOF > ./exam/course/8/overlays/production/kustomization.yaml
namespace: lyric
commonLabels:
  env: production
resources:
  - ../../base
patches:
  - target:
      kind: Deployment
      name: app-deploy
    patch: |-
      - op: replace
        path: /spec/replicas
        value: 4
EOF
kubectl apply -k ./exam/course/8/overlays/production
```

---

### Question 9

```bash
kubectl describe pod metrics-pod -n tempo
# See it's missing a configmap named metrics-config
kubectl create configmap metrics-config -n tempo
```

---

### Question 10

```bash
kubectl get --raw /apis/metrics.k8s.io/v1beta1/namespaces/aria/pods/heavy-worker | jq -r '.containers[0].usage.memory' > ./exam/course/10/metrics.txt
```

---

### Question 11

```bash
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: health-check
  namespace: harmony
spec:
  containers:
  - name: nginx
    image: nginx:alpine
    livenessProbe:
      httpGet:
        path: /healthz
        port: 80
      initialDelaySeconds: 5
      periodSeconds: 10
    readinessProbe:
      httpGet:
        path: /ready
        port: 80
      initialDelaySeconds: 10
      periodSeconds: 5
EOF
```

---

### Question 12

```bash
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: projected-pod
  namespace: melody
spec:
  containers:
  - name: main
    image: busybox
    command: ["sleep", "3600"]
    volumeMounts:
    - name: all-in-one
      mountPath: /etc/projected
      readOnly: true
  volumes:
  - name: all-in-one
    projected:
      sources:
      - downwardAPI:
          items:
            - path: "pod-labels.txt"
              fieldRef:
                fieldPath: metadata.labels
      - configMap:
          name: info-cm
      - secret:
          name: info-secret
EOF
```

---

### Question 13

```bash
kubectl create configmap binary-config --from-file=data.bin=./exam/course/13/data.bin -n rhythm
```

---

### Question 14

```bash
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: selinux-pod
  namespace: cadence
spec:
  securityContext:
    seLinuxOptions:
      level: "s0:c123,c456"
  containers:
  - name: main
    image: busybox
    command: ["sleep", "3600"]
EOF
```

---

### Question 15

```bash
kubectl create serviceaccount vault-accessor -n sonata
kubectl create token vault-accessor -n sonata --duration=3600s > ./exam/course/15/token.txt
```

---

### Question 16

```bash
cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: port-range-allow
  namespace: chorus
spec:
  podSelector:
    matchLabels:
      role: backend
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector: {}
    ports:
    - protocol: TCP
      port: 3000
      endPort: 3010
EOF
```

---

### Question 17

```bash
cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: egress-external-only
  namespace: verse
spec:
  podSelector:
    matchLabels:
      role: egress-app
  policyTypes:
  - Egress
  egress:
  - to:
    - ipBlock:
        cidr: 10.0.0.0/8
        except:
        - 10.200.0.0/16
EOF
```

---

### Question 18

```bash
cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: multi-tls-ingress
  namespace: lyric
spec:
  tls:
  - hosts:
    - app1.benzaiten.dojo
    secretName: app1-tls
  - hosts:
    - app2.benzaiten.dojo
    secretName: app2-tls
  rules:
  - host: app1.benzaiten.dojo
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: app1-svc
            port:
              number: 80
  - host: app2.benzaiten.dojo
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: app2-svc
            port:
              number: 80
EOF
```

---

### Question 19

```bash
kubectl get endpointslice -n tempo -l kubernetes.io/service-name=external-db-svc -o jsonpath='{.items[*].endpoints[*].addresses[*]}' | tr ' ' '
' > ./exam/course/19/endpoints.txt
```

---

### Question 20

```bash
kubectl create deployment local-app --image=nginx:alpine --replicas=3 -n aria
kubectl expose deployment local-app --name=local-app-svc --port=80 --type=NodePort -n aria
kubectl patch svc local-app-svc -n aria -p '{"spec":{"externalTrafficPolicy":"Local"}}'
```
