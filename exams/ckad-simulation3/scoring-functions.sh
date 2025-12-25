#!/bin/bash
# scoring-functions.sh - Scoring functions for CKAD Simulation 3 - Dojo Byakko
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
# QUESTION 1 - kubectl explain (2 points)
# ============================================================================
score_q1() {
    local score=0
    local total=2

    echo "Question 1 | kubectl explain"

    # Check if file exists
    local file="$EXAM_DIR/1/pod-spec-fields.txt"
    check_criterion "File /exam/course/1/pod-spec-fields.txt exists" "$([ -f "$file" ] && echo true || echo false)" && ((score++))

    # Check file contains resources documentation
    if [ -f "$file" ]; then
        check_criterion "File contains resources field documentation" "$(grep -qi "resources\|limits\|requests" "$file" && echo true || echo false)" && ((score++))
    else
        check_criterion "File contains resources field documentation" "false" || true
    fi

    echo "$score/$total"
    return 0
}

# ============================================================================
# QUESTION 2 - Pod Anti-Affinity (7 points)
# ============================================================================
score_q2() {
    local score=0
    local total=7

    echo "Question 2 | Pod Anti-Affinity"

    # Check Deployment exists
    local deploy_exists=$(kubectl get deployment spread-pods -n tiger 2>/dev/null && echo true || echo false)
    check_criterion "Deployment spread-pods exists" "$deploy_exists" && ((score++))

    # Check replicas
    local replicas=$(kubectl get deployment spread-pods -n tiger -o jsonpath='{.spec.replicas}' 2>/dev/null)
    check_criterion "Deployment has 3 replicas" "$([ "$replicas" = "3" ] && echo true || echo false)" && ((score++))

    # Check container name
    local container_name=$(kubectl get deployment spread-pods -n tiger -o jsonpath='{.spec.template.spec.containers[0].name}' 2>/dev/null)
    check_criterion "Container named web" "$([ "$container_name" = "web" ] && echo true || echo false)" && ((score++))

    # Check labels
    local app_label=$(kubectl get deployment spread-pods -n tiger -o jsonpath='{.spec.template.metadata.labels.app}' 2>/dev/null)
    check_criterion "Pod has label app=spread-pods" "$([ "$app_label" = "spread-pods" ] && echo true || echo false)" && ((score++))

    # Check anti-affinity exists
    local anti_affinity=$(kubectl get deployment spread-pods -n tiger -o jsonpath='{.spec.template.spec.affinity.podAntiAffinity}' 2>/dev/null)
    check_criterion "Pod anti-affinity configured" "$([ -n "$anti_affinity" ] && echo true || echo false)" && ((score++))

    # Check required anti-affinity
    local required=$(kubectl get deployment spread-pods -n tiger -o jsonpath='{.spec.template.spec.affinity.podAntiAffinity.requiredDuringSchedulingIgnoredDuringExecution}' 2>/dev/null)
    check_criterion "Uses requiredDuringSchedulingIgnoredDuringExecution" "$([ -n "$required" ] && echo true || echo false)" && ((score++))

    # Check topology key
    local topology=$(kubectl get deployment spread-pods -n tiger -o json 2>/dev/null | grep -o '"topologyKey"[^,]*' | head -1)
    check_criterion "Topology key is kubernetes.io/hostname" "$(echo "$topology" | grep -q "kubernetes.io/hostname" && echo true || echo false)" && ((score++))

    echo "$score/$total"
    return 0
}

# ============================================================================
# QUESTION 3 - Blue-Green Deployment (7 points)
# ============================================================================
score_q3() {
    local score=0
    local total=7

    echo "Question 3 | Blue-Green Deployment"

    # Check green deployment exists
    local green_exists=$(kubectl get deployment stable-green -n stripe 2>/dev/null && echo true || echo false)
    check_criterion "Deployment stable-green exists" "$green_exists" && ((score++))

    # Check green deployment image
    local green_image=$(kubectl get deployment stable-green -n stripe -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null)
    check_criterion "Green deployment uses nginx:1.22" "$(echo "$green_image" | grep -q "nginx:1.22" && echo true || echo false)" && ((score++))

    # Check green deployment replicas
    local green_replicas=$(kubectl get deployment stable-green -n stripe -o jsonpath='{.spec.replicas}' 2>/dev/null)
    check_criterion "Green deployment has 3 replicas" "$([ "$green_replicas" = "3" ] && echo true || echo false)" && ((score++))

    # Check green deployment labels
    local green_version=$(kubectl get deployment stable-green -n stripe -o jsonpath='{.spec.template.metadata.labels.version}' 2>/dev/null)
    check_criterion "Green pods have version=green label" "$([ "$green_version" = "green" ] && echo true || echo false)" && ((score++))

    # Check service exists
    local svc_exists=$(kubectl get service web-service -n stripe 2>/dev/null && echo true || echo false)
    check_criterion "Service web-service exists" "$svc_exists" && ((score++))

    # Check service selector targets green
    local svc_selector=$(kubectl get service web-service -n stripe -o jsonpath='{.spec.selector.version}' 2>/dev/null)
    check_criterion "Service selector targets version=green" "$([ "$svc_selector" = "green" ] && echo true || echo false)" && ((score++))

    # Check service has endpoints (green pods)
    local endpoints=$(kubectl get endpoints web-service -n stripe -o jsonpath='{.subsets[0].addresses}' 2>/dev/null)
    check_criterion "Service has green pod endpoints" "$([ -n "$endpoints" ] && echo true || echo false)" && ((score++))

    echo "$score/$total"
    return 0
}

# ============================================================================
# QUESTION 4 - CronJob Advanced (6 points)
# ============================================================================
score_q4() {
    local score=0
    local total=6

    echo "Question 4 | CronJob Advanced"

    # Check CronJob exists
    local cj_exists=$(kubectl get cronjob data-sync -n prowl 2>/dev/null && echo true || echo false)
    check_criterion "CronJob data-sync exists" "$cj_exists" && ((score++))

    # Check startingDeadlineSeconds
    local deadline=$(kubectl get cronjob data-sync -n prowl -o jsonpath='{.spec.startingDeadlineSeconds}' 2>/dev/null)
    check_criterion "startingDeadlineSeconds is 200" "$([ "$deadline" = "200" ] && echo true || echo false)" && ((score++))

    # Check concurrencyPolicy
    local concurrency=$(kubectl get cronjob data-sync -n prowl -o jsonpath='{.spec.concurrencyPolicy}' 2>/dev/null)
    check_criterion "concurrencyPolicy is Forbid" "$([ "$concurrency" = "Forbid" ] && echo true || echo false)" && ((score++))

    # Check suspend is false (resumed)
    local suspend=$(kubectl get cronjob data-sync -n prowl -o jsonpath='{.spec.suspend}' 2>/dev/null)
    check_criterion "CronJob is not suspended" "$([ "$suspend" = "false" ] || [ -z "$suspend" ] && echo true || echo false)" && ((score++))

    # Check CronJob has schedule
    local schedule=$(kubectl get cronjob data-sync -n prowl -o jsonpath='{.spec.schedule}' 2>/dev/null)
    check_criterion "CronJob has valid schedule" "$([ -n "$schedule" ] && echo true || echo false)" && ((score++))

    # Check CronJob is active
    check_criterion "CronJob is actively scheduling" "$([ "$suspend" != "true" ] && echo true || echo false)" && ((score++))

    echo "$score/$total"
    return 0
}

# ============================================================================
# QUESTION 5 - Immutable ConfigMap (4 points)
# ============================================================================
score_q5() {
    local score=0
    local total=4

    echo "Question 5 | Immutable ConfigMap"

    # Check ConfigMap exists
    local cm_exists=$(kubectl get configmap locked-config -n hunt 2>/dev/null && echo true || echo false)
    check_criterion "ConfigMap locked-config exists" "$cm_exists" && ((score++))

    # Check DB_HOST
    local db_host=$(kubectl get configmap locked-config -n hunt -o jsonpath='{.data.DB_HOST}' 2>/dev/null)
    check_criterion "ConfigMap has DB_HOST=postgres.hunt.svc" "$([ "$db_host" = "postgres.hunt.svc" ] && echo true || echo false)" && ((score++))

    # Check DB_PORT
    local db_port=$(kubectl get configmap locked-config -n hunt -o jsonpath='{.data.DB_PORT}' 2>/dev/null)
    check_criterion "ConfigMap has DB_PORT=5432" "$([ "$db_port" = "5432" ] && echo true || echo false)" && ((score++))

    # Check immutable
    local immutable=$(kubectl get configmap locked-config -n hunt -o jsonpath='{.immutable}' 2>/dev/null)
    check_criterion "ConfigMap is immutable" "$([ "$immutable" = "true" ] && echo true || echo false)" && ((score++))

    echo "$score/$total"
    return 0
}

# ============================================================================
# QUESTION 6 - Projected Volume (6 points)
# ============================================================================
score_q6() {
    local score=0
    local total=6

    echo "Question 6 | Projected Volume"

    # Check Pod exists
    local pod_status=$(kubectl get pod config-aggregator -n hunt -o jsonpath='{.status.phase}' 2>/dev/null)
    check_criterion "Pod config-aggregator is running" "$([ "$pod_status" = "Running" ] && echo true || echo false)" && ((score++))

    # Check container name
    local container_name=$(kubectl get pod config-aggregator -n hunt -o jsonpath='{.spec.containers[0].name}' 2>/dev/null)
    check_criterion "Container named aggregator" "$([ "$container_name" = "aggregator" ] && echo true || echo false)" && ((score++))

    # Check projected volume exists
    local projected=$(kubectl get pod config-aggregator -n hunt -o jsonpath='{.spec.volumes[?(@.name=="combined-config")].projected}' 2>/dev/null)
    check_criterion "Projected volume combined-config exists" "$([ -n "$projected" ] && echo true || echo false)" && ((score++))

    # Check serviceAccountToken source
    local token_source=$(kubectl get pod config-aggregator -n hunt -o json 2>/dev/null | grep -q "serviceAccountToken" && echo true || echo false)
    check_criterion "Projected volume has serviceAccountToken" "$token_source" && ((score++))

    # Check configMap source
    local cm_source=$(kubectl get pod config-aggregator -n hunt -o json 2>/dev/null | grep -q '"configMap"' && echo true || echo false)
    check_criterion "Projected volume has configMap" "$cm_source" && ((score++))

    # Check mount path
    local mount_path=$(kubectl get pod config-aggregator -n hunt -o jsonpath='{.spec.containers[0].volumeMounts[?(@.name=="combined-config")].mountPath}' 2>/dev/null)
    check_criterion "Volume mounted at /etc/config" "$([ "$mount_path" = "/etc/config" ] && echo true || echo false)" && ((score++))

    echo "$score/$total"
    return 0
}

# ============================================================================
# QUESTION 7 - PodDisruptionBudget (6 points)
# ============================================================================
score_q7() {
    local score=0
    local total=6

    echo "Question 7 | PodDisruptionBudget"

    # Check PDB exists
    local pdb_exists=$(kubectl get pdb critical-pdb -n jungle 2>/dev/null && echo true || echo false)
    check_criterion "PodDisruptionBudget critical-pdb exists" "$pdb_exists" && ((score++))

    # Check minAvailable
    local min_available=$(kubectl get pdb critical-pdb -n jungle -o jsonpath='{.spec.minAvailable}' 2>/dev/null)
    check_criterion "PDB has minAvailable=3" "$([ "$min_available" = "3" ] && echo true || echo false)" && ((score++))

    # Check selector
    local selector=$(kubectl get pdb critical-pdb -n jungle -o jsonpath='{.spec.selector.matchLabels.app}' 2>/dev/null)
    check_criterion "PDB targets app=critical-app" "$([ "$selector" = "critical-app" ] && echo true || echo false)" && ((score++))

    # Check allowed disruptions
    local allowed=$(kubectl get pdb critical-pdb -n jungle -o jsonpath='{.status.disruptionsAllowed}' 2>/dev/null)
    check_criterion "PDB has allowed disruptions calculated" "$([ -n "$allowed" ] && echo true || echo false)" && ((score++))

    # Check current healthy
    local healthy=$(kubectl get pdb critical-pdb -n jungle -o jsonpath='{.status.currentHealthy}' 2>/dev/null)
    check_criterion "PDB tracks current healthy pods" "$([ -n "$healthy" ] && echo true || echo false)" && ((score++))

    # Check expected pods
    local expected=$(kubectl get pdb critical-pdb -n jungle -o jsonpath='{.status.expectedPods}' 2>/dev/null)
    check_criterion "PDB tracks expected pods (5)" "$([ "$expected" = "5" ] && echo true || echo false)" && ((score++))

    echo "$score/$total"
    return 0
}

# ============================================================================
# QUESTION 8 - Service ExternalName (4 points)
# ============================================================================
score_q8() {
    local score=0
    local total=4

    echo "Question 8 | Service ExternalName"

    # Check Service exists
    local svc_exists=$(kubectl get service external-api -n fang 2>/dev/null && echo true || echo false)
    check_criterion "Service external-api exists" "$svc_exists" && ((score++))

    # Check Service type
    local svc_type=$(kubectl get service external-api -n fang -o jsonpath='{.spec.type}' 2>/dev/null)
    check_criterion "Service type is ExternalName" "$([ "$svc_type" = "ExternalName" ] && echo true || echo false)" && ((score++))

    # Check external name
    local ext_name=$(kubectl get service external-api -n fang -o jsonpath='{.spec.externalName}' 2>/dev/null)
    check_criterion "ExternalName is api.external-service.com" "$([ "$ext_name" = "api.external-service.com" ] && echo true || echo false)" && ((score++))

    # Check no clusterIP
    local cluster_ip=$(kubectl get service external-api -n fang -o jsonpath='{.spec.clusterIP}' 2>/dev/null)
    check_criterion "Service has no ClusterIP" "$([ -z "$cluster_ip" ] || [ "$cluster_ip" = "None" ] && echo true || echo false)" && ((score++))

    echo "$score/$total"
    return 0
}

# ============================================================================
# QUESTION 9 - LimitRange (5 points)
# ============================================================================
score_q9() {
    local score=0
    local total=5

    echo "Question 9 | LimitRange"

    # Check LimitRange exists
    local lr_exists=$(kubectl get limitrange container-limits -n pounce 2>/dev/null && echo true || echo false)
    check_criterion "LimitRange container-limits exists" "$lr_exists" && ((score++))

    # Check default CPU limit
    local default_cpu=$(kubectl get limitrange container-limits -n pounce -o jsonpath='{.spec.limits[?(@.type=="Container")].default.cpu}' 2>/dev/null)
    check_criterion "Default CPU limit is 500m" "$([ "$default_cpu" = "500m" ] && echo true || echo false)" && ((score++))

    # Check default CPU request
    local default_req_cpu=$(kubectl get limitrange container-limits -n pounce -o jsonpath='{.spec.limits[?(@.type=="Container")].defaultRequest.cpu}' 2>/dev/null)
    check_criterion "Default CPU request is 100m" "$([ "$default_req_cpu" = "100m" ] && echo true || echo false)" && ((score++))

    # Check max memory
    local max_mem=$(kubectl get limitrange container-limits -n pounce -o jsonpath='{.spec.limits[?(@.type=="Container")].max.memory}' 2>/dev/null)
    check_criterion "Max memory is 512Mi" "$([ "$max_mem" = "512Mi" ] && echo true || echo false)" && ((score++))

    # Check min memory
    local min_mem=$(kubectl get limitrange container-limits -n pounce -o jsonpath='{.spec.limits[?(@.type=="Container")].min.memory}' 2>/dev/null)
    check_criterion "Min memory is 32Mi" "$([ "$min_mem" = "32Mi" ] && echo true || echo false)" && ((score++))

    echo "$score/$total"
    return 0
}

# ============================================================================
# QUESTION 10 - Pod Security Context (7 points)
# ============================================================================
score_q10() {
    local score=0
    local total=7

    echo "Question 10 | Pod Security Context"

    # Check Pod exists
    local pod_exists=$(kubectl get pod secure-pod -n stalker 2>/dev/null && echo true || echo false)
    check_criterion "Pod secure-pod exists" "$pod_exists" && ((score++))

    # Check runAsUser
    local run_as_user=$(kubectl get pod secure-pod -n stalker -o jsonpath='{.spec.securityContext.runAsUser}' 2>/dev/null)
    check_criterion "Pod runAsUser is 1000" "$([ "$run_as_user" = "1000" ] && echo true || echo false)" && ((score++))

    # Check runAsGroup
    local run_as_group=$(kubectl get pod secure-pod -n stalker -o jsonpath='{.spec.securityContext.runAsGroup}' 2>/dev/null)
    check_criterion "Pod runAsGroup is 3000" "$([ "$run_as_group" = "3000" ] && echo true || echo false)" && ((score++))

    # Check fsGroup
    local fs_group=$(kubectl get pod secure-pod -n stalker -o jsonpath='{.spec.securityContext.fsGroup}' 2>/dev/null)
    check_criterion "Pod fsGroup is 2000" "$([ "$fs_group" = "2000" ] && echo true || echo false)" && ((score++))

    # Check readOnlyRootFilesystem
    local readonly_fs=$(kubectl get pod secure-pod -n stalker -o jsonpath='{.spec.containers[0].securityContext.readOnlyRootFilesystem}' 2>/dev/null)
    check_criterion "Container has readOnlyRootFilesystem" "$([ "$readonly_fs" = "true" ] && echo true || echo false)" && ((score++))

    # Check allowPrivilegeEscalation
    local priv_escalation=$(kubectl get pod secure-pod -n stalker -o jsonpath='{.spec.containers[0].securityContext.allowPrivilegeEscalation}' 2>/dev/null)
    check_criterion "Container has allowPrivilegeEscalation=false" "$([ "$priv_escalation" = "false" ] && echo true || echo false)" && ((score++))

    # Check emptyDir volume at /tmp
    local tmp_mount=$(kubectl get pod secure-pod -n stalker -o jsonpath='{.spec.containers[0].volumeMounts[?(@.mountPath=="/tmp")].name}' 2>/dev/null)
    check_criterion "EmptyDir volume mounted at /tmp" "$([ -n "$tmp_mount" ] && echo true || echo false)" && ((score++))

    echo "$score/$total"
    return 0
}

# ============================================================================
# QUESTION 11 - Deployment Rollout Control (5 points)
# ============================================================================
score_q11() {
    local score=0
    local total=5

    echo "Question 11 | Deployment Rollout Control"

    # Check Deployment exists
    local deploy_exists=$(kubectl get deployment rolling-app -n pounce 2>/dev/null && echo true || echo false)
    check_criterion "Deployment rolling-app exists" "$deploy_exists" && ((score++))

    # Check image is nginx:1.22
    local image=$(kubectl get deployment rolling-app -n pounce -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null)
    check_criterion "Deployment uses nginx:1.22" "$(echo "$image" | grep -q "nginx:1.22" && echo true || echo false)" && ((score++))

    # Check revisionHistoryLimit
    local history_limit=$(kubectl get deployment rolling-app -n pounce -o jsonpath='{.spec.revisionHistoryLimit}' 2>/dev/null)
    check_criterion "revisionHistoryLimit is 5" "$([ "$history_limit" = "5" ] && echo true || echo false)" && ((score++))

    # Check deployment is not paused
    local paused=$(kubectl get deployment rolling-app -n pounce -o jsonpath='{.spec.paused}' 2>/dev/null)
    check_criterion "Deployment is not paused" "$([ "$paused" != "true" ] && echo true || echo false)" && ((score++))

    # Check rollout status
    local ready=$(kubectl get deployment rolling-app -n pounce -o jsonpath='{.status.readyReplicas}' 2>/dev/null)
    local replicas=$(kubectl get deployment rolling-app -n pounce -o jsonpath='{.spec.replicas}' 2>/dev/null)
    check_criterion "Rollout completed successfully" "$([ "$ready" = "$replicas" ] && echo true || echo false)" && ((score++))

    echo "$score/$total"
    return 0
}

# ============================================================================
# QUESTION 12 - kubectl exec Troubleshooting (4 points)
# ============================================================================
score_q12() {
    local score=0
    local total=4

    echo "Question 12 | kubectl exec Troubleshooting"

    # Check Pod exists
    local pod_exists=$(kubectl get pod config-pod -n stalker 2>/dev/null && echo true || echo false)
    check_criterion "Pod config-pod exists" "$pod_exists" && ((score++))

    # Check config file exists
    local file="$EXAM_DIR/12/nginx-config.txt"
    check_criterion "File /exam/course/12/nginx-config.txt exists" "$([ -f "$file" ] && echo true || echo false)" && ((score++))

    # Check file has nginx config content
    if [ -f "$file" ]; then
        check_criterion "File contains nginx configuration" "$(grep -qi "server\|listen\|location" "$file" && echo true || echo false)" && ((score++))
    else
        check_criterion "File contains nginx configuration" "false" || true
    fi

    # Check file mentions port 8080
    if [ -f "$file" ]; then
        check_criterion "Configuration shows port 8080" "$(grep -q "8080" "$file" && echo true || echo false)" && ((score++))
    else
        check_criterion "Configuration shows port 8080" "false" || true
    fi

    echo "$score/$total"
    return 0
}

# ============================================================================
# QUESTION 13 - Resource Metrics (3 points)
# ============================================================================
score_q13() {
    local score=0
    local total=3

    echo "Question 13 | Resource Metrics"

    # Check pod-resources.txt exists
    local file="$EXAM_DIR/13/pod-resources.txt"
    check_criterion "File /exam/course/13/pod-resources.txt exists" "$([ -f "$file" ] && echo true || echo false)" && ((score++))

    # Check file has content (or error message if metrics-server unavailable)
    if [ -f "$file" ]; then
        check_criterion "File has content" "$([ -s "$file" ] && echo true || echo false)" && ((score++))
    else
        check_criterion "File has content" "false" || true
    fi

    # Check top-cpu-pod.txt exists
    local cpu_file="$EXAM_DIR/13/top-cpu-pod.txt"
    check_criterion "File /exam/course/13/top-cpu-pod.txt exists" "$([ -f "$cpu_file" ] && echo true || echo false)" && ((score++))

    echo "$score/$total"
    return 0
}

# ============================================================================
# QUESTION 14 - Downward API (6 points)
# ============================================================================
score_q14() {
    local score=0
    local total=6

    echo "Question 14 | Downward API"

    # Check Pod exists
    local pod_status=$(kubectl get pod metadata-pod -n claw -o jsonpath='{.status.phase}' 2>/dev/null)
    check_criterion "Pod metadata-pod is running" "$([ "$pod_status" = "Running" ] && echo true || echo false)" && ((score++))

    # Check POD_NAME env
    local pod_name_env=$(kubectl get pod metadata-pod -n claw -o json 2>/dev/null | grep -q '"POD_NAME"' && echo true || echo false)
    check_criterion "Pod has POD_NAME env var" "$pod_name_env" && ((score++))

    # Check POD_NAMESPACE env
    local pod_ns_env=$(kubectl get pod metadata-pod -n claw -o json 2>/dev/null | grep -q '"POD_NAMESPACE"' && echo true || echo false)
    check_criterion "Pod has POD_NAMESPACE env var" "$pod_ns_env" && ((score++))

    # Check POD_IP env
    local pod_ip_env=$(kubectl get pod metadata-pod -n claw -o json 2>/dev/null | grep -q '"POD_IP"' && echo true || echo false)
    check_criterion "Pod has POD_IP env var" "$pod_ip_env" && ((score++))

    # Check NODE_NAME env
    local node_env=$(kubectl get pod metadata-pod -n claw -o json 2>/dev/null | grep -q '"NODE_NAME"' && echo true || echo false)
    check_criterion "Pod has NODE_NAME env var" "$node_env" && ((score++))

    # Check container name
    local container_name=$(kubectl get pod metadata-pod -n claw -o jsonpath='{.spec.containers[0].name}' 2>/dev/null)
    check_criterion "Container named info" "$([ "$container_name" = "info" ] && echo true || echo false)" && ((score++))

    echo "$score/$total"
    return 0
}

# ============================================================================
# QUESTION 15 - Job TTL (5 points)
# ============================================================================
score_q15() {
    local score=0
    local total=5

    echo "Question 15 | Job TTL"

    # Check Job exists (or was created and deleted by TTL)
    local job_exists=$(kubectl get job cleanup-job -n stripe 2>/dev/null && echo true || echo false)

    if [ "$job_exists" = "true" ]; then
        # Job still exists - check all criteria
        check_criterion "Job cleanup-job exists" "true" && ((score++))

        # Check ttlSecondsAfterFinished
        local ttl=$(kubectl get job cleanup-job -n stripe -o jsonpath='{.spec.ttlSecondsAfterFinished}' 2>/dev/null)
        check_criterion "Job has ttlSecondsAfterFinished=60" "$([ "$ttl" = "60" ] && echo true || echo false)" && ((score++))

        # Check backoffLimit
        local backoff=$(kubectl get job cleanup-job -n stripe -o jsonpath='{.spec.backoffLimit}' 2>/dev/null)
        check_criterion "Job has backoffLimit=2" "$([ "$backoff" = "2" ] && echo true || echo false)" && ((score++))

        # Check container name
        local container=$(kubectl get job cleanup-job -n stripe -o jsonpath='{.spec.template.spec.containers[0].name}' 2>/dev/null)
        check_criterion "Container named cleanup" "$([ "$container" = "cleanup" ] && echo true || echo false)" && ((score++))

        # Check image
        local image=$(kubectl get job cleanup-job -n stripe -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null)
        check_criterion "Job uses busybox:1.36" "$(echo "$image" | grep -q "busybox:1.36" && echo true || echo false)" && ((score++))
    else
        # Job doesn't exist - check if it was deleted (no points if never created)
        check_criterion "Job cleanup-job exists (not found)" "false" || true
        check_criterion "Job has ttlSecondsAfterFinished=60" "false" || true
        check_criterion "Job has backoffLimit=2" "false" || true
        check_criterion "Container named cleanup" "false" || true
        check_criterion "Job uses busybox:1.36" "false" || true
    fi

    echo "$score/$total"
    return 0
}

# ============================================================================
# QUESTION 16 - Container Capabilities (6 points)
# ============================================================================
score_q16() {
    local score=0
    local total=6

    echo "Question 16 | Container Capabilities"

    # Check Pod exists
    local pod_exists=$(kubectl get pod hardened-pod -n predator 2>/dev/null && echo true || echo false)
    check_criterion "Pod hardened-pod exists" "$pod_exists" && ((score++))

    # Check capabilities drop ALL
    local drop_all=$(kubectl get pod hardened-pod -n predator -o json 2>/dev/null | grep -q '"drop".*"ALL"' && echo true || echo false)
    check_criterion "Capabilities drop ALL" "$drop_all" && ((score++))

    # Check capabilities add NET_BIND_SERVICE
    local add_cap=$(kubectl get pod hardened-pod -n predator -o json 2>/dev/null | grep -q '"add".*"NET_BIND_SERVICE"' && echo true || echo false)
    check_criterion "Capabilities add NET_BIND_SERVICE" "$add_cap" && ((score++))

    # Check runAsNonRoot
    local non_root=$(kubectl get pod hardened-pod -n predator -o jsonpath='{.spec.containers[0].securityContext.runAsNonRoot}' 2>/dev/null)
    check_criterion "runAsNonRoot is true" "$([ "$non_root" = "true" ] && echo true || echo false)" && ((score++))

    # Check runAsUser
    local run_user=$(kubectl get pod hardened-pod -n predator -o jsonpath='{.spec.containers[0].securityContext.runAsUser}' 2>/dev/null)
    check_criterion "runAsUser is 101" "$([ "$run_user" = "101" ] && echo true || echo false)" && ((score++))

    # Check container name
    local container=$(kubectl get pod hardened-pod -n predator -o jsonpath='{.spec.containers[0].name}' 2>/dev/null)
    check_criterion "Container named secure-app" "$([ "$container" = "secure-app" ] && echo true || echo false)" && ((score++))

    echo "$score/$total"
    return 0
}

# ============================================================================
# QUESTION 17 - Service Session Affinity (5 points)
# ============================================================================
score_q17() {
    local score=0
    local total=5

    echo "Question 17 | Service Session Affinity"

    # Check Service exists
    local svc_exists=$(kubectl get service backend-svc -n claw 2>/dev/null && echo true || echo false)
    check_criterion "Service backend-svc exists" "$svc_exists" && ((score++))

    # Check sessionAffinity
    local affinity=$(kubectl get service backend-svc -n claw -o jsonpath='{.spec.sessionAffinity}' 2>/dev/null)
    check_criterion "Service has sessionAffinity=ClientIP" "$([ "$affinity" = "ClientIP" ] && echo true || echo false)" && ((score++))

    # Check timeout
    local timeout=$(kubectl get service backend-svc -n claw -o jsonpath='{.spec.sessionAffinityConfig.clientIP.timeoutSeconds}' 2>/dev/null)
    check_criterion "Session timeout is 3600 seconds" "$([ "$timeout" = "3600" ] && echo true || echo false)" && ((score++))

    # Check service has selector
    local selector=$(kubectl get service backend-svc -n claw -o jsonpath='{.spec.selector.app}' 2>/dev/null)
    check_criterion "Service has selector app=backend" "$([ "$selector" = "backend" ] && echo true || echo false)" && ((score++))

    # Check service has endpoints
    local endpoints=$(kubectl get endpoints backend-svc -n claw -o jsonpath='{.subsets[0].addresses}' 2>/dev/null)
    check_criterion "Service has endpoints" "$([ -n "$endpoints" ] && echo true || echo false)" && ((score++))

    echo "$score/$total"
    return 0
}

# ============================================================================
# QUESTION 18 - Deployment Safe Rollout (5 points)
# ============================================================================
score_q18() {
    local score=0
    local total=5

    echo "Question 18 | Deployment Safe Rollout"

    # Check Deployment exists
    local deploy_exists=$(kubectl get deployment safe-deploy -n fang 2>/dev/null && echo true || echo false)
    check_criterion "Deployment safe-deploy exists" "$deploy_exists" && ((score++))

    # Check minReadySeconds
    local min_ready=$(kubectl get deployment safe-deploy -n fang -o jsonpath='{.spec.minReadySeconds}' 2>/dev/null)
    check_criterion "minReadySeconds is 30" "$([ "$min_ready" = "30" ] && echo true || echo false)" && ((score++))

    # Check progressDeadlineSeconds
    local progress=$(kubectl get deployment safe-deploy -n fang -o jsonpath='{.spec.progressDeadlineSeconds}' 2>/dev/null)
    check_criterion "progressDeadlineSeconds is 120" "$([ "$progress" = "120" ] && echo true || echo false)" && ((score++))

    # Check image is nginx:1.22
    local image=$(kubectl get deployment safe-deploy -n fang -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null)
    check_criterion "Deployment uses nginx:1.22" "$(echo "$image" | grep -q "nginx:1.22" && echo true || echo false)" && ((score++))

    # Check deployment is available
    local available=$(kubectl get deployment safe-deploy -n fang -o jsonpath='{.status.conditions[?(@.type=="Available")].status}' 2>/dev/null)
    check_criterion "Deployment is available" "$([ "$available" = "True" ] && echo true || echo false)" && ((score++))

    echo "$score/$total"
    return 0
}

# ============================================================================
# QUESTION 19 - Container Lifecycle Hook (5 points)
# ============================================================================
score_q19() {
    local score=0
    local total=5

    echo "Question 19 | Container Lifecycle Hook"

    # Check Pod exists
    local pod_exists=$(kubectl get pod graceful-pod -n tiger 2>/dev/null && echo true || echo false)
    check_criterion "Pod graceful-pod exists" "$pod_exists" && ((score++))

    # Check container name
    local container=$(kubectl get pod graceful-pod -n tiger -o jsonpath='{.spec.containers[0].name}' 2>/dev/null)
    check_criterion "Container named main" "$([ "$container" = "main" ] && echo true || echo false)" && ((score++))

    # Check preStop hook exists
    local prestop=$(kubectl get pod graceful-pod -n tiger -o jsonpath='{.spec.containers[0].lifecycle.preStop}' 2>/dev/null)
    check_criterion "Container has preStop hook" "$([ -n "$prestop" ] && echo true || echo false)" && ((score++))

    # Check preStop command contains nginx -s quit
    local prestop_cmd=$(kubectl get pod graceful-pod -n tiger -o json 2>/dev/null | grep -q "nginx -s quit" && echo true || echo false)
    check_criterion "preStop hook gracefully stops nginx" "$prestop_cmd" && ((score++))

    # Check terminationGracePeriodSeconds
    local grace=$(kubectl get pod graceful-pod -n tiger -o jsonpath='{.spec.terminationGracePeriodSeconds}' 2>/dev/null)
    check_criterion "terminationGracePeriodSeconds is 30" "$([ "$grace" = "30" ] && echo true || echo false)" && ((score++))

    echo "$score/$total"
    return 0
}

# ============================================================================
# QUESTION 20 - NetworkPolicy Default Deny (7 points)
# ============================================================================
score_q20() {
    local score=0
    local total=7

    echo "Question 20 | NetworkPolicy Default Deny"

    # Check default-deny-all exists
    local deny_exists=$(kubectl get networkpolicy default-deny-all -n predator 2>/dev/null && echo true || echo false)
    check_criterion "NetworkPolicy default-deny-all exists" "$deny_exists" && ((score++))

    # Check default-deny applies to all pods
    local deny_selector=$(kubectl get networkpolicy default-deny-all -n predator -o jsonpath='{.spec.podSelector}' 2>/dev/null)
    check_criterion "default-deny-all applies to all pods" "$([ "$deny_selector" = "{}" ] && echo true || echo false)" && ((score++))

    # Check default-deny has both policy types
    local deny_types=$(kubectl get networkpolicy default-deny-all -n predator -o jsonpath='{.spec.policyTypes[*]}' 2>/dev/null)
    check_criterion "default-deny-all denies Ingress" "$(echo "$deny_types" | grep -q "Ingress" && echo true || echo false)" && ((score++))
    check_criterion "default-deny-all denies Egress" "$(echo "$deny_types" | grep -q "Egress" && echo true || echo false)" && ((score++))

    # Check allow-frontend-to-api exists
    local allow_exists=$(kubectl get networkpolicy allow-frontend-to-api -n predator 2>/dev/null && echo true || echo false)
    check_criterion "NetworkPolicy allow-frontend-to-api exists" "$allow_exists" && ((score++))

    # Check allow policy targets backend
    local allow_selector=$(kubectl get networkpolicy allow-frontend-to-api -n predator -o jsonpath='{.spec.podSelector.matchLabels.tier}' 2>/dev/null)
    check_criterion "allow policy targets tier=backend" "$([ "$allow_selector" = "backend" ] && echo true || echo false)" && ((score++))

    # Check allow policy allows from frontend
    local from_frontend=$(kubectl get networkpolicy allow-frontend-to-api -n predator -o json 2>/dev/null | grep -q '"tier":"frontend"' && echo true || echo false)
    check_criterion "allow policy allows from tier=frontend" "$from_frontend" && ((score++))

    echo "$score/$total"
    return 0
}
