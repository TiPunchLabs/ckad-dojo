#!/bin/bash
# scoring-functions.sh - Scoring functions for CKAD Exam Simulator 3
# Each function returns the number of points scored and prints detailed results

# Source common utilities from scripts/lib
CURRENT_EXAM_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$CURRENT_EXAM_DIR/../.." && pwd)"
source "$PROJECT_DIR/scripts/lib/common.sh"

# ============================================================================
# SCORING HELPER FUNCTIONS
# ============================================================================

# Check criterion and print result
# Returns 1 if passed, 0 if failed
check_criterion() {
    local description="$1"
    local condition="$2"  # Should be "true" or "false"

    if [ "$condition" = "true" ]; then
        print_success "$description"
        return 0
    else
        print_fail "$description"
        return 1
    fi
}

# ============================================================================
# QUESTION 1 - Namespaces (1 point)
# ============================================================================
score_q1() {
    local score=0
    local total=1

    echo "Question 1 | Namespaces"

    # Check if file exists and contains namespaces with "a"
    local file="$EXAM_DIR/1/namespaces"
    if [ -f "$file" ] && grep -q "athena\|apollo\|ares\|hera\|hades" "$file" 2>/dev/null; then
        check_criterion "File /exam/course/1/namespaces contains filtered namespaces" "true" && ((score++))
    else
        check_criterion "File /exam/course/1/namespaces contains filtered namespaces" "false" || true
    fi

    echo "$score/$total"
    return 0
}

# ============================================================================
# QUESTION 2 - Multi-container Pod (6 points)
# ============================================================================
score_q2() {
    local score=0
    local total=6

    echo "Question 2 | Multi-container Pod"

    # Check Pod exists and is running
    local pod_status=$(kubectl get pod wisdom-pod -n athena -o jsonpath='{.status.phase}' 2>/dev/null)
    check_criterion "Pod wisdom-pod is running" "$([ "$pod_status" = "Running" ] && echo true || echo false)" && ((score++))

    # Check has 2 containers
    local container_count=$(kubectl get pod wisdom-pod -n athena -o jsonpath='{.spec.containers[*].name}' 2>/dev/null | wc -w)
    check_criterion "Pod has two containers" "$([ "$container_count" = "2" ] && echo true || echo false)" && ((score++))

    # Check main container image
    local main_image=$(kubectl get pod wisdom-pod -n athena -o jsonpath='{.spec.containers[?(@.name=="main")].image}' 2>/dev/null)
    check_criterion "Main container uses nginx:1.21-alpine" "$(echo "$main_image" | grep -q "nginx:1.21-alpine" && echo true || echo false)" && ((score++))

    # Check sidecar container image
    local sidecar_image=$(kubectl get pod wisdom-pod -n athena -o jsonpath='{.spec.containers[?(@.name=="sidecar")].image}' 2>/dev/null)
    check_criterion "Sidecar container uses busybox:1.35" "$(echo "$sidecar_image" | grep -q "busybox:1.35" && echo true || echo false)" && ((score++))

    # Check emptyDir volume exists
    local volume_type=$(kubectl get pod wisdom-pod -n athena -o jsonpath='{.spec.volumes[?(@.name=="shared-logs")].emptyDir}' 2>/dev/null)
    check_criterion "Pod has emptyDir volume named shared-logs" "$([ -n "$volume_type" ] && echo true || echo false)" && ((score++))

    # Check main container mounts volume
    local main_mount=$(kubectl get pod wisdom-pod -n athena -o jsonpath='{.spec.containers[?(@.name=="main")].volumeMounts[?(@.name=="shared-logs")].mountPath}' 2>/dev/null)
    check_criterion "Main container mounts volume at /usr/share/nginx/html" "$([ "$main_mount" = "/usr/share/nginx/html" ] && echo true || echo false)" && ((score++))

    echo "$score/$total"
    return 0
}

# ============================================================================
# QUESTION 3 - CronJob (5 points)
# ============================================================================
score_q3() {
    local score=0
    local total=5

    echo "Question 3 | CronJob"

    # Check CronJob exists
    local cronjob_exists=$(kubectl get cronjob sun-check -n apollo 2>/dev/null && echo true || echo false)
    check_criterion "CronJob sun-check exists" "$cronjob_exists" && ((score++))

    # Check schedule
    local schedule=$(kubectl get cronjob sun-check -n apollo -o jsonpath='{.spec.schedule}' 2>/dev/null)
    check_criterion "CronJob runs every 15 minutes" "$(echo "$schedule" | grep -q "*/15" && echo true || echo false)" && ((score++))

    # Check image
    local image=$(kubectl get cronjob sun-check -n apollo -o jsonpath='{.spec.jobTemplate.spec.template.spec.containers[0].image}' 2>/dev/null)
    check_criterion "CronJob uses busybox:1.35 image" "$(echo "$image" | grep -q "busybox:1.35" && echo true || echo false)" && ((score++))

    # Check successful jobs history
    local success_history=$(kubectl get cronjob sun-check -n apollo -o jsonpath='{.spec.successfulJobsHistoryLimit}' 2>/dev/null)
    check_criterion "CronJob keeps 3 successful jobs" "$([ "$success_history" = "3" ] && echo true || echo false)" && ((score++))

    # Check failed jobs history
    local failed_history=$(kubectl get cronjob sun-check -n apollo -o jsonpath='{.spec.failedJobsHistoryLimit}' 2>/dev/null)
    check_criterion "CronJob keeps 1 failed job" "$([ "$failed_history" = "1" ] && echo true || echo false)" && ((score++))

    echo "$score/$total"
    return 0
}

# ============================================================================
# QUESTION 4 - Helm Management (5 points)
# ============================================================================
score_q4() {
    local score=0
    local total=5

    echo "Question 4 | Helm Management"

    # Check release olympus-web-v1 deleted
    local v1_exists=$(helm list -n olympus -q 2>/dev/null | grep -q "olympus-web-v1" && echo true || echo false)
    check_criterion "Deleted Helm release olympus-web-v1" "$([ "$v1_exists" = "false" ] && echo true || echo false)" && ((score++))

    # Check release olympus-web-v2 upgraded
    local v2_upgraded=$(helm history olympus-web-v2 -n olympus 2>/dev/null | wc -l)
    check_criterion "Upgraded Helm release olympus-web-v2" "$([ "$v2_upgraded" -gt 1 ] && echo true || echo false)" && ((score++))

    # Check olympus-apache release installed
    local apache_exists=$(helm list -n olympus -q 2>/dev/null | grep -q "olympus-apache" && echo true || echo false)
    check_criterion "Installed Helm release olympus-apache" "$apache_exists" && ((score++))

    # Check olympus-apache has 3 replicas
    local apache_replicas=$(kubectl get deploy olympus-apache -n olympus -o jsonpath='{.spec.replicas}' 2>/dev/null)
    check_criterion "Helm release olympus-apache has three replicas" "$([ "$apache_replicas" = "3" ] && echo true || echo false)" && ((score++))

    # Check broken release deleted
    local broken_exists=$(helm list -n olympus -a -o json 2>/dev/null | grep -q "pending-install" && echo true || echo false)
    check_criterion "Deleted broken Helm release" "$([ "$broken_exists" = "false" ] && echo true || echo false)" && ((score++))

    echo "$score/$total"
    return 0
}

# ============================================================================
# QUESTION 5 - ConfigMap and Environment Variables (5 points)
# ============================================================================
score_q5() {
    local score=0
    local total=5

    echo "Question 5 | ConfigMap and Environment Variables"

    # Check ConfigMap exists
    local cm_exists=$(kubectl get configmap messenger-config -n hermes 2>/dev/null && echo true || echo false)
    check_criterion "ConfigMap messenger-config exists" "$cm_exists" && ((score++))

    # Check ConfigMap has SPEED key
    local speed=$(kubectl get configmap messenger-config -n hermes -o jsonpath='{.data.SPEED}' 2>/dev/null)
    check_criterion "ConfigMap has SPEED=fast" "$([ "$speed" = "fast" ] && echo true || echo false)" && ((score++))

    # Check Pod exists and is running
    local pod_status=$(kubectl get pod messenger-pod -n hermes -o jsonpath='{.status.phase}' 2>/dev/null)
    check_criterion "Pod messenger-pod is running" "$([ "$pod_status" = "Running" ] && echo true || echo false)" && ((score++))

    # Check Pod uses envFrom configMapRef
    local env_from=$(kubectl get pod messenger-pod -n hermes -o jsonpath='{.spec.containers[0].envFrom[*].configMapRef.name}' 2>/dev/null)
    check_criterion "Pod uses envFrom with messenger-config" "$(echo "$env_from" | grep -q "messenger-config" && echo true || echo false)" && ((score++))

    # Check Pod has correct image
    local image=$(kubectl get pod messenger-pod -n hermes -o jsonpath='{.spec.containers[0].image}' 2>/dev/null)
    check_criterion "Pod uses nginx:1.21-alpine" "$(echo "$image" | grep -q "nginx:1.21-alpine" && echo true || echo false)" && ((score++))

    echo "$score/$total"
    return 0
}

# ============================================================================
# QUESTION 6 - Secret Volume Mount (6 points)
# ============================================================================
score_q6() {
    local score=0
    local total=6

    echo "Question 6 | Secret Volume Mount"

    # Check Secret exists
    local secret_exists=$(kubectl get secret underworld-creds -n hades 2>/dev/null && echo true || echo false)
    check_criterion "Secret underworld-creds exists" "$secret_exists" && ((score++))

    # Check Secret has username key
    local username=$(kubectl get secret underworld-creds -n hades -o jsonpath='{.data.username}' 2>/dev/null | base64 -d 2>/dev/null)
    check_criterion "Secret has username=hades" "$([ "$username" = "hades" ] && echo true || echo false)" && ((score++))

    # Check Pod exists and is running
    local pod_status=$(kubectl get pod cerberus-pod -n hades -o jsonpath='{.status.phase}' 2>/dev/null)
    check_criterion "Pod cerberus-pod is running" "$([ "$pod_status" = "Running" ] && echo true || echo false)" && ((score++))

    # Check Pod mounts secret
    local mount_path=$(kubectl get pod cerberus-pod -n hades -o jsonpath='{.spec.containers[0].volumeMounts[?(@.name=="secret-volume")].mountPath}' 2>/dev/null)
    check_criterion "Pod mounts secret at /etc/secrets" "$([ "$mount_path" = "/etc/secrets" ] && echo true || echo false)" && ((score++))

    # Check mount is read-only
    local read_only=$(kubectl get pod cerberus-pod -n hades -o jsonpath='{.spec.containers[0].volumeMounts[?(@.name=="secret-volume")].readOnly}' 2>/dev/null)
    check_criterion "Secret mount is read-only" "$([ "$read_only" = "true" ] && echo true || echo false)" && ((score++))

    # Check volume uses secret
    local secret_name=$(kubectl get pod cerberus-pod -n hades -o jsonpath='{.spec.volumes[?(@.name=="secret-volume")].secret.secretName}' 2>/dev/null)
    check_criterion "Volume references underworld-creds secret" "$([ "$secret_name" = "underworld-creds" ] && echo true || echo false)" && ((score++))

    echo "$score/$total"
    return 0
}

# ============================================================================
# QUESTION 7 - Pod with Resource Limits (5 points)
# ============================================================================
score_q7() {
    local score=0
    local total=5

    echo "Question 7 | Pod with Resource Limits"

    # Check Pod exists and is running
    local pod_status=$(kubectl get pod thunder-pod -n zeus -o jsonpath='{.status.phase}' 2>/dev/null)
    check_criterion "Pod thunder-pod is running" "$([ "$pod_status" = "Running" ] && echo true || echo false)" && ((score++))

    # Check CPU request
    local cpu_request=$(kubectl get pod thunder-pod -n zeus -o jsonpath='{.spec.containers[0].resources.requests.cpu}' 2>/dev/null)
    check_criterion "CPU request is 100m" "$([ "$cpu_request" = "100m" ] && echo true || echo false)" && ((score++))

    # Check memory request
    local mem_request=$(kubectl get pod thunder-pod -n zeus -o jsonpath='{.spec.containers[0].resources.requests.memory}' 2>/dev/null)
    check_criterion "Memory request is 64Mi" "$([ "$mem_request" = "64Mi" ] && echo true || echo false)" && ((score++))

    # Check CPU limit
    local cpu_limit=$(kubectl get pod thunder-pod -n zeus -o jsonpath='{.spec.containers[0].resources.limits.cpu}' 2>/dev/null)
    check_criterion "CPU limit is 200m" "$([ "$cpu_limit" = "200m" ] && echo true || echo false)" && ((score++))

    # Check memory limit
    local mem_limit=$(kubectl get pod thunder-pod -n zeus -o jsonpath='{.spec.containers[0].resources.limits.memory}' 2>/dev/null)
    check_criterion "Memory limit is 128Mi" "$([ "$mem_limit" = "128Mi" ] && echo true || echo false)" && ((score++))

    echo "$score/$total"
    return 0
}

# ============================================================================
# QUESTION 8 - Deployment Rollback (6 points)
# ============================================================================
score_q8() {
    local score=0
    local total=6

    echo "Question 8 | Deployment Rollback"

    # Check Deployment exists
    local deploy_exists=$(kubectl get deployment battle-app -n ares 2>/dev/null && echo true || echo false)
    check_criterion "Deployment battle-app exists" "$deploy_exists" && ((score++))

    # Check Deployment is available
    local available=$(kubectl get deployment battle-app -n ares -o jsonpath='{.status.availableReplicas}' 2>/dev/null)
    check_criterion "Deployment has available replicas" "$([ "$available" -gt 0 ] 2>/dev/null && echo true || echo false)" && ((score++))

    # Check rollback-info.txt exists
    local file="$EXAM_DIR/8/rollback-info.txt"
    check_criterion "File /exam/course/8/rollback-info.txt exists" "$([ -f "$file" ] && echo true || echo false)" && ((score++))

    # Check file contains revision number
    if [ -f "$file" ]; then
        local content=$(cat "$file" 2>/dev/null)
        check_criterion "File contains revision number" "$(echo "$content" | grep -qE "^[0-9]+$" && echo true || echo false)" && ((score++))
    else
        check_criterion "File contains revision number" "false" || true
    fi

    # Check deployment uses working image (nginx, not broken)
    local image=$(kubectl get deployment battle-app -n ares -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null)
    check_criterion "Deployment uses working nginx image" "$(echo "$image" | grep -q "nginx" && ! echo "$image" | grep -q "broken" && echo true || echo false)" && ((score++))

    # Check deployment is ready
    local ready=$(kubectl get deployment battle-app -n ares -o jsonpath='{.status.readyReplicas}' 2>/dev/null)
    local desired=$(kubectl get deployment battle-app -n ares -o jsonpath='{.spec.replicas}' 2>/dev/null)
    check_criterion "All replicas are ready" "$([ "$ready" = "$desired" ] && echo true || echo false)" && ((score++))

    echo "$score/$total"
    return 0
}

# ============================================================================
# QUESTION 9 - Service ClusterIP (5 points)
# ============================================================================
score_q9() {
    local score=0
    local total=5

    echo "Question 9 | Service ClusterIP"

    # Check Pod exists and is running
    local pod_status=$(kubectl get pod hunter-api -n artemis -o jsonpath='{.status.phase}' 2>/dev/null)
    check_criterion "Pod hunter-api is running" "$([ "$pod_status" = "Running" ] && echo true || echo false)" && ((score++))

    # Check Pod has correct label
    local pod_label=$(kubectl get pod hunter-api -n artemis -o jsonpath='{.metadata.labels.app}' 2>/dev/null)
    check_criterion "Pod has label app=hunter" "$([ "$pod_label" = "hunter" ] && echo true || echo false)" && ((score++))

    # Check Service exists
    local svc_exists=$(kubectl get service hunter-svc -n artemis 2>/dev/null && echo true || echo false)
    check_criterion "Service hunter-svc exists" "$svc_exists" && ((score++))

    # Check Service port
    local svc_port=$(kubectl get service hunter-svc -n artemis -o jsonpath='{.spec.ports[0].port}' 2>/dev/null)
    check_criterion "Service exposes port 8080" "$([ "$svc_port" = "8080" ] && echo true || echo false)" && ((score++))

    # Check service-test.txt exists
    local file="$EXAM_DIR/9/service-test.txt"
    check_criterion "File /exam/course/9/service-test.txt exists" "$([ -f "$file" ] && echo true || echo false)" && ((score++))

    echo "$score/$total"
    return 0
}

# ============================================================================
# QUESTION 10 - NetworkPolicy (7 points)
# ============================================================================
score_q10() {
    local score=0
    local total=7

    echo "Question 10 | NetworkPolicy"

    # Check NetworkPolicy exists
    local np_exists=$(kubectl get networkpolicy sea-wall -n poseidon 2>/dev/null && echo true || echo false)
    check_criterion "NetworkPolicy sea-wall exists" "$np_exists" && ((score++))

    # Check podSelector
    local pod_selector=$(kubectl get networkpolicy sea-wall -n poseidon -o jsonpath='{.spec.podSelector.matchLabels.zone}' 2>/dev/null)
    check_criterion "NetworkPolicy applies to pods with zone=deep-sea" "$([ "$pod_selector" = "deep-sea" ] && echo true || echo false)" && ((score++))

    # Check ingress policy type
    local policy_types=$(kubectl get networkpolicy sea-wall -n poseidon -o jsonpath='{.spec.policyTypes[*]}' 2>/dev/null)
    check_criterion "NetworkPolicy has Ingress policy type" "$(echo "$policy_types" | grep -q "Ingress" && echo true || echo false)" && ((score++))

    # Check egress policy type
    check_criterion "NetworkPolicy has Egress policy type" "$(echo "$policy_types" | grep -q "Egress" && echo true || echo false)" && ((score++))

    # Check ingress from trusted pods
    local ingress_label=$(kubectl get networkpolicy sea-wall -n poseidon -o jsonpath='{.spec.ingress[0].from[0].podSelector.matchLabels.trusted}' 2>/dev/null)
    check_criterion "Ingress allows from pods with trusted=true" "$([ "$ingress_label" = "true" ] && echo true || echo false)" && ((score++))

    # Check egress to surface pods
    local egress_label=$(kubectl get networkpolicy sea-wall -n poseidon -o jsonpath='{.spec.egress[0].to[0].podSelector.matchLabels.zone}' 2>/dev/null)
    check_criterion "Egress allows to pods with zone=surface" "$([ "$egress_label" = "surface" ] && echo true || echo false)" && ((score++))

    # Check egress port
    local egress_port=$(kubectl get networkpolicy sea-wall -n poseidon -o jsonpath='{.spec.egress[0].ports[0].port}' 2>/dev/null)
    check_criterion "Egress allows port 80" "$([ "$egress_port" = "80" ] && echo true || echo false)" && ((score++))

    echo "$score/$total"
    return 0
}

# ============================================================================
# QUESTION 11 - PersistentVolume and PVC (6 points)
# ============================================================================
score_q11() {
    local score=0
    local total=6

    echo "Question 11 | PersistentVolume and PVC"

    # Check PV exists
    local pv_exists=$(kubectl get pv hera-pv 2>/dev/null && echo true || echo false)
    check_criterion "PersistentVolume hera-pv exists" "$pv_exists" && ((score++))

    # Check PV capacity
    local pv_capacity=$(kubectl get pv hera-pv -o jsonpath='{.spec.capacity.storage}' 2>/dev/null)
    check_criterion "PV has capacity 1Gi" "$([ "$pv_capacity" = "1Gi" ] && echo true || echo false)" && ((score++))

    # Check PVC exists
    local pvc_exists=$(kubectl get pvc hera-pvc -n hera 2>/dev/null && echo true || echo false)
    check_criterion "PersistentVolumeClaim hera-pvc exists" "$pvc_exists" && ((score++))

    # Check PVC is bound
    local pvc_status=$(kubectl get pvc hera-pvc -n hera -o jsonpath='{.status.phase}' 2>/dev/null)
    check_criterion "PVC is bound" "$([ "$pvc_status" = "Bound" ] && echo true || echo false)" && ((score++))

    # Check Pod exists
    local pod_status=$(kubectl get pod hera-storage-pod -n hera -o jsonpath='{.status.phase}' 2>/dev/null)
    check_criterion "Pod hera-storage-pod is running" "$([ "$pod_status" = "Running" ] && echo true || echo false)" && ((score++))

    # Check Pod mounts PVC
    local pvc_name=$(kubectl get pod hera-storage-pod -n hera -o jsonpath='{.spec.volumes[*].persistentVolumeClaim.claimName}' 2>/dev/null)
    check_criterion "Pod mounts hera-pvc" "$(echo "$pvc_name" | grep -q "hera-pvc" && echo true || echo false)" && ((score++))

    echo "$score/$total"
    return 0
}

# ============================================================================
# QUESTION 12 - Init Container (6 points)
# ============================================================================
score_q12() {
    local score=0
    local total=6

    echo "Question 12 | Init Container"

    # Check Pod exists and is running
    local pod_status=$(kubectl get pod titan-init-pod -n titan -o jsonpath='{.status.phase}' 2>/dev/null)
    check_criterion "Pod titan-init-pod is running" "$([ "$pod_status" = "Running" ] && echo true || echo false)" && ((score++))

    # Check init container exists
    local init_name=$(kubectl get pod titan-init-pod -n titan -o jsonpath='{.spec.initContainers[0].name}' 2>/dev/null)
    check_criterion "Init container named init-setup exists" "$([ "$init_name" = "init-setup" ] && echo true || echo false)" && ((score++))

    # Check init container image
    local init_image=$(kubectl get pod titan-init-pod -n titan -o jsonpath='{.spec.initContainers[0].image}' 2>/dev/null)
    check_criterion "Init container uses busybox:1.35" "$(echo "$init_image" | grep -q "busybox:1.35" && echo true || echo false)" && ((score++))

    # Check main container exists
    local main_name=$(kubectl get pod titan-init-pod -n titan -o jsonpath='{.spec.containers[0].name}' 2>/dev/null)
    check_criterion "Main container named titan-main exists" "$([ "$main_name" = "titan-main" ] && echo true || echo false)" && ((score++))

    # Check main container image
    local main_image=$(kubectl get pod titan-init-pod -n titan -o jsonpath='{.spec.containers[0].image}' 2>/dev/null)
    check_criterion "Main container uses nginx:1.21-alpine" "$(echo "$main_image" | grep -q "nginx:1.21-alpine" && echo true || echo false)" && ((score++))

    # Check init container completed
    local init_status=$(kubectl get pod titan-init-pod -n titan -o jsonpath='{.status.initContainerStatuses[0].state.terminated.reason}' 2>/dev/null)
    check_criterion "Init container completed successfully" "$([ "$init_status" = "Completed" ] && echo true || echo false)" && ((score++))

    echo "$score/$total"
    return 0
}

# ============================================================================
# QUESTION 13 - Probes (7 points)
# ============================================================================
score_q13() {
    local score=0
    local total=7

    echo "Question 13 | Probes (Liveness and Readiness)"

    # Check Pod exists
    local pod_exists=$(kubectl get pod oracle-pod -n apollo 2>/dev/null && echo true || echo false)
    check_criterion "Pod oracle-pod exists" "$pod_exists" && ((score++))

    # Check liveness probe path
    local liveness_path=$(kubectl get pod oracle-pod -n apollo -o jsonpath='{.spec.containers[0].livenessProbe.httpGet.path}' 2>/dev/null)
    check_criterion "Liveness probe path is /healthz" "$([ "$liveness_path" = "/healthz" ] && echo true || echo false)" && ((score++))

    # Check liveness probe initial delay
    local liveness_delay=$(kubectl get pod oracle-pod -n apollo -o jsonpath='{.spec.containers[0].livenessProbe.initialDelaySeconds}' 2>/dev/null)
    check_criterion "Liveness probe initial delay is 10s" "$([ "$liveness_delay" = "10" ] && echo true || echo false)" && ((score++))

    # Check liveness probe period
    local liveness_period=$(kubectl get pod oracle-pod -n apollo -o jsonpath='{.spec.containers[0].livenessProbe.periodSeconds}' 2>/dev/null)
    check_criterion "Liveness probe period is 5s" "$([ "$liveness_period" = "5" ] && echo true || echo false)" && ((score++))

    # Check readiness probe path
    local readiness_path=$(kubectl get pod oracle-pod -n apollo -o jsonpath='{.spec.containers[0].readinessProbe.httpGet.path}' 2>/dev/null)
    check_criterion "Readiness probe path is /ready" "$([ "$readiness_path" = "/ready" ] && echo true || echo false)" && ((score++))

    # Check readiness probe initial delay
    local readiness_delay=$(kubectl get pod oracle-pod -n apollo -o jsonpath='{.spec.containers[0].readinessProbe.initialDelaySeconds}' 2>/dev/null)
    check_criterion "Readiness probe initial delay is 5s" "$([ "$readiness_delay" = "5" ] && echo true || echo false)" && ((score++))

    # Check readiness probe period
    local readiness_period=$(kubectl get pod oracle-pod -n apollo -o jsonpath='{.spec.containers[0].readinessProbe.periodSeconds}' 2>/dev/null)
    check_criterion "Readiness probe period is 3s" "$([ "$readiness_period" = "3" ] && echo true || echo false)" && ((score++))

    echo "$score/$total"
    return 0
}

# ============================================================================
# QUESTION 14 - ServiceAccount (4 points)
# ============================================================================
score_q14() {
    local score=0
    local total=4

    echo "Question 14 | ServiceAccount"

    # Check ServiceAccount exists
    local sa_exists=$(kubectl get serviceaccount messenger-sa -n hermes 2>/dev/null && echo true || echo false)
    check_criterion "ServiceAccount messenger-sa exists" "$sa_exists" && ((score++))

    # Check Pod exists and is running
    local pod_status=$(kubectl get pod messenger-runner -n hermes -o jsonpath='{.status.phase}' 2>/dev/null)
    check_criterion "Pod messenger-runner is running" "$([ "$pod_status" = "Running" ] && echo true || echo false)" && ((score++))

    # Check Pod uses ServiceAccount
    local pod_sa=$(kubectl get pod messenger-runner -n hermes -o jsonpath='{.spec.serviceAccountName}' 2>/dev/null)
    check_criterion "Pod uses messenger-sa ServiceAccount" "$([ "$pod_sa" = "messenger-sa" ] && echo true || echo false)" && ((score++))

    # Check automountServiceAccountToken is false
    local automount=$(kubectl get pod messenger-runner -n hermes -o jsonpath='{.spec.automountServiceAccountToken}' 2>/dev/null)
    check_criterion "automountServiceAccountToken is false" "$([ "$automount" = "false" ] && echo true || echo false)" && ((score++))

    echo "$score/$total"
    return 0
}

# ============================================================================
# QUESTION 15 - Labels and Selectors (5 points)
# ============================================================================
score_q15() {
    local score=0
    local total=5

    echo "Question 15 | Labels and Selectors"

    # Check file exists
    local file="$EXAM_DIR/15/gods-pods.txt"
    check_criterion "File /exam/course/15/gods-pods.txt exists" "$([ -f "$file" ] && echo true || echo false)" && ((score++))

    # Check file has content
    if [ -f "$file" ]; then
        local line_count=$(wc -l < "$file" 2>/dev/null)
        check_criterion "File contains pod names" "$([ "$line_count" -gt 0 ] && echo true || echo false)" && ((score++))
    else
        check_criterion "File contains pod names" "false" || true
    fi

    # Check pods with role=god exist
    local god_pods=$(kubectl get pods -n olympus -l role=god -o name 2>/dev/null | wc -l)
    check_criterion "Pods with role=god exist in olympus" "$([ "$god_pods" -gt 0 ] && echo true || echo false)" && ((score++))

    # Check pods have power=divine label
    local divine_pods=$(kubectl get pods -n olympus -l role=god,power=divine -o name 2>/dev/null | wc -l)
    check_criterion "Pods with role=god have power=divine label" "$([ "$divine_pods" -gt 0 ] && echo true || echo false)" && ((score++))

    # Check all god pods have divine label
    local all_gods=$(kubectl get pods -n olympus -l role=god -o name 2>/dev/null | wc -l)
    check_criterion "All god pods have power=divine label" "$([ "$divine_pods" = "$all_gods" ] && echo true || echo false)" && ((score++))

    echo "$score/$total"
    return 0
}

# ============================================================================
# QUESTION 16 - Deployment Scaling (4 points)
# ============================================================================
score_q16() {
    local score=0
    local total=4

    echo "Question 16 | Deployment Scaling"

    # Check Deployment exists
    local deploy_exists=$(kubectl get deployment warrior-squad -n ares 2>/dev/null && echo true || echo false)
    check_criterion "Deployment warrior-squad exists" "$deploy_exists" && ((score++))

    # Check replicas is 5
    local replicas=$(kubectl get deployment warrior-squad -n ares -o jsonpath='{.spec.replicas}' 2>/dev/null)
    check_criterion "Deployment has 5 replicas" "$([ "$replicas" = "5" ] && echo true || echo false)" && ((score++))

    # Check maxSurge
    local max_surge=$(kubectl get deployment warrior-squad -n ares -o jsonpath='{.spec.strategy.rollingUpdate.maxSurge}' 2>/dev/null)
    check_criterion "maxSurge is 2" "$([ "$max_surge" = "2" ] && echo true || echo false)" && ((score++))

    # Check maxUnavailable
    local max_unavailable=$(kubectl get deployment warrior-squad -n ares -o jsonpath='{.spec.strategy.rollingUpdate.maxUnavailable}' 2>/dev/null)
    check_criterion "maxUnavailable is 1" "$([ "$max_unavailable" = "1" ] && echo true || echo false)" && ((score++))

    echo "$score/$total"
    return 0
}

# ============================================================================
# QUESTION 17 - Job with Completions (5 points)
# ============================================================================
score_q17() {
    local score=0
    local total=5

    echo "Question 17 | Job with Completions"

    # Check Job exists
    local job_exists=$(kubectl get job wisdom-task -n athena 2>/dev/null && echo true || echo false)
    check_criterion "Job wisdom-task exists" "$job_exists" && ((score++))

    # Check completions
    local completions=$(kubectl get job wisdom-task -n athena -o jsonpath='{.spec.completions}' 2>/dev/null)
    check_criterion "Job has 4 completions" "$([ "$completions" = "4" ] && echo true || echo false)" && ((score++))

    # Check parallelism
    local parallelism=$(kubectl get job wisdom-task -n athena -o jsonpath='{.spec.parallelism}' 2>/dev/null)
    check_criterion "Job has parallelism 2" "$([ "$parallelism" = "2" ] && echo true || echo false)" && ((score++))

    # Check container name
    local container_name=$(kubectl get job wisdom-task -n athena -o jsonpath='{.spec.template.spec.containers[0].name}' 2>/dev/null)
    check_criterion "Container is named wisdom-container" "$([ "$container_name" = "wisdom-container" ] && echo true || echo false)" && ((score++))

    # Check pod label
    local pod_label=$(kubectl get job wisdom-task -n athena -o jsonpath='{.spec.template.metadata.labels.task}' 2>/dev/null)
    check_criterion "Pod has label task=wisdom" "$([ "$pod_label" = "wisdom" ] && echo true || echo false)" && ((score++))

    echo "$score/$total"
    return 0
}

# ============================================================================
# QUESTION 18 - Pod Logs and Debugging (5 points)
# ============================================================================
score_q18() {
    local score=0
    local total=5

    echo "Question 18 | Pod Logs and Debugging"

    # Check Pod exists
    local pod_exists=$(kubectl get pod shadow-app -n hades 2>/dev/null && echo true || echo false)
    check_criterion "Pod shadow-app exists" "$pod_exists" && ((score++))

    # Check shadow-logs.txt exists
    local logs_file="$EXAM_DIR/18/shadow-logs.txt"
    check_criterion "File /exam/course/18/shadow-logs.txt exists" "$([ -f "$logs_file" ] && echo true || echo false)" && ((score++))

    # Check shadow-logs.txt has content
    if [ -f "$logs_file" ]; then
        local line_count=$(wc -l < "$logs_file" 2>/dev/null)
        check_criterion "Logs file has content" "$([ "$line_count" -gt 0 ] && echo true || echo false)" && ((score++))
    else
        check_criterion "Logs file has content" "false" || true
    fi

    # Check error-count.txt exists
    local error_file="$EXAM_DIR/18/error-count.txt"
    check_criterion "File /exam/course/18/error-count.txt exists" "$([ -f "$error_file" ] && echo true || echo false)" && ((score++))

    # Check error-count.txt contains a number
    if [ -f "$error_file" ]; then
        local count=$(cat "$error_file" 2>/dev/null)
        check_criterion "Error count file contains a number" "$(echo "$count" | grep -qE "^[0-9]+$" && echo true || echo false)" && ((score++))
    else
        check_criterion "Error count file contains a number" "false" || true
    fi

    echo "$score/$total"
    return 0
}

# ============================================================================
# QUESTION 19 - Annotations (3 points)
# ============================================================================
score_q19() {
    local score=0
    local total=3

    echo "Question 19 | Annotations"

    # Check description annotation
    local description=$(kubectl get pod lightning-pod -n zeus -o jsonpath='{.metadata.annotations.description}' 2>/dev/null)
    check_criterion "Pod has description annotation" "$([ "$description" = "Primary lightning generator" ] && echo true || echo false)" && ((score++))

    # Check maintainer annotation
    local maintainer=$(kubectl get pod lightning-pod -n zeus -o jsonpath='{.metadata.annotations.maintainer}' 2>/dev/null)
    check_criterion "Pod has maintainer annotation" "$([ "$maintainer" = "zeus-team@olympus.io" ] && echo true || echo false)" && ((score++))

    # Check version annotation
    local version=$(kubectl get pod lightning-pod -n zeus -o jsonpath='{.metadata.annotations.version}' 2>/dev/null)
    check_criterion "Pod has version annotation" "$([ "$version" = "2.0" ] && echo true || echo false)" && ((score++))

    echo "$score/$total"
    return 0
}

# ============================================================================
# QUESTION 20 - Container Image Build (9 points)
# ============================================================================
score_q20() {
    local score=0
    local total=9

    echo "Question 20 | Container Image Build"

    # Check Dockerfile has APP_VERSION
    local dockerfile="$EXAM_DIR/20/image/Dockerfile"
    if [ -f "$dockerfile" ]; then
        check_criterion "Dockerfile has APP_VERSION env var" "$(grep -q "APP_VERSION.*3.0.0" "$dockerfile" && echo true || echo false)" && ((score++))
    else
        check_criterion "Dockerfile has APP_VERSION env var" "false" || true
    fi

    # Check Docker image exists locally
    local docker_image_local=$(sudo docker images --format '{{.Repository}}:{{.Tag}}' 2>/dev/null | grep -q "localhost:5000/olympus-app:v1" && echo true || echo false)
    check_criterion "Docker image built locally" "$docker_image_local" && ((score++))

    # Check Docker image exists in registry
    local docker_image=$(curl -s http://localhost:5000/v2/olympus-app/tags/list 2>/dev/null | grep -q "v1" && echo true || echo false)
    check_criterion "Docker image pushed to registry" "$docker_image" && ((score++))
    check_criterion "Docker image tagged correctly" "$docker_image" && ((score++))

    # Check container is running
    local container_running=$(sudo docker ps --filter name=olympus-runner --format "{{.Names}}" 2>/dev/null | grep -q "olympus-runner" && echo true || echo false)
    check_criterion "Container olympus-runner is running" "$container_running" && ((score++))

    # Check container uses correct image
    local container_image=$(sudo docker inspect olympus-runner --format "{{.Config.Image}}" 2>/dev/null | grep -q "olympus-app" && echo true || echo false)
    check_criterion "Container uses olympus-app image" "$container_image" && ((score++))

    # Check logs file exists
    local logs_file="$EXAM_DIR/20/container-logs.txt"
    check_criterion "File /exam/course/20/container-logs.txt exists" "$([ -f "$logs_file" ] && echo true || echo false)" && ((score++))

    # Check logs file has content
    if [ -f "$logs_file" ]; then
        check_criterion "Logs file has content" "$([ -s "$logs_file" ] && echo true || echo false)" && ((score++))
    else
        check_criterion "Logs file has content" "false" || true
    fi

    # Bonus criterion for correct workflow
    check_criterion "Container workflow complete" "$([ "$container_running" = "true" ] && [ -s "$logs_file" ] && echo true || echo false)" && ((score++))

    echo "$score/$total"
    return 0
}
