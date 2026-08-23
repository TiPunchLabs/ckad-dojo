#!/bin/bash

# Post-setup for CKAD Simulation 18

exam_post_setup() {
  local exam_dir=$1
  
  # Install genesis-web helm chart in nexus namespace
  echo "Installing genesis-web Helm chart..."
  helm install genesis-web "$exam_dir/templates/5/genesis-web-chart" -n nexus --set customLabel="initial-install" --wait

  # === Auto-generated starter files ===
  local BASE_DIR="./exam/course"
  mkdir -p "$BASE_DIR/1/Dockerfile"
  touch "$BASE_DIR/1/Dockerfile/.gitkeep"
  mkdir -p "$BASE_DIR/10"
  cat << 'EOF_FILE' > "$BASE_DIR/10/events.txt"
# This file will be populated when you run the relevant kubectl commands
EOF_FILE
  mkdir -p "$BASE_DIR/11"
  cat << 'EOF_FILE' > "$BASE_DIR/11/check.sh"
#!/bin/bash
# TODO: Complete this script per the task instructions
echo "Stub script"
EOF_FILE
  chmod +x "$BASE_DIR/11/check.sh"
  mkdir -p "$BASE_DIR/11"
  cat << 'EOF_FILE' > "$BASE_DIR/11/health.log"
# This file will be populated when you run the relevant kubectl commands
EOF_FILE
  mkdir -p "$BASE_DIR/19"
  cat << 'EOF_FILE' > "$BASE_DIR/19/fqdn.txt"
# This file will be populated when you run the relevant kubectl commands
EOF_FILE
  mkdir -p "$BASE_DIR/5/genesis-web-chart"
  touch "$BASE_DIR/5/genesis-web-chart/.gitkeep"
  mkdir -p "$BASE_DIR/8/kustomize"
  touch "$BASE_DIR/8/kustomize/.gitkeep"
}
