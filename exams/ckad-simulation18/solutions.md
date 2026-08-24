# CKAD Simulation 18 - Solutions (Dojo Izanagi ✨)

## Question 1 | Kubernetes Practice

```bash
# 1. Modify Dockerfile
cat <<EOF > ./exam/course/1/Dockerfile
FROM nginx:1.21

RUN echo "Hello World" > /usr/share/nginx/html/index.html

# Add instructions
RUN useradd -u 1000 izanagi
USER 1000

CMD ["nginx", "-g", "daemon off;"]
EOF

# 2. Build image
docker build -t localhost:5000/genesis-app:v1 ./exam/course/1/

# 3. Push image
docker push localhost:5000/genesis-app:v1

# 4. Create Pod
kubectl run genesis-pod -n genesis --image=localhost:5000/genesis-app:v1
```
**Explanation:** The `USER` instruction sets the user for the container. Building, tagging, and pushing standard docker commands.

---

## Question 2 | Kubernetes Practice

```bash
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: data-transformer
  namespace: origin
spec:
  volumes:
  - name: shared-data
    emptyDir: {}
  containers:
  - name: app-container
    image: busybox:1.32
    command: ['sh', '-c', 'while true; do echo "\$(date) - DATA" >> /var/log/app.log; sleep 5; done']
    volumeMounts:
    - name: shared-data
      mountPath: /var/log
  - name: adapter-container
    image: busybox:1.32
    command: ['sh', '-c', 'tail -f /var/log/app.log | sed "s/DATA/TRANSFORMED_DATA/g" > /var/log/transformed.log']
    volumeMounts:
    - name: shared-data
      mountPath: /var/log
EOF
```
**Explanation:** The adapter pattern uses an `emptyDir` volume shared between containers. The adapter container reads from the shared volume and modifies the data.

---

## Question 3 | Kubernetes Practice

```bash
cat <<EOF | kubectl apply -f -
apiVersion: batch/v1
kind: Job
metadata:
  name: index-processor
  namespace: primal
spec:
  completions: 5
  parallelism: 2
  completionMode: Indexed
  template:
    spec:
      containers:
      - name: processor
        image: busybox:1.32
        command: ['sh', '-c', 'echo "Processing item \$JOB_COMPLETION_INDEX"']
      restartPolicy: Never
EOF
```
**Explanation:** Indexed jobs provide the `$JOB_COMPLETION_INDEX` environment variable to each pod, allowing them to process specific slices of data.

---

## Question 4 | Kubernetes Practice

```bash
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: graceful-shutdown
  namespace: ancient
spec:
  terminationGracePeriodSeconds: 45
  containers:
  - name: nginx
    image: nginx:1.21
    lifecycle:
      preStop:
        exec:
          command: ["sh", "-c", "sleep 10 && nginx -s quit"]
EOF
```
**Explanation:** The `preStop` hook runs before the container receives a SIGTERM. `terminationGracePeriodSeconds` gives it enough time to complete.

---

## Question 5 | Kubernetes Practice

```bash
# Upgrade the release reusing existing values
helm upgrade genesis-web ./exam/course/5/genesis-web-chart -n nexus --reuse-values --set replicaCount=3
```
**Explanation:** `--reuse-values` keeps all previously set custom values, while `--set` applies the new changes.

---

## Question 6 | Kubernetes Practice

```bash
# Create Deployment
kubectl create deployment terra-web --image=nginx:1.21 --replicas=4 -n terra

# Create PDB
cat <<EOF | kubectl apply -f -
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: terra-pdb
  namespace: terra
spec:
  minAvailable: 75%
  selector:
    matchLabels:
      app: terra-web
EOF
```
**Explanation:** A PodDisruptionBudget ensures a minimum number of pods remain available during voluntary disruptions.

---

## Question 7 | Kubernetes Practice

```bash
# Update image
kubectl set image deployment/eden-api nginx=nginx:1.21 -n eden --record

# Ensure annotation
kubectl annotate deployment eden-api kubernetes.io/change-cause="Updated to nginx:1.21" -n eden

# Patch strategy
kubectl patch deployment eden-api -n eden -p '{"spec":{"strategy":{"type":"RollingUpdate","rollingUpdate":{"maxSurge":2,"maxUnavailable":0}}}}'
```
**Explanation:** Using `set image`, `annotate`, and `patch` to modify the deployment without writing a full YAML file.

---

## Question 8 | Kubernetes Practice

```bash
# Modify kustomization.yaml
cat <<EOF >> ./exam/course/8/kustomize/kustomization.yaml
secretGenerator:
- name: matrix-secret
  literals:
  - db-password=supersecret
generatorOptions:
  disableNameSuffixHash: true
EOF

# Apply Kustomize
kubectl kustomize ./exam/course/8/kustomize | kubectl apply -n matrix -f -
```
**Explanation:** Kustomize `secretGenerator` creates secrets. `disableNameSuffixHash: true` prevents the random hash suffix.

---

## Question 9 | Kubernetes Practice

```bash
# View pod status and init containers
kubectl describe pod stuck-pod -n cosmos
# Edit the pod
kubectl get pod stuck-pod -n cosmos -o yaml > stuck.yaml
sed -i 's/exit 1/exit 0/g' stuck.yaml
kubectl replace --force -f stuck.yaml
```
**Explanation:** The init container was intentionally exiting with 1. We change it to 0 so it succeeds.

---

## Question 10 | Kubernetes Practice

```bash
kubectl get events -n zenith -o custom-columns=TYPE:.type,REASON:.reason,MESSAGE:.message > ./exam/course/10/events.txt
```
**Explanation:** `custom-columns` allows exact formatting of kubectl output.

---

## Question 11 | Kubernetes Practice

```bash
cat <<EOF > ./exam/course/11/check.sh
#!/bin/bash
kubectl port-forward svc/backend-api 9999:8080 -n genesis &
PF_PID=\$!
sleep 2
curl http://localhost:9999/health >> ./exam/course/11/health.log
kill \$PF_PID
EOF
chmod +x ./exam/course/11/check.sh
```
**Explanation:** Port-forward runs in the background. We fetch the endpoint, log it, then kill the process.

---

## Question 12 | Kubernetes Practice

```bash
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: projected-pod
  namespace: origin
  labels:
    app: projected
spec:
  containers:
  - name: nginx
    image: nginx:alpine
    volumeMounts:
    - name: all-in-one
      mountPath: /var/run/projected
  volumes:
  - name: all-in-one
    projected:
      sources:
      - secret:
          name: my-secret
          items:
            - key: username
              path: username
      - configMap:
          name: my-config
      - downwardAPI:
          items:
            - path: "labels"
              fieldRef:
                fieldPath: metadata.labels
      - serviceAccountToken:
          path: token
          expirationSeconds: 3600
          audience: vault
EOF
```
**Explanation:** Projected volumes combine multiple sources (Secrets, ConfigMaps, DownwardAPI, ServiceAccountTokens) into a single directory.

---

## Question 13 | Kubernetes Practice

```bash
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: static-creds
  namespace: primal
type: Opaque
immutable: true
stringData:
  api-key: 12345ABC
EOF
```
**Explanation:** Setting `immutable: true` on a Secret or ConfigMap prevents any updates to its data.

---

## Question 14 | Kubernetes Practice

```bash
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: secure-pod
  namespace: ancient
spec:
  containers:
  - name: nginx
    image: nginx:alpine
    securityContext:
      runAsNonRoot: true
      runAsUser: 1000
      readOnlyRootFilesystem: true
      allowPrivilegeEscalation: false
      capabilities:
        drop:
        - ALL
    volumeMounts:
    - name: cache-volume
      mountPath: /var/cache/nginx
    - name: run-volume
      mountPath: /var/run
  volumes:
  - name: cache-volume
    emptyDir: {}
  - name: run-volume
    emptyDir: {}
EOF
```
**Explanation:** Hardening settings require an emptyDir for nginx because it needs to write to `/var/cache/nginx` and `/var/run` when the root FS is read-only.

---

## Question 15 | Kubernetes Practice

```bash
cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: monitor-viewer
  labels:
    rbac.example.com/aggregate-to-monitor: "true"
rules:
- apiGroups: [""]
  resources: ["pods", "services"]
  verbs: ["get", "list", "watch"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: aggregated-monitor
aggregationRule:
  clusterRoleSelectors:
  - matchLabels:
      rbac.example.com/aggregate-to-monitor: "true"
rules: []
EOF
```
**Explanation:** Aggregation allows a ClusterRole to dynamically inherit rules from other ClusterRoles based on labels.

---

## Question 16 | Kubernetes Practice

```bash
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ResourceQuota
metadata:
  name: priority-quota
  namespace: eden
spec:
  hard:
    pods: "5"
    requests.cpu: "2"
  scopes:
  - PriorityClass
  scopeSelector:
    matchExpressions:
    - operator: In
      scopeName: PriorityClass
      values:
      - high-priority
EOF
```
**Explanation:** ResourceQuotas can be restricted to specific scopes, like PriorityClasses.

---

## Question 17 | Kubernetes Practice

```bash
cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-named-port
  namespace: matrix
spec:
  podSelector:
    matchLabels:
      role: backend
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          role: frontend
    ports:
    - port: api-port
      protocol: TCP
EOF
```
**Explanation:** Network Policies support named ports, which allows decoupling the policy from the specific port number.

---

## Question 18 | Kubernetes Practice

```bash
kubectl get ingress cosmos-ingress -n cosmos -o yaml > ingress.yaml
# Edit the file to add ingressClassName: nginx and fix port to 80
cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: cosmos-ingress
  namespace: cosmos
spec:
  ingressClassName: nginx
  rules:
  - host: cosmos.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: cosmos-svc
            port:
              number: 80
EOF
```
**Explanation:** Explicitly setting `ingressClassName` is the standard way to associate an Ingress with a controller.

---

## Question 19 | Kubernetes Practice

```bash
kubectl run dns-tester -n zenith --image=busybox:1.32 -- sleep 3600
echo "data-svc.ancient.svc.cluster.local" > ./exam/course/19/fqdn.txt
```
**Explanation:** Cross-namespace service communication requires the FQDN: `<service-name>.<namespace>.svc.cluster.local`.

---

## Question 20 | Kubernetes Practice

```bash
cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: isolate-namespace
  namespace: nexus
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - podSelector: {}
  egress:
  - {}
EOF
```
**Explanation:** `podSelector: {}` targets all pods in the namespace. `from: - podSelector: {}` allows traffic from all pods in the same namespace. Egress with `{}` allows all outbound.
