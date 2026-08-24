#!/bin/bash
# ckad-simulation8 - Post Setup

function exam_post_setup() {

  # === Auto-generated starter files ===
  local BASE_DIR="./exam/course"
  mkdir -p "$BASE_DIR/12"
  cat << 'EOF_FILE' > "$BASE_DIR/12/pods.txt"
# This file will be populated when you run the relevant kubectl commands
EOF_FILE
  mkdir -p "$BASE_DIR/14"
  cat << 'EOF_FILE' > "$BASE_DIR/14/values.txt"
# This file will be populated when you run the relevant kubectl commands
EOF_FILE
  mkdir -p "$BASE_DIR/15"
  cat << 'EOF_FILE' > "$BASE_DIR/15/releases.txt"
# This file will be populated when you run the relevant kubectl commands
EOF_FILE
  mkdir -p "$BASE_DIR/18"
  cat << 'EOF_FILE' > "$BASE_DIR/18/dns.txt"
# This file will be populated when you run the relevant kubectl commands
EOF_FILE
  mkdir -p "$BASE_DIR/20"
  cat << 'EOF_FILE' > "$BASE_DIR/20/token.txt"
# This file will be populated when you run the relevant kubectl commands
EOF_FILE
  return 0
}
