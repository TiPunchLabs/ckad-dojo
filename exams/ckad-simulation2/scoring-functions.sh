#!/bin/bash
# scoring-functions.sh - Scoring functions for CKAD Simulation 2
# Each function returns the number of points scored and prints detailed results

# Source common utilities from scripts/lib/
SCRIPT_LIB_DIR="${SCRIPT_LIB_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../scripts/lib" && pwd)}"
source "$SCRIPT_LIB_DIR/common.sh"

# Exam directory for student answers
EXAM_DIR="${EXAM_DIR:-./exam/course}"

# ============================================================================
# SCORING HELPER FUNCTIONS
# ============================================================================

# Check criterion and print result
# Returns 0 if passed, 1 if failed (for use with && ((score++)))
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

    # Check if file exists and contains namespaces
    local file="$EXAM_DIR/1/namespaces"
    if [ -f "$file" ] && grep -q "default" "$file" 2>/dev/null; then
        check_criterion "File contains namespace list" "true" && ((score++))
    else
        check_criterion "File contains namespace list" "false"
    fi

    echo "$score/$total"
    return $score
}

# ============================================================================
# QUESTION 2 - Multi-container Pod (5 points)
# ============================================================================
score_q2() {
    local score=0
    local total=5

    echo "Question 2 | Multi-container Pod"

    # Check Pod exists
    local pod_exists=$(kubectl get pod multi-container-pod -n andromeda 2>/dev/null && echo true || echo false)
    check_criterion "Pod multi-container-pod exists" "$pod_exists" && ((score++))

    # Check Pod is running
    local pod_status=$(kubectl get pod multi-container-pod -n andromeda -o jsonpath='{.status.phase}' 2>/dev/null)
    check_criterion "Pod is Running" "$([ "$pod_status" = "Running" ] && echo true || echo false)" && ((score++))

    # Check container count
    local container_count=$(kubectl get pod multi-container-pod -n andromeda -o jsonpath='{.spec.containers[*].name}' 2>/dev/null | wc -w)
    check_criterion "Pod has 2 containers" "$([ "$container_count" = "2" ] && echo true || echo false)" && ((score++))

    # Check first container image
    local img1=$(kubectl get pod multi-container-pod -n andromeda -o jsonpath='{.spec.containers[0].image}' 2>/dev/null)
    check_criterion "First container uses nginx image" "$(echo "$img1" | grep -q "nginx" && echo true || echo false)" && ((score++))

    # Check second container image
    local img2=$(kubectl get pod multi-container-pod -n andromeda -o jsonpath='{.spec.containers[1].image}' 2>/dev/null)
    check_criterion "Second container uses busybox image" "$(echo "$img2" | grep -q "busybox" && echo true || echo false)" && ((score++))

    echo "$score/$total"
    return $score
}

# ============================================================================
# QUESTION 3 - CronJob (5 points)
# ============================================================================
score_q3() {
    local score=0
    local total=5

    echo "Question 3 | CronJob"

    # Check CronJob exists
    local cronjob_exists=$(kubectl get cronjob galaxy-backup -n orion 2>/dev/null && echo true || echo false)
    check_criterion "CronJob galaxy-backup exists" "$cronjob_exists" && ((score++))

    # Check schedule
    local schedule=$(kubectl get cronjob galaxy-backup -n orion -o jsonpath='{.spec.schedule}' 2>/dev/null)
    check_criterion "Schedule is */5 * * * *" "$([ "$schedule" = "*/5 * * * *" ] && echo true || echo false)" && ((score++))

    # Check image
    local image=$(kubectl get cronjob galaxy-backup -n orion -o jsonpath='{.spec.jobTemplate.spec.template.spec.containers[0].image}' 2>/dev/null)
    check_criterion "Uses busybox image" "$(echo "$image" | grep -q "busybox" && echo true || echo false)" && ((score++))

    # Check command
    local cmd=$(kubectl get cronjob galaxy-backup -n orion -o jsonpath='{.spec.jobTemplate.spec.template.spec.containers[0].command}' 2>/dev/null)
    check_criterion "Command includes echo" "$(echo "$cmd" | grep -q "echo" && echo true || echo false)" && ((score++))

    # Check YAML file exists
    local yaml_file="$EXAM_DIR/3/cronjob.yaml"
    check_criterion "YAML file saved to exam/course/3/cronjob.yaml" "$([ -f "$yaml_file" ] && echo true || echo false)" && ((score++))

    echo "$score/$total"
    return $score
}

# ============================================================================
# QUESTION 4 - Deployment Scaling (4 points)
# ============================================================================
score_q4() {
    local score=0
    local total=4

    echo "Question 4 | Deployment Scaling"

    # Check Deployment exists
    local deploy_exists=$(kubectl get deployment star-app -n pegasus 2>/dev/null && echo true || echo false)
    check_criterion "Deployment star-app exists" "$deploy_exists" && ((score++))

    # Check replica count
    local replicas=$(kubectl get deployment star-app -n pegasus -o jsonpath='{.spec.replicas}' 2>/dev/null)
    check_criterion "Deployment has 5 replicas" "$([ "$replicas" = "5" ] && echo true || echo false)" && ((score++))

    # Check all pods are ready
    local ready=$(kubectl get deployment star-app -n pegasus -o jsonpath='{.status.readyReplicas}' 2>/dev/null)
    check_criterion "All 5 replicas are ready" "$([ "$ready" = "5" ] && echo true || echo false)" && ((score++))

    # Check command file exists
    local cmd_file="$EXAM_DIR/4/scale-command.sh"
    if [ -f "$cmd_file" ] && grep -q "kubectl scale" "$cmd_file" 2>/dev/null; then
        check_criterion "Scale command saved to file" "true" && ((score++))
    else
        check_criterion "Scale command saved to file" "false"
    fi

    echo "$score/$total"
    return $score
}

# ============================================================================
# QUESTION 5 - Deployment Troubleshooting (6 points)
# ============================================================================
score_q5() {
    local score=0
    local total=6

    echo "Question 5 | Deployment Troubleshooting"

    # Check Deployment exists
    local deploy_exists=$(kubectl get deployment broken-app -n cygnus 2>/dev/null && echo true || echo false)
    check_criterion "Deployment broken-app exists" "$deploy_exists" && ((score++))

    # Check image is corrected (nginx instead of ngnix)
    local image=$(kubectl get deployment broken-app -n cygnus -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null)
    check_criterion "Image typo fixed (nginx)" "$(echo "$image" | grep -qE "^nginx:" && echo true || echo false)" && ((score++))

    # Check deployment is available
    local available=$(kubectl get deployment broken-app -n cygnus -o jsonpath='{.status.availableReplicas}' 2>/dev/null)
    check_criterion "Deployment has available replicas" "$([ -n "$available" ] && [ "$available" -gt 0 ] && echo true || echo false)" && ((score++))

    # Check pods are running
    local running_pods=$(kubectl get pods -n cygnus -l app=broken-app --field-selector=status.phase=Running 2>/dev/null | grep -c "Running")
    check_criterion "Pods are Running" "$([ "$running_pods" -gt 0 ] && echo true || echo false)" && ((score++))

    # Check reason file exists
    local reason_file="$EXAM_DIR/5/fix-reason.txt"
    check_criterion "Fix reason documented" "$([ -f "$reason_file" ] && echo true || echo false)" && ((score++))

    # Check rollout status
    local rollout=$(kubectl rollout status deployment/broken-app -n cygnus --timeout=5s 2>/dev/null && echo true || echo false)
    check_criterion "Rollout completed successfully" "$rollout" && ((score++))

    echo "$score/$total"
    return $score
}

# ============================================================================
# QUESTION 6 - ConfigMap Volume Mount (5 points)
# ============================================================================
score_q6() {
    local score=0
    local total=5

    echo "Question 6 | ConfigMap Volume Mount"

    # Check ConfigMap exists
    local cm_exists=$(kubectl get configmap app-config -n lyra 2>/dev/null && echo true || echo false)
    check_criterion "ConfigMap app-config exists" "$cm_exists" && ((score++))

    # Check Pod exists
    local pod_exists=$(kubectl get pod config-pod -n lyra 2>/dev/null && echo true || echo false)
    check_criterion "Pod config-pod exists" "$pod_exists" && ((score++))

    # Check Pod is running
    local pod_status=$(kubectl get pod config-pod -n lyra -o jsonpath='{.status.phase}' 2>/dev/null)
    check_criterion "Pod is Running" "$([ "$pod_status" = "Running" ] && echo true || echo false)" && ((score++))

    # Check volume mount exists
    local mount=$(kubectl get pod config-pod -n lyra -o jsonpath='{.spec.containers[0].volumeMounts[*].mountPath}' 2>/dev/null)
    check_criterion "ConfigMap mounted as volume" "$(echo "$mount" | grep -q "/etc/config" && echo true || echo false)" && ((score++))

    # Check ConfigMap has correct data
    local data=$(kubectl get configmap app-config -n lyra -o jsonpath='{.data.app\.properties}' 2>/dev/null)
    check_criterion "ConfigMap contains app.properties" "$([ -n "$data" ] && echo true || echo false)" && ((score++))

    echo "$score/$total"
    return $score
}

# ============================================================================
# QUESTION 7 - Secret Environment Variables (5 points)
# ============================================================================
score_q7() {
    local score=0
    local total=5

    echo "Question 7 | Secret Environment Variables"

    # Check Secret exists
    local secret_exists=$(kubectl get secret db-credentials -n aquila 2>/dev/null && echo true || echo false)
    check_criterion "Secret db-credentials exists" "$secret_exists" && ((score++))

    # Check Pod exists
    local pod_exists=$(kubectl get pod secret-pod -n aquila 2>/dev/null && echo true || echo false)
    check_criterion "Pod secret-pod exists" "$pod_exists" && ((score++))

    # Check Pod is running
    local pod_status=$(kubectl get pod secret-pod -n aquila -o jsonpath='{.status.phase}' 2>/dev/null)
    check_criterion "Pod is Running" "$([ "$pod_status" = "Running" ] && echo true || echo false)" && ((score++))

    # Check env from secret
    local env_from=$(kubectl get pod secret-pod -n aquila -o jsonpath='{.spec.containers[0].env[*].valueFrom.secretKeyRef.name}' 2>/dev/null)
    check_criterion "Environment uses secretKeyRef" "$(echo "$env_from" | grep -q "db-credentials" && echo true || echo false)" && ((score++))

    # Check specific env var DB_PASSWORD exists
    local db_pass_ref=$(kubectl get pod secret-pod -n aquila -o json 2>/dev/null | grep -q "DB_PASSWORD" && echo true || echo false)
    check_criterion "DB_PASSWORD env var configured" "$db_pass_ref" && ((score++))

    echo "$score/$total"
    return $score
}

# ============================================================================
# QUESTION 8 - Service NodePort (4 points)
# ============================================================================
score_q8() {
    local score=0
    local total=4

    echo "Question 8 | Service NodePort"

    # Check Service exists
    local svc_exists=$(kubectl get service web-service -n draco 2>/dev/null && echo true || echo false)
    check_criterion "Service web-service exists" "$svc_exists" && ((score++))

    # Check Service type
    local svc_type=$(kubectl get service web-service -n draco -o jsonpath='{.spec.type}' 2>/dev/null)
    check_criterion "Service type is NodePort" "$([ "$svc_type" = "NodePort" ] && echo true || echo false)" && ((score++))

    # Check port
    local port=$(kubectl get service web-service -n draco -o jsonpath='{.spec.ports[0].port}' 2>/dev/null)
    check_criterion "Service port is 80" "$([ "$port" = "80" ] && echo true || echo false)" && ((score++))

    # Check selector matches Pod
    local selector=$(kubectl get service web-service -n draco -o jsonpath='{.spec.selector.app}' 2>/dev/null)
    check_criterion "Service selector configured" "$([ -n "$selector" ] && echo true || echo false)" && ((score++))

    echo "$score/$total"
    return $score
}

# ============================================================================
# QUESTION 9 - Pod to Deployment Conversion (8 points)
# ============================================================================
score_q9() {
    local score=0
    local total=8

    echo "Question 9 | Pod to Deployment Conversion"

    # Check original Pod deleted
    local pod_deleted=$(kubectl get pod galaxy-api -n phoenix 2>/dev/null && echo false || echo true)
    check_criterion "Original Pod galaxy-api deleted" "$pod_deleted" && ((score++))

    # Check Deployment exists
    local deploy_exists=$(kubectl get deployment galaxy-api -n phoenix 2>/dev/null && echo true || echo false)
    check_criterion "Deployment galaxy-api exists" "$deploy_exists" && ((score++))

    # Check replicas
    local replicas=$(kubectl get deployment galaxy-api -n phoenix -o jsonpath='{.spec.replicas}' 2>/dev/null)
    check_criterion "Deployment has 3 replicas" "$([ "$replicas" = "3" ] && echo true || echo false)" && ((score++))

    # Check all replicas ready
    local ready=$(kubectl get deployment galaxy-api -n phoenix -o jsonpath='{.status.readyReplicas}' 2>/dev/null)
    check_criterion "All 3 replicas ready" "$([ "$ready" = "3" ] && echo true || echo false)" && ((score++))

    # Check security context - allowPrivilegeEscalation
    local priv_esc=$(kubectl get deployment galaxy-api -n phoenix -o jsonpath='{.spec.template.spec.containers[0].securityContext.allowPrivilegeEscalation}' 2>/dev/null)
    check_criterion "allowPrivilegeEscalation: false" "$([ "$priv_esc" = "false" ] && echo true || echo false)" && ((score++))

    # Check security context - privileged
    local privileged=$(kubectl get deployment galaxy-api -n phoenix -o jsonpath='{.spec.template.spec.containers[0].securityContext.privileged}' 2>/dev/null)
    check_criterion "privileged: false" "$([ "$privileged" = "false" ] && echo true || echo false)" && ((score++))

    # Check YAML file saved
    local yaml_file="$EXAM_DIR/9/galaxy-api-deployment.yaml"
    check_criterion "YAML saved to exam/course/9/" "$([ -f "$yaml_file" ] && echo true || echo false)" && ((score++))

    # Check image preserved
    local image=$(kubectl get deployment galaxy-api -n phoenix -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null)
    check_criterion "Original image preserved" "$([ -n "$image" ] && echo true || echo false)" && ((score++))

    echo "$score/$total"
    return $score
}

# ============================================================================
# QUESTION 10 - PV/PVC Creation (6 points)
# ============================================================================
score_q10() {
    local score=0
    local total=6

    echo "Question 10 | PV/PVC Creation"

    # Check PV exists
    local pv_exists=$(kubectl get pv galaxy-pv 2>/dev/null && echo true || echo false)
    check_criterion "PersistentVolume galaxy-pv exists" "$pv_exists" && ((score++))

    # Check PV capacity
    local pv_cap=$(kubectl get pv galaxy-pv -o jsonpath='{.spec.capacity.storage}' 2>/dev/null)
    check_criterion "PV capacity is 1Gi" "$([ "$pv_cap" = "1Gi" ] && echo true || echo false)" && ((score++))

    # Check PVC exists
    local pvc_exists=$(kubectl get pvc galaxy-pvc -n hydra 2>/dev/null && echo true || echo false)
    check_criterion "PersistentVolumeClaim galaxy-pvc exists" "$pvc_exists" && ((score++))

    # Check PVC is Bound
    local pvc_status=$(kubectl get pvc galaxy-pvc -n hydra -o jsonpath='{.status.phase}' 2>/dev/null)
    check_criterion "PVC is Bound" "$([ "$pvc_status" = "Bound" ] && echo true || echo false)" && ((score++))

    # Check Pod exists with PVC
    local pod_exists=$(kubectl get pod storage-pod -n hydra 2>/dev/null && echo true || echo false)
    check_criterion "Pod storage-pod exists" "$pod_exists" && ((score++))

    # Check Pod mounts PVC
    local pvc_mount=$(kubectl get pod storage-pod -n hydra -o jsonpath='{.spec.volumes[*].persistentVolumeClaim.claimName}' 2>/dev/null)
    check_criterion "Pod mounts galaxy-pvc" "$(echo "$pvc_mount" | grep -q "galaxy-pvc" && echo true || echo false)" && ((score++))

    echo "$score/$total"
    return $score
}

# ============================================================================
# QUESTION 11 - NetworkPolicy (6 points)
# ============================================================================
score_q11() {
    local score=0
    local total=6

    echo "Question 11 | NetworkPolicy"

    # Check NetworkPolicy exists
    local np_exists=$(kubectl get networkpolicy allow-internal -n centaurus 2>/dev/null && echo true || echo false)
    check_criterion "NetworkPolicy allow-internal exists" "$np_exists" && ((score++))

    # Check policy type includes Ingress
    local ingress=$(kubectl get networkpolicy allow-internal -n centaurus -o jsonpath='{.spec.policyTypes}' 2>/dev/null)
    check_criterion "Policy includes Ingress" "$(echo "$ingress" | grep -q "Ingress" && echo true || echo false)" && ((score++))

    # Check podSelector
    local pod_sel=$(kubectl get networkpolicy allow-internal -n centaurus -o jsonpath='{.spec.podSelector.matchLabels}' 2>/dev/null)
    check_criterion "podSelector configured" "$([ -n "$pod_sel" ] && echo true || echo false)" && ((score++))

    # Check ingress from rules
    local from_rules=$(kubectl get networkpolicy allow-internal -n centaurus -o jsonpath='{.spec.ingress[0].from}' 2>/dev/null)
    check_criterion "Ingress from rules defined" "$([ -n "$from_rules" ] && echo true || echo false)" && ((score++))

    # Check YAML file saved
    local yaml_file="$EXAM_DIR/11/networkpolicy.yaml"
    check_criterion "YAML saved to exam/course/11/" "$([ -f "$yaml_file" ] && echo true || echo false)" && ((score++))

    # Check pods can communicate (basic test)
    check_criterion "NetworkPolicy applied successfully" "$np_exists" && ((score++))

    echo "$score/$total"
    return $score
}

# ============================================================================
# QUESTION 12 - Container Image Build (7 points)
# ============================================================================
score_q12() {
    local score=0
    local total=7

    echo "Question 12 | Container Image Build"

    # Check Dockerfile exists
    local dockerfile="$EXAM_DIR/12/image/Dockerfile"
    check_criterion "Dockerfile exists in exam/course/12/image/" "$([ -f "$dockerfile" ] && echo true || echo false)" && ((score++))

    # Check Dockerfile has FROM
    check_criterion "Dockerfile has FROM instruction" "$(grep -q "^FROM" "$dockerfile" 2>/dev/null && echo true || echo false)" && ((score++))

    # Check image exists in local registry
    local image_exists=$(curl -s http://localhost:5000/v2/galaxy-app/tags/list 2>/dev/null | grep -q "v1" && echo true || echo false)
    check_criterion "Image pushed to localhost:5000" "$image_exists" && ((score++))

    # Check Pod exists using the image
    local pod_exists=$(kubectl get pod image-test-pod -n cassiopeia 2>/dev/null && echo true || echo false)
    check_criterion "Pod image-test-pod created" "$pod_exists" && ((score++))

    # Check Pod uses correct image
    local pod_image=$(kubectl get pod image-test-pod -n cassiopeia -o jsonpath='{.spec.containers[0].image}' 2>/dev/null)
    check_criterion "Pod uses localhost:5000/galaxy-app:v1" "$(echo "$pod_image" | grep -q "localhost:5000/galaxy-app" && echo true || echo false)" && ((score++))

    # Check Pod is running
    local pod_status=$(kubectl get pod image-test-pod -n cassiopeia -o jsonpath='{.status.phase}' 2>/dev/null)
    check_criterion "Pod is Running" "$([ "$pod_status" = "Running" ] && echo true || echo false)" && ((score++))

    # Check logs file
    local logs_file="$EXAM_DIR/12/logs"
    check_criterion "Pod logs saved to exam/course/12/logs" "$([ -f "$logs_file" ] && echo true || echo false)" && ((score++))

    echo "$score/$total"
    return $score
}

# ============================================================================
# QUESTION 13 - Helm Operations (5 points)
# ============================================================================
score_q13() {
    local score=0
    local total=5

    echo "Question 13 | Helm Operations"

    # Check release galaxy-nginx-v1 deleted
    local v1_exists=$(helm list -n andromeda -q 2>/dev/null | grep -q "galaxy-nginx-v1" && echo true || echo false)
    check_criterion "Deleted Helm release galaxy-nginx-v1" "$([ "$v1_exists" = "false" ] && echo true || echo false)" && ((score++))

    # Check release galaxy-nginx-v2 upgraded
    local v2_history=$(helm history galaxy-nginx-v2 -n andromeda 2>/dev/null | wc -l)
    check_criterion "Upgraded Helm release galaxy-nginx-v2" "$([ "$v2_history" -gt 1 ] && echo true || echo false)" && ((score++))

    # Check new release installed
    local new_release=$(helm list -n andromeda -q 2>/dev/null | grep -q "galaxy-redis" && echo true || echo false)
    check_criterion "Installed new release galaxy-redis" "$new_release" && ((score++))

    # Check new release has correct replicas
    local redis_replicas=$(kubectl get statefulset -n andromeda -l app.kubernetes.io/instance=galaxy-redis -o jsonpath='{.items[0].spec.replicas}' 2>/dev/null)
    check_criterion "galaxy-redis has 2 replicas" "$([ "$redis_replicas" = "2" ] && echo true || echo false)" && ((score++))

    # Check broken release deleted
    local broken=$(helm list -n andromeda -a -o json 2>/dev/null | grep -q "pending-install" && echo true || echo false)
    check_criterion "Deleted broken release" "$([ "$broken" = "false" ] && echo true || echo false)" && ((score++))

    echo "$score/$total"
    return $score
}

# ============================================================================
# QUESTION 14 - InitContainer (5 points)
# ============================================================================
score_q14() {
    local score=0
    local total=5

    echo "Question 14 | InitContainer"

    # Check Pod/Deployment exists
    local deploy_exists=$(kubectl get deployment init-app -n orion 2>/dev/null && echo true || echo false)
    check_criterion "Deployment init-app exists" "$deploy_exists" && ((score++))

    # Check InitContainer exists
    local init_name=$(kubectl get deployment init-app -n orion -o jsonpath='{.spec.template.spec.initContainers[0].name}' 2>/dev/null)
    check_criterion "InitContainer configured" "$([ -n "$init_name" ] && echo true || echo false)" && ((score++))

    # Check InitContainer uses correct image
    local init_image=$(kubectl get deployment init-app -n orion -o jsonpath='{.spec.template.spec.initContainers[0].image}' 2>/dev/null)
    check_criterion "InitContainer uses busybox" "$(echo "$init_image" | grep -q "busybox" && echo true || echo false)" && ((score++))

    # Check shared volume exists
    local volume=$(kubectl get deployment init-app -n orion -o jsonpath='{.spec.template.spec.volumes[*].name}' 2>/dev/null)
    check_criterion "Shared volume configured" "$([ -n "$volume" ] && echo true || echo false)" && ((score++))

    # Check pods are running
    local ready=$(kubectl get deployment init-app -n orion -o jsonpath='{.status.readyReplicas}' 2>/dev/null)
    check_criterion "Deployment is ready" "$([ -n "$ready" ] && [ "$ready" -gt 0 ] && echo true || echo false)" && ((score++))

    echo "$score/$total"
    return $score
}

# ============================================================================
# QUESTION 15 - Sidecar Logging (6 points)
# ============================================================================
score_q15() {
    local score=0
    local total=6

    echo "Question 15 | Sidecar Logging"

    # Check Deployment exists
    local deploy_exists=$(kubectl get deployment logger-app -n pegasus 2>/dev/null && echo true || echo false)
    check_criterion "Deployment logger-app exists" "$deploy_exists" && ((score++))

    # Check container count (should be 2)
    local containers=$(kubectl get deployment logger-app -n pegasus -o jsonpath='{.spec.template.spec.containers[*].name}' 2>/dev/null | wc -w)
    check_criterion "Deployment has 2 containers" "$([ "$containers" = "2" ] && echo true || echo false)" && ((score++))

    # Check sidecar container exists
    local sidecar=$(kubectl get deployment logger-app -n pegasus -o jsonpath='{.spec.template.spec.containers[1].name}' 2>/dev/null)
    check_criterion "Sidecar container configured" "$([ -n "$sidecar" ] && echo true || echo false)" && ((score++))

    # Check shared volume for logs
    local volume=$(kubectl get deployment logger-app -n pegasus -o jsonpath='{.spec.template.spec.volumes[*].name}' 2>/dev/null)
    check_criterion "Shared log volume configured" "$(echo "$volume" | grep -qE "log|shared" && echo true || echo false)" && ((score++))

    # Check YAML file saved
    local yaml_file="$EXAM_DIR/15/logger-app.yaml"
    check_criterion "YAML saved to exam/course/15/" "$([ -f "$yaml_file" ] && echo true || echo false)" && ((score++))

    # Check deployment is running
    local ready=$(kubectl get deployment logger-app -n pegasus -o jsonpath='{.status.readyReplicas}' 2>/dev/null)
    check_criterion "Deployment is ready" "$([ -n "$ready" ] && [ "$ready" -gt 0 ] && echo true || echo false)" && ((score++))

    echo "$score/$total"
    return $score
}

# ============================================================================
# QUESTION 16 - ServiceAccount Token (2 points)
# ============================================================================
score_q16() {
    local score=0
    local total=2

    echo "Question 16 | ServiceAccount Token"

    # Check ServiceAccount exists
    local sa_exists=$(kubectl get serviceaccount galaxy-sa -n cygnus 2>/dev/null && echo true || echo false)
    check_criterion "ServiceAccount galaxy-sa exists" "$sa_exists" && ((score++))

    # Check token file saved
    local token_file="$EXAM_DIR/16/token"
    if [ -f "$token_file" ]; then
        local token_content=$(cat "$token_file" 2>/dev/null)
        check_criterion "Token saved (base64 decoded)" "$([ -n "$token_content" ] && echo true || echo false)" && ((score++))
    else
        check_criterion "Token saved (base64 decoded)" "false"
    fi

    echo "$score/$total"
    return $score
}

# ============================================================================
# QUESTION 17 - Liveness Probe (5 points)
# ============================================================================
score_q17() {
    local score=0
    local total=5

    echo "Question 17 | Liveness Probe"

    # Check Pod exists
    local pod_exists=$(kubectl get pod liveness-pod -n lyra 2>/dev/null && echo true || echo false)
    check_criterion "Pod liveness-pod exists" "$pod_exists" && ((score++))

    # Check Pod is running
    local pod_status=$(kubectl get pod liveness-pod -n lyra -o jsonpath='{.status.phase}' 2>/dev/null)
    check_criterion "Pod is Running" "$([ "$pod_status" = "Running" ] && echo true || echo false)" && ((score++))

    # Check livenessProbe configured
    local liveness=$(kubectl get pod liveness-pod -n lyra -o jsonpath='{.spec.containers[0].livenessProbe}' 2>/dev/null)
    check_criterion "Liveness probe configured" "$([ -n "$liveness" ] && echo true || echo false)" && ((score++))

    # Check httpGet path
    local path=$(kubectl get pod liveness-pod -n lyra -o jsonpath='{.spec.containers[0].livenessProbe.httpGet.path}' 2>/dev/null)
    check_criterion "Probe uses httpGet" "$([ -n "$path" ] && echo true || echo false)" && ((score++))

    # Check initialDelaySeconds
    local delay=$(kubectl get pod liveness-pod -n lyra -o jsonpath='{.spec.containers[0].livenessProbe.initialDelaySeconds}' 2>/dev/null)
    check_criterion "initialDelaySeconds configured" "$([ -n "$delay" ] && echo true || echo false)" && ((score++))

    echo "$score/$total"
    return $score
}

# ============================================================================
# QUESTION 18 - Readiness Probe (5 points)
# ============================================================================
score_q18() {
    local score=0
    local total=5

    echo "Question 18 | Readiness Probe"

    # Check Pod exists
    local pod_exists=$(kubectl get pod readiness-pod -n aquila 2>/dev/null && echo true || echo false)
    check_criterion "Pod readiness-pod exists" "$pod_exists" && ((score++))

    # Check Pod is running
    local pod_status=$(kubectl get pod readiness-pod -n aquila -o jsonpath='{.status.phase}' 2>/dev/null)
    check_criterion "Pod is Running" "$([ "$pod_status" = "Running" ] && echo true || echo false)" && ((score++))

    # Check readinessProbe configured
    local readiness=$(kubectl get pod readiness-pod -n aquila -o jsonpath='{.spec.containers[0].readinessProbe}' 2>/dev/null)
    check_criterion "Readiness probe configured" "$([ -n "$readiness" ] && echo true || echo false)" && ((score++))

    # Check exec command
    local exec_cmd=$(kubectl get pod readiness-pod -n aquila -o jsonpath='{.spec.containers[0].readinessProbe.exec.command}' 2>/dev/null)
    check_criterion "Probe uses exec command" "$([ -n "$exec_cmd" ] && echo true || echo false)" && ((score++))

    # Check periodSeconds
    local period=$(kubectl get pod readiness-pod -n aquila -o jsonpath='{.spec.containers[0].readinessProbe.periodSeconds}' 2>/dev/null)
    check_criterion "periodSeconds configured" "$([ -n "$period" ] && echo true || echo false)" && ((score++))

    echo "$score/$total"
    return $score
}

# ============================================================================
# QUESTION 19 - Resource Limits (5 points)
# ============================================================================
score_q19() {
    local score=0
    local total=5

    echo "Question 19 | Resource Limits"

    # Check Deployment exists
    local deploy_exists=$(kubectl get deployment resource-app -n draco 2>/dev/null && echo true || echo false)
    check_criterion "Deployment resource-app exists" "$deploy_exists" && ((score++))

    # Check memory request
    local mem_req=$(kubectl get deployment resource-app -n draco -o jsonpath='{.spec.template.spec.containers[0].resources.requests.memory}' 2>/dev/null)
    check_criterion "Memory request: 64Mi" "$([ "$mem_req" = "64Mi" ] && echo true || echo false)" && ((score++))

    # Check memory limit
    local mem_limit=$(kubectl get deployment resource-app -n draco -o jsonpath='{.spec.template.spec.containers[0].resources.limits.memory}' 2>/dev/null)
    check_criterion "Memory limit: 128Mi" "$([ "$mem_limit" = "128Mi" ] && echo true || echo false)" && ((score++))

    # Check CPU request
    local cpu_req=$(kubectl get deployment resource-app -n draco -o jsonpath='{.spec.template.spec.containers[0].resources.requests.cpu}' 2>/dev/null)
    check_criterion "CPU request: 100m" "$([ "$cpu_req" = "100m" ] && echo true || echo false)" && ((score++))

    # Check CPU limit
    local cpu_limit=$(kubectl get deployment resource-app -n draco -o jsonpath='{.spec.template.spec.containers[0].resources.limits.cpu}' 2>/dev/null)
    check_criterion "CPU limit: 200m" "$([ "$cpu_limit" = "200m" ] && echo true || echo false)" && ((score++))

    echo "$score/$total"
    return $score
}

# ============================================================================
# QUESTION 20 - Labels and Selectors (4 points)
# ============================================================================
score_q20() {
    local score=0
    local total=4

    echo "Question 20 | Labels and Selectors"

    # Check Pod has required labels
    local pod_labels=$(kubectl get pod labeled-pod -n phoenix -o jsonpath='{.metadata.labels}' 2>/dev/null)
    check_criterion "Pod labeled-pod has labels" "$([ -n "$pod_labels" ] && echo true || echo false)" && ((score++))

    # Check specific label app=galaxy
    local app_label=$(kubectl get pod labeled-pod -n phoenix -o jsonpath='{.metadata.labels.app}' 2>/dev/null)
    check_criterion "Label app=galaxy exists" "$([ "$app_label" = "galaxy" ] && echo true || echo false)" && ((score++))

    # Check label tier=frontend
    local tier_label=$(kubectl get pod labeled-pod -n phoenix -o jsonpath='{.metadata.labels.tier}' 2>/dev/null)
    check_criterion "Label tier=frontend exists" "$([ "$tier_label" = "frontend" ] && echo true || echo false)" && ((score++))

    # Check output file with selector query
    local output_file="$EXAM_DIR/20/selected-pods.txt"
    check_criterion "Selected pods saved to file" "$([ -f "$output_file" ] && echo true || echo false)" && ((score++))

    echo "$score/$total"
    return $score
}

# ============================================================================
# QUESTION 21 - Rollback Deployment (3 points)
# ============================================================================
score_q21() {
    local score=0
    local total=3

    echo "Question 21 | Rollback Deployment"

    # Check Deployment exists
    local deploy_exists=$(kubectl get deployment rollback-app -n hydra 2>/dev/null && echo true || echo false)
    check_criterion "Deployment rollback-app exists" "$deploy_exists" && ((score++))

    # Check image is rolled back (nginx:1.19 not nginx:broken)
    local image=$(kubectl get deployment rollback-app -n hydra -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null)
    check_criterion "Image rolled back (not :broken)" "$(echo "$image" | grep -qv "broken" && echo true || echo false)" && ((score++))

    # Check deployment is available
    local ready=$(kubectl get deployment rollback-app -n hydra -o jsonpath='{.status.readyReplicas}' 2>/dev/null)
    check_criterion "Deployment is ready after rollback" "$([ -n "$ready" ] && [ "$ready" -gt 0 ] && echo true || echo false)" && ((score++))

    echo "$score/$total"
    return $score
}

# ============================================================================
# PREVIEW QUESTION 1 - Startup Probe (4 points)
# ============================================================================
score_preview_q1() {
    local score=0
    local total=4

    echo "Preview Question 1 | Startup Probe"

    # Check Pod exists
    local pod_exists=$(kubectl get pod startup-pod -n centaurus 2>/dev/null && echo true || echo false)
    check_criterion "Pod startup-pod exists" "$pod_exists" && ((score++))

    # Check startupProbe configured
    local startup=$(kubectl get pod startup-pod -n centaurus -o jsonpath='{.spec.containers[0].startupProbe}' 2>/dev/null)
    check_criterion "Startup probe configured" "$([ -n "$startup" ] && echo true || echo false)" && ((score++))

    # Check failureThreshold
    local threshold=$(kubectl get pod startup-pod -n centaurus -o jsonpath='{.spec.containers[0].startupProbe.failureThreshold}' 2>/dev/null)
    check_criterion "failureThreshold configured" "$([ -n "$threshold" ] && echo true || echo false)" && ((score++))

    # Check periodSeconds
    local period=$(kubectl get pod startup-pod -n centaurus -o jsonpath='{.spec.containers[0].startupProbe.periodSeconds}' 2>/dev/null)
    check_criterion "periodSeconds configured" "$([ -n "$period" ] && echo true || echo false)" && ((score++))

    echo "$score/$total"
    return $score
}
