#!/bin/bash
# CKAD Simulation 20 Scoring Functions (Dojo Musashi)
# Total Points: 122

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../scripts/lib/common.sh" 2>/dev/null || true

EXAM_DIR="/opt/course"

score_q1() {
  local score=0
  local max_points=6
  local details=""
  if resource_exists pod musashi-pod apex; then
    score=$((score + 2))
    details+="Pod musashi-pod exists. "
    local image=$(kubectl get pod musashi-pod -n apex -o jsonpath='{.spec.containers[0].image}')
    if [[ "$image" == "localhost:5000/musashi-app:v1" ]]; then
      score=$((score + 4))
      details+="Image is correct. "
    else
      details+="Image is incorrect. "
    fi
  else
    details+="Pod musashi-pod not found. "
  fi
  echo "$score/$max_points"
  echo "DETAILS:$details"
}

score_q2() {
  local score=0
  local max_points=6
  local details=""
  if resource_exists pod tri-blade summit; then
    score=$((score + 2))
    details+="Pod tri-blade exists. "
    local containers=$(kubectl get pod tri-blade -n summit -o jsonpath='{.spec.containers[*].name}')
    if [[ "$containers" == *"main"* && "$containers" == *"sidecar"* && "$containers" == *"adapter"* ]]; then
      score=$((score + 4))
      details+="Containers exist. "
    else
      details+="Containers mismatch. "
    fi
  else
    details+="Pod tri-blade not found. "
  fi
  echo "$score/$max_points"
  echo "DETAILS:$details"
}

score_q3() {
  local score=0
  local max_points=6
  local details=""
  if resource_exists job data-processor pinnacle; then
    score=$((score + 2))
    details+="Job data-processor exists. "
    local completions=$(kubectl get job data-processor -n pinnacle -o jsonpath='{.spec.completions}')
    local parallelism=$(kubectl get job data-processor -n pinnacle -o jsonpath='{.spec.parallelism}')
    if [[ "$completions" == "3" && "$parallelism" == "2" ]]; then
      score=$((score + 4))
      details+="Completions and parallelism correct. "
    else
      details+="Incorrect completions or parallelism. "
    fi
  else
    details+="Job data-processor not found. "
  fi
  echo "$score/$max_points"
  echo "DETAILS:$details"
}

score_q4() {
  local score=0
  local max_points=6
  local details=""
  if resource_exists cronjob db-backup zenith; then
    score=$((score + 2))
    details+="CronJob db-backup exists. "
    local schedule=$(kubectl get cronjob db-backup -n zenith -o jsonpath='{.spec.schedule}')
    if [[ "$schedule" == "*/15 * * * *" ]]; then
      score=$((score + 4))
      details+="Schedule correct. "
    else
      details+="Schedule incorrect. "
    fi
  else
    details+="CronJob db-backup not found. "
  fi
  echo "$score/$max_points"
  echo "DETAILS:$details"
}

score_q5() {
  local score=0
  local max_points=6
  local details=""
  if helm ls -n crown | grep -q "crown-release"; then
    score=$((score + 6))
    details+="Helm release crown-release exists. "
  else
    details+="Helm release crown-release not found. "
  fi
  echo "$score/$max_points"
  echo "DETAILS:$details"
}

score_q6() {
  local score=0
  local max_points=6
  local details=""
  if resource_exists deployment glory-deploy glory; then
    score=$((score + 2))
    details+="Deployment glory-deploy exists. "
    local image=$(kubectl get deployment glory-deploy -n glory -o jsonpath='{.spec.template.spec.containers[0].image}')
    local replicas=$(kubectl get deployment glory-deploy -n glory -o jsonpath='{.spec.replicas}')
    if [[ "$image" == "nginx:1.25" || "$image" == "nginx" ]]; then
      score=$((score + 2))
      details+="Image updated. "
    fi
    if [[ "$replicas" == "5" ]]; then
      score=$((score + 2))
      details+="Replicas correct. "
    fi
  else
    details+="Deployment glory-deploy not found. "
  fi
  echo "$score/$max_points"
  echo "DETAILS:$details"
}

score_q7() {
  local score=0
  local max_points=6
  local details=""
  if resource_exists deployment legacy-canary legacy; then
    score=$((score + 3))
    details+="Canary deployment exists. "
    local labels=$(kubectl get deployment legacy-canary -n legacy -o jsonpath='{.spec.template.metadata.labels.app}')
    if [[ "$labels" == "legacy-web" ]]; then
      score=$((score + 3))
      details+="Labels match main deployment. "
    else
      details+="Labels do not match legacy-web. "
    fi
  else
    details+="Canary deployment not found. "
  fi
  echo "$score/$max_points"
  echo "DETAILS:$details"
}

score_q8() {
  local score=0
  local max_points=6
  local details=""
  if resource_exists deployment my-app mastery; then
    score=$((score + 3))
    details+="Deployment my-app applied in mastery. "
    local labels=$(kubectl get deployment my-app -n mastery -o jsonpath='{.metadata.labels.env}')
    if [[ "$labels" == "prod" ]]; then
      score=$((score + 3))
      details+="Label env=prod applied by Kustomize. "
    else
      details+="Label env=prod not found. "
    fi
  else
    details+="Deployment my-app not found. "
  fi
  echo "$score/$max_points"
  echo "DETAILS:$details"
}

score_q9() {
  local score=0
  local max_points=6
  local details=""
  local count=$(kubectl get pods -n ascend --field-selector=status.phase=Running 2>/dev/null | grep -E "bug-[123]" | wc -l || echo "0")
  if [[ "$count" -eq 3 ]]; then
    score=6
    details+="All 3 broken pods are now running. "
  else
    score=$((count * 2))
    details+="$count/3 broken pods are running. "
  fi
  echo "$score/$max_points"
  echo "DETAILS:$details"
}

score_q10() {
  local score=0
  local max_points=6
  local details=""
  if [ -f "/opt/course/10/logs.txt" ] || [ -f "./exam/course/10/logs.txt" ]; then
    score=$((score + 3))
    details+="File logs.txt created. "
    if grep -q "ERROR" ./exam/course/10/logs.txt 2>/dev/null || grep -q "ERROR" /opt/course/10/logs.txt 2>/dev/null; then
      score=$((score + 3))
      details+="Contains ERROR. "
    else
      details+="No ERROR found in file. "
    fi
  else
    details+="File logs.txt not found. "
  fi
  echo "$score/$max_points"
  echo "DETAILS:$details"
}

score_q11() {
  local score=0
  local max_points=6
  local details=""
  local eph=$(kubectl get pod distroless-pod -n apex -o jsonpath='{.spec.ephemeralContainers}' 2>/dev/null)
  if [[ -n "$eph" && "$eph" != "[]" ]]; then
    score=6
    details+="Ephemeral container found. "
  else
    details+="No ephemeral container found on distroless-pod. "
  fi
  echo "$score/$max_points"
  echo "DETAILS:$details"
}

score_q12() {
  local score=0
  local max_points=6
  local details=""
  if resource_exists pod secure-pod summit; then
    score=$((score + 2))
    details+="Pod secure-pod exists. "
    local user=$(kubectl get pod secure-pod -n summit -o jsonpath='{.spec.containers[0].securityContext.runAsUser}')
    if [[ "$user" == "2000" ]]; then
      score=$((score + 4))
      details+="runAsUser is 2000. "
    else
      details+="runAsUser is incorrect. "
    fi
  else
    details+="Pod secure-pod not found. "
  fi
  echo "$score/$max_points"
  echo "DETAILS:$details"
}

score_q13() {
  local score=0
  local max_points=6
  local details=""
  if resource_exists rolebinding master-binding pinnacle; then
    score=$((score + 6))
    details+="Rolebinding master-binding exists. "
  else
    details+="Rolebinding master-binding not found. "
  fi
  echo "$score/$max_points"
  echo "DETAILS:$details"
}

score_q14() {
  local score=0
  local max_points=6
  local details=""
  if resource_exists pod inject-pod zenith; then
    score=$((score + 2))
    details+="Pod inject-pod exists. "
    local env=$(kubectl get pod inject-pod -n zenith -o jsonpath='{.spec.containers[0].envFrom}')
    local vol=$(kubectl get pod inject-pod -n zenith -o jsonpath='{.spec.volumes}')
    if [[ "$env" == *"configMapRef"* || "$env" == *"app-config"* || "$vol" == *"secret"* ]]; then
      score=$((score + 4))
      details+="ConfigMap or Secret mounted. "
    else
      details+="ConfigMap/Secret not properly injected. "
    fi
  else
    details+="Pod inject-pod not found. "
  fi
  echo "$score/$max_points"
  echo "DETAILS:$details"
}

score_q15() {
  local score=0
  local max_points=6
  local details=""
  if resource_exists limitrange cpu-limits crown; then
    score=$((score + 3))
    details+="LimitRange exists. "
  else
    details+="LimitRange missing. "
  fi
  if resource_exists resourcequota compute-quota crown; then
    score=$((score + 3))
    details+="ResourceQuota exists. "
  else
    details+="ResourceQuota missing. "
  fi
  echo "$score/$max_points"
  echo "DETAILS:$details"
}

score_q16() {
  local score=0
  local max_points=6
  local details=""
  if kubectl get pv glory-pv &>/dev/null; then
    score=$((score + 3))
    details+="PV glory-pv exists. "
  else
    details+="PV glory-pv missing. "
  fi
  if resource_exists pvc glory-pvc glory; then
    score=$((score + 3))
    details+="PVC glory-pvc exists. "
  else
    details+="PVC glory-pvc missing. "
  fi
  echo "$score/$max_points"
  echo "DETAILS:$details"
}

score_q17() {
  local score=0
  local max_points=7
  local details=""
  if resource_exists networkpolicy allow-web legacy; then
    score=$((score + 7))
    details+="NetworkPolicy allow-web exists. "
  else
    details+="NetworkPolicy allow-web missing. "
  fi
  echo "$score/$max_points"
  echo "DETAILS:$details"
}

score_q18() {
  local score=0
  local max_points=7
  local details=""
  if resource_exists ingress mastery-ing mastery; then
    score=$((score + 7))
    details+="Ingress mastery-ing exists. "
  else
    details+="Ingress mastery-ing missing. "
  fi
  echo "$score/$max_points"
  echo "DETAILS:$details"
}

score_q19() {
  local score=0
  local max_points=6
  local details=""
  if resource_exists svc ascend-svc ascend; then
    score=$((score + 2))
    details+="Service ascend-svc exists. "
    local type=$(kubectl get svc ascend-svc -n ascend -o jsonpath='{.spec.type}')
    if [[ "$type" == "NodePort" ]]; then
      score=$((score + 4))
      details+="Service is NodePort. "
    else
      details+="Service is not NodePort. "
    fi
  else
    details+="Service ascend-svc missing. "
  fi
  echo "$score/$max_points"
  echo "DETAILS:$details"
}

score_q20() {
  local score=0
  local max_points=6
  local details=""
  if [ -f "/opt/course/20/dns-output.txt" ] || [ -f "./exam/course/20/dns-output.txt" ]; then
    score=6
    details+="Output file dns-output.txt exists. "
  else
    details+="Output file dns-output.txt missing. "
  fi
  echo "$score/$max_points"
  echo "DETAILS:$details"
}
