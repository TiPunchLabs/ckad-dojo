#!/bin/bash
# ckad-simulation7 - Post Setup

function exam_post_setup() {

  # === Auto-generated starter files ===
  local BASE_DIR="./exam/course"
  mkdir -p "$BASE_DIR/15"
  cat << 'EOF_FILE' > "$BASE_DIR/15/config.txt"
# This file will be populated when you run the relevant kubectl commands
EOF_FILE
  mkdir -p "$BASE_DIR/17"
  cat << 'EOF_FILE' > "$BASE_DIR/17/username"
# This file will be populated when you run the relevant kubectl commands
EOF_FILE
  mkdir -p "$BASE_DIR/2"
  cat << 'EOF_FILE' > "$BASE_DIR/2/pod-ip.txt"
# This file will be populated when you run the relevant kubectl commands
EOF_FILE
  mkdir -p "$BASE_DIR/20"
  cat << 'EOF_FILE' > "$BASE_DIR/20/passwd"
# This file will be populated when you run the relevant kubectl commands
EOF_FILE
  mkdir -p "$BASE_DIR/3"
  cat << 'EOF_FILE' > "$BASE_DIR/3/logs.txt"
# This file will be populated when you run the relevant kubectl commands
EOF_FILE
  mkdir -p "$BASE_DIR/4"
  cat << 'EOF_FILE' > "$BASE_DIR/4/error.txt"
# This file will be populated when you run the relevant kubectl commands
EOF_FILE
  return $errors
}
