#!/bin/bash
# CKAD Simulation 14 - Scoring Functions
# Total Points: 112

source "$SCRIPT_DIR/../../scripts/lib/common.sh" 2>/dev/null || true

EXAM_DIR="./exam/course/14"

score_q1() {
  local score=0
  local max_points=4
  local details=""
  local file="${EXAM_DIR}/q1/Dockerfile"

  if [ -f "$file" ]; then
    ((score++))
    details+="Dockerfile exists. "
    
    if grep -q "FROM nginx:1.23-alpine" "$file"; then
      ((score++))
      details+="Base image is correct. "
    fi
    
    if grep -q "HEALTHCHECK" "$file" && grep -q "\--interval=10s" "$file" && grep -q "\--timeout=3s" "$file"; then
      ((score++))
      details+="HEALTHCHECK timing options correct. "
    fi
    
    if grep -q "curl -f http://localhost/ || exit 1" "$file"; then
      ((score++))
      details+="HEALTHCHECK command correct. "
    fi
  else
    details+="Dockerfile not found."
  fi

  echo "$score/$max_points"
  echo "DETAILS:$details"
}

score_q2() {
  local score=0
  local max_points=6
  local details=""

  if resource_exists pod thunder-logger thunder; then
    ((score+=2))
    details+="Pod exists. "
    
    local init_cnt=$(kubectl get pod thunder-logger -n thunder -o jsonpath='{.spec.containers[*].name}')
    if [[ "$init_cnt" == *"app-container"* ]] && [[ "$init_cnt" == *"error-tailer"* ]]; then
      ((score+=2))
      details+="Containers exist. "
    fi
    
    local vol=$(kubectl get pod thunder-logger -n thunder -o jsonpath='{.spec.volumes[0].emptyDir}')
    if [[ -n "$vol" ]]; then
      ((score++))
      details+="emptyDir volume configured. "
    fi
    
    local cmd=$(kubectl get pod thunder-logger -n thunder -o jsonpath='{.spec.containers[?(@.name=="error-tailer")].command}')
    if [[ "$cmd" == *"grep"* ]] && [[ "$cmd" == *"ERROR"* ]]; then
      ((score++))
      details+="Sidecar tail/grep command present. "
    fi
  else
    details+="Pod thunder-logger not found in thunder namespace."
  fi

  echo "$score/$max_points"
  echo "DETAILS:$details"
}

score_q3() {
  local score=0
  local max_points=6
  local details=""

  if resource_exists cronjob lightning-strike bolt; then
    ((score+=2))
    details+="CronJob exists. "
    
    local sched=$(kubectl get cronjob lightning-strike -n bolt -o jsonpath='{.spec.schedule}')
    if [[ "$sched" == *"*/5 * * * *"* ]]; then
      ((score+=2))
      details+="Schedule correct. "
    fi
    
    local dls=$(kubectl get cronjob lightning-strike -n bolt -o jsonpath='{.spec.startingDeadlineSeconds}')
    if [[ "$dls" == "15" ]]; then
      ((score++))
      details+="startingDeadlineSeconds correct. "
    fi
    
    local hl=$(kubectl get cronjob lightning-strike -n bolt -o jsonpath='{.spec.successfulJobsHistoryLimit}')
    if [[ "$hl" == "2" ]]; then
      ((score++))
      details+="successfulJobsHistoryLimit correct. "
    fi
  else
    details+="CronJob lightning-strike not found."
  fi

  echo "$score/$max_points"
  echo "DETAILS:$details"
}

score_q4() {
  local score=0
  local max_points=6
  local details=""

  if resource_exists pod app-with-wait storm; then
    ((score+=2))
    details+="Pod exists. "
    
    local init_name=$(kubectl get pod app-with-wait -n storm -o jsonpath='{.spec.initContainers[0].name}')
    if [[ "$init_name" == "wait-for-db" ]]; then
      ((score+=2))
      details+="Init container exists. "
      
      local cmd=$(kubectl get pod app-with-wait -n storm -o jsonpath='{.spec.initContainers[0].command}')
      if [[ "$cmd" == *"database-svc"* ]]; then
        ((score+=2))
        details+="Init container references database-svc. "
      fi
    else
      details+="Init container incorrect. "
    fi
  else
    details+="Pod app-with-wait not found."
  fi

  echo "$score/$max_points"
  echo "DETAILS:$details"
}

score_q5() {
  local score=0
  local max_points=5
  local details=""
  local file="${EXAM_DIR}/q5/output.yaml"

  if [ -f "$file" ]; then
    ((score+=2))
    details+="Output file exists. "
    
    if grep -q "replicas: 3" "$file"; then
      ((score+=1))
      details+="Replica override successful. "
    fi
    
    if grep -q "image: \"nginx:latest\"" "$file"; then
      ((score+=2))
      details+="Image tag override successful. "
    fi
  else
    details+="output.yaml not found."
  fi

  echo "$score/$max_points"
  echo "DETAILS:$details"
}

score_q6() {
  local score=0
  local max_points=5
  local details=""

  if resource_exists deployment api-gateway voltage; then
    ((score+=2))
    details+="Deployment exists. "
    
    local img=$(kubectl get deployment api-gateway -n voltage -o jsonpath='{.spec.template.spec.containers[0].image}')
    if [[ "$img" == "nginx:1.23" ]]; then
      ((score+=3))
      details+="Deployment rolled back to revision 1 (nginx:1.23). "
    else
      details+="Image is $img, rollback might not be complete. "
    fi
  else
    details+="Deployment api-gateway not found."
  fi

  echo "$score/$max_points"
  echo "DETAILS:$details"
}

score_q7() {
  local score=0
  local max_points=7
  local details=""

  if resource_exists deployment backend-v2 spark; then
    ((score+=2))
    details+="Canary deployment exists. "
    
    local rep=$(kubectl get deployment backend-v2 -n spark -o jsonpath='{.spec.replicas}')
    if [[ "$rep" == "1" ]]; then
      ((score+=2))
      details+="Replicas is 1. "
    fi
    
    local img=$(kubectl get deployment backend-v2 -n spark -o jsonpath='{.spec.template.spec.containers[0].image}')
    if [[ "$img" == "nginx:1.23" ]]; then
      ((score+=1))
      details+="Image is correct. "
    fi
    
    local labels=$(kubectl get deployment backend-v2 -n spark -o jsonpath='{.spec.template.metadata.labels.app}')
    if [[ "$labels" == "backend" ]]; then
      ((score+=2))
      details+="Labels match service selector. "
    fi
  else
    details+="Canary deployment not found."
  fi

  echo "$score/$max_points"
  echo "DETAILS:$details"
}

score_q8() {
  local score=0
  local max_points=6
  local details=""

  if resource_exists deployment api-worker charge; then
    ((score+=2))
    details+="Deployment exists in charge namespace. "
    
    local env_val=$(kubectl get deployment api-worker -n charge -o jsonpath='{.spec.template.spec.containers[0].env[?(@.name=="APP_ENV")].value}')
    if [[ "$env_val" == "production" ]]; then
      ((score+=4))
      details+="Strategic merge patch successfully applied APP_ENV. "
    else
      details+="APP_ENV not found or incorrect. "
    fi
  else
    details+="Deployment api-worker not found."
  fi

  echo "$score/$max_points"
  echo "DETAILS:$details"
}

score_q9() {
  local score=0
  local max_points=5
  local details=""

  if resource_exists pod data-processor flash; then
    local phase=$(kubectl get pod data-processor -n flash -o jsonpath='{.status.phase}')
    if [[ "$phase" == "Running" ]]; then
      ((score+=5))
      details+="Pod is running and fixed. "
    else
      details+="Pod is still failing (Phase: $phase). "
    fi
  else
    details+="Pod not found."
  fi

  echo "$score/$max_points"
  echo "DETAILS:$details"
}

score_q10() {
  local score=0
  local max_points=5
  local details=""
  local file="${EXAM_DIR}/q10/events.txt"

  if [ -f "$file" ]; then
    ((score+=3))
    details+="Events file exists. "
    
    if [ -s "$file" ]; then
      ((score+=2))
      details+="File is not empty. "
    fi
  else
    details+="events.txt not found."
  fi

  echo "$score/$max_points"
  echo "DETAILS:$details"
}

score_q11() {
  local score=0
  local max_points=7
  local details=""

  if resource_exists pod complex-app plasma; then
    ((score+=1))
    details+="Pod exists. "
    
    local sp=$(kubectl get pod complex-app -n plasma -o jsonpath='{.spec.containers[0].startupProbe}')
    if [[ -n "$sp" ]]; then
      ((score+=2))
      details+="Startup probe exists. "
    fi
    
    local lp=$(kubectl get pod complex-app -n plasma -o jsonpath='{.spec.containers[0].livenessProbe}')
    if [[ -n "$lp" ]]; then
      ((score+=2))
      details+="Liveness probe exists. "
    fi
    
    local rp=$(kubectl get pod complex-app -n plasma -o jsonpath='{.spec.containers[0].readinessProbe}')
    if [[ -n "$rp" ]]; then
      ((score+=2))
      details+="Readiness probe exists. "
    fi
  else
    details+="Pod complex-app not found."
  fi

  echo "$score/$max_points"
  echo "DETAILS:$details"
}

score_q12() {
  local score=0
  local max_points=5
  local details=""

  if resource_exists pod env-info thunder; then
    ((score+=1))
    details+="Pod exists. "
    
    local p_name=$(kubectl get pod env-info -n thunder -o jsonpath='{.spec.containers[0].env[?(@.name=="POD_NAME")].valueFrom.fieldRef.fieldPath}')
    if [[ "$p_name" == "metadata.name" ]]; then
      ((score+=2))
      details+="POD_NAME mapped correctly. "
    fi
    
    local p_ns=$(kubectl get pod env-info -n thunder -o jsonpath='{.spec.containers[0].env[?(@.name=="POD_NAMESPACE")].valueFrom.fieldRef.fieldPath}')
    if [[ "$p_ns" == "metadata.namespace" ]]; then
      ((score+=2))
      details+="POD_NAMESPACE mapped correctly. "
    fi
  else
    details+="Pod env-info not found."
  fi

  echo "$score/$max_points"
  echo "DETAILS:$details"
}

score_q13() {
  local score=0
  local max_points=6
  local details=""

  if resource_exists pod secure-net bolt; then
    ((score+=2))
    details+="Pod exists. "
    
    local drop=$(kubectl get pod secure-net -n bolt -o jsonpath='{.spec.containers[0].securityContext.capabilities.drop[0]}')
    if [[ "$drop" == "ALL" ]]; then
      ((score+=2))
      details+="Dropped ALL capabilities. "
    fi
    
    local add=$(kubectl get pod secure-net -n bolt -o jsonpath='{.spec.containers[0].securityContext.capabilities.add[0]}')
    if [[ "$add" == "NET_ADMIN" ]]; then
      ((score+=2))
      details+="Added NET_ADMIN capability. "
    fi
  else
    details+="Pod secure-net not found."
  fi

  echo "$score/$max_points"
  echo "DETAILS:$details"
}

score_q14() {
  local score=0
  local max_points=5
  local details=""

  if resource_exists secret db-credentials storm; then
    ((score+=2))
    details+="Secret exists. "
    
    local user=$(kubectl get secret db-credentials -n storm -o jsonpath='{.data.username}' | base64 -d)
    if [[ "$user" == "admin" ]]; then
      ((score+=1))
      details+="Username correct. "
    fi
    
    local pass=$(kubectl get secret db-credentials -n storm -o jsonpath='{.data.password}' | base64 -d)
    if [[ "$pass" == "supersecret123" ]]; then
      ((score+=2))
      details+="Password correct. "
    fi
  else
    details+="Secret db-credentials not found."
  fi

  echo "$score/$max_points"
  echo "DETAILS:$details"
}

score_q15() {
  local score=0
  local max_points=5
  local details=""

  if resource_exists configmap app-args voltage; then
    ((score+=1))
    details+="ConfigMap exists. "
  else
    details+="ConfigMap app-args not found. "
  fi

  if resource_exists pod arg-reader voltage; then
    ((score+=2))
    details+="Pod exists. "
    
    local args=$(kubectl get pod arg-reader -n voltage -o jsonpath='{.spec.containers[0].args}')
    if [[ -n "$args" ]]; then
      ((score+=2))
      details+="Pod args configured. "
    fi
  else
    details+="Pod arg-reader not found."
  fi

  echo "$score/$max_points"
  echo "DETAILS:$details"
}

score_q16() {
  local score=0
  local max_points=7
  local details=""

  if resource_exists clusterrole secret-reader; then
    ((score+=2))
    details+="ClusterRole exists. "
    
    local res=$(kubectl get clusterrole secret-reader -o jsonpath='{.rules[0].resources[0]}')
    if [[ "$res" == "secrets" ]]; then
      ((score+=2))
      details+="Resource is secrets. "
    fi
  else
    details+="ClusterRole not found. "
  fi

  if resource_exists clusterrolebinding secret-reader-binding; then
    ((score+=2))
    details+="ClusterRoleBinding exists. "
    
    local sa=$(kubectl get clusterrolebinding secret-reader-binding -o jsonpath='{.subjects[0].name}')
    if [[ "$sa" == "app-sa" ]]; then
      ((score+=1))
      details+="Bound to app-sa. "
    fi
  else
    details+="ClusterRoleBinding not found."
  fi

  echo "$score/$max_points"
  echo "DETAILS:$details"
}

score_q17() {
  local score=0
  local max_points=6
  local details=""

  if resource_exists networkpolicy strict-ingress charge; then
    ((score+=2))
    details+="NetworkPolicy exists. "
    
    local ps=$(kubectl get networkpolicy strict-ingress -n charge -o jsonpath='{.spec.podSelector.matchLabels.role}')
    if [[ "$ps" == "db" ]]; then
      ((score+=1))
      details+="Applied to correct pods. "
    fi
    
    local ns_sel=$(kubectl get networkpolicy strict-ingress -n charge -o jsonpath='{.spec.ingress[0].from[0].namespaceSelector.matchLabels.env}')
    local p_sel=$(kubectl get networkpolicy strict-ingress -n charge -o jsonpath='{.spec.ingress[0].from[0].podSelector.matchLabels.role}')
    
    if [[ "$ns_sel" == "prod" ]] && [[ "$p_sel" == "api" ]]; then
      ((score+=3))
      details+="AND logic correctly implemented. "
    else
      details+="AND logic missing or incorrect. "
    fi
  else
    details+="NetworkPolicy strict-ingress not found."
  fi

  echo "$score/$max_points"
  echo "DETAILS:$details"
}

score_q18() {
  local score=0
  local max_points=5
  local details=""

  if resource_exists ingress default-ing surge; then
    ((score+=2))
    details+="Ingress exists. "
    
    local svc=$(kubectl get ingress default-ing -n surge -o jsonpath='{.spec.defaultBackend.service.name}')
    if [[ "$svc" == "fallback-svc" ]]; then
      ((score+=3))
      details+="Default backend configured correctly. "
    else
      details+="Default backend incorrect. "
    fi
  else
    details+="Ingress default-ing not found."
  fi

  echo "$score/$max_points"
  echo "DETAILS:$details"
}

score_q19() {
  local score=0
  local max_points=5
  local details=""

  if resource_exists service sticky-svc flash; then
    ((score+=2))
    details+="Service exists. "
    
    local affinity=$(kubectl get service sticky-svc -n flash -o jsonpath='{.spec.sessionAffinity}')
    if [[ "$affinity" == "ClientIP" ]]; then
      ((score+=2))
      details+="ClientIP affinity set. "
      
      local timeout=$(kubectl get service sticky-svc -n flash -o jsonpath='{.spec.sessionAffinityConfig.clientIP.timeoutSeconds}')
      if [[ "$timeout" == "10800" ]]; then
        ((score+=1))
        details+="Timeout set correctly. "
      fi
    else
      details+="Session affinity not ClientIP. "
    fi
  else
    details+="Service sticky-svc not found."
  fi

  echo "$score/$max_points"
  echo "DETAILS:$details"
}

score_q20() {
  local score=0
  local max_points=6
  local details=""
  local file="${EXAM_DIR}/q20/response.txt"

  if [ -f "$file" ]; then
    ((score+=3))
    details+="Response file exists. "
    
    if grep -iq "method" "$file" || grep -iq "path" "$file" || grep -iq "headers" "$file"; then
      ((score+=3))
      details+="Response contains expected output. "
    else
      details+="Response content does not look like http-https-echo output. "
    fi
  else
    details+="response.txt not found."
  fi

  echo "$score/$max_points"
  echo "DETAILS:$details"
}
