#!/bin/bash
# scoring-functions.sh - Scoring functions for CKAD Exam Simulator
# Each function returns the number of points scored and prints detailed results

# Source common utilities
SCRIPT_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_LIB_DIR/common.sh"

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

    # Check if file exists and contains namespaces
    local file="$EXAM_DIR/1/namespaces"
    if [ -f "$file" ] && grep -q "default" "$file" 2>/dev/null; then
        check_criterion "File /exam/course/1/namespaces contains all namespaces" "true" && ((score++))
    else
        check_criterion "File /exam/course/1/namespaces contains all namespaces" "false"
    fi

    echo "$score/$total"
    return $score
}

# ============================================================================
# QUESTION 2 - Pods (5 points)
# ============================================================================
score_q2() {
    local score=0
    local total=5

    echo "Question 2 | Pods"

    # Check if Pod is running
    local pod_status=$(kubectl get pod pod1 -n default -o jsonpath='{.status.phase}' 2>/dev/null)
    check_criterion "Pod is running" "$([ "$pod_status" = "Running" ] && echo true || echo false)" && ((score++))

    # Check if Pod has single container
    local container_count=$(kubectl get pod pod1 -n default -o jsonpath='{.spec.containers[*].name}' 2>/dev/null | wc -w)
    check_criterion "Pod has single container" "$([ "$container_count" = "1" ] && echo true || echo false)" && ((score++))

    # Check container name
    local container_name=$(kubectl get pod pod1 -n default -o jsonpath='{.spec.containers[0].name}' 2>/dev/null)
    check_criterion "Container has correct name" "$([ "$container_name" = "pod1-container" ] && echo true || echo false)" && ((score++))

    # Check container image
    local container_image=$(kubectl get pod pod1 -n default -o jsonpath='{.spec.containers[0].image}' 2>/dev/null)
    check_criterion "Container has correct image" "$(echo "$container_image" | grep -q "httpd:2.4.41-alpine" && echo true || echo false)" && ((score++))

    # Check script file exists and uses kubectl
    local script_file="$EXAM_DIR/2/pod1-status-command.sh"
    if [ -f "$script_file" ] && grep -q "kubectl" "$script_file" 2>/dev/null; then
        check_criterion "File /exam/course/2/pod1-status-command.sh uses kubectl" "true" && ((score++))
    else
        check_criterion "File /exam/course/2/pod1-status-command.sh uses kubectl" "false"
    fi

    echo "$score/$total"
    return $score
}

# ============================================================================
# QUESTION 3 - Job (6 points)
# ============================================================================
score_q3() {
    local score=0
    local total=6

    echo "Question 3 | Job"

    # Check Job exists
    local job_exists=$(kubectl get job neb-new-job -n neptune 2>/dev/null && echo true || echo false)
    check_criterion "Job created" "$job_exists" && ((score++))

    # Check Job succeeded 3 times
    local succeeded=$(kubectl get job neb-new-job -n neptune -o jsonpath='{.status.succeeded}' 2>/dev/null)
    check_criterion "Job has succeeded three times" "$([ "$succeeded" = "3" ] && echo true || echo false)" && ((score++))

    # Check parallelism
    local parallelism=$(kubectl get job neb-new-job -n neptune -o jsonpath='{.spec.parallelism}' 2>/dev/null)
    check_criterion "Job has parallelism of two" "$([ "$parallelism" = "2" ] && echo true || echo false)" && ((score++))

    # Check single container
    local container_count=$(kubectl get job neb-new-job -n neptune -o jsonpath='{.spec.template.spec.containers[*].name}' 2>/dev/null | wc -w)
    check_criterion "Job has single container" "$([ "$container_count" = "1" ] && echo true || echo false)" && ((score++))

    # Check container name
    local container_name=$(kubectl get job neb-new-job -n neptune -o jsonpath='{.spec.template.spec.containers[0].name}' 2>/dev/null)
    check_criterion "Container has correct name" "$([ "$container_name" = "neb-new-job-container" ] && echo true || echo false)" && ((score++))

    # Check container image
    local container_image=$(kubectl get job neb-new-job -n neptune -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null)
    check_criterion "Container has correct image" "$(echo "$container_image" | grep -q "busybox:1.31.0" && echo true || echo false)" && ((score++))

    echo "$score/$total"
    return $score
}

# ============================================================================
# QUESTION 4 - Helm Management (5 points)
# ============================================================================
score_q4() {
    local score=0
    local total=5

    echo "Question 4 | Helm Management"

    # Check release apiv1 deleted
    local apiv1_exists=$(helm list -n mercury -q 2>/dev/null | grep -q "internal-issue-report-apiv1" && echo true || echo false)
    check_criterion "Deleted Helm release internal-issue-report-apiv1" "$([ "$apiv1_exists" = "false" ] && echo true || echo false)" && ((score++))

    # Check release apiv2 upgraded
    local apiv2_revision=$(helm list -n mercury -o json 2>/dev/null | grep -o '"revision":[0-9]*' | grep "internal-issue-report-apiv2" -A1 | head -1)
    local apiv2_upgraded=$(helm history internal-issue-report-apiv2 -n mercury 2>/dev/null | wc -l)
    check_criterion "Upgraded Helm release internal-issue-report-apiv2" "$([ "$apiv2_upgraded" -gt 1 ] && echo true || echo false)" && ((score++))

    # Check apache release installed
    local apache_exists=$(helm list -n mercury -q 2>/dev/null | grep -q "internal-issue-report-apache" && echo true || echo false)
    check_criterion "Installed Helm release internal-issue-report-apache" "$apache_exists" && ((score++))

    # Check apache has 2 replicas
    local apache_replicas=$(kubectl get deploy internal-issue-report-apache -n mercury -o jsonpath='{.spec.replicas}' 2>/dev/null)
    check_criterion "Helm release internal-issue-report-apache has two replicas" "$([ "$apache_replicas" = "2" ] && echo true || echo false)" && ((score++))

    # Check broken release deleted (pending-install)
    local broken_exists=$(helm list -n mercury -a -o json 2>/dev/null | grep -q "pending-install" && echo true || echo false)
    check_criterion "Deleted broken Helm release" "$([ "$broken_exists" = "false" ] && echo true || echo false)" && ((score++))

    echo "$score/$total"
    return $score
}

# ============================================================================
# QUESTION 5 - ServiceAccount Token (1 point)
# ============================================================================
score_q5() {
    local score=0
    local total=1

    echo "Question 5 | ServiceAccount, Secret"

    # Check token file exists and contains valid JWT token
    local token_file="$EXAM_DIR/5/token"
    if [ -f "$token_file" ]; then
        local token_content=$(cat "$token_file" 2>/dev/null)
        # JWT tokens start with "ey" and have 3 parts separated by dots
        if echo "$token_content" | grep -q "^ey.*\..*\..*$"; then
            check_criterion "File /exam/course/5/token contains correct token" "true" && ((score++))
        else
            check_criterion "File /exam/course/5/token contains correct token" "false"
        fi
    else
        check_criterion "File /exam/course/5/token contains correct token" "false"
    fi

    echo "$score/$total"
    return $score
}

# ============================================================================
# QUESTION 6 - ReadinessProbe (5 points)
# ============================================================================
score_q6() {
    local score=0
    local total=5

    echo "Question 6 | ReadinessProbe"

    # Check Pod is running
    local pod_status=$(kubectl get pod pod6 -n default -o jsonpath='{.status.phase}' 2>/dev/null)
    check_criterion "Pod is running" "$([ "$pod_status" = "Running" ] && echo true || echo false)" && ((score++))

    # Check single container
    local container_count=$(kubectl get pod pod6 -n default -o jsonpath='{.spec.containers[*].name}' 2>/dev/null | wc -w)
    check_criterion "Pod has single container" "$([ "$container_count" = "1" ] && echo true || echo false)" && ((score++))

    # Check container image
    local container_image=$(kubectl get pod pod6 -n default -o jsonpath='{.spec.containers[0].image}' 2>/dev/null)
    check_criterion "Container has correct image" "$(echo "$container_image" | grep -q "busybox:1.31.0" && echo true || echo false)" && ((score++))

    # Check readinessProbe initialDelaySeconds
    local initial_delay=$(kubectl get pod pod6 -n default -o jsonpath='{.spec.containers[0].readinessProbe.initialDelaySeconds}' 2>/dev/null)
    check_criterion "ReadinessProbe has correct initialDelaySeconds" "$([ "$initial_delay" = "5" ] && echo true || echo false)" && ((score++))

    # Check readinessProbe periodSeconds
    local period=$(kubectl get pod pod6 -n default -o jsonpath='{.spec.containers[0].readinessProbe.periodSeconds}' 2>/dev/null)
    check_criterion "ReadinessProbe has correct periodSeconds" "$([ "$period" = "10" ] && echo true || echo false)" && ((score++))

    echo "$score/$total"
    return $score
}

# ============================================================================
# QUESTION 7 - Pods, Namespaces (6 points)
# ============================================================================
score_q7() {
    local score=0
    local total=6

    echo "Question 7 | Pods, Namespaces"

    # Check Pod running in neptune namespace
    local pod_status=$(kubectl get pod webserver-sat-003 -n neptune -o jsonpath='{.status.phase}' 2>/dev/null)
    check_criterion "Pod is running in new namespace" "$([ "$pod_status" = "Running" ] && echo true || echo false)" && ((score++))

    # Check Pod has name labels
    local pod_labels=$(kubectl get pod webserver-sat-003 -n neptune -o jsonpath='{.metadata.labels}' 2>/dev/null)
    check_criterion "Pod has name labels" "$(echo "$pod_labels" | grep -q "webserver-sat-003" && echo true || echo false)" && ((score++))

    # Check Pod has same amount containers (1)
    local container_count=$(kubectl get pod webserver-sat-003 -n neptune -o jsonpath='{.spec.containers[*].name}' 2>/dev/null | wc -w)
    check_criterion "Pod has same amount containers" "$([ "$container_count" = "1" ] && echo true || echo false)" && ((score++))

    # Check container name
    local container_name=$(kubectl get pod webserver-sat-003 -n neptune -o jsonpath='{.spec.containers[0].name}' 2>/dev/null)
    check_criterion "Container has same name" "$([ "$container_name" = "webserver-sat" ] && echo true || echo false)" && ((score++))

    # Check container image
    local container_image=$(kubectl get pod webserver-sat-003 -n neptune -o jsonpath='{.spec.containers[0].image}' 2>/dev/null)
    check_criterion "Container has same image" "$(echo "$container_image" | grep -q "nginx:1.16.1-alpine" && echo true || echo false)" && ((score++))

    # Check old Pod removed from saturn
    local old_pod=$(kubectl get pod webserver-sat-003 -n saturn 2>/dev/null && echo exists || echo removed)
    check_criterion "Old Pod has been removed" "$([ "$old_pod" = "removed" ] && echo true || echo false)" && ((score++))

    echo "$score/$total"
    return $score
}

# ============================================================================
# QUESTION 8 - Deployment, Rollouts (4 points)
# ============================================================================
score_q8() {
    local score=0
    local total=4

    echo "Question 8 | Deployment, Rollouts"

    # Check container has correct image (not ngnix typo)
    local container_image=$(kubectl get deploy api-new-c32 -n neptune -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null)
    check_criterion "Container has corrected image" "$(echo "$container_image" | grep -v "ngnix" | grep -q "nginx" && echo true || echo false)" && ((score++))

    # Check Deployment has 3 replicas
    local replicas=$(kubectl get deploy api-new-c32 -n neptune -o jsonpath='{.spec.replicas}' 2>/dev/null)
    check_criterion "Deployment has 3 replicas" "$([ "$replicas" = "3" ] && echo true || echo false)" && ((score++))

    # Check Deployment has 3 up-to-date replicas
    local uptodate=$(kubectl get deploy api-new-c32 -n neptune -o jsonpath='{.status.updatedReplicas}' 2>/dev/null)
    check_criterion "Deployment has 3 up-to-date replicas" "$([ "$uptodate" = "3" ] && echo true || echo false)" && ((score++))

    # Check rollout has been made
    local revision=$(kubectl rollout history deploy api-new-c32 -n neptune 2>/dev/null | tail -1 | awk '{print $1}')
    check_criterion "Rollout has been made" "$([ "$revision" -gt 1 ] 2>/dev/null && echo true || echo false)" && ((score++))

    echo "$score/$total"
    return $score
}

# ============================================================================
# QUESTION 9 - Pod to Deployment (10 points)
# ============================================================================
score_q9() {
    local score=0
    local total=10

    echo "Question 9 | Pod -> Deployment"

    # Check Deployment exists
    local deploy_exists=$(kubectl get deploy holy-api -n pluto 2>/dev/null && echo true || echo false)
    check_criterion "Deployment exists" "$deploy_exists" && ((score++))

    # Check 3 replicas
    local replicas=$(kubectl get deploy holy-api -n pluto -o jsonpath='{.spec.replicas}' 2>/dev/null)
    check_criterion "Deployment has 3 replicas" "$([ "$replicas" = "3" ] && echo true || echo false)" && ((score++))

    # Check 3 ready replicas
    local ready=$(kubectl get deploy holy-api -n pluto -o jsonpath='{.status.readyReplicas}' 2>/dev/null)
    check_criterion "Deployment has 3 ready replicas" "$([ "$ready" = "3" ] && echo true || echo false)" && ((score++))

    # Check single container
    local container_count=$(kubectl get deploy holy-api -n pluto -o jsonpath='{.spec.template.spec.containers[*].name}' 2>/dev/null | wc -w)
    check_criterion "Deployment has single container" "$([ "$container_count" = "1" ] && echo true || echo false)" && ((score++))

    # Check container name
    local container_name=$(kubectl get deploy holy-api -n pluto -o jsonpath='{.spec.template.spec.containers[0].name}' 2>/dev/null)
    check_criterion "Container has correct name" "$([ "$container_name" = "holy-api-container" ] && echo true || echo false)" && ((score++))

    # Check container image
    local container_image=$(kubectl get deploy holy-api -n pluto -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null)
    check_criterion "Container has correct image" "$(echo "$container_image" | grep -q "nginx:1.17.3-alpine" && echo true || echo false)" && ((score++))

    # Check SecurityContext
    local allow_priv=$(kubectl get deploy holy-api -n pluto -o jsonpath='{.spec.template.spec.containers[0].securityContext.allowPrivilegeEscalation}' 2>/dev/null)
    local privileged=$(kubectl get deploy holy-api -n pluto -o jsonpath='{.spec.template.spec.containers[0].securityContext.privileged}' 2>/dev/null)
    check_criterion "Deployment defines correct SecurityContext" "$([ "$allow_priv" = "false" ] && [ "$privileged" = "false" ] && echo true || echo false)" && ((score++))

    # Check template has same label as pod
    local template_labels=$(kubectl get deploy holy-api -n pluto -o jsonpath='{.spec.template.metadata.labels.id}' 2>/dev/null)
    check_criterion "Deployment template has same label as pod" "$([ "$template_labels" = "holy-api" ] && echo true || echo false)" && ((score++))

    # Check yaml file exists
    local yaml_file="$EXAM_DIR/9/holy-api-deployment.yaml"
    check_criterion "File /exam/course/9/holy-api-deployment.yaml exists" "$([ -f "$yaml_file" ] && echo true || echo false)" && ((score++))

    # Check old Pod removed
    local old_pod=$(kubectl get pod holy-api -n pluto 2>/dev/null && echo exists || echo removed)
    check_criterion "Old Pod has been removed" "$([ "$old_pod" = "removed" ] && echo true || echo false)" && ((score++))

    echo "$score/$total"
    return $score
}

# ============================================================================
# QUESTION 10 - Service, Logs (9 points)
# ============================================================================
score_q10() {
    local score=0
    local total=9

    echo "Question 10 | Service, Logs"

    # Check Service exists with ClusterIP type
    local svc_type=$(kubectl get svc project-plt-6cc-svc -n pluto -o jsonpath='{.spec.type}' 2>/dev/null)
    check_criterion "Service type ClusterIP exists" "$([ "$svc_type" = "ClusterIP" ] && echo true || echo false)" && ((score++))

    # Check Service selector
    local svc_selector=$(kubectl get svc project-plt-6cc-svc -n pluto -o jsonpath='{.spec.selector.project}' 2>/dev/null)
    check_criterion "Service has correct selector" "$([ "$svc_selector" = "plt-6cc-api" ] && echo true || echo false)" && ((score++))

    # Check Service port
    local svc_port=$(kubectl get svc project-plt-6cc-svc -n pluto -o jsonpath='{.spec.ports[0].port}' 2>/dev/null)
    check_criterion "Service has correct port" "$([ "$svc_port" = "3333" ] && echo true || echo false)" && ((score++))

    # Check Pod exists
    local pod_exists=$(kubectl get pod project-plt-6cc-api -n pluto 2>/dev/null && echo true || echo false)
    check_criterion "Pod exists" "$pod_exists" && ((score++))

    # Check Pod is running
    local pod_status=$(kubectl get pod project-plt-6cc-api -n pluto -o jsonpath='{.status.phase}' 2>/dev/null)
    check_criterion "Pod is running" "$([ "$pod_status" = "Running" ] && echo true || echo false)" && ((score++))

    # Check Pod container image
    local pod_image=$(kubectl get pod project-plt-6cc-api -n pluto -o jsonpath='{.spec.containers[0].image}' 2>/dev/null)
    check_criterion "Pod has correct container image" "$(echo "$pod_image" | grep -q "nginx:1.17.3-alpine" && echo true || echo false)" && ((score++))

    # Check Pod label
    local pod_label=$(kubectl get pod project-plt-6cc-api -n pluto -o jsonpath='{.metadata.labels.project}' 2>/dev/null)
    check_criterion "Pod has correct label" "$([ "$pod_label" = "plt-6cc-api" ] && echo true || echo false)" && ((score++))

    # Check HTML file exists and is valid
    local html_file="$EXAM_DIR/10/service_test.html"
    check_criterion "File /exam/course/10/service_test.html valid" "$([ -s "$html_file" ] && grep -q "nginx" "$html_file" && echo true || echo false)" && ((score++))

    # Check log file exists and is valid
    local log_file="$EXAM_DIR/10/service_test.log"
    check_criterion "File /exam/course/10/service_test.log valid" "$([ -s "$log_file" ] && echo true || echo false)" && ((score++))

    echo "$score/$total"
    return $score
}

# ============================================================================
# QUESTION 11 - Working with Containers (7 points)
# NOTE: This question does NOT use kubectl - only docker/podman commands
# ============================================================================
score_q11() {
    local score=0
    local total=7

    echo "Question 11 | Working with Containers"

    # Check Dockerfile has been adjusted (ENV SUN_CIPHER_ID)
    local dockerfile="$EXAM_DIR/11/image/Dockerfile"
    if [ -f "$dockerfile" ]; then
        check_criterion "Dockerfile has been adjusted" "$(grep -q "ENV SUN_CIPHER_ID" "$dockerfile" && echo true || echo false)" && ((score++))
    else
        check_criterion "Dockerfile has been adjusted" "false"
    fi

    # Check Docker image built with tag
    local docker_image=$(sudo docker images --format '{{.Repository}}:{{.Tag}}' 2>/dev/null | grep -q "localhost:5000/sun-cipher:v1-docker" && echo true || echo false)
    check_criterion "Docker image built with tag" "$docker_image" && ((score++))

    # Check Docker image pushed to registry
    # We check if the image exists in the registry by trying to pull it
    local docker_pushed=$(curl -s http://localhost:5000/v2/sun-cipher/tags/list 2>/dev/null | grep -q "v1-docker" && echo true || echo false)
    check_criterion "Docker image pushed to registry with tag" "$docker_pushed" && ((score++))

    # Check Podman image built with tag
    local podman_image=$(sudo podman images --format '{{.Repository}}:{{.Tag}}' 2>/dev/null | grep -q "localhost:5000/sun-cipher:v1-podman" && echo true || echo false)
    check_criterion "Podman image built with tag" "$podman_image" && ((score++))

    # Check Podman image pushed to registry
    local podman_pushed=$(curl -s http://localhost:5000/v2/sun-cipher/tags/list 2>/dev/null | grep -q "v1-podman" && echo true || echo false)
    check_criterion "Podman image pushed to registry with tag" "$podman_pushed" && ((score++))

    # Check Podman container is running
    local container_running=$(sudo podman ps --format '{{.Names}}' 2>/dev/null | grep -q "sun-cipher" && echo true || echo false)
    check_criterion "Podman container is running" "$container_running" && ((score++))

    # Check logs file exists
    local logs_file="$EXAM_DIR/11/logs"
    check_criterion "Podman container produces correct logs and export is in file /exam/course/11/logs" "$([ -s "$logs_file" ] && echo true || echo false)" && ((score++))

    echo "$score/$total"
    return $score
}

# ============================================================================
# QUESTION 12 - Storage, PV, PVC, Pod volume (6 points)
# ============================================================================
score_q12() {
    local score=0
    local total=6

    echo "Question 12 | Storage, PV, PVC, Pod volume"

    # Check PV exists
    local pv_exists=$(kubectl get pv earth-project-earthflower-pv 2>/dev/null && echo true || echo false)
    check_criterion "PersistentVolume exists" "$pv_exists" && ((score++))

    # Check PV is correctly defined
    local pv_capacity=$(kubectl get pv earth-project-earthflower-pv -o jsonpath='{.spec.capacity.storage}' 2>/dev/null)
    local pv_access=$(kubectl get pv earth-project-earthflower-pv -o jsonpath='{.spec.accessModes[0]}' 2>/dev/null)
    local pv_path=$(kubectl get pv earth-project-earthflower-pv -o jsonpath='{.spec.hostPath.path}' 2>/dev/null)
    check_criterion "PersistentVolume correct defined" "$([ "$pv_capacity" = "2Gi" ] && [ "$pv_access" = "ReadWriteOnce" ] && [ "$pv_path" = "/Volumes/Data" ] && echo true || echo false)" && ((score++))

    # Check PVC exists
    local pvc_exists=$(kubectl get pvc earth-project-earthflower-pvc -n earth 2>/dev/null && echo true || echo false)
    check_criterion "PersistentVolumeClaim exists" "$pvc_exists" && ((score++))

    # Check PVC is correctly defined
    local pvc_capacity=$(kubectl get pvc earth-project-earthflower-pvc -n earth -o jsonpath='{.spec.resources.requests.storage}' 2>/dev/null)
    local pvc_access=$(kubectl get pvc earth-project-earthflower-pvc -n earth -o jsonpath='{.spec.accessModes[0]}' 2>/dev/null)
    check_criterion "PersistentVolumeClaim correct defined" "$([ "$pvc_capacity" = "2Gi" ] && [ "$pvc_access" = "ReadWriteOnce" ] && echo true || echo false)" && ((score++))

    # Check Deployment exists
    local deploy_exists=$(kubectl get deploy project-earthflower -n earth 2>/dev/null && echo true || echo false)
    check_criterion "Deployment exists" "$deploy_exists" && ((score++))

    # Check Deployment mounts volume
    local mount_path=$(kubectl get deploy project-earthflower -n earth -o jsonpath='{.spec.template.spec.containers[0].volumeMounts[0].mountPath}' 2>/dev/null)
    check_criterion "Deployment container mounts volume" "$([ "$mount_path" = "/tmp/project-data" ] && echo true || echo false)" && ((score++))

    echo "$score/$total"
    return $score
}

# ============================================================================
# QUESTION 13 - Storage, StorageClass, PVC (6 points)
# ============================================================================
score_q13() {
    local score=0
    local total=6

    echo "Question 13 | Storage, StorageClass, PVC"

    # Check StorageClass exists
    local sc_exists=$(kubectl get sc moon-retain 2>/dev/null && echo true || echo false)
    check_criterion "StorageClass exists" "$sc_exists" && ((score++))

    # Check StorageClass correctly defined
    local sc_provisioner=$(kubectl get sc moon-retain -o jsonpath='{.provisioner}' 2>/dev/null)
    local sc_reclaim=$(kubectl get sc moon-retain -o jsonpath='{.reclaimPolicy}' 2>/dev/null)
    check_criterion "StorageClass correct defined" "$([ "$sc_provisioner" = "moon-retainer" ] && [ "$sc_reclaim" = "Retain" ] && echo true || echo false)" && ((score++))

    # Check PVC exists
    local pvc_exists=$(kubectl get pvc moon-pvc-126 -n moon 2>/dev/null && echo true || echo false)
    check_criterion "PersistentVolumeClaim exists" "$pvc_exists" && ((score++))

    # Check PVC correctly defined
    local pvc_storage=$(kubectl get pvc moon-pvc-126 -n moon -o jsonpath='{.spec.resources.requests.storage}' 2>/dev/null)
    local pvc_access=$(kubectl get pvc moon-pvc-126 -n moon -o jsonpath='{.spec.accessModes[0]}' 2>/dev/null)
    local pvc_sc=$(kubectl get pvc moon-pvc-126 -n moon -o jsonpath='{.spec.storageClassName}' 2>/dev/null)
    check_criterion "PersistentVolumeClaim correct defined" "$([ "$pvc_storage" = "3Gi" ] && [ "$pvc_access" = "ReadWriteOnce" ] && [ "$pvc_sc" = "moon-retain" ] && echo true || echo false)" && ((score++))

    # Check PVC status is Pending
    local pvc_status=$(kubectl get pvc moon-pvc-126 -n moon -o jsonpath='{.status.phase}' 2>/dev/null)
    check_criterion "PersistentVolumeClaim status Pending" "$([ "$pvc_status" = "Pending" ] && echo true || echo false)" && ((score++))

    # Check reason file exists
    local reason_file="$EXAM_DIR/13/pvc-126-reason"
    check_criterion "File /exam/course/13/pvc-126-reason valid" "$([ -s "$reason_file" ] && echo true || echo false)" && ((score++))

    echo "$score/$total"
    return $score
}

# ============================================================================
# QUESTION 14 - Secret, Secret-Volume, Secret-Env (8 points)
# ============================================================================
score_q14() {
    local score=0
    local total=8

    echo "Question 14 | Secret, Secret-Volume, Secret-Env"

    # Check secret1 exists
    local secret1_exists=$(kubectl get secret secret1 -n moon 2>/dev/null && echo true || echo false)
    check_criterion "Secret secret1 exists" "$secret1_exists" && ((score++))

    # Check secret1 correctly defined (has user and pass keys)
    local secret1_user=$(kubectl get secret secret1 -n moon -o jsonpath='{.data.user}' 2>/dev/null | base64 -d)
    local secret1_pass=$(kubectl get secret secret1 -n moon -o jsonpath='{.data.pass}' 2>/dev/null | base64 -d)
    check_criterion "Secret secret1 correct defined" "$([ "$secret1_user" = "test" ] && [ "$secret1_pass" = "pwd" ] && echo true || echo false)" && ((score++))

    # Check secret2 exists
    local secret2_exists=$(kubectl get secret secret2 -n moon 2>/dev/null && echo true || echo false)
    check_criterion "Secret secret2 exists" "$secret2_exists" && ((score++))

    # Check Pod has secret2 volume
    local pod_volumes=$(kubectl get pod secret-handler -n moon -o jsonpath='{.spec.volumes[*].secret.secretName}' 2>/dev/null)
    check_criterion "Pod has secret2 volume" "$(echo "$pod_volumes" | grep -q "secret2" && echo true || echo false)" && ((score++))

    # Check Pod container mounts secret2 volume
    local mount_paths=$(kubectl get pod secret-handler -n moon -o jsonpath='{.spec.containers[0].volumeMounts[*].mountPath}' 2>/dev/null)
    check_criterion "Pod container mounts secret2 volume" "$(echo "$mount_paths" | grep -q "/tmp/secret2" && echo true || echo false)" && ((score++))

    # Check Pod container ready
    local pod_ready=$(kubectl get pod secret-handler -n moon -o jsonpath='{.status.containerStatuses[0].ready}' 2>/dev/null)
    check_criterion "Pod container ready" "$([ "$pod_ready" = "true" ] && echo true || echo false)" && ((score++))

    # Check Pod container has secret1 envs
    local env_names=$(kubectl get pod secret-handler -n moon -o jsonpath='{.spec.containers[0].env[*].name}' 2>/dev/null)
    check_criterion "Pod container has secret1 envs" "$(echo "$env_names" | grep -q "SECRET1_USER" && echo "$env_names" | grep -q "SECRET1_PASS" && echo true || echo false)" && ((score++))

    # Check yaml file exists
    local yaml_file="$EXAM_DIR/14/secret-handler-new.yaml"
    check_criterion "File /exam/course/14/secret-handler-new.yaml exists" "$([ -f "$yaml_file" ] && echo true || echo false)" && ((score++))

    echo "$score/$total"
    return $score
}

# ============================================================================
# QUESTION 15 - ConfigMap, Configmap-Volume (3 points)
# ============================================================================
score_q15() {
    local score=0
    local total=3

    echo "Question 15 | ConfigMap, Configmap-Volume"

    # Check ConfigMap exists
    local cm_exists=$(kubectl get cm configmap-web-moon-html -n moon 2>/dev/null && echo true || echo false)
    check_criterion "ConfigMap exists" "$cm_exists" && ((score++))

    # Check ConfigMap correctly defined (has index.html key)
    local cm_keys=$(kubectl get cm configmap-web-moon-html -n moon -o jsonpath='{.data}' 2>/dev/null)
    check_criterion "ConfigMap correct defined" "$(echo "$cm_keys" | grep -q "index.html" && echo true || echo false)" && ((score++))

    # Check Deployment running
    local deploy_ready=$(kubectl get deploy web-moon -n moon -o jsonpath='{.status.readyReplicas}' 2>/dev/null)
    local deploy_replicas=$(kubectl get deploy web-moon -n moon -o jsonpath='{.spec.replicas}' 2>/dev/null)
    check_criterion "Deployment running" "$([ "$deploy_ready" = "$deploy_replicas" ] && [ -n "$deploy_ready" ] && echo true || echo false)" && ((score++))

    echo "$score/$total"
    return $score
}

# ============================================================================
# QUESTION 16 - Logging sidecar (6 points)
# ============================================================================
score_q16() {
    local score=0
    local total=6

    echo "Question 16 | Logging sidecar"

    # Check Deployment has logger sidecar container
    local init_containers=$(kubectl get deploy cleaner -n mercury -o jsonpath='{.spec.template.spec.initContainers[*].name}' 2>/dev/null)
    check_criterion "Deployment has new logger sidecar container" "$(echo "$init_containers" | grep -q "logger-con" && echo true || echo false)" && ((score++))

    # Check sidecar is initContainer with RestartPolicy=Always
    local restart_policy=$(kubectl get deploy cleaner -n mercury -o json 2>/dev/null | grep -A5 '"name": "logger-con"' | grep -o '"restartPolicy": "[^"]*"' | head -1)
    check_criterion "Sidecar container is initContainer with RestartPolicy=Always" "$(echo "$restart_policy" | grep -q "Always" && echo true || echo false)" && ((score++))

    # Check Deployment has two ready replicas
    local ready_replicas=$(kubectl get deploy cleaner -n mercury -o jsonpath='{.status.readyReplicas}' 2>/dev/null)
    check_criterion "Deployment has two ready replicas" "$([ "$ready_replicas" = "2" ] && echo true || echo false)" && ((score++))

    # Check logger container has correct image
    local logger_image=$(kubectl get deploy cleaner -n mercury -o json 2>/dev/null | grep -A5 '"name": "logger-con"' | grep '"image"' | head -1)
    check_criterion "Deployment logger container correct image" "$(echo "$logger_image" | grep -q "busybox:1.31.0" && echo true || echo false)" && ((score++))

    # Check logger container has correct volumeMount
    local logger_mount=$(kubectl get deploy cleaner -n mercury -o json 2>/dev/null | grep -A20 '"name": "logger-con"' | grep -A5 '"volumeMounts"' | grep '"mountPath"' | head -1)
    check_criterion "Deployment logger container correct volumeMount" "$(echo "$logger_mount" | grep -q "/var/log/cleaner" && echo true || echo false)" && ((score++))

    # Check yaml file exists
    local yaml_file="$EXAM_DIR/16/cleaner-new.yaml"
    check_criterion "File /exam/course/16/cleaner-new.yaml exists" "$([ -f "$yaml_file" ] && echo true || echo false)" && ((score++))

    echo "$score/$total"
    return $score
}

# ============================================================================
# QUESTION 17 - InitContainer (5 points)
# ============================================================================
score_q17() {
    local score=0
    local total=5

    echo "Question 17 | InitContainer"

    # Check Deployment exists and replicas ready
    local ready_replicas=$(kubectl get deploy test-init-container -n mars -o jsonpath='{.status.readyReplicas}' 2>/dev/null)
    local replicas=$(kubectl get deploy test-init-container -n mars -o jsonpath='{.spec.replicas}' 2>/dev/null)
    check_criterion "Deployment exists and replicas ready" "$([ "$ready_replicas" = "$replicas" ] && [ -n "$ready_replicas" ] && echo true || echo false)" && ((score++))

    # Check Deployment has new initcontainer
    local init_containers=$(kubectl get deploy test-init-container -n mars -o jsonpath='{.spec.template.spec.initContainers[*].name}' 2>/dev/null)
    check_criterion "Deployment has new initcontainer" "$(echo "$init_containers" | grep -q "init-con" && echo true || echo false)" && ((score++))

    # Check Initcontainer has correct image
    local init_image=$(kubectl get deploy test-init-container -n mars -o jsonpath='{.spec.template.spec.initContainers[?(@.name=="init-con")].image}' 2>/dev/null)
    check_criterion "Initcontainer has correct image" "$(echo "$init_image" | grep -q "busybox:1.31.0" && echo true || echo false)" && ((score++))

    # Check Pod responds via http
    local pod_ip=$(kubectl get pod -n mars -l id=test-init-container -o jsonpath='{.items[0].status.podIP}' 2>/dev/null)
    local http_response=$(kubectl run tmp-q17 --restart=Never --rm -i --image=nginx:alpine -- curl -s -m 2 "http://$pod_ip" 2>/dev/null)
    check_criterion "Pod responds via http" "$([ -n "$http_response" ] && echo true || echo false)" && ((score++))

    # Check Pod http responds contains correct text
    check_criterion "Pod http respond contains correct text" "$(echo "$http_response" | grep -q "check this out" && echo true || echo false)" && ((score++))

    echo "$score/$total"
    return $score
}

# ============================================================================
# QUESTION 18 - Service misconfiguration (2 points)
# ============================================================================
score_q18() {
    local score=0
    local total=2

    echo "Question 18 | Service misconfiguration"

    # Check Service has correct selector
    local svc_selector=$(kubectl get svc manager-api-svc -n mars -o jsonpath='{.spec.selector.id}' 2>/dev/null)
    check_criterion "Service has correct selector" "$([ "$svc_selector" = "manager-api-pod" ] && echo true || echo false)" && ((score++))

    # Check Service has Pods as Endpoints
    local endpoints=$(kubectl get endpoints manager-api-svc -n mars -o jsonpath='{.subsets[0].addresses}' 2>/dev/null)
    check_criterion "Service has Pods as Endpoints" "$([ -n "$endpoints" ] && echo true || echo false)" && ((score++))

    echo "$score/$total"
    return $score
}

# ============================================================================
# QUESTION 19 - Service ClusterIP->NodePort (2 points)
# ============================================================================
score_q19() {
    local score=0
    local total=2

    echo "Question 19 | Service ClusterIP->NodePort"

    # Check Service is NodePort type
    local svc_type=$(kubectl get svc jupiter-crew-svc -n jupiter -o jsonpath='{.spec.type}' 2>/dev/null)
    check_criterion "Service is of type NodePort" "$([ "$svc_type" = "NodePort" ] && echo true || echo false)" && ((score++))

    # Check NodePort is 30100
    local node_port=$(kubectl get svc jupiter-crew-svc -n jupiter -o jsonpath='{.spec.ports[0].nodePort}' 2>/dev/null)
    check_criterion "Service NodePort has correct port" "$([ "$node_port" = "30100" ] && echo true || echo false)" && ((score++))

    echo "$score/$total"
    return $score
}

# ============================================================================
# QUESTION 20 - NetworkPolicy (5 points)
# ============================================================================
score_q20() {
    local score=0
    local total=5

    echo "Question 20 | NetworkPolicy"

    # Check NetworkPolicy exists
    local np_exists=$(kubectl get networkpolicy np1 -n venus 2>/dev/null && echo true || echo false)
    check_criterion "NetworkPolicy exists" "$np_exists" && ((score++))

    # Check Deployments exist with replicas ready
    local api_ready=$(kubectl get deploy api -n venus -o jsonpath='{.status.readyReplicas}' 2>/dev/null)
    local frontend_ready=$(kubectl get deploy frontend -n venus -o jsonpath='{.status.readyReplicas}' 2>/dev/null)
    check_criterion "Deployments api and frontend exist with replicas ready" "$([ -n "$api_ready" ] && [ -n "$frontend_ready" ] && echo true || echo false)" && ((score++))

    # Check frontend cannot reach internet (this is hard to test accurately without running a pod)
    # We'll check if the NetworkPolicy has egress rules that restrict internet access
    local np_egress=$(kubectl get networkpolicy np1 -n venus -o jsonpath='{.spec.egress}' 2>/dev/null)
    check_criterion "Deployment frontend cannot reach internet" "$([ -n "$np_egress" ] && echo true || echo false)" && ((score++))

    # Check frontend can resolve DNS (NetworkPolicy allows port 53)
    local np_dns=$(kubectl get networkpolicy np1 -n venus -o json 2>/dev/null | grep -q '"port": 53' && echo true || echo false)
    check_criterion "Deployment frontend can resolve DNS" "$np_dns" && ((score++))

    # Check frontend can reach api
    local np_api=$(kubectl get networkpolicy np1 -n venus -o jsonpath='{.spec.egress[*].to[*].podSelector.matchLabels.id}' 2>/dev/null)
    check_criterion "Deployment frontend can reach deployment api" "$(echo "$np_api" | grep -q "api" && echo true || echo false)" && ((score++))

    echo "$score/$total"
    return $score
}

# ============================================================================
# QUESTION 21 - Requests and Limits, ServiceAccount (8 points)
# ============================================================================
score_q21() {
    local score=0
    local total=8

    echo "Question 21 | Requests and Limits, ServiceAccount"

    # Check Deployment has 3 replicas
    local replicas=$(kubectl get deploy neptune-10ab -n neptune -o jsonpath='{.spec.replicas}' 2>/dev/null)
    check_criterion "Deployment has 3 replicas" "$([ "$replicas" = "3" ] && echo true || echo false)" && ((score++))

    # Check Deployment has 3 ready replicas
    local ready_replicas=$(kubectl get deploy neptune-10ab -n neptune -o jsonpath='{.status.readyReplicas}' 2>/dev/null)
    check_criterion "Deployment has 3 ready replicas" "$([ "$ready_replicas" = "3" ] && echo true || echo false)" && ((score++))

    # Check single container
    local container_count=$(kubectl get deploy neptune-10ab -n neptune -o jsonpath='{.spec.template.spec.containers[*].name}' 2>/dev/null | wc -w)
    check_criterion "Deployment has single container" "$([ "$container_count" = "1" ] && echo true || echo false)" && ((score++))

    # Check container name
    local container_name=$(kubectl get deploy neptune-10ab -n neptune -o jsonpath='{.spec.template.spec.containers[0].name}' 2>/dev/null)
    check_criterion "Container has correct name" "$([ "$container_name" = "neptune-pod-10ab" ] && echo true || echo false)" && ((score++))

    # Check container image
    local container_image=$(kubectl get deploy neptune-10ab -n neptune -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null)
    check_criterion "Container has correct image" "$(echo "$container_image" | grep -q "httpd:2.4-alpine" && echo true || echo false)" && ((score++))

    # Check resource limits
    local mem_limit=$(kubectl get deploy neptune-10ab -n neptune -o jsonpath='{.spec.template.spec.containers[0].resources.limits.memory}' 2>/dev/null)
    check_criterion "Container has correct resource limits" "$([ "$mem_limit" = "50Mi" ] && echo true || echo false)" && ((score++))

    # Check resource requests
    local mem_request=$(kubectl get deploy neptune-10ab -n neptune -o jsonpath='{.spec.template.spec.containers[0].resources.requests.memory}' 2>/dev/null)
    check_criterion "Container has correct resource requests" "$([ "$mem_request" = "20Mi" ] && echo true || echo false)" && ((score++))

    # Check ServiceAccount
    local sa=$(kubectl get deploy neptune-10ab -n neptune -o jsonpath='{.spec.template.spec.serviceAccountName}' 2>/dev/null)
    check_criterion "Template has correct ServiceAccount" "$([ "$sa" = "neptune-sa-v2" ] && echo true || echo false)" && ((score++))

    echo "$score/$total"
    return $score
}

# ============================================================================
# QUESTION 22 - Labels, Annotations (3 points)
# ============================================================================
score_q22() {
    local score=0
    local total=3

    echo "Question 22 | Labels, Annotations"

    # Check Pods with type=runner have new labels
    local runner_pods=$(kubectl get pods -n sun -l type=runner -o jsonpath='{.items[*].metadata.labels.protected}' 2>/dev/null)
    check_criterion "Pods with label type=runner have new labels" "$(echo "$runner_pods" | grep -q "true" && echo true || echo false)" && ((score++))

    # Check Pods with type=worker have new labels
    local worker_pods=$(kubectl get pods -n sun -l type=worker -o jsonpath='{.items[*].metadata.labels.protected}' 2>/dev/null)
    check_criterion "Pods with label type=worker have new labels" "$(echo "$worker_pods" | grep -q "true" && echo true || echo false)" && ((score++))

    # Check Pods with protected=true have annotation
    local protected_pods=$(kubectl get pods -n sun -l protected=true -o jsonpath='{.items[*].metadata.annotations.protected}' 2>/dev/null)
    check_criterion "Pods with label protected=true have annotation" "$(echo "$protected_pods" | grep -q "do not delete this pod" && echo true || echo false)" && ((score++))

    echo "$score/$total"
    return $score
}

# ============================================================================
# PREVIEW QUESTION 1 - Liveness Probe (scored as preview)
# ============================================================================
score_preview_q1() {
    local score=0
    local total=3

    echo "Preview Question 1 | Liveness Probe"

    # Check Pod/Deployment exists
    local resource_exists=$(kubectl get deploy project-23-api -n shell-intern 2>/dev/null && echo true || echo false)
    check_criterion "Deployment exists" "$resource_exists" && ((score++))

    # Check livenessProbe exists
    local liveness=$(kubectl get deploy project-23-api -n shell-intern -o jsonpath='{.spec.template.spec.containers[0].livenessProbe}' 2>/dev/null)
    check_criterion "Liveness probe configured" "$([ -n "$liveness" ] && echo true || echo false)" && ((score++))

    # Check replicas ready
    local ready=$(kubectl get deploy project-23-api -n shell-intern -o jsonpath='{.status.readyReplicas}' 2>/dev/null)
    check_criterion "Replicas ready" "$([ -n "$ready" ] && echo true || echo false)" && ((score++))

    echo "$score/$total"
    return $score
}
