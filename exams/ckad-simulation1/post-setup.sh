#!/bin/bash
# ckad-simulation1 - Post Setup

function exam_post_setup() {
  local BASE_DIR="./exam/course"
  mkdir -p "$BASE_DIR/1"
  touch "$BASE_DIR/1/api-resources"
  
  # Q2 file to create
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

  # Q3 job.yaml is provided by template, no need to touch it
  
  # Q4 rendered.yaml is to be created by student, no need for starter stub, but let's just make the dir
  mkdir -p "$BASE_DIR/4"
  
  # Q7
  mkdir -p "$BASE_DIR/7"
  cat << 'EOF_FILE' > "$BASE_DIR/7/password.txt"
# This file will be populated when you run the relevant kubectl commands
EOF_FILE

  # Q12 Dockerfile is provided by template, no need to touch it

  # Q13 values.yaml is provided by template, no need to touch it

  # Q20
  mkdir -p "$BASE_DIR/20"
  cat << 'EOF_FILE' > "$BASE_DIR/20/running-pods.txt"
# This file will be populated when you run the relevant kubectl commands
EOF_FILE

  # Q21
  mkdir -p "$BASE_DIR/21"
  cat << 'EOF_FILE' > "$BASE_DIR/21/drain-command.sh"
#!/bin/bash
# TODO: Complete this script per the task instructions
echo "Stub script"
EOF_FILE
  chmod +x "$BASE_DIR/21/drain-command.sh"
  return $errors
}
