#!/bin/bash
# ckad-simulation1 - Post Setup

function exam_post_setup() {

  # === Auto-generated starter files ===
  local BASE_DIR="./exam/course"
  mkdir -p "$BASE_DIR/1/api-resources"
  touch "$BASE_DIR/1/api-resources/.gitkeep"
  mkdir -p "$BASE_DIR/12/Dockerfile"
  touch "$BASE_DIR/12/Dockerfile/.gitkeep"
  mkdir -p "$BASE_DIR/12/image/Dockerfile"
  touch "$BASE_DIR/12/image/Dockerfile/.gitkeep"
  mkdir -p "$BASE_DIR/13"
  cat << 'EOF_FILE' > "$BASE_DIR/13/values.yaml"
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
  cat << 'EOF_FILE' > "$BASE_DIR/2/fire-app.yaml"
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
  cat << 'EOF_FILE' > "$BASE_DIR/20/running-pods.txt"
# This file will be populated when you run the relevant kubectl commands
EOF_FILE
  mkdir -p "$BASE_DIR/21"
  cat << 'EOF_FILE' > "$BASE_DIR/21/drain-command.sh"
#!/bin/bash
# TODO: Complete this script per the task instructions
echo "Stub script"
EOF_FILE
  chmod +x "$BASE_DIR/21/drain-command.sh"
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
  cat << 'EOF_FILE' > "$BASE_DIR/4/rendered.yaml"
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
  cat << 'EOF_FILE' > "$BASE_DIR/7/password.txt"
# This file will be populated when you run the relevant kubectl commands
EOF_FILE
}
