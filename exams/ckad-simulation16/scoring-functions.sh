#!/bin/bash
# CKAD Simulation 16 - Scoring Functions
# Dojo Benzaiten 🎶
# Total Points: 114

source "$SCRIPT_DIR/../../scripts/lib/common.sh" 2>/dev/null || true

EXAM_DIR=${EXAM_DIR:-"/opt/course"}

score_q1() {
  local score=0
  local max_points=5
  local details=""
  
  if resource_exists pod wisdom-server harmony; then
    local img=$(kubectl get pod wisdom-server -n harmony -o jsonpath='{.spec.containers[0].image}')
    if [[ "$img" == *"benzaiten-wisdom"* ]]; then
      score=$((score + 5))
      details="Pod created with correct image"
    else
      details="Pod image incorrect"
    fi
  else
    details="Pod not found"
  fi
  
  echo "$score/$max_points"
  echo "DETAILS:$details"
}

score_q2() {
  local score=0
  local max_points=6
  local details=""
  
  if resource_exists pod ambassador-pod melody; then
    score=$((score + 2))
    local cm=$(kubectl get pod ambassador-pod -n melody -o jsonpath='{.spec.volumes[?(@.configMap.name=="haproxy-config")].configMap.name}')
    if [ "$cm" == "haproxy-config" ]; then
      score=$((score + 4))
      details="Pod created with ambassador and configmap mounted"
    else
      details="ConfigMap not mounted"
    fi
  else
    details="Pod not found"
  fi
  
  echo "$score/$max_points"
  echo "DETAILS:$details"
}

score_q3() {
  local score=0
  local max_points=5
  local details=""
  
  if resource_exists job data-cleanup rhythm; then
    score=$((score + 2))
    local ttl=$(kubectl get job data-cleanup -n rhythm -o jsonpath='{.spec.ttlSecondsAfterFinished}')
    if [ "$ttl" == "10" ]; then
      score=$((score + 3))
      details="Job created with ttlSecondsAfterFinished=10"
    else
      details="Job created but ttl missing"
    fi
  else
    details="Job not found"
  fi
  
  echo "$score/$max_points"
  echo "DETAILS:$details"
}

score_q4() {
  local score=0
  local max_points=6
  local details=""
  
  if resource_exists pod shared-process-pod cadence; then
    score=$((score + 2))
    local share=$(kubectl get pod shared-process-pod -n cadence -o jsonpath='{.spec.shareProcessNamespace}')
    if [ "$share" == "true" ]; then
      score=$((score + 4))
      details="Pod created with shareProcessNamespace enabled"
    else
      details="shareProcessNamespace not enabled"
    fi
  else
    details="Pod not found"
  fi
  
  echo "$score/$max_points"
  echo "DETAILS:$details"
}

score_q5() {
  local score=0
  local max_points=6
  local details=""
  
  if helm ls -n chorus | grep -q wisdom-app; then
    score=$((score + 3))
    local rep=$(helm get values wisdom-app -n chorus | grep replicaCount)
    if [[ "$rep" != "" ]]; then
        score=$((score + 3))
        details="Helm release exists with values"
    else
        details="Helm release exists but custom values might not be set"
    fi
  else
    details="Helm release not found"
  fi
  
  echo "$score/$max_points"
  echo "DETAILS:$details"
}

score_q6() {
  local score=0
  local max_points=7
  local details=""
  
  if resource_exists deployment rolling-deploy sonata; then
    score=$((score + 2))
    local surge=$(kubectl get deploy rolling-deploy -n sonata -o jsonpath='{.spec.strategy.rollingUpdate.maxSurge}')
    local unav=$(kubectl get deploy rolling-deploy -n sonata -o jsonpath='{.spec.strategy.rollingUpdate.maxUnavailable}')
    if [ "$surge" == "40%" ] && [ "$unav" == "20%" ]; then
      score=$((score + 5))
      details="Deployment created with correct rolling update strategy"
    else
      details="Deployment strategy incorrect"
    fi
  else
    details="Deployment not found"
  fi
  
  echo "$score/$max_points"
  echo "DETAILS:$details"
}

score_q7() {
  local score=0
  local max_points=5
  local details=""
  
  if resource_exists deployment legacy-app verse; then
    local rev=$(kubectl get deploy legacy-app -n verse -o jsonpath='{.metadata.annotations.deployment\.kubernetes\.io/revision}')
    if [ "$rev" == "3" ] || [ "$rev" == "4" ]; then
      score=$((score + 5))
      details="Deployment undone"
    else
      details="Deployment revision check - you might have passed if you rolled back"
      score=5
    fi
  else
    details="Deployment not found"
  fi
  
  echo "$score/$max_points"
  echo "DETAILS:$details"
}

score_q8() {
  local score=0
  local max_points=8
  local details=""
  
  if resource_exists deployment app-deploy lyric; then
    score=$((score + 4))
    local rep=$(kubectl get deploy app-deploy -n lyric -o jsonpath='{.spec.replicas}')
    if [ "$rep" == "4" ]; then
      score=$((score + 4))
      details="Overlay applied successfully"
    else
      details="Overlay not applied correctly"
    fi
  else
    details="Deployment not found in lyric namespace"
  fi
  
  echo "$score/$max_points"
  echo "DETAILS:$details"
}

score_q9() {
  local score=0
  local max_points=5
  local details=""
  
  if resource_exists pod metrics-pod tempo; then
    local status=$(kubectl get pod metrics-pod -n tempo -o jsonpath='{.status.phase}')
    if [ "$status" == "Running" ]; then
      score=$((score + 5))
      details="Pod is running"
    else
      details="Pod is not running"
    fi
  else
    details="Pod not found"
  fi
  
  echo "$score/$max_points"
  echo "DETAILS:$details"
}

score_q10() {
  local score=0
  local max_points=6
  local details=""
  
  if [ -f "$LOCAL_PATH_PREFIX/10/metrics.txt" ] || [ -f "/opt/course/10/metrics.txt" ]; then
    local val=$(cat $LOCAL_PATH_PREFIX/10/metrics.txt 2>/dev/null || cat /opt/course/10/metrics.txt 2>/dev/null)
    if [[ -n "$val" ]]; then
      score=$((score + 6))
      details="Metrics file found and has content"
    else
      details="Metrics file empty"
    fi
  else
    details="Metrics file not found"
  fi
  
  echo "$score/$max_points"
  echo "DETAILS:$details"
}

score_q11() {
  local score=0
  local max_points=6
  local details=""
  
  if resource_exists pod health-check harmony; then
    score=$((score + 2))
    local live=$(kubectl get pod health-check -n harmony -o jsonpath='{.spec.containers[0].livenessProbe}')
    local read=$(kubectl get pod health-check -n harmony -o jsonpath='{.spec.containers[0].readinessProbe}')
    if [[ -n "$live" ]] && [[ -n "$read" ]]; then
      score=$((score + 4))
      details="Pod has both probes"
    else
      details="Probes missing"
    fi
  else
    details="Pod not found"
  fi
  
  echo "$score/$max_points"
  echo "DETAILS:$details"
}

score_q12() {
  local score=0
  local max_points=6
  local details=""
  
  if resource_exists pod projected-pod melody; then
    score=$((score + 2))
    local proj=$(kubectl get pod projected-pod -n melody -o jsonpath='{.spec.volumes[?(@.projected)].projected.sources}')
    if [[ "$proj" == *"downwardAPI"* ]] && [[ "$proj" == *"configMap"* ]] && [[ "$proj" == *"secret"* ]]; then
      score=$((score + 4))
      details="Projected volume configured correctly"
    else
      details="Projected volume sources missing"
    fi
  else
    details="Pod not found"
  fi
  
  echo "$score/$max_points"
  echo "DETAILS:$details"
}

score_q13() {
  local score=0
  local max_points=4
  local details=""
  
  if resource_exists configmap binary-config rhythm; then
    local bin=$(kubectl get cm binary-config -n rhythm -o jsonpath='{.binaryData}')
    if [[ -n "$bin" ]]; then
      score=$((score + 4))
      details="ConfigMap with binary data found"
    else
      details="Binary data missing"
    fi
  else
    details="ConfigMap not found"
  fi
  
  echo "$score/$max_points"
  echo "DETAILS:$details"
}

score_q14() {
  local score=0
  local max_points=5
  local details=""
  
  if resource_exists pod selinux-pod cadence; then
    score=$((score + 2))
    local se=$(kubectl get pod selinux-pod -n cadence -o jsonpath='{.spec.securityContext.seLinuxOptions.level}')
    if [ "$se" == "s0:c123,c456" ]; then
      score=$((score + 3))
      details="SELinux options set correctly"
    else
      details="SELinux options incorrect"
    fi
  else
    details="Pod not found"
  fi
  
  echo "$score/$max_points"
  echo "DETAILS:$details"
}

score_q15() {
  local score=0
  local max_points=4
  local details=""
  
  if [ -f "$LOCAL_PATH_PREFIX/15/token.txt" ] || [ -f "/opt/course/15/token.txt" ]; then
    local val=$(cat $LOCAL_PATH_PREFIX/15/token.txt 2>/dev/null || cat /opt/course/15/token.txt 2>/dev/null)
    if [[ -n "$val" ]]; then
      score=$((score + 4))
      details="Token file found and has content"
    else
      details="Token file empty"
    fi
  else
    details="Token file not found"
  fi
  
  echo "$score/$max_points"
  echo "DETAILS:$details"
}

score_q16() {
  local score=0
  local max_points=7
  local details=""
  
  if resource_exists networkpolicy port-range-allow chorus; then
    score=$((score + 3))
    local endp=$(kubectl get netpol port-range-allow -n chorus -o jsonpath='{.spec.ingress[0].ports[0].endPort}')
    if [ "$endp" == "3010" ]; then
      score=$((score + 4))
      details="NetworkPolicy with port range found"
    else
      details="Port range not set correctly"
    fi
  else
    details="NetworkPolicy not found"
  fi
  
  echo "$score/$max_points"
  echo "DETAILS:$details"
}

score_q17() {
  local score=0
  local max_points=6
  local details=""
  
  if resource_exists networkpolicy egress-external-only verse; then
    score=$((score + 2))
    local exc=$(kubectl get netpol egress-external-only -n verse -o jsonpath='{.spec.egress[0].to[0].ipBlock.except}')
    if [[ -n "$exc" ]]; then
      score=$((score + 4))
      details="NetworkPolicy with except block found"
    else
      details="Except block missing"
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
  
  if resource_exists ingress multi-tls-ingress lyric; then
    score=$((score + 2))
    local tls=$(kubectl get ingress multi-tls-ingress -n lyric -o jsonpath='{.spec.tls}')
    if [[ "$tls" == *"app1-tls"* ]] && [[ "$tls" == *"app2-tls"* ]]; then
      score=$((score + 4))
      details="Ingress with multiple TLS hosts found"
    else
      details="TLS configuration incorrect"
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
  
  if [ -f "$LOCAL_PATH_PREFIX/19/endpoints.txt" ] || [ -f "/opt/course/19/endpoints.txt" ]; then
    local val=$(cat $LOCAL_PATH_PREFIX/19/endpoints.txt 2>/dev/null || cat /opt/course/19/endpoints.txt 2>/dev/null)
    if [[ -n "$val" ]]; then
      score=$((score + 5))
      details="Endpoints file found and has content"
    else
      details="Endpoints file empty"
    fi
  else
    details="Endpoints file not found"
  fi
  
  echo "$score/$max_points"
  echo "DETAILS:$details"
}

score_q20() {
  local score=0
  local max_points=6
  local details=""
  
  if resource_exists service local-app-svc aria; then
    score=$((score + 2))
    local pol=$(kubectl get svc local-app-svc -n aria -o jsonpath='{.spec.externalTrafficPolicy}')
    if [ "$pol" == "Local" ]; then
      score=$((score + 4))
      details="Service with Local externalTrafficPolicy found"
    else
      details="externalTrafficPolicy not set to Local"
    fi
  else
    details="Service not found"
  fi
  
  echo "$score/$max_points"
  echo "DETAILS:$details"
}
