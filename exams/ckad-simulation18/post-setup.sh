#!/bin/bash

# Post-setup for CKAD Simulation 18

exam_post_setup() {
  local exam_dir=$1
  
  # Install genesis-web helm chart in nexus namespace
  echo "Installing genesis-web Helm chart..."
  helm install genesis-web "$exam_dir/templates/5/genesis-web-chart" -n nexus --set customLabel="initial-install" --wait
}
