#!/bin/bash
# ckad-simulation3 - Post Setup

function exam_post_setup() {

  # === Auto-generated starter files ===
  local BASE_DIR="./exam/course"
  mkdir -p "$BASE_DIR/13"
  cat << 'EOF_FILE' > "$BASE_DIR/13/top-cpu-pod.txt"
# This file will be populated when you run the relevant kubectl commands
EOF_FILE
  mkdir -p "$BASE_DIR/12"
  cat << 'EOF_FILE' > "$BASE_DIR/12/nginx-config.txt"
# This file will be populated when you run the relevant kubectl commands
EOF_FILE
  mkdir -p "$BASE_DIR/13"
  cat << 'EOF_FILE' > "$BASE_DIR/13/pod-resources.txt"
# This file will be populated when you run the relevant kubectl commands
EOF_FILE
  mkdir -p "$BASE_DIR/1"
  cat << 'EOF_FILE' > "$BASE_DIR/1/pod-spec-fields.txt"
# This file will be populated when you run the relevant kubectl commands
EOF_FILE

  return $errors
}
