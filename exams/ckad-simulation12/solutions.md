# CKAD Simulation 12 - Solutions (Dojo Tsukuyomi 🌙)

## Question 1 | Image Save and Load

```bash
cd ./exam/course/1
docker build -t lunar-app:v1.0 .
docker save -o lunar-app.tar lunar-app:v1.0

# Load restores the original tag; add the new one on the loaded image
docker load -i lunar-app.tar
docker tag lunar-app:v1.0 lunar-app:v1.0-verified

docker run --rm lunar-app:v1.0-verified > run-output.txt
cat run-output.txt
cd -
```

Explanation: `docker save` exports an image with all its layers and tags to a tar archive, and `docker load` imports it back without any build step. The archive keeps the original tag, so a second tag is added with `docker tag`. Both tags point to the same image ID, which is how you can tell the image was loaded, not rebuilt.

---

## Question 2 | ConfigMap subPath Mount

```bash
kubectl get pod config-pod -n crescent -o yaml > config-pod.yaml
```

Edit the volume mount in `config-pod.yaml`:

```yaml
    volumeMounts:
    - name: config-vol
      mountPath: /etc/app/app.conf
      subPath: app.conf
```

```bash
kubectl replace --force -f config-pod.yaml
kubectl wait --for=condition=Ready pod/config-pod -n crescent

kubectl exec -n crescent config-pod -- cat /etc/app/app.conf > ./exam/course/2/before.txt

kubectl patch configmap app-config -n crescent --type merge -p '{"data":{"app.conf":"mode=staging"}}'
sleep 90
kubectl exec -n crescent config-pod -- cat /etc/app/app.conf > ./exam/course/2/after-no-restart.txt

kubectl replace --force -f config-pod.yaml
kubectl wait --for=condition=Ready pod/config-pod -n crescent
kubectl exec -n crescent config-pod -- cat /etc/app/app.conf > ./exam/course/2/after-restart.txt
```

Expected contents: `before.txt` → `mode=production`, `after-no-restart.txt` → `mode=production`, `after-restart.txt` → `mode=staging`.

Explanation: A ConfigMap mounted as a directory is refreshed by the kubelet after an update, because the kubelet swaps a symlink. A `subPath` mount bind-mounts one file once, when the container starts, so it never sees later ConfigMap updates. Only a new Pod picks up the new value.

---

## Question 3 | CronJob with Manual Trigger

```bash
kubectl create cronjob nightly-backup -n twilight --image=busybox:1.36 \
  --schedule="*/10 * * * *" --dry-run=client -o yaml -- sh -c 'sleep 30' > cj.yaml
```

Add the concurrency policy under `spec`:

```yaml
spec:
  concurrencyPolicy: Forbid
```

```bash
kubectl apply -f cj.yaml
kubectl create job nightly-backup-manual --from=cronjob/nightly-backup -n twilight
kubectl wait --for=condition=complete job/nightly-backup-manual -n twilight --timeout=90s
```

Explanation: `concurrencyPolicy: Forbid` skips a scheduled run while the previous one is still active. `kubectl create job --from=cronjob/...` creates a Job from the CronJob's `jobTemplate` right away, which is the standard way to test a CronJob without waiting for its schedule.

---

## Question 4 | Log Streaming Sidecar

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: log-aggregator
  namespace: eclipse
spec:
  containers:
  - name: app
    image: nginx:1.25
    ports:
    - containerPort: 80
    command: ["sh", "-c", "while true; do echo \"Request processed\" >> /var/log/app.log; sleep 5; done"]
    volumeMounts:
    - name: logs
      mountPath: /var/log
  - name: log-tailer
    image: busybox:1.36
    command: ["sh", "-c", "tail -f /var/log/app.log"]
    volumeMounts:
    - name: logs
      mountPath: /var/log
  volumes:
  - name: logs
    emptyDir: {}
```

```bash
kubectl logs log-aggregator -c log-tailer -n eclipse
```

Explanation: The `emptyDir` volume lives as long as the Pod and is shared by every container that mounts it. The sidecar turns a log file into stdout, which is what `kubectl logs` and cluster log collectors read.

---

## Question 5 | Helm Release Rollback

```bash
helm rollback api-release 1 -n nebula
```

Explanation: The `helm rollback` command takes the release name and the target revision.

---

## Question 6 | Rolling Update Strategy

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: slow-start-app
  namespace: shadow
spec:
  replicas: 4
  minReadySeconds: 20
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
  selector:
    matchLabels:
      app: slow-start-app
  template:
    metadata:
      labels:
        app: slow-start-app
    spec:
      containers:
      - name: nginx
        image: nginx:1.24
```

Explanation: `maxSurge: 1` allows one extra Pod above `replicas` during an update, and `maxUnavailable: 0` forbids dropping below `replicas` available Pods. `minReadySeconds: 20` makes a new Pod count as available only after it has stayed ready for 20 seconds, so the rollout waits for real readiness before removing an old Pod.

---

## Question 7 | Paused Rollout

```bash
kubectl get rs -n nightfall -o wide > ./exam/course/7/before-pause.txt

kubectl rollout pause deployment/critical-processor -n nightfall
kubectl set image deployment/critical-processor app=nginx:1.26 -n nightfall
kubectl get rs -n nightfall -o wide > ./exam/course/7/during-pause.txt

kubectl rollout resume deployment/critical-processor -n nightfall
kubectl rollout status deployment/critical-processor -n nightfall
kubectl get rs -n nightfall -o wide > ./exam/course/7/after-resume.txt
```

Explanation: While a Deployment is paused, changes to its Pod template are recorded but not acted on: no new ReplicaSet appears in `during-pause.txt`. When the rollout resumes, the controller creates the `nginx:1.26` ReplicaSet and scales the old one down. Pausing lets you batch several changes into a single rollout.

---

## Question 8 | Kustomize JSON Patch

```json
# ./exam/course/8/patch.json
[
  {
    "op": "add",
    "path": "/spec/template/spec/containers/0/env",
    "value": [
      {
        "name": "MODE",
        "value": "production"
      }
    ]
  }
]
```

```yaml
# ./exam/course/8/kustomization.yaml
resources:
  - deployment.yaml

patches:
  - target:
      kind: Deployment
      name: frontend
    path: patch.json
```

Explanation: JSON patching in Kustomize allows fine-grained manipulation of manifests without inline editing.

---

## Question 9 | Fix a Failing Pod

```bash
kubectl describe pod metrics-gatherer -n starlight   # Events: failed to pull image "nginxxxxx:alpine"
kubectl set image pod/metrics-gatherer gatherer=nginx:alpine -n starlight
kubectl get pod metrics-gatherer -n starlight
```

Explanation: The Pod events show an `ErrImagePull` / `ImagePullBackOff` for a misspelled image. A container image is one of the few Pod fields that can be changed in place, so no recreation is needed.

---

## Question 10 | Top CPU Consumer

```bash
kubectl top pod -n kube-system --sort-by=cpu --no-headers | head -1 | awk '{print $1}' > ./exam/course/10/cpu-usage.txt
```

Explanation: `kubectl top` reads live usage from metrics-server. `--sort-by=cpu` puts the largest consumer first.

---

## Question 11 | Broken Deployment Manifest

```bash
kubectl apply -f ./exam/course/11/broken-deploy.yaml
# The Deployment "broken-app" is invalid: spec.template.metadata.labels: Invalid value: ...
#   `selector` does not match template `labels`
```

Fix both defects in `./exam/course/11/broken-deploy.yaml`:

```yaml
  template:
    metadata:
      labels:
        app: broken-app        # was "broken": must match spec.selector
    spec:
      containers:
      - name: web
        image: nginx:1.25
        ports:
        - containerPort: 80
        readinessProbe:
          httpGet:
            path: /
            port: 80           # was 8080: nginx listens on 80
          initialDelaySeconds: 2
          periodSeconds: 3
```

```bash
kubectl apply -f ./exam/course/11/broken-deploy.yaml
kubectl rollout status deployment/broken-app -n lunar
```

Explanation: The API server rejects a Deployment whose selector does not match its Pod template labels. Once that is fixed, the Pods start but stay `0/1 READY`: `kubectl describe pod` shows `Readiness probe failed: ... connection refused` on port 8080. Pointing the probe at the port nginx really listens on makes the Pods Ready.

---

## Question 12 | Read a Mounted Secret

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: secret-reader
  namespace: crescent
spec:
  containers:
  - name: reader
    image: busybox:1.36
    command: ["sh", "-c", "cat /etc/secrets/*; sleep 3600"]
    volumeMounts:
    - name: creds
      mountPath: /etc/secrets
      readOnly: true
  volumes:
  - name: creds
    secret:
      secretName: db-credentials
```

```bash
kubectl logs secret-reader -n crescent
kubectl get secret db-credentials -n crescent -o jsonpath='{.data.password}' | base64 -d > ./exam/course/12/password.txt
```

Explanation: Each key of a Secret mounted as a volume becomes a file, already decoded. Through the API, `data` values are base64-encoded, which is an encoding, not encryption: anyone who can read the Secret can decode it.

---

## Question 13 | Container Capabilities

```bash
kubectl get pod secure-runner -n twilight -o yaml > secure-runner.yaml
```

Add to the container in `secure-runner.yaml`:

```yaml
    securityContext:
      runAsUser: 2000
      capabilities:
        drop: ["ALL"]
        add: ["NET_ADMIN"]
```

```bash
kubectl replace --force -f secure-runner.yaml
```

Explanation: `drop: ["ALL"]` removes every Linux capability, then `add` grants back only what the workload needs. Most `securityContext` fields are immutable on a running Pod, so the Pod has to be recreated.

---

## Question 14 | Hardened Pod Security Context

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: secure-pod
  namespace: eclipse
spec:
  securityContext:
    runAsUser: 1000
  containers:
  - name: nginx
    image: nginx:alpine
    securityContext:
      allowPrivilegeEscalation: false
      readOnlyRootFilesystem: true
    volumeMounts:
    - name: nginx-cache
      mountPath: /var/cache/nginx
    - name: nginx-run
      mountPath: /var/run
  volumes:
  - name: nginx-cache
    emptyDir: {}
  - name: nginx-run
    emptyDir: {}
```

Explanation: When `readOnlyRootFilesystem` is `true`, standard nginx images crash because they try to write to `/var/cache/nginx` and `/var/run`. Providing temporary `emptyDir` mounts resolves this.

---

## Question 15 | Rotate a Mounted Secret

```bash
kubectl exec -n shadow token-reader -- cat /etc/secret/token > ./exam/course/15/before.txt

kubectl create secret generic legacy-token -n shadow --from-literal=token=super-secret-v2 \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl get pod token-reader -n shadow -o yaml > token-reader.yaml
kubectl replace --force -f token-reader.yaml
kubectl wait --for=condition=Ready pod/token-reader -n shadow

kubectl exec -n shadow token-reader -- cat /etc/secret/token > ./exam/course/15/after.txt
```

Explanation: The `--dry-run=client -o yaml | kubectl apply` pattern updates an existing Secret from literals without hand-encoding base64. A Secret volume (without `subPath`) is eventually refreshed in a running Pod, but recreating the Pod guarantees the new value is read right away — and is required when the application only reads its credentials at startup.

---

## Question 16 | ResourceQuota

```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: compute-quota
  namespace: dusk
spec:
  hard:
    pods: "4"
    requests.cpu: "2"
    limits.memory: "4Gi"
```

Explanation: ResourceQuota objects enforce hard limits per namespace on the amount of resources that can be requested or defined. Once a quota covers `requests.cpu` or `limits.memory`, every new Pod in the namespace must declare those values or it is rejected.

---

## Question 17 | Restrict Ingress with a NetworkPolicy

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: frontend-policy
  namespace: dusk
spec:
  podSelector:
    matchLabels:
      app: frontend
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: backend
```

Explanation: Listing only `Ingress` in `policyTypes` leaves egress untouched. Once a Pod is selected by a policy with an ingress section, everything not explicitly allowed is denied. A `podSelector` alone in `from` matches Pods of the policy's own namespace.

---

## Question 18 | Path-Based Ingress

```bash
kubectl create ingress star-ingress -n starlight --class=nginx \
  --rule="star.local/api*=api-svc:8080" \
  --rule="star.local/web*=web-svc:80"
```

Equivalent manifest:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: star-ingress
  namespace: starlight
spec:
  ingressClassName: nginx
  rules:
  - host: star.local
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
```

Explanation: A trailing `*` in a `kubectl create ingress` rule sets `pathType: Prefix`. `Prefix` matches element by element on `/`-separated segments, so `/api` matches `/api` and `/api/users` but not `/apiary`, whatever the Ingress controller. `Exact` would only match `/api` itself, and `ImplementationSpecific` leaves the behaviour to the controller. Only standard `networking.k8s.io/v1` fields are used here, so the manifest works with any controller behind the `nginx` class.

---

## Question 19 | ExternalName Service

```yaml
apiVersion: v1
kind: Service
metadata:
  name: db-ext-svc
  namespace: nebula
spec:
  type: ExternalName
  externalName: database.external.example.com
```

Explanation: ExternalName services return a CNAME record so that pods can use internal K8s DNS to resolve to an external endpoint without needing IP addresses.

---

## Question 20 | Canary Deployment

```bash
kubectl get svc void-svc -n void -o jsonpath='{.spec.selector}'   # {"app":"api","version":"stable"}
```

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-deploy-canary
  namespace: void
spec:
  replicas: 1
  selector:
    matchLabels:
      app: api
      version: canary
  template:
    metadata:
      labels:
        app: api
        version: canary
    spec:
      containers:
      - name: api
        image: nginx:1.25
        ports:
        - containerPort: 80
```

```bash
kubectl apply -f canary.yaml
kubectl patch svc void-svc -n void --type json -p '[{"op":"remove","path":"/spec/selector/version"}]'
kubectl get endpointslices -n void -l kubernetes.io/service-name=void-svc
```

Explanation: A Service sends traffic to every Pod matching all of its selector labels. `void-svc` also selected `version=stable`, which excluded the canary. Keeping only the shared `app=api` label makes it balance across both Deployments — roughly 1 request in 3 goes to the canary with 2 stable replicas.
