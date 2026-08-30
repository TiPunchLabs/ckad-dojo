#!/bin/bash
# Scoring functions for CKAD Simulation 13
# Total Points: 110

source "$SCRIPT_DIR/../../scripts/lib/common.sh" 2>/dev/null || true
EXAM_DIR="./exam/course/13"

score_q1() {
  local score=0
  local max_points=5
  local details=""
  
  if curl -s http://localhost:5000/v2/fujin-api/tags/list 2>/dev/null | grep -q 'v2'; then
    score=$((score + 5))
    details="Image fujin-api:v2 pushed to local registry"
  else
    details="Image fujin-api:v2 not found in registry"
  fi
  
  echo "$score/$max_points"
  echo "DETAILS:$details"
}

score_q2() {
  local score=0
  local max_points=6
  local details=""
  
  if resource_exists pod wind-logger gale; then
    local adapter=$(kubectl get pod wind-logger -n gale -o jsonpath='{.spec.containers[?(@.name=="adapter")].name}')
    local mnt=$(kubectl get pod wind-logger -n gale -o jsonpath='{.spec.containers[?(@.name=="adapter")].volumeMounts[?(@.mountPath=="/var/log")].name}')
    if [ "$adapter" == "adapter" ]; then
      score=$((score + 3))
      details="Adapter container exists"
      if [ "$mnt" == "logs" ]; then
        score=$((score + 3))
        details="$details; Volume mounted correctly"
      fi
    else
      details="Adapter container not found"
    fi
  else
    details="Pod wind-logger not found"
  fi
  echo "$score/$max_points"
  echo "DETAILS:$details"
}

score_q3() {
  local score=0
  local max_points=5
  local details=""
  
  if resource_exists job storm-processor breeze; then
    local comps=$(kubectl get job storm-processor -n breeze -o jsonpath='{.spec.completions}')
    local para=$(kubectl get job storm-processor -n breeze -o jsonpath='{.spec.parallelism}')
    if [ "$comps" == "6" ] && [ "$para" == "3" ]; then
      score=$((score + 5))
      details="Job completions and parallelism are correct"
    else
      details="Job configuration is incorrect"
    fi
  else
    details="Job storm-processor not found"
  fi
  echo "$score/$max_points"
  echo "DETAILS:$details"
}

score_q4() {
  local score=0
  local max_points=6
  local details=""
  
  if resource_exists pod tempest-debug tempest; then
    local cmd=$(kubectl get pod tempest-debug -n tempest -o jsonpath='{.spec.containers[0].command[0]}')
    if [ "$cmd" == "sleep" ]; then
      score=$((score + 3))
      details="Pod created with correct command"
    else
      details="Pod created but command is incorrect"
    fi
  else
    details="Pod tempest-debug not found"
  fi
  
  if [ -f "$LOCAL_PATH_PREFIX/13/q4/pod.yaml" ]; then
    score=$((score + 3))
    details="$details; File created"
  else
    details="$details; File not created"
  fi
  echo "$score/$max_points"
  echo "DETAILS:$details"
}

score_q5() {
  local score=0
  local max_points=5
  local details=""
  
  local deploy_name=$(kubectl get deploy -n typhoon -o name | grep storm-app | head -n 1)
  if [ -n "$deploy_name" ]; then
    local reps=$(kubectl get $deploy_name -n typhoon -o jsonpath='{.spec.replicas}')
    local img=$(kubectl get $deploy_name -n typhoon -o jsonpath='{.spec.template.spec.containers[0].image}')
    if [ "$reps" == "3" ]; then
      score=$((score + 2))
      details="Replicas correct"
    fi
    if [[ "$img" == *"v2.0.0"* ]]; then
      score=$((score + 3))
      details="$details; Image correct"
    fi
  else
    details="Helm deployment not found"
  fi
  echo "$score/$max_points"
  echo "DETAILS:$details"
}

score_q6() {
  local score=0
  local max_points=5
  local details=""
  
  if resource_exists deploy cyclone-web cyclone; then
    local rev=$(kubectl get deploy cyclone-web -n cyclone -o jsonpath='{.spec.revisionHistoryLimit}')
    local img=$(kubectl get deploy cyclone-web -n cyclone -o jsonpath='{.spec.template.spec.containers[0].image}')
    if [ "$rev" == "2" ] && [ "$img" == "nginx:1.23.1" ]; then
      score=$((score + 5))
      details="Deployment updated correctly"
    else
      details="Deployment properties incorrect"
    fi
  else
    details="Deployment cyclone-web not found"
  fi
  echo "$score/$max_points"
  echo "DETAILS:$details"
}

score_q7() {
  local score=0
  local max_points=6
  local details=""
  
  if resource_exists svc zephyr-svc zephyr; then
    local sel=$(kubectl get svc zephyr-svc -n zephyr -o jsonpath='{.spec.selector.version}')
    if [ "$sel" == "green" ]; then
      score=$((score + 6))
      details="Service routes to green version"
    else
      details="Service selector is incorrect"
    fi
  else
    details="Service zephyr-svc not found"
  fi
  echo "$score/$max_points"
  echo "DETAILS:$details"
}

score_q8() {
  local score=0
  local max_points=6
  local details=""
  
  local cm_name=$(kubectl get cm -n tornado -o name | grep tornado-config | head -n 1)
  if [ -n "$cm_name" ]; then
    score=$((score + 3))
    details="ConfigMap created"
  else
    details="ConfigMap not found"
  fi
  if [ -f "$EXAM_DIR/q8/kustomization.yaml" ]; then
    score=$((score + 3))
    details="$details; kustomization.yaml created"
  fi
  echo "$score/$max_points"
  echo "DETAILS:$details"
}

score_q9() {
  local score=0
  local max_points=5
  local details=""
  
  if resource_exists pod memory-hog mistral; then
    local lim=$(kubectl get pod memory-hog -n mistral -o jsonpath='{.spec.containers[0].resources.limits.memory}')
    if [ "$lim" == "256Mi" ]; then
      score=$((score + 5))
      details="Memory limit updated correctly"
    else
      details="Memory limit is incorrect"
    fi
  else
    details="Pod memory-hog not found"
  fi
  echo "$score/$max_points"
  echo "DETAILS:$details"
}

score_q10() {
  local score=0
  local max_points=5
  local details=""
  
  if [ -f "$LOCAL_PATH_PREFIX/13/q10/top-pods.txt" ]; then
    local lines=$(wc -l < "$LOCAL_PATH_PREFIX/13/q10/top-pods.txt")
    if [ "$lines" -ge 3 ]; then
      score=$((score + 5))
      details="Top pods file created with content"
    else
      details="File does not have enough lines"
    fi
  else
    details="top-pods.txt not found"
  fi
  echo "$score/$max_points"
  echo "DETAILS:$details"
}

score_q11() {
  local score=0
  local max_points=6
  local details=""
  
  if resource_exists pod monsoon-checker monsoon; then
    local prob=$(kubectl get pod monsoon-checker -n monsoon -o jsonpath='{.spec.containers[0].readinessProbe.exec.command[0]}')
    if [ "$prob" == "cat" ]; then
      score=$((score + 6))
      details="Readiness probe configured correctly"
    else
      details="Readiness probe is incorrect"
    fi
  else
    details="Pod monsoon-checker not found"
  fi
  echo "$score/$max_points"
  echo "DETAILS:$details"
}

score_q12() {
  local score=0
  local max_points=6
  local details=""
  
  if resource_exists pod secret-reader gale; then
    local sub=$(kubectl get pod secret-reader -n gale -o jsonpath='{.spec.containers[0].volumeMounts[0].subPath}')
    if [ "$sub" == "password.txt" ]; then
      score=$((score + 6))
      details="SubPath mounted correctly"
    else
      details="SubPath not used or incorrect"
    fi
  else
    details="Pod secret-reader not found"
  fi
  echo "$score/$max_points"
  echo "DETAILS:$details"
}

score_q13() {
  local score=0
  local max_points=5
  local details=""
  
  if resource_exists role breeze-manager breeze; then
    score=$((score + 2))
    details="Role exists"
  fi
  if resource_exists rolebinding breeze-manager-binding breeze; then
    score=$((score + 3))
    details="$details; RoleBinding exists"
  fi
  echo "$score/$max_points"
  echo "DETAILS:$details"
}

score_q14() {
  local score=0
  local max_points=5
  local details=""
  
  if resource_exists pod secure-storage tempest; then
    local fsg=$(kubectl get pod secure-storage -n tempest -o jsonpath='{.spec.securityContext.fsGroup}')
    if [ "$fsg" == "2000" ]; then
      score=$((score + 5))
      details="fsGroup set correctly"
    else
      details="fsGroup is incorrect"
    fi
  else
    details="Pod secure-storage not found"
  fi
  echo "$score/$max_points"
  echo "DETAILS:$details"
}

score_q15() {
  local score=0
  local max_points=6
  local details=""
  
  if resource_exists limitrange cyclone-limits cyclone; then
    score=$((score + 6))
    details="LimitRange created"
  else
    details="LimitRange not found"
  fi
  echo "$score/$max_points"
  echo "DETAILS:$details"
}

score_q16() {
  local score=0
  local max_points=5
  local details=""
  
  if resource_exists pod zephyr-api zephyr; then
    local auto=$(kubectl get pod zephyr-api -n zephyr -o jsonpath='{.spec.automountServiceAccountToken}')
    if [ "$auto" == "false" ]; then
      score=$((score + 5))
      details="automountServiceAccountToken is false"
    else
      details="automountServiceAccountToken is not false"
    fi
  else
    details="Pod zephyr-api not found"
  fi
  echo "$score/$max_points"
  echo "DETAILS:$details"
}

score_q17() {
  local score=0
  local max_points=6
  local details=""
  
  if resource_exists netpol allow-dns-egress typhoon; then
    local port=$(kubectl get netpol allow-dns-egress -n typhoon -o jsonpath='{.spec.egress[0].ports[0].port}')
    if [ "$port" == "53" ]; then
      score=$((score + 6))
      details="NetworkPolicy created with correct port"
    else
      details="NetworkPolicy port incorrect"
    fi
  else
    details="NetworkPolicy not found"
  fi
  echo "$score/$max_points"
  echo "DETAILS:$details"
}

score_q18() {
  local score=0
  local max_points=6
  local details=""
  
  if resource_exists ingress tornado-ingress tornado; then
    local host=$(kubectl get ingress tornado-ingress -n tornado -o jsonpath='{.spec.rules[0].host}')
    if [ "$host" == "tornado.dojo.com" ]; then
      score=$((score + 6))
      details="Ingress created with correct host"
    else
      details="Ingress host incorrect"
    fi
  else
    details="Ingress not found"
  fi
  echo "$score/$max_points"
  echo "DETAILS:$details"
}

score_q19() {
  local score=0
  local max_points=5
  local details=""
  
  if resource_exists svc mistral-db-headless mistral; then
    local ip=$(kubectl get svc mistral-db-headless -n mistral -o jsonpath='{.spec.clusterIP}')
    if [ "$ip" == "None" ]; then
      score=$((score + 5))
      details="Headless service created correctly"
    else
      details="Service is not headless"
    fi
  else
    details="Service mistral-db-headless not found"
  fi
  echo "$score/$max_points"
  echo "DETAILS:$details"
}

score_q20() {
  local score=0
  local max_points=6
  local details=""
  
  if [ -f "$LOCAL_PATH_PREFIX/13/q20/svc-env.txt" ]; then
    if grep -q "SIROCCO_BACKEND_SERVICE_HOST" "$LOCAL_PATH_PREFIX/13/q20/svc-env.txt"; then
      score=$((score + 6))
      details="Environment variable identified correctly"
    else
      details="Incorrect environment variable name"
    fi
  else
    details="File svc-env.txt not found"
  fi
  echo "$score/$max_points"
  echo "DETAILS:$details"
}
