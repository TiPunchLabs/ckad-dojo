#!/bin/bash

# Post-setup script for Simulation 17

function exam_post_setup() {
    echo "Running post-setup tasks for Simulation 17..."
    
    # Q5: Helm chart and release setup
    mkdir -p /opt/course/5/
    helm create /opt/course/5/battle-chart > /dev/null 2>&1
    
    # Intentionally modify the chart so the probe fails (so --atomic will revert it if wait/timeout is long enough, though the student just needs to run it)
    # The default nginx chart works, so let's just make sure it's installed
    helm install battle-web /opt/course/5/battle-chart -n garrison --set replicaCount=1 > /dev/null 2>&1
    
    # Make a broken version of the chart for the upgrade?
    # Actually, the question just says "upgrade it with atomic and timeout". The chart doesn't necessarily need to be broken,
    # but the prompt hints: "The underlying deployment may have a failing probe if configured incorrectly".
    sed -i 's/path: \//path: \/broken/g' /opt/course/5/battle-chart/templates/deployment.yaml
    
    # Q8: Kustomize setup
    mkdir -p /opt/course/8/
    cat <<EOF > /opt/course/8/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
- deployment.yaml
EOF
    cat <<EOF > /opt/course/8/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: vanguard-web
  namespace: vanguard
spec:
  replicas: 2
  selector:
    matchLabels:
      app: vanguard-web
  template:
    metadata:
      labels:
        app: vanguard-web
    spec:
      containers:
      - name: nginx
        image: nginx:1.21.0-alpine
EOF

    echo "Post-setup complete."
}

exam_post_setup
