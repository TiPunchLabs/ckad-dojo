#!/bin/bash
# ckad-simulation2 - Post Setup

function exam_post_setup() {

  # === Auto-generated starter files ===
  local BASE_DIR="./exam/course"
  mkdir -p "$BASE_DIR/7"
  cat << 'EOF_FILE' > "$BASE_DIR/7/rollout-status.txt"
# This file will be populated when you run the relevant kubectl commands
EOF_FILE

  return 0
}
