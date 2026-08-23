#!/bin/bash
# ckad-simulation5 - Post Setup

function exam_post_setup() {

  # === Auto-generated starter files ===
  local BASE_DIR="./exam/course"
  mkdir -p "$BASE_DIR/10"
  cat << 'EOF_FILE' > "$BASE_DIR/10/debug-output.txt"
# This file will be populated when you run the relevant kubectl commands
EOF_FILE
  mkdir -p "$BASE_DIR/11"
  cat << 'EOF_FILE' > "$BASE_DIR/11/endpoints-info.txt"
# This file will be populated when you run the relevant kubectl commands
EOF_FILE
  mkdir -p "$BASE_DIR/15"
  cat << 'EOF_FILE' > "$BASE_DIR/15/patch-commands.sh"
#!/bin/bash
# TODO: Complete this script per the task instructions
echo "Stub script"
EOF_FILE
  chmod +x "$BASE_DIR/15/patch-commands.sh"
  mkdir -p "$BASE_DIR/19"
  cat << 'EOF_FILE' > "$BASE_DIR/19/permissions.txt"
# This file will be populated when you run the relevant kubectl commands
EOF_FILE
}
