#!/bin/bash
exam_post_setup() {
  local BASE_DIR="./exam/course"
  mkdir -p "$BASE_DIR/1" "$BASE_DIR/2" "$BASE_DIR/3" "$BASE_DIR/4" "$BASE_DIR/5" "$BASE_DIR/6" "$BASE_DIR/7" "$BASE_DIR/8/base" "$BASE_DIR/8/prod" "$BASE_DIR/10" "$BASE_DIR/12" "$BASE_DIR/13" "$BASE_DIR/14" "$BASE_DIR/15" "$BASE_DIR/16" "$BASE_DIR/17" "$BASE_DIR/18" "$BASE_DIR/19" "$BASE_DIR/20"

  cat << 'EOF2' > "$BASE_DIR/1/main.go"
package main
import "fmt"
func main() { fmt.Println("Hello Dojo") }
EOF2
  cat << 'EOF2' > "$BASE_DIR/1/Dockerfile"
FROM nginx:alpine
# TODO
EOF2
  cat << 'EOF2' > "$BASE_DIR/1/pod.yaml"
apiVersion: v1
kind: Pod
metadata:
  name: stub
spec:
  containers:
  - name: c
    image: nginx
EOF2

  for q in 2/multi-pod 6/deploy 7/canary 12/secure-pod 14/inject 19/svc 20/dns; do
    cat << 'EOF2' > "$BASE_DIR/${q}.yaml"
apiVersion: v1
kind: Pod
metadata:
  name: stub
spec:
  containers:
  - name: c
    image: nginx
EOF2
  done

  cat << 'EOF2' > "$BASE_DIR/3/job.yaml"
apiVersion: batch/v1
kind: Job
metadata:
  name: stub
spec:
  template:
    spec:
      containers:
      - name: c
        image: nginx
      restartPolicy: Never
EOF2

  cat << 'EOF2' > "$BASE_DIR/4/cronjob.yaml"
apiVersion: batch/v1
kind: CronJob
metadata:
  name: stub
spec:
  schedule: "* * * * *"
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: c
            image: nginx
          restartPolicy: Never
EOF2

  mkdir -p "$BASE_DIR/5/my-chart"
  cat << 'EOF2' > "$BASE_DIR/5/values.yaml"
# stub values
EOF2

  cat << 'EOF2' > "$BASE_DIR/8/kustomization.yaml"
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
EOF2

  cat << 'EOF2' > "$BASE_DIR/13/rbac.yaml"
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: stub
rules: []
EOF2

  cat << 'EOF2' > "$BASE_DIR/15/quota.yaml"
apiVersion: v1
kind: ResourceQuota
metadata:
  name: stub
spec:
  hard: {}
EOF2

  cat << 'EOF2' > "$BASE_DIR/16/storage.yaml"
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: stub
spec:
  accessModes: []
  resources: {}
EOF2

  cat << 'EOF2' > "$BASE_DIR/17/netpol.yaml"
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: stub
spec:
  podSelector: {}
EOF2

  cat << 'EOF2' > "$BASE_DIR/18/ingress.yaml"
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: stub
spec:
  rules: []
EOF2

  touch "$BASE_DIR/10/logs.txt"
  touch "$BASE_DIR/20/dns-output.txt"
}
