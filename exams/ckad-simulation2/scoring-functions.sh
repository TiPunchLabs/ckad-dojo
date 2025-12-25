#!/bin/bash
# scoring-functions.sh - Scoring functions for CKAD Simulation 2 (Dojo Suzaku 🔥)
# 21 original questions - 112 points total
# Each function returns the number of points scored and prints detailed results

# Source common utilities from scripts/lib
CURRENT_EXAM_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$CURRENT_EXAM_DIR/../.." && pwd)"
source "$PROJECT_DIR/scripts/lib/common.sh"

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
# QUESTION 1 - API Resources (1 point)
# ============================================================================
score_q1() {
    local score=0
    local total=1

    echo "Question 1 | API Resources"

    # Check if file exists and contains API resources
    local file="$EXAM_DIR/1/api-resources"
    if [ -f "$file" ] && grep -qE "NAME.*SHORTNAMES|pods.*po|deployments.*deploy" "$file" 2>/dev/null; then
        check_criterion "File contains API resources list" "true" && ((score++))
    else
        check_criterion "File contains API resources list" "false" || true
    fi

    echo "$score/$total"
    return 0
}

# ============================================================================
# QUESTION 2 - Deployment Recreate Strategy (6 points)
# ============================================================================
score_q2() {
    local score=0
    local total=6

    echo "Question 2 | Deployment Recreate Strategy"

    # Check Deployment exists
    local deploy_exists=$(kubectl get deployment fire-app -n blaze 2>/dev/null && echo true || echo false)
    check_criterion "Deployment fire-app exists in blaze" "$deploy_exists" && ((score++))

    # Check image
    local image=$(kubectl get deployment fire-app -n blaze -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null)
    check_criterion "Image is nginx:1.21" "$([ "$image" = "nginx:1.21" ] && echo true || echo false)" && ((score++))

    # Check replica count
    local replicas=$(kubectl get deployment fire-app -n blaze -o jsonpath='{.spec.replicas}' 2>/dev/null)
    check_criterion "Deployment has 3 replicas" "$([ "$replicas" = "3" ] && echo true || echo false)" && ((score++))

    # Check strategy type is Recreate
    local strategy=$(kubectl get deployment fire-app -n blaze -o jsonpath='{.spec.strategy.type}' 2>/dev/null)
    check_criterion "Strategy type is Recreate" "$([ "$strategy" = "Recreate" ] && echo true || echo false)" && ((score++))

    # Check container name
    local container_name=$(kubectl get deployment fire-app -n blaze -o jsonpath='{.spec.template.spec.containers[0].name}' 2>/dev/null)
    check_criterion "Container name is fire-container" "$([ "$container_name" = "fire-container" ] && echo true || echo false)" && ((score++))

    # Check YAML file saved
    local yaml_file="$EXAM_DIR/2/fire-app.yaml"
    check_criterion "YAML saved to exam/course/2/fire-app.yaml" "$([ -f "$yaml_file" ] && echo true || echo false)" && ((score++))

    echo "$score/$total"
    return 0
}

# ============================================================================
# QUESTION 3 - Job with Timeout (6 points)
# ============================================================================
score_q3() {
    local score=0
    local total=6

    echo "Question 3 | Job with Timeout"

    # Check Job exists
    local job_exists=$(kubectl get job data-processor -n spark 2>/dev/null && echo true || echo false)
    check_criterion "Job data-processor exists in spark" "$job_exists" && ((score++))

    # Check activeDeadlineSeconds
    local deadline=$(kubectl get job data-processor -n spark -o jsonpath='{.spec.activeDeadlineSeconds}' 2>/dev/null)
    check_criterion "activeDeadlineSeconds is 60" "$([ "$deadline" = "60" ] && echo true || echo false)" && ((score++))

    # Check backoffLimit
    local backoff=$(kubectl get job data-processor -n spark -o jsonpath='{.spec.backoffLimit}' 2>/dev/null)
    check_criterion "backoffLimit is 2" "$([ "$backoff" = "2" ] && echo true || echo false)" && ((score++))

    # Check image
    local image=$(kubectl get job data-processor -n spark -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null)
    check_criterion "Uses busybox image" "$(echo "$image" | grep -q "busybox" && echo true || echo false)" && ((score++))

    # Check container name
    local container_name=$(kubectl get job data-processor -n spark -o jsonpath='{.spec.template.spec.containers[0].name}' 2>/dev/null)
    check_criterion "Container name is processor" "$([ "$container_name" = "processor" ] && echo true || echo false)" && ((score++))

    # Check YAML file
    local yaml_file="$EXAM_DIR/3/job.yaml"
    check_criterion "YAML saved to exam/course/3/job.yaml" "$([ -f "$yaml_file" ] && echo true || echo false)" && ((score++))

    echo "$score/$total"
    return 0
}

# ============================================================================
# QUESTION 4 - Helm Template Debug (5 points)
# ============================================================================
score_q4() {
    local score=0
    local total=5

    echo "Question 4 | Helm Template Debug"

    local file="$EXAM_DIR/4/rendered.yaml"

    # Check file exists
    check_criterion "File rendered.yaml exists" "$([ -f "$file" ] && echo true || echo false)" && ((score++))

    # Check file contains Kubernetes manifests
    if [ -f "$file" ]; then
        check_criterion "File contains apiVersion" "$(grep -q "apiVersion:" "$file" && echo true || echo false)" && ((score++))
        check_criterion "File contains kind" "$(grep -q "kind:" "$file" && echo true || echo false)" && ((score++))
        check_criterion "File contains metadata" "$(grep -q "metadata:" "$file" && echo true || echo false)" && ((score++))
        check_criterion "File has substantial content (>50 lines)" "$([ $(wc -l < "$file") -gt 50 ] && echo true || echo false)" && ((score++))
    else
        check_criterion "File contains apiVersion" "false" || true
        check_criterion "File contains kind" "false" || true
        check_criterion "File contains metadata" "false" || true
        check_criterion "File has substantial content" "false" || true
    fi

    echo "$score/$total"
    return 0
}

# ============================================================================
# QUESTION 5 - Fix CrashLoopBackOff (6 points)
# ============================================================================
score_q5() {
    local score=0
    local total=6

    echo "Question 5 | Fix CrashLoopBackOff"

    # Check Pod exists
    local pod_exists=$(kubectl get pod crash-app -n ember 2>/dev/null && echo true || echo false)
    check_criterion "Pod crash-app exists in ember" "$pod_exists" && ((score++))

    # Check Pod is Running
    local pod_status=$(kubectl get pod crash-app -n ember -o jsonpath='{.status.phase}' 2>/dev/null)
    check_criterion "Pod status is Running" "$([ "$pod_status" = "Running" ] && echo true || echo false)" && ((score++))

    # Check container is ready
    local ready=$(kubectl get pod crash-app -n ember -o jsonpath='{.status.containerStatuses[0].ready}' 2>/dev/null)
    check_criterion "Container is ready" "$([ "$ready" = "true" ] && echo true || echo false)" && ((score++))

    # Check command is fixed (should use "sleep" not "sleepx")
    local cmd=$(kubectl get pod crash-app -n ember -o jsonpath='{.spec.containers[0].command[0]}' 2>/dev/null)
    check_criterion "Command is 'sleep' (not 'sleepx')" "$([ "$cmd" = "sleep" ] && echo true || echo false)" && ((score++))

    # Check restart count is low (problem was fixed)
    local restarts=$(kubectl get pod crash-app -n ember -o jsonpath='{.status.containerStatuses[0].restartCount}' 2>/dev/null)
    check_criterion "Restart count is reasonable (<5)" "$([ "${restarts:-0}" -lt 5 ] && echo true || echo false)" && ((score++))

    # Check pod has been running for a while
    local running_seconds=$(kubectl get pod crash-app -n ember -o jsonpath='{.status.containerStatuses[0].state.running.startedAt}' 2>/dev/null)
    check_criterion "Pod is currently running" "$([ -n "$running_seconds" ] && echo true || echo false)" && ((score++))

    echo "$score/$total"
    return 0
}

# ============================================================================
# QUESTION 6 - ConfigMap Items Mount (6 points)
# ============================================================================
score_q6() {
    local score=0
    local total=6

    echo "Question 6 | ConfigMap Items Mount"

    # Check Pod exists
    local pod_exists=$(kubectl get pod config-reader -n flame 2>/dev/null && echo true || echo false)
    check_criterion "Pod config-reader exists in flame" "$pod_exists" && ((score++))

    # Check Pod is Running
    local pod_status=$(kubectl get pod config-reader -n flame -o jsonpath='{.status.phase}' 2>/dev/null)
    check_criterion "Pod status is Running" "$([ "$pod_status" = "Running" ] && echo true || echo false)" && ((score++))

    # Check image
    local image=$(kubectl get pod config-reader -n flame -o jsonpath='{.spec.containers[0].image}' 2>/dev/null)
    check_criterion "Uses busybox image" "$(echo "$image" | grep -q "busybox" && echo true || echo false)" && ((score++))

    # Check volume mount path
    local mount_path=$(kubectl get pod config-reader -n flame -o jsonpath='{.spec.containers[0].volumeMounts[0].mountPath}' 2>/dev/null)
    check_criterion "Volume mounted at /config" "$([ "$mount_path" = "/config" ] && echo true || echo false)" && ((score++))

    # Check ConfigMap reference
    local cm_name=$(kubectl get pod config-reader -n flame -o jsonpath='{.spec.volumes[0].configMap.name}' 2>/dev/null)
    check_criterion "Uses ConfigMap app-settings" "$([ "$cm_name" = "app-settings" ] && echo true || echo false)" && ((score++))

    # Check items are specified (selective mounting)
    local items=$(kubectl get pod config-reader -n flame -o jsonpath='{.spec.volumes[0].configMap.items}' 2>/dev/null)
    check_criterion "Items specified for selective mount" "$([ -n "$items" ] && echo true || echo false)" && ((score++))

    echo "$score/$total"
    return 0
}

# ============================================================================
# QUESTION 7 - Secret from File (5 points)
# ============================================================================
score_q7() {
    local score=0
    local total=5

    echo "Question 7 | Secret from File"

    # Check password file exists
    local pwd_file="$EXAM_DIR/7/password.txt"
    check_criterion "File password.txt exists" "$([ -f "$pwd_file" ] && echo true || echo false)" && ((score++))

    # Check file content
    if [ -f "$pwd_file" ]; then
        local content=$(cat "$pwd_file")
        check_criterion "File contains correct password" "$([ "$content" = "FirePhoenix2024!" ] && echo true || echo false)" && ((score++))
    else
        check_criterion "File contains correct password" "false" || true
    fi

    # Check Secret exists
    local secret_exists=$(kubectl get secret db-credentials -n magma 2>/dev/null && echo true || echo false)
    check_criterion "Secret db-credentials exists in magma" "$secret_exists" && ((score++))

    # Check Secret type
    local secret_type=$(kubectl get secret db-credentials -n magma -o jsonpath='{.type}' 2>/dev/null)
    check_criterion "Secret type is Opaque" "$([ "$secret_type" = "Opaque" ] && echo true || echo false)" && ((score++))

    # Check Secret has password.txt key
    local has_key=$(kubectl get secret db-credentials -n magma -o jsonpath='{.data.password\.txt}' 2>/dev/null)
    check_criterion "Secret has key password.txt" "$([ -n "$has_key" ] && echo true || echo false)" && ((score++))

    echo "$score/$total"
    return 0
}

# ============================================================================
# QUESTION 8 - Headless Service (6 points)
# ============================================================================
score_q8() {
    local score=0
    local total=6

    echo "Question 8 | Headless Service"

    # Check Service exists
    local svc_exists=$(kubectl get service backend-headless -n corona 2>/dev/null && echo true || echo false)
    check_criterion "Service backend-headless exists in corona" "$svc_exists" && ((score++))

    # Check clusterIP is None
    local cluster_ip=$(kubectl get service backend-headless -n corona -o jsonpath='{.spec.clusterIP}' 2>/dev/null)
    check_criterion "clusterIP is None (headless)" "$([ "$cluster_ip" = "None" ] && echo true || echo false)" && ((score++))

    # Check selector
    local selector=$(kubectl get service backend-headless -n corona -o jsonpath='{.spec.selector.app}' 2>/dev/null)
    check_criterion "Selector is app=backend" "$([ "$selector" = "backend" ] && echo true || echo false)" && ((score++))

    # Check port
    local port=$(kubectl get service backend-headless -n corona -o jsonpath='{.spec.ports[0].port}' 2>/dev/null)
    check_criterion "Port is 80" "$([ "$port" = "80" ] && echo true || echo false)" && ((score++))

    # Check targetPort
    local target_port=$(kubectl get service backend-headless -n corona -o jsonpath='{.spec.ports[0].targetPort}' 2>/dev/null)
    check_criterion "TargetPort is 80" "$([ "$target_port" = "80" ] && echo true || echo false)" && ((score++))

    # Check protocol
    local protocol=$(kubectl get service backend-headless -n corona -o jsonpath='{.spec.ports[0].protocol}' 2>/dev/null)
    check_criterion "Protocol is TCP" "$([ "$protocol" = "TCP" ] && echo true || echo false)" && ((score++))

    echo "$score/$total"
    return 0
}

# ============================================================================
# QUESTION 9 - Canary Deployment (7 points)
# ============================================================================
score_q9() {
    local score=0
    local total=7

    echo "Question 9 | Canary Deployment"

    # Check stable-v1 exists (pre-existing)
    local stable_exists=$(kubectl get deployment stable-v1 -n blaze 2>/dev/null && echo true || echo false)
    check_criterion "Deployment stable-v1 exists" "$stable_exists" && ((score++))

    # Check canary-v2 exists
    local canary_exists=$(kubectl get deployment canary-v2 -n blaze 2>/dev/null && echo true || echo false)
    check_criterion "Deployment canary-v2 exists" "$canary_exists" && ((score++))

    # Check canary has 1 replica
    local canary_replicas=$(kubectl get deployment canary-v2 -n blaze -o jsonpath='{.spec.replicas}' 2>/dev/null)
    check_criterion "Canary has 1 replica" "$([ "$canary_replicas" = "1" ] && echo true || echo false)" && ((score++))

    # Check canary image
    local canary_image=$(kubectl get deployment canary-v2 -n blaze -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null)
    check_criterion "Canary uses nginx:1.22" "$(echo "$canary_image" | grep -q "nginx:1.22" && echo true || echo false)" && ((score++))

    # Check canary has version=v2 label
    local canary_version=$(kubectl get deployment canary-v2 -n blaze -o jsonpath='{.spec.template.metadata.labels.version}' 2>/dev/null)
    check_criterion "Canary has version=v2 label" "$([ "$canary_version" = "v2" ] && echo true || echo false)" && ((score++))

    # Check Service exists
    local svc_exists=$(kubectl get service frontend-svc -n blaze 2>/dev/null && echo true || echo false)
    check_criterion "Service frontend-svc exists" "$svc_exists" && ((score++))

    # Check Service selects both (app=web-frontend without version)
    local svc_selector=$(kubectl get service frontend-svc -n blaze -o jsonpath='{.spec.selector}' 2>/dev/null)
    if echo "$svc_selector" | grep -q "web-frontend" && ! echo "$svc_selector" | grep -q "version"; then
        check_criterion "Service routes to both stable and canary" "true" && ((score++))
    else
        check_criterion "Service routes to both stable and canary" "false" || true
    fi

    echo "$score/$total"
    return 0
}

# ============================================================================
# QUESTION 10 - Sidecar Data Processing (6 points)
# ============================================================================
score_q10() {
    local score=0
    local total=6

    echo "Question 10 | Sidecar Data Processing"

    # Check Pod exists
    local pod_exists=$(kubectl get pod data-transform -n phoenix 2>/dev/null && echo true || echo false)
    check_criterion "Pod data-transform exists in phoenix" "$pod_exists" && ((score++))

    # Check Pod is Running
    local pod_status=$(kubectl get pod data-transform -n phoenix -o jsonpath='{.status.phase}' 2>/dev/null)
    check_criterion "Pod status is Running" "$([ "$pod_status" = "Running" ] && echo true || echo false)" && ((score++))

    # Check has 2 containers
    local container_count=$(kubectl get pod data-transform -n phoenix -o jsonpath='{.spec.containers[*].name}' 2>/dev/null | wc -w)
    check_criterion "Pod has 2 containers" "$([ "$container_count" = "2" ] && echo true || echo false)" && ((score++))

    # Check producer container
    local producer=$(kubectl get pod data-transform -n phoenix -o jsonpath='{.spec.containers[?(@.name=="producer")].name}' 2>/dev/null)
    check_criterion "Container 'producer' exists" "$([ "$producer" = "producer" ] && echo true || echo false)" && ((score++))

    # Check transformer container
    local transformer=$(kubectl get pod data-transform -n phoenix -o jsonpath='{.spec.containers[?(@.name=="transformer")].name}' 2>/dev/null)
    check_criterion "Container 'transformer' exists" "$([ "$transformer" = "transformer" ] && echo true || echo false)" && ((score++))

    # Check emptyDir volume
    local volume_type=$(kubectl get pod data-transform -n phoenix -o jsonpath='{.spec.volumes[0].emptyDir}' 2>/dev/null)
    check_criterion "Uses emptyDir volume" "$([ -n "$volume_type" ] && echo true || echo false)" && ((score++))

    echo "$score/$total"
    return 0
}

# ============================================================================
# QUESTION 11 - Cross-Namespace NetworkPolicy (6 points)
# ============================================================================
score_q11() {
    local score=0
    local total=6

    echo "Question 11 | Cross-Namespace NetworkPolicy"

    # Check NetworkPolicy exists
    local np_exists=$(kubectl get networkpolicy allow-from-flame -n corona 2>/dev/null && echo true || echo false)
    check_criterion "NetworkPolicy allow-from-flame exists in corona" "$np_exists" && ((score++))

    # Check podSelector
    local pod_selector=$(kubectl get networkpolicy allow-from-flame -n corona -o jsonpath='{.spec.podSelector.matchLabels.app}' 2>/dev/null)
    check_criterion "Applies to pods with app=backend" "$([ "$pod_selector" = "backend" ] && echo true || echo false)" && ((score++))

    # Check policyTypes includes Ingress
    local policy_types=$(kubectl get networkpolicy allow-from-flame -n corona -o jsonpath='{.spec.policyTypes}' 2>/dev/null)
    check_criterion "Policy type includes Ingress" "$(echo "$policy_types" | grep -q "Ingress" && echo true || echo false)" && ((score++))

    # Check has ingress rules
    local ingress=$(kubectl get networkpolicy allow-from-flame -n corona -o jsonpath='{.spec.ingress}' 2>/dev/null)
    check_criterion "Has ingress rules defined" "$([ -n "$ingress" ] && [ "$ingress" != "[]" ] && echo true || echo false)" && ((score++))

    # Check namespaceSelector is used
    local ns_selector=$(kubectl get networkpolicy allow-from-flame -n corona -o json 2>/dev/null | grep -c "namespaceSelector")
    check_criterion "Uses namespaceSelector" "$([ "$ns_selector" -gt 0 ] && echo true || echo false)" && ((score++))

    # Check port 80
    local port=$(kubectl get networkpolicy allow-from-flame -n corona -o jsonpath='{.spec.ingress[0].ports[0].port}' 2>/dev/null)
    check_criterion "Allows port 80" "$([ "$port" = "80" ] && echo true || echo false)" && ((score++))

    echo "$score/$total"
    return 0
}

# ============================================================================
# QUESTION 12 - Docker Build with ARG (6 points)
# ============================================================================
score_q12() {
    local score=0
    local total=6

    echo "Question 12 | Docker Build with ARG"

    # Check Dockerfile exists
    local dockerfile="$EXAM_DIR/12/Dockerfile"
    check_criterion "Dockerfile exists" "$([ -f "$dockerfile" ] && echo true || echo false)" && ((score++))

    if [ -f "$dockerfile" ]; then
        # Check ARG instruction
        check_criterion "Dockerfile has ARG APP_VERSION" "$(grep -q "ARG APP_VERSION" "$dockerfile" && echo true || echo false)" && ((score++))

        # Check LABEL instruction
        check_criterion "Dockerfile has LABEL version" "$(grep -q "LABEL.*version" "$dockerfile" && echo true || echo false)" && ((score++))
    else
        check_criterion "Dockerfile has ARG APP_VERSION" "false" || true
        check_criterion "Dockerfile has LABEL version" "false" || true
    fi

    # Check image exists in registry
    local image_exists=$(docker images localhost:5000/phoenix-app:2.0.0 --format "{{.Repository}}" 2>/dev/null | grep -q "phoenix-app" && echo true || echo false)
    check_criterion "Image localhost:5000/phoenix-app:2.0.0 built" "$image_exists" && ((score++))

    # Check image label
    local label=$(docker inspect localhost:5000/phoenix-app:2.0.0 --format '{{index .Config.Labels "version"}}' 2>/dev/null)
    check_criterion "Image has version=2.0.0 label" "$([ "$label" = "2.0.0" ] && echo true || echo false)" && ((score++))

    # Check pushed to registry (try to pull)
    local pushed=$(docker manifest inspect localhost:5000/phoenix-app:2.0.0 2>/dev/null && echo true || echo false)
    check_criterion "Image pushed to localhost:5000" "$pushed" && ((score++))

    echo "$score/$total"
    return 0
}

# ============================================================================
# QUESTION 13 - Helm Values File (5 points)
# ============================================================================
score_q13() {
    local score=0
    local total=5

    echo "Question 13 | Helm Values File"

    # Check values file exists
    local values_file="$EXAM_DIR/13/values.yaml"
    check_criterion "Values file exists" "$([ -f "$values_file" ] && echo true || echo false)" && ((score++))

    # Check Helm release exists
    local release_exists=$(helm list -n flare 2>/dev/null | grep -q "phoenix-api" && echo true || echo false)
    check_criterion "Helm release phoenix-api exists in flare" "$release_exists" && ((score++))

    # Check release status
    local status=$(helm list -n flare -o json 2>/dev/null | grep -o '"status":"[^"]*"' | head -1 | cut -d'"' -f4)
    check_criterion "Release status is deployed" "$([ "$status" = "deployed" ] && echo true || echo false)" && ((score++))

    # Check replicas (should be 3 from values file)
    local replicas=$(kubectl get deployment -n flare -l app.kubernetes.io/instance=phoenix-api -o jsonpath='{.items[0].spec.replicas}' 2>/dev/null)
    check_criterion "Deployment has 3 replicas" "$([ "$replicas" = "3" ] && echo true || echo false)" && ((score++))

    # Check service port (should be 8080 from values file)
    local svc_port=$(kubectl get service -n flare -l app.kubernetes.io/instance=phoenix-api -o jsonpath='{.items[0].spec.ports[0].port}' 2>/dev/null)
    check_criterion "Service port is 8080" "$([ "$svc_port" = "8080" ] && echo true || echo false)" && ((score++))

    echo "$score/$total"
    return 0
}

# ============================================================================
# QUESTION 14 - PostStart Lifecycle Hook (6 points)
# ============================================================================
score_q14() {
    local score=0
    local total=6

    echo "Question 14 | PostStart Lifecycle Hook"

    # Check Pod exists
    local pod_exists=$(kubectl get pod lifecycle-pod -n phoenix 2>/dev/null && echo true || echo false)
    check_criterion "Pod lifecycle-pod exists in phoenix" "$pod_exists" && ((score++))

    # Check Pod is Running
    local pod_status=$(kubectl get pod lifecycle-pod -n phoenix -o jsonpath='{.status.phase}' 2>/dev/null)
    check_criterion "Pod status is Running" "$([ "$pod_status" = "Running" ] && echo true || echo false)" && ((score++))

    # Check image
    local image=$(kubectl get pod lifecycle-pod -n phoenix -o jsonpath='{.spec.containers[0].image}' 2>/dev/null)
    check_criterion "Image is nginx:1.21" "$([ "$image" = "nginx:1.21" ] && echo true || echo false)" && ((score++))

    # Check container name
    local container_name=$(kubectl get pod lifecycle-pod -n phoenix -o jsonpath='{.spec.containers[0].name}' 2>/dev/null)
    check_criterion "Container name is main" "$([ "$container_name" = "main" ] && echo true || echo false)" && ((score++))

    # Check lifecycle hook exists
    local lifecycle=$(kubectl get pod lifecycle-pod -n phoenix -o jsonpath='{.spec.containers[0].lifecycle.postStart}' 2>/dev/null)
    check_criterion "postStart lifecycle hook exists" "$([ -n "$lifecycle" ] && echo true || echo false)" && ((score++))

    # Check file was created by postStart
    local file_exists=$(kubectl exec lifecycle-pod -n phoenix -c main -- cat /usr/share/nginx/html/started.txt 2>/dev/null && echo true || echo false)
    check_criterion "started.txt file created by hook" "$file_exists" && ((score++))

    echo "$score/$total"
    return 0
}

# ============================================================================
# QUESTION 15 - Guaranteed QoS Class (5 points)
# ============================================================================
score_q15() {
    local score=0
    local total=5

    echo "Question 15 | Guaranteed QoS Class"

    # Check Pod exists
    local pod_exists=$(kubectl get pod qos-guaranteed -n spark 2>/dev/null && echo true || echo false)
    check_criterion "Pod qos-guaranteed exists in spark" "$pod_exists" && ((score++))

    # Check Pod is Running
    local pod_status=$(kubectl get pod qos-guaranteed -n spark -o jsonpath='{.status.phase}' 2>/dev/null)
    check_criterion "Pod status is Running" "$([ "$pod_status" = "Running" ] && echo true || echo false)" && ((score++))

    # Check QoS class
    local qos=$(kubectl get pod qos-guaranteed -n spark -o jsonpath='{.status.qosClass}' 2>/dev/null)
    check_criterion "QoS class is Guaranteed" "$([ "$qos" = "Guaranteed" ] && echo true || echo false)" && ((score++))

    # Check requests = limits for memory
    local mem_req=$(kubectl get pod qos-guaranteed -n spark -o jsonpath='{.spec.containers[0].resources.requests.memory}' 2>/dev/null)
    local mem_lim=$(kubectl get pod qos-guaranteed -n spark -o jsonpath='{.spec.containers[0].resources.limits.memory}' 2>/dev/null)
    check_criterion "Memory requests = limits" "$([ "$mem_req" = "$mem_lim" ] && [ -n "$mem_req" ] && echo true || echo false)" && ((score++))

    # Check requests = limits for CPU
    local cpu_req=$(kubectl get pod qos-guaranteed -n spark -o jsonpath='{.spec.containers[0].resources.requests.cpu}' 2>/dev/null)
    local cpu_lim=$(kubectl get pod qos-guaranteed -n spark -o jsonpath='{.spec.containers[0].resources.limits.cpu}' 2>/dev/null)
    check_criterion "CPU requests = limits" "$([ "$cpu_req" = "$cpu_lim" ] && [ -n "$cpu_req" ] && echo true || echo false)" && ((score++))

    echo "$score/$total"
    return 0
}

# ============================================================================
# QUESTION 16 - ServiceAccount Projected Token (4 points)
# ============================================================================
score_q16() {
    local score=0
    local total=4

    echo "Question 16 | ServiceAccount Projected Token"

    # Check Pod exists
    local pod_exists=$(kubectl get pod token-pod -n magma 2>/dev/null && echo true || echo false)
    check_criterion "Pod token-pod exists in magma" "$pod_exists" && ((score++))

    # Check Pod uses ServiceAccount fire-sa
    local sa=$(kubectl get pod token-pod -n magma -o jsonpath='{.spec.serviceAccountName}' 2>/dev/null)
    check_criterion "Pod uses ServiceAccount fire-sa" "$([ "$sa" = "fire-sa" ] && echo true || echo false)" && ((score++))

    # Check projected volume exists
    local projected=$(kubectl get pod token-pod -n magma -o json 2>/dev/null | grep -c "projected")
    check_criterion "Has projected volume" "$([ "$projected" -gt 0 ] && echo true || echo false)" && ((score++))

    # Check mount path
    local mount_path=$(kubectl get pod token-pod -n magma -o jsonpath='{.spec.containers[0].volumeMounts[?(@.name=="fire-token")].mountPath}' 2>/dev/null)
    check_criterion "Token mounted at /var/run/secrets/fire-token/" "$(echo "$mount_path" | grep -q "fire-token" && echo true || echo false)" && ((score++))

    echo "$score/$total"
    return 0
}

# ============================================================================
# QUESTION 17 - TCP Liveness Probe (6 points)
# ============================================================================
score_q17() {
    local score=0
    local total=6

    echo "Question 17 | TCP Liveness Probe"

    # Check Pod exists
    local pod_exists=$(kubectl get pod tcp-health -n ember 2>/dev/null && echo true || echo false)
    check_criterion "Pod tcp-health exists in ember" "$pod_exists" && ((score++))

    # Check Pod is Running
    local pod_status=$(kubectl get pod tcp-health -n ember -o jsonpath='{.status.phase}' 2>/dev/null)
    check_criterion "Pod status is Running" "$([ "$pod_status" = "Running" ] && echo true || echo false)" && ((score++))

    # Check tcpSocket probe exists
    local tcp_probe=$(kubectl get pod tcp-health -n ember -o jsonpath='{.spec.containers[0].livenessProbe.tcpSocket}' 2>/dev/null)
    check_criterion "Has tcpSocket liveness probe" "$([ -n "$tcp_probe" ] && echo true || echo false)" && ((score++))

    # Check port
    local port=$(kubectl get pod tcp-health -n ember -o jsonpath='{.spec.containers[0].livenessProbe.tcpSocket.port}' 2>/dev/null)
    check_criterion "Probe targets port 80" "$([ "$port" = "80" ] && echo true || echo false)" && ((score++))

    # Check initialDelaySeconds
    local initial_delay=$(kubectl get pod tcp-health -n ember -o jsonpath='{.spec.containers[0].livenessProbe.initialDelaySeconds}' 2>/dev/null)
    check_criterion "Initial delay is 10 seconds" "$([ "$initial_delay" = "10" ] && echo true || echo false)" && ((score++))

    # Check periodSeconds
    local period=$(kubectl get pod tcp-health -n ember -o jsonpath='{.spec.containers[0].livenessProbe.periodSeconds}' 2>/dev/null)
    check_criterion "Period is 5 seconds" "$([ "$period" = "5" ] && echo true || echo false)" && ((score++))

    echo "$score/$total"
    return 0
}

# ============================================================================
# QUESTION 18 - Service with Named Ports (6 points)
# ============================================================================
score_q18() {
    local score=0
    local total=6

    echo "Question 18 | Service with Named Ports"

    # Check Service exists
    local svc_exists=$(kubectl get service web-svc -n flame 2>/dev/null && echo true || echo false)
    check_criterion "Service web-svc exists in flame" "$svc_exists" && ((score++))

    # Check service type
    local svc_type=$(kubectl get service web-svc -n flame -o jsonpath='{.spec.type}' 2>/dev/null)
    check_criterion "Service type is ClusterIP" "$([ "$svc_type" = "ClusterIP" ] && echo true || echo false)" && ((score++))

    # Check port 80 exists
    local port80=$(kubectl get service web-svc -n flame -o jsonpath='{.spec.ports[?(@.port==80)].port}' 2>/dev/null)
    check_criterion "Service exposes port 80" "$([ "$port80" = "80" ] && echo true || echo false)" && ((score++))

    # Check targetPort for port 80 is named
    local target80=$(kubectl get service web-svc -n flame -o jsonpath='{.spec.ports[?(@.port==80)].targetPort}' 2>/dev/null)
    check_criterion "Port 80 targets named port http-web" "$([ "$target80" = "http-web" ] && echo true || echo false)" && ((score++))

    # Check port 443
    local port443=$(kubectl get service web-svc -n flame -o jsonpath='{.spec.ports[?(@.port==443)].port}' 2>/dev/null)
    check_criterion "Service exposes port 443" "$([ "$port443" = "443" ] && echo true || echo false)" && ((score++))

    # Check targetPort for port 443 is named
    local target443=$(kubectl get service web-svc -n flame -o jsonpath='{.spec.ports[?(@.port==443)].targetPort}' 2>/dev/null)
    check_criterion "Port 443 targets named port https-web" "$([ "$target443" = "https-web" ] && echo true || echo false)" && ((score++))

    echo "$score/$total"
    return 0
}

# ============================================================================
# QUESTION 19 - Topology Spread Constraints (6 points)
# ============================================================================
score_q19() {
    local score=0
    local total=6

    echo "Question 19 | Topology Spread Constraints"

    # Check Deployment exists
    local deploy_exists=$(kubectl get deployment spread-deploy -n blaze 2>/dev/null && echo true || echo false)
    check_criterion "Deployment spread-deploy exists in blaze" "$deploy_exists" && ((score++))

    # Check replica count
    local replicas=$(kubectl get deployment spread-deploy -n blaze -o jsonpath='{.spec.replicas}' 2>/dev/null)
    check_criterion "Deployment has 4 replicas" "$([ "$replicas" = "4" ] && echo true || echo false)" && ((score++))

    # Check topologySpreadConstraints exists
    local tsc=$(kubectl get deployment spread-deploy -n blaze -o jsonpath='{.spec.template.spec.topologySpreadConstraints}' 2>/dev/null)
    check_criterion "Has topologySpreadConstraints" "$([ -n "$tsc" ] && echo true || echo false)" && ((score++))

    # Check topologyKey
    local topology_key=$(kubectl get deployment spread-deploy -n blaze -o jsonpath='{.spec.template.spec.topologySpreadConstraints[0].topologyKey}' 2>/dev/null)
    check_criterion "topologyKey is kubernetes.io/hostname" "$([ "$topology_key" = "kubernetes.io/hostname" ] && echo true || echo false)" && ((score++))

    # Check maxSkew
    local max_skew=$(kubectl get deployment spread-deploy -n blaze -o jsonpath='{.spec.template.spec.topologySpreadConstraints[0].maxSkew}' 2>/dev/null)
    check_criterion "maxSkew is 1" "$([ "$max_skew" = "1" ] && echo true || echo false)" && ((score++))

    # Check whenUnsatisfiable
    local when_unsat=$(kubectl get deployment spread-deploy -n blaze -o jsonpath='{.spec.template.spec.topologySpreadConstraints[0].whenUnsatisfiable}' 2>/dev/null)
    check_criterion "whenUnsatisfiable is ScheduleAnyway" "$([ "$when_unsat" = "ScheduleAnyway" ] && echo true || echo false)" && ((score++))

    echo "$score/$total"
    return 0
}

# ============================================================================
# QUESTION 20 - Field Selectors (4 points)
# ============================================================================
score_q20() {
    local score=0
    local total=4

    echo "Question 20 | Field Selectors"

    # Check file exists
    local file="$EXAM_DIR/20/running-pods.txt"
    check_criterion "File running-pods.txt exists" "$([ -f "$file" ] && echo true || echo false)" && ((score++))

    if [ -f "$file" ]; then
        # Check file is not empty
        local line_count=$(wc -l < "$file" 2>/dev/null)
        check_criterion "File contains pod names" "$([ "$line_count" -gt 0 ] && echo true || echo false)" && ((score++))

        # Check format is one pod per line (no spaces in lines)
        local valid_format=$(grep -v ' ' "$file" 2>/dev/null | wc -l)
        check_criterion "Format is one pod name per line" "$([ "$valid_format" -eq "$line_count" ] && echo true || echo false)" && ((score++))

        # Verify content contains actual running pods
        local actual_running=$(kubectl get pods --all-namespaces --field-selector=status.phase=Running -o jsonpath='{.items[*].metadata.name}' 2>/dev/null | tr ' ' '\n' | sort)
        local file_pods=$(cat "$file" | sort)
        # At least some overlap
        local overlap=$(comm -12 <(echo "$actual_running") <(echo "$file_pods") | wc -l)
        check_criterion "Content matches running pods" "$([ "$overlap" -gt 0 ] && echo true || echo false)" && ((score++))
    else
        check_criterion "File contains pod names" "false" || true
        check_criterion "Format is one pod name per line" "false" || true
        check_criterion "Content matches running pods" "false" || true
    fi

    echo "$score/$total"
    return 0
}

# ============================================================================
# QUESTION 21 - Node Drain (4 points)
# ============================================================================
score_q21() {
    local score=0
    local total=4

    echo "Question 21 | Node Drain"

    # Check file exists
    local file="$EXAM_DIR/21/drain-command.sh"
    check_criterion "File drain-command.sh exists" "$([ -f "$file" ] && echo true || echo false)" && ((score++))

    if [ -f "$file" ]; then
        local content=$(cat "$file")

        # Check contains kubectl drain
        check_criterion "Command contains 'kubectl drain'" "$(echo "$content" | grep -q "kubectl drain" && echo true || echo false)" && ((score++))

        # Check has required flags
        local has_flags=true
        if ! echo "$content" | grep -q "ignore-daemonsets"; then has_flags=false; fi
        if ! echo "$content" | grep -q "delete-emptydir-data\|delete-local-data"; then has_flags=false; fi
        if ! echo "$content" | grep -q "force"; then has_flags=false; fi
        check_criterion "Command has required flags" "$([ "$has_flags" = true ] && echo true || echo false)" && ((score++))

        # Check has timeout flag
        check_criterion "Command has timeout flag" "$(echo "$content" | grep -qE "timeout[= ]*[0-9]+" && echo true || echo false)" && ((score++))
    else
        check_criterion "Command contains 'kubectl drain'" "false" || true
        check_criterion "Command has required flags" "false" || true
        check_criterion "Command has timeout flag" "false" || true
    fi

    echo "$score/$total"
    return 0
}
