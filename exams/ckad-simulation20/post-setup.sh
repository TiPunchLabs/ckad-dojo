#!/bin/bash
exam_post_setup() {
  echo "Post setup for Dojo Musashi complete"

  # === Auto-generated starter files ===
  local BASE_DIR="./exam/course"
  mkdir -p "$BASE_DIR/1/Dockerfile"
  touch "$BASE_DIR/1/Dockerfile/.gitkeep"
  mkdir -p "$BASE_DIR/1"
  cat << 'EOF_FILE' > "$BASE_DIR/1/main.go"
package main
import "fmt"
func main() {
    fmt.Println("Stub main.go")
}
EOF_FILE
  mkdir -p "$BASE_DIR/1"
  cat << 'EOF_FILE' > "$BASE_DIR/1/pod.yaml"
apiVersion: v1
kind: Pod
metadata:
  name: stub-pod
spec:
  containers:
  - name: nginx
    image: nginx
# TODO: Complete this manifest per the task instructions
EOF_FILE
  mkdir -p "$BASE_DIR/10"
  cat << 'EOF_FILE' > "$BASE_DIR/10/logs.txt"
# This file will be populated when you run the relevant kubectl commands
EOF_FILE
  mkdir -p "$BASE_DIR/12"
  cat << 'EOF_FILE' > "$BASE_DIR/12/secure-pod.yaml"
apiVersion: v1
kind: Pod
metadata:
  name: stub-pod
spec:
  containers:
  - name: nginx
    image: nginx
# TODO: Complete this manifest per the task instructions
EOF_FILE
  mkdir -p "$BASE_DIR/13"
  cat << 'EOF_FILE' > "$BASE_DIR/13/rbac.yaml"
apiVersion: v1
kind: Pod
metadata:
  name: stub-pod
spec:
  containers:
  - name: nginx
    image: nginx
# TODO: Complete this manifest per the task instructions
EOF_FILE
  mkdir -p "$BASE_DIR/14"
  cat << 'EOF_FILE' > "$BASE_DIR/14/inject.yaml"
apiVersion: v1
kind: Pod
metadata:
  name: stub-pod
spec:
  containers:
  - name: nginx
    image: nginx
# TODO: Complete this manifest per the task instructions
EOF_FILE
  mkdir -p "$BASE_DIR/15"
  cat << 'EOF_FILE' > "$BASE_DIR/15/quota.yaml"
apiVersion: v1
kind: Pod
metadata:
  name: stub-pod
spec:
  containers:
  - name: nginx
    image: nginx
# TODO: Complete this manifest per the task instructions
EOF_FILE
  mkdir -p "$BASE_DIR/16"
  cat << 'EOF_FILE' > "$BASE_DIR/16/storage.yaml"
apiVersion: v1
kind: Pod
metadata:
  name: stub-pod
spec:
  containers:
  - name: nginx
    image: nginx
# TODO: Complete this manifest per the task instructions
EOF_FILE
  mkdir -p "$BASE_DIR/17"
  cat << 'EOF_FILE' > "$BASE_DIR/17/netpol.yaml"
apiVersion: v1
kind: Pod
metadata:
  name: stub-pod
spec:
  containers:
  - name: nginx
    image: nginx
# TODO: Complete this manifest per the task instructions
EOF_FILE
  mkdir -p "$BASE_DIR/18"
  cat << 'EOF_FILE' > "$BASE_DIR/18/ingress.yaml"
apiVersion: v1
kind: Pod
metadata:
  name: stub-pod
spec:
  containers:
  - name: nginx
    image: nginx
# TODO: Complete this manifest per the task instructions
EOF_FILE
  mkdir -p "$BASE_DIR/19"
  cat << 'EOF_FILE' > "$BASE_DIR/19/svc.yaml"
apiVersion: v1
kind: Pod
metadata:
  name: stub-pod
spec:
  containers:
  - name: nginx
    image: nginx
# TODO: Complete this manifest per the task instructions
EOF_FILE
  mkdir -p "$BASE_DIR/2"
  cat << 'EOF_FILE' > "$BASE_DIR/2/multi-pod.yaml"
apiVersion: v1
kind: Pod
metadata:
  name: stub-pod
spec:
  containers:
  - name: nginx
    image: nginx
# TODO: Complete this manifest per the task instructions
EOF_FILE
  mkdir -p "$BASE_DIR/20"
  cat << 'EOF_FILE' > "$BASE_DIR/20/dns-output.txt"
# This file will be populated when you run the relevant kubectl commands
EOF_FILE
  mkdir -p "$BASE_DIR/20"
  cat << 'EOF_FILE' > "$BASE_DIR/20/dns.yaml"
apiVersion: v1
kind: Pod
metadata:
  name: stub-pod
spec:
  containers:
  - name: nginx
    image: nginx
# TODO: Complete this manifest per the task instructions
EOF_FILE
  mkdir -p "$BASE_DIR/3"
  cat << 'EOF_FILE' > "$BASE_DIR/3/job.yaml"
apiVersion: v1
kind: Pod
metadata:
  name: stub-pod
spec:
  containers:
  - name: nginx
    image: nginx
# TODO: Complete this manifest per the task instructions
EOF_FILE
  mkdir -p "$BASE_DIR/4"
  cat << 'EOF_FILE' > "$BASE_DIR/4/cronjob.yaml"
apiVersion: v1
kind: Pod
metadata:
  name: stub-pod
spec:
  containers:
  - name: nginx
    image: nginx
# TODO: Complete this manifest per the task instructions
EOF_FILE
  mkdir -p "$BASE_DIR/5/my-chart"
  touch "$BASE_DIR/5/my-chart/.gitkeep"
  mkdir -p "$BASE_DIR/5"
  cat << 'EOF_FILE' > "$BASE_DIR/5/values.yaml"
apiVersion: v1
kind: Pod
metadata:
  name: stub-pod
spec:
  containers:
  - name: nginx
    image: nginx
# TODO: Complete this manifest per the task instructions
EOF_FILE
  mkdir -p "$BASE_DIR/6"
  cat << 'EOF_FILE' > "$BASE_DIR/6/deploy.yaml"
apiVersion: v1
kind: Pod
metadata:
  name: stub-pod
spec:
  containers:
  - name: nginx
    image: nginx
# TODO: Complete this manifest per the task instructions
EOF_FILE
  mkdir -p "$BASE_DIR/7"
  cat << 'EOF_FILE' > "$BASE_DIR/7/canary.yaml"
apiVersion: v1
kind: Pod
metadata:
  name: stub-pod
spec:
  containers:
  - name: nginx
    image: nginx
# TODO: Complete this manifest per the task instructions
EOF_FILE
  mkdir -p "$BASE_DIR/8/base"
  touch "$BASE_DIR/8/base/.gitkeep"
  mkdir -p "$BASE_DIR/8"
  cat << 'EOF_FILE' > "$BASE_DIR/8/kustomization.yaml"
apiVersion: v1
kind: Pod
metadata:
  name: stub-pod
spec:
  containers:
  - name: nginx
    image: nginx
# TODO: Complete this manifest per the task instructions
EOF_FILE
  mkdir -p "$BASE_DIR/8/prod"
  touch "$BASE_DIR/8/prod/.gitkeep"
}
