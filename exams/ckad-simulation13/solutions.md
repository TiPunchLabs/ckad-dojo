# CKAD Simulation 13 - Solutions (Dojo Fujin 🌬️)

---

## Question 1 | Docker Image Build and Push

```bash
cd ./exam/course/13/q1
docker build -t localhost:5000/fujin-api:v2 .
docker push localhost:5000/fujin-api:v2
```

**Explanation:** Build the container image from the provided Dockerfile and tag it appropriately. Then push it to the local registry.

---

## Question 2 | Sidecar Logging Container

```bash
kubectl get pod wind-logger -n gale -o yaml > wind.yaml
# Edit wind.yaml to add the adapter container
```

```yaml
# Add this under spec.containers:
  - name: adapter
    image: busybox:1.31.1
    command: ["sh", "-c", "tail -f /var/log/wind.log | sed 's/^/[WIND-LOG] /'"]
    volumeMounts:
    - name: logs
      mountPath: /var/log
```

```bash
kubectl replace --force -f wind.yaml
```

**Explanation:** Extract the pod YAML, add the adapter container sharing the same volume mount, and force replace the pod since container changes aren't allowed dynamically.

---

## Question 3 | Batch Job Processing

```bash
kubectl create job storm-processor -n breeze --image=busybox:1.31.1 --dry-run=client -o yaml -- sh -c 'sleep 2; echo "Processing storm data"' > job.yaml
# Edit job.yaml to add completions and parallelism
```

```yaml
# Add under spec:
  completions: 6
  parallelism: 3
```

```bash
kubectl apply -f job.yaml
```

**Explanation:** Create a Job with specific completions and parallelism directly in the spec.

---

## Question 4 | Fix Deployment CrashLoopBackOff

```bash
kubectl get deployment tempest-app -n tempest -o yaml > dep.yaml
# Extract the pod template and create pod.yaml
```

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: tempest-debug
  namespace: tempest
spec:
  containers:
  - name: main
    image: nginx:1.22
    command: ['sleep', '3600']
    ports:
    - containerPort: 80
    env:
    - name: WIND_FORCE
      value: "high"
```

```bash
kubectl apply -f ./exam/course/13/q4/pod.yaml
```

**Explanation:** Extract the template from the deployment and wrap it in a Pod definition, changing only the requested command.

---

## Question 5 | Helm Release Upgrade

```bash
helm upgrade storm-app ./exam/course/13/q5/storm-chart -n typhoon --set replicaCount=3 --set image.tag=v2.0.0
```

**Explanation:** Upgrade the helm release using `--set` to override values defined in `values.yaml`.

---

## Question 6 | Rolling Update Strategy

```bash
kubectl patch deployment cyclone-web -n cyclone -p '{"spec":{"revisionHistoryLimit":2}}'
kubectl set image deployment/cyclone-web -n cyclone web=nginx:1.23.1
```

**Explanation:** Patch the `revisionHistoryLimit` first, then trigger a rolling update by changing the image.

---

## Question 7 | Blue-Green Deployment Switch

```bash
kubectl patch svc zephyr-svc -n zephyr -p '{"spec":{"selector":{"version":"green"}}}'
```

**Explanation:** Patching the service selector routes traffic to the pods with the label `version: green`.

---

## Question 8 | Kustomize Apply

```bash
cd ./exam/course/13/q8
cat <<EOF > kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - deployment.yaml
configMapGenerator:
  - name: tornado-config
    literals:
      - WIND_SPEED=150mph
EOF
kubectl apply -k . -n tornado
```

**Explanation:** Create `kustomization.yaml` defining the resource and configMapGenerator, then apply it using `kubectl apply -k`.

---

## Question 9 | OOMKilled Pod Troubleshooting

```bash
kubectl get pod memory-hog -n mistral -o yaml > hog.yaml
# Edit hog.yaml to update memory limits to 256Mi
kubectl replace --force -f hog.yaml
```

**Explanation:** Since it's crashing with OOMKilled, extract the configuration, increase the memory limit, and force replace.

---

## Question 10 | Top Memory-Consuming Pods

```bash
kubectl top pods -n sirocco --sort-by=memory
# Find top 3 pod names and write to top-pods.txt
cat <<EOF > ./exam/course/13/q10/top-pods.txt
pod-1
pod-2
pod-3
EOF
```

**Explanation:** Use `kubectl top pods --sort-by=memory` to find the pods consuming the most memory.

---

## Question 11 | Liveness and Readiness Probes

```bash
cat <<EOF > q11.yaml
apiVersion: v1
kind: Pod
metadata:
  name: monsoon-checker
  namespace: monsoon
spec:
  containers:
  - name: checker
    image: busybox:1.31.1
    command: ["sh", "-c", "touch /tmp/ready && sleep 3600"]
    readinessProbe:
      exec:
        command:
        - cat
        - /tmp/ready
      initialDelaySeconds: 5
      periodSeconds: 10
EOF
kubectl apply -f q11.yaml
```

**Explanation:** Define a pod with an exec-based readiness probe using the exact requested parameters.

---

## Question 12 | Secret from File

```bash
kubectl create secret generic gale-secret -n gale --from-literal=password.txt=super-secret-wind
cat <<EOF > q12.yaml
apiVersion: v1
kind: Pod
metadata:
  name: secret-reader
  namespace: gale
spec:
  containers:
  - name: reader
    image: alpine:3.14
    command: ["sleep", "3600"]
    volumeMounts:
    - name: sec-vol
      mountPath: /etc/secrets/password.txt
      subPath: password.txt
  volumes:
  - name: sec-vol
    secret:
      secretName: gale-secret
EOF
kubectl apply -f q12.yaml
```

**Explanation:** Create the secret, then define a pod mounting it using `subPath` to avoid overwriting the entire directory.

---

## Question 13 | Role and RoleBinding

```bash
kubectl create role breeze-manager -n breeze --verb=create,delete,list,watch --resource=deployments,statefulsets --dry-run=client -o yaml > role.yaml
# You must specify API group apps if using dry-run, but since deployments and statefulsets belong to apps, creating them works fine if you provide apps explicitly or just let kubectl resolve it.
# Actually, the command automatically uses the apps group. Let's verify:
kubectl create role breeze-manager -n breeze --verb=create,delete,list,watch --resource=deployments.apps,statefulsets.apps
kubectl create rolebinding breeze-manager-binding -n breeze --role=breeze-manager --serviceaccount=breeze:breeze-admin
```

**Explanation:** Use imperative commands to create the Role and RoleBinding mapping permissions to the service account.

---

## Question 14 | Pod with Volume and SecurityContext

```bash
cat <<EOF > q14.yaml
apiVersion: v1
kind: Pod
metadata:
  name: secure-storage
  namespace: tempest
spec:
  securityContext:
    fsGroup: 2000
  containers:
  - name: storage
    image: nginx:1.23.1
EOF
kubectl apply -f q14.yaml
```

**Explanation:** Pod-level security context is used to set `fsGroup`.

---

## Question 15 | LimitRange Configuration

```bash
cat <<EOF > q15.yaml
apiVersion: v1
kind: LimitRange
metadata:
  name: cyclone-limits
  namespace: cyclone
spec:
  limits:
  - type: Pod
    max:
      memory: "500Mi"
    min:
      memory: "100Mi"
  - type: Container
    default:
      cpu: "500m"
    defaultRequest:
      cpu: "200m"
EOF
kubectl apply -f q15.yaml
```

**Explanation:** Define a LimitRange containing constraints for both Pod (min/max) and Container (default/defaultRequest).

---

## Question 16 | Disable Default ServiceAccount Automount

```bash
kubectl get pod zephyr-api -n zephyr -o yaml > q16.yaml
# Edit to add automountServiceAccountToken: false under spec
kubectl replace --force -f q16.yaml
```

**Explanation:** `automountServiceAccountToken: false` must be set at the Pod spec level.

---

## Question 17 | Egress NetworkPolicy for DNS

```bash
cat <<EOF > q17.yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-dns-egress
  namespace: typhoon
spec:
  podSelector:
    matchLabels:
      role: worker
  policyTypes:
  - Egress
  egress:
  - ports:
    - protocol: UDP
      port: 53
    - protocol: TCP
      port: 53
EOF
kubectl apply -f q17.yaml
```

**Explanation:** Egress policy matching label, allowing only TCP/UDP port 53. Since egress is defined, all other egress traffic is denied.

---

## Question 18 | Ingress with Path Routing

```bash
cat <<EOF > q18.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: tornado-ingress
  namespace: tornado
spec:
  rules:
  - host: tornado.dojo.com
    http:
      paths:
      - path: /api
        pathType: Prefix
        backend:
          service:
            name: api-svc
            port:
              number: 8080
      - path: /web
        pathType: Prefix
        backend:
          service:
            name: web-svc
            port:
              number: 80
EOF
kubectl apply -f q18.yaml
```

**Explanation:** Create standard Ingress definition mapping paths to specific backend services and ports.

---

## Question 19 | Headless Service for StatefulSet

```bash
kubectl create service clusterip mistral-db-headless -n mistral --clusterip="None" --tcp=3306:3306 --dry-run=client -o yaml > svc.yaml
# Edit selector to match app: mistral-db
kubectl apply -f svc.yaml
```

**Explanation:** A headless service sets `clusterIP: None`. Modify the generated selector to target the statefulset pods.

---

## Question 20 | Debug Service Connectivity

```bash
kubectl exec -it sirocco-app -n sirocco -- env | grep SIROCCO_BACKEND
echo "SIROCCO_BACKEND_SERVICE_HOST" > ./exam/course/13/q20/svc-env.txt
```

**Explanation:** Kubernetes injects variables mapping service IP (e.g. `[SERVICE_NAME]_SERVICE_HOST`). The file should contain this exact variable name.