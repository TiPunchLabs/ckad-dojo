#!/bin/bash
# setup-functions.sh - Functions for CKAD Exam Simulator setup and cleanup
# This file is sourced by ckad-setup.sh and ckad-cleanup.sh

# Source common utilities
SCRIPT_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_LIB_DIR/common.sh"

# ============================================================================
# SETUP FUNCTIONS
# ============================================================================

# Create all exam namespaces
setup_namespaces() {
    print_section "Creating namespaces..."

    # Use exam-specific path if available, fallback to legacy
    local manifests_dir="${CURRENT_MANIFESTS_DIR:-$MANIFESTS_DIR}"

    if [ -f "$manifests_dir/namespaces.yaml" ]; then
        if kubectl apply -f "$manifests_dir/namespaces.yaml" 2>/dev/null; then
            print_success "Namespaces created/verified"
        else
            print_fail "Failed to create namespaces"
            return 1
        fi
    else
        print_error "namespaces.yaml not found at $manifests_dir"
        return 1
    fi
}

# Deploy pre-existing resources for exam questions
setup_resources() {
    print_section "Deploying pre-existing resources..."

    local errors=0
    # Use exam-specific path if available, fallback to legacy
    local manifests_dir="${CURRENT_MANIFESTS_DIR:-$MANIFESTS_DIR}"

    # Apply all YAML files in the manifests/setup directory
    if [ -d "$manifests_dir" ]; then
        for manifest in "$manifests_dir"/*.yaml; do
            if [ -f "$manifest" ]; then
                local filename
                filename=$(basename "$manifest")
                # Skip namespaces.yaml as it's handled separately
                if [ "$filename" = "namespaces.yaml" ]; then
                    continue
                fi

                # Try apply first, if it fails due to immutable fields, use replace --force
                if kubectl apply -f "$manifest" 2>/dev/null; then
                    print_success "Applied $filename"
                elif kubectl replace --force -f "$manifest" 2>/dev/null; then
                    print_success "Replaced $filename (force)"
                else
                    print_fail "Failed to apply $filename"
                    ((++errors))
                fi
            fi
        done
    else
        print_skip "No manifests directory found at $manifests_dir"
    fi

    return $errors
}

# Create exam directory structure
setup_directories() {
    print_section "Creating exam directories..."

    # Get total questions from config (default to 22 if not set)
    local total_questions="${TOTAL_QUESTIONS:-22}"
    local preview_questions="${PREVIEW_QUESTIONS:-3}"
    # Use exam-specific path if available, fallback to legacy
    local templates_dir="${CURRENT_TEMPLATES_DIR:-$TEMPLATES_DIR}"

    # Create main exam directory structure
    for i in $(seq 1 "$total_questions"); do
        mkdir -p "$EXAM_DIR/$i"
    done

    # Create preview question directories
    for i in $(seq 1 "$preview_questions"); do
        mkdir -p "$EXAM_DIR/p$i"
    done

    # Create special directories for container build questions
    # Check if there are templates with image directories
    if [ -d "$templates_dir" ]; then
        for image_dir in "$templates_dir"/q*-image/; do
            if [ -d "$image_dir" ]; then
                local q_num
                q_num=$(basename "$image_dir" | sed 's/q\([0-9]*\)-.*/\1/')
                mkdir -p "$EXAM_DIR/$q_num/image"
            fi
        done
    fi

    print_success "Created exam/course directories for $total_questions questions + $preview_questions preview"
}

# Copy template files to exam directories
setup_templates() {
    print_section "Copying template files..."

    local errors=0
    local copied=0
    # Use exam-specific path if available, fallback to legacy
    local templates_dir="${CURRENT_TEMPLATES_DIR:-$TEMPLATES_DIR}"

    if [ ! -d "$templates_dir" ]; then
        print_skip "No templates directory found at $templates_dir"
        return 0
    fi

    # Copy all template files (q##-*.* format - yaml, html, sh, etc.)
    for template in "$templates_dir"/q[0-9]*-*.*; do
        if [ -f "$template" ]; then
            local filename
            filename=$(basename "$template")
            # Extract question number (e.g., q09-pod.yaml -> 9, q15-web-moon.html -> 15)
            local q_num
            q_num=$(echo "$filename" | sed 's/q0*\([0-9]*\)-.*/\1/')
            # Extract target filename (e.g., q09-pod.yaml -> pod.yaml, q15-web-moon.html -> web-moon.html)
            local target_name
            target_name=$(echo "$filename" | sed 's/q[0-9]*-//')

            if [ -d "$EXAM_DIR/$q_num" ]; then
                cp "$template" "$EXAM_DIR/$q_num/$target_name"
                print_success "Q$q_num: $target_name template"
                ((++copied))
            fi
        fi
    done

    # Copy preview question templates (q-p#-*.yaml format)
    for template in "$templates_dir"/q-p[0-9]*-*.yaml; do
        if [ -f "$template" ]; then
            local filename
            filename=$(basename "$template")
            # Extract preview question number (e.g., q-p1-startup-probe.yaml -> p1)
            local p_num
            p_num=$(echo "$filename" | sed 's/q-\(p[0-9]*\)-.*/\1/')
            # Extract target filename
            local target_name
            target_name=$(echo "$filename" | sed 's/q-p[0-9]*-//')

            if [ -d "$EXAM_DIR/$p_num" ]; then
                cp "$template" "$EXAM_DIR/$p_num/$target_name"
                print_success "Preview $p_num: $target_name template"
                ((++copied))
            fi
        fi
    done

    # Copy image directories (q##-image/ format)
    for image_dir in "$templates_dir"/q[0-9]*-image/; do
        if [ -d "$image_dir" ]; then
            local dirname
            dirname=$(basename "$image_dir")
            # Extract question number
            local q_num
            q_num=$(echo "$dirname" | sed 's/q0*\([0-9]*\)-.*/\1/')

            if [ -d "$EXAM_DIR/$q_num/image" ]; then
                cp -r "$image_dir"* "$EXAM_DIR/$q_num/image/"
                print_success "Q$q_num: image files (Dockerfile, etc.)"
                ((++copied))
            fi
        fi
    done

    if [ $copied -eq 0 ]; then
        print_skip "No templates to copy"
    fi

    return $errors
}

# Start local Docker registry for Q11
setup_registry() {
    print_section "Setting up local Docker registry..."

    if docker_container_running "registry"; then
        print_skip "Registry already running"
        return 0
    fi

    # Remove stopped registry container if exists
    docker rm -f registry 2>/dev/null

    # Start registry
    if docker run -d -p 5000:5000 --restart=always --name registry registry:2 2>/dev/null; then
        print_success "Local registry started at localhost:5000"
    else
        print_fail "Failed to start local registry"
        return 1
    fi
}

# Setup Helm environment
setup_helm() {
    print_section "Setting up Helm environment..."

    # Check if helm is available
    if ! command_exists helm; then
        print_fail "Helm is not installed"
        return 1
    fi

    # Check if HELM_RELEASES is defined
    if [ ${#HELM_RELEASES[@]} -eq 0 ]; then
        print_skip "No Helm releases defined for this exam"
        return 0
    fi

    # Get helm namespace from config (default to first exam namespace)
    local helm_ns="${HELM_NAMESPACE:-${EXAM_NAMESPACES[0]}}"

    # Add bitnami repo for Helm charts
    helm repo add bitnami https://charts.bitnami.com/bitnami 2>/dev/null
    helm repo update 2>/dev/null
    print_success "Helm repo configured"

    # Wait for helm namespace to be ready
    local wait_count=0
    while ! namespace_exists "$helm_ns" && [ $wait_count -lt 30 ]; do
        sleep 1
        ((wait_count++))
    done

    if ! namespace_exists "$helm_ns"; then
        print_fail "Helm namespace '$helm_ns' not available"
        return 1
    fi

    # Install all Helm releases defined in config
    for release in "${HELM_RELEASES[@]}"; do
        if ! helm status "$release" -n "$helm_ns" &>/dev/null; then
            if helm install "$release" bitnami/nginx -n "$helm_ns" \
                --set service.type=ClusterIP \
                --set replicaCount=1 \
                --wait --timeout 120s 2>/dev/null; then
                print_success "Installed Helm release: $release"
            else
                print_fail "Failed to install $release"
            fi
        else
            print_skip "$release already exists"
        fi
    done

    return 0
}

# Post-setup for specific questions requiring multi-step initialization
setup_post_resources() {
    print_section "Applying post-setup configurations..."

    local errors=0

    # ============================================================================
    # CKAD-SIMULATION1: Q8 - Create broken revision for rollback exercise
    # ============================================================================
    if kubectl get deployment api-new-c32 -n neptune &>/dev/null; then
        # Wait for deployment to be available
        kubectl rollout status deployment api-new-c32 -n neptune --timeout=60s 2>/dev/null

        # Update with broken image to create revision 2
        if kubectl set image deployment/api-new-c32 nginx=ngnix:1.25.5-alpine -n neptune --record=false 2>/dev/null; then
            print_success "Q8: Created broken deployment revision (ngnix typo)"
        else
            print_fail "Q8: Failed to create broken revision"
            ((errors++))
        fi
    fi

    # ============================================================================
    # CKAD-SIMULATION2: Q21 - Create broken revision for rollback exercise
    # ============================================================================
    if kubectl get deployment rollback-app -n hydra &>/dev/null; then
        # Wait for deployment to be available
        kubectl rollout status deployment rollback-app -n hydra --timeout=60s 2>/dev/null

        # Update with broken image to create revision 2
        if kubectl set image deployment/rollback-app nginx=nginx:broken -n hydra --record=false 2>/dev/null; then
            print_success "Q21: Created broken deployment revision (nginx:broken)"
        else
            print_fail "Q21: Failed to create broken revision"
            ((errors++))
        fi
    fi

    # ============================================================================
    # CKAD-SIMULATION3: Q8 - Create broken revision for rollback exercise
    # ============================================================================
    if kubectl get deployment battle-app -n ares &>/dev/null; then
        # Wait for deployment to be available
        kubectl rollout status deployment battle-app -n ares --timeout=60s 2>/dev/null

        # Update with broken image to create revision 2
        if kubectl set image deployment/battle-app battle-container=nginx:broken-image -n ares --record=false 2>/dev/null; then
            print_success "Q8: Created broken deployment revision (nginx:broken-image)"
        else
            print_fail "Q8: Failed to create broken revision"
            ((errors++))
        fi
    fi

    # ============================================================================
    # CKAD-SIMULATION4: Q9 - Create broken revision for rollback exercise
    # ============================================================================
    if kubectl get deployment voyage-app -n njord &>/dev/null; then
        # Wait for deployment to be available
        kubectl rollout status deployment voyage-app -n njord --timeout=60s 2>/dev/null

        # Update with broken image to create revision 2
        if kubectl set image deployment/voyage-app voyage-container=nginx:broken-voyage -n njord --record=false 2>/dev/null; then
            print_success "Q9: Created broken deployment revision (nginx:broken-voyage)"
        else
            print_fail "Q9: Failed to create broken revision"
            ((errors++))
        fi
    fi

    # ============================================================================
    # BOTH EXAMS: Create broken Helm release for Q4/Q13
    # ============================================================================
    local helm_ns="${HELM_NAMESPACE:-}"
    if [ -n "$helm_ns" ] && namespace_exists "$helm_ns"; then
        # Create a broken Helm release that stays in pending-install state
        if ! helm status broken-release -n "$helm_ns" &>/dev/null; then
            # Method: Use --wait with very short timeout (1s)
            # The chart won't be ready in 1s, leaving release in pending-install state
            helm install broken-release bitnami/nginx -n "$helm_ns" \
                --set service.type=ClusterIP \
                --set replicaCount=1 \
                --wait --timeout 1s &>/dev/null || true

            # Wait a moment for Helm to record the state
            sleep 2

            # Verify the release is in pending-install state
            if helm list -n "$helm_ns" -a 2>/dev/null | grep -q "broken-release.*pending-install"; then
                print_success "Q4/Q13: Created broken Helm release (pending-install)"
            elif helm list -n "$helm_ns" -a 2>/dev/null | grep -q "broken-release.*failed"; then
                # Failed state is also acceptable for the exercise
                print_success "Q4/Q13: Created broken Helm release (failed)"
            elif helm list -n "$helm_ns" -a 2>/dev/null | grep -q "broken-release"; then
                print_success "Q4/Q13: Created broken Helm release"
            else
                print_skip "Q4/Q13: Broken Helm release may not be in expected state"
            fi
        fi
    fi

    return $errors
}

# ============================================================================
# CLEANUP FUNCTIONS
# ============================================================================

# Delete all exam namespaces
cleanup_namespaces() {
    print_section "Deleting exam namespaces..."

    # Use EXAM_NAMESPACES from config if available
    if [ ${#EXAM_NAMESPACES[@]} -eq 0 ]; then
        print_error "No EXAM_NAMESPACES defined in exam config"
        return 1
    fi

    for ns in "${EXAM_NAMESPACES[@]}"; do
        if namespace_exists "$ns"; then
            kubectl delete namespace "$ns" --wait=false 2>/dev/null
            print_success "Deleting $ns (background)"
        else
            print_skip "$ns (not found)"
        fi
    done
}

# Clean up exam-related resources in default namespace
cleanup_default_namespace() {
    print_section "Cleaning up default namespace exam resources..."

    local deleted=0

    # Delete user-created pods in default namespace (exclude system pods)
    local pods
    pods=$(kubectl get pods -n default -o name 2>/dev/null | grep -v "^pod/kube-\|^pod/coredns\|^pod/etcd\|^pod/local-path" || true)
    if [ -n "$pods" ]; then
        for pod in $pods; do
            kubectl delete "$pod" -n default --grace-period=0 --force 2>/dev/null
            print_success "Deleted $pod"
            ((++deleted))
        done
    fi

    # Delete user-created deployments in default namespace
    local deployments
    deployments=$(kubectl get deployments -n default -o name 2>/dev/null)
    if [ -n "$deployments" ]; then
        for deploy in $deployments; do
            kubectl delete "$deploy" -n default 2>/dev/null
            print_success "Deleted $deploy"
            ((++deleted))
        done
    fi

    # Delete user-created services (exclude kubernetes service)
    local services
    services=$(kubectl get services -n default -o name 2>/dev/null | grep -v "^service/kubernetes$" || true)
    if [ -n "$services" ]; then
        for svc in $services; do
            kubectl delete "$svc" -n default 2>/dev/null
            print_success "Deleted $svc"
            ((++deleted))
        done
    fi

    # Delete user-created secrets (exclude default-token and helm releases)
    local secrets
    secrets=$(kubectl get secrets -n default -o name 2>/dev/null | grep -v "default-token\|sh.helm.release" || true)
    if [ -n "$secrets" ]; then
        for secret in $secrets; do
            kubectl delete "$secret" -n default 2>/dev/null
            print_success "Deleted $secret"
            ((++deleted))
        done
    fi

    # Delete user-created configmaps (exclude kube-root-ca.crt)
    local configmaps
    configmaps=$(kubectl get configmaps -n default -o name 2>/dev/null | grep -v "kube-root-ca.crt" || true)
    if [ -n "$configmaps" ]; then
        for cm in $configmaps; do
            kubectl delete "$cm" -n default 2>/dev/null
            print_success "Deleted $cm"
            ((++deleted))
        done
    fi

    # Delete user-created PVCs in default namespace
    local pvcs
    pvcs=$(kubectl get pvc -n default -o name 2>/dev/null)
    if [ -n "$pvcs" ]; then
        for pvc in $pvcs; do
            kubectl delete "$pvc" -n default 2>/dev/null
            print_success "Deleted $pvc"
            ((++deleted))
        done
    fi

    if [ $deleted -eq 0 ]; then
        print_skip "No exam resources found in default namespace"
    fi
}

# Uninstall Helm releases
cleanup_helm() {
    print_section "Cleaning up Helm releases..."

    local found_releases=0

    # Search for helm releases in all exam namespaces
    for ns in "${EXAM_NAMESPACES[@]}"; do
        if namespace_exists "$ns"; then
            local releases
            releases=$(helm list -n "$ns" -q 2>/dev/null)
            if [ -n "$releases" ]; then
                for release in $releases; do
                    helm uninstall "$release" -n "$ns" 2>/dev/null
                    print_success "Uninstalled Helm release: $release (namespace: $ns)"
                    ((++found_releases))
                done
            fi
        fi
    done

    if [ $found_releases -eq 0 ]; then
        print_skip "No Helm releases found in exam namespaces"
    fi
}

# Remove exam directories
cleanup_directories() {
    print_section "Removing exam directories..."

    if [ -d "$EXAM_DIR" ]; then
        rm -rf "$EXAM_DIR"
        print_success "Removed exam/course directory"
    else
        print_skip "exam/course directory not found"
    fi
}

# Stop and remove registry container
cleanup_registry() {
    print_section "Stopping local registry..."

    if docker_container_running "registry"; then
        docker stop registry 2>/dev/null
        docker rm registry 2>/dev/null
        print_success "Registry stopped and removed"
    else
        print_skip "Registry not running"
    fi
}

# Clean up exam Docker containers (Q11 sun-cipher, etc.)
cleanup_docker_containers() {
    print_section "Cleaning up exam Docker containers..."

    local deleted=0

    # List of exam-specific container names/patterns
    local exam_containers=("sun-cipher")

    for container in "${exam_containers[@]}"; do
        if docker ps -a --format '{{.Names}}' | grep -q "^${container}$"; then
            docker stop "$container" 2>/dev/null || true
            docker rm "$container" 2>/dev/null || true
            print_success "Removed container: $container"
            ((++deleted))
        fi
    done

    if [ $deleted -eq 0 ]; then
        print_skip "No exam containers found"
    fi
}

# Clean up Docker images pushed to local registry and local images
cleanup_docker_images() {
    print_section "Cleaning up exam Docker images..."

    local deleted=0

    # Clean up local images tagged with localhost:5000
    local registry_images
    registry_images=$(docker images --format '{{.Repository}}:{{.Tag}}' 2>/dev/null | grep "^localhost:5000/" || true)

    if [ -n "$registry_images" ]; then
        while read -r image; do
            [ -z "$image" ] && continue
            docker rmi "$image" 2>/dev/null || true
            print_success "Removed local image: $image"
            ((++deleted))
        done <<< "$registry_images"
    fi

    # Also clean up known exam image patterns (without registry prefix)
    local exam_image_patterns=("sun-cipher" "holy-api" "web-moon")

    for pattern in "${exam_image_patterns[@]}"; do
        local matching_images
        matching_images=$(docker images --format '{{.Repository}}:{{.Tag}}' 2>/dev/null | grep "$pattern" || true)
        if [ -n "$matching_images" ]; then
            while read -r image; do
                [ -z "$image" ] && continue
                docker rmi "$image" 2>/dev/null || true
                print_success "Removed local image: $image"
                ((++deleted))
            done <<< "$matching_images"
        fi
    done

    # If registry is running, delete images from registry catalog
    if docker_container_running "registry"; then
        # Get list of repositories in the registry
        local repos
        repos=$(curl -s http://localhost:5000/v2/_catalog 2>/dev/null | grep -o '"[^"]*"' | tr -d '"' | grep -v "repositories" || true)

        if [ -n "$repos" ]; then
            print_info "Note: Images in registry will be cleaned when registry restarts"
        fi
    fi

    if [ $deleted -eq 0 ]; then
        print_skip "No exam Docker images found"
    fi
}

# Clean up PersistentVolumes created during exam
cleanup_persistent_volumes() {
    print_section "Cleaning up PersistentVolumes..."

    local deleted=0

    # Get all PVs that are not bound to system namespaces
    local pvs
    pvs=$(kubectl get pv -o jsonpath='{range .items[*]}{.metadata.name}{" "}{.spec.claimRef.namespace}{"\n"}{end}' 2>/dev/null)

    while IFS=' ' read -r pv_name pv_ns; do
        # Skip if empty
        [ -z "$pv_name" ] && continue

        # Check if PV belongs to an exam namespace or has no claim
        local is_exam_pv=false

        # Check against exam namespaces
        for ns in "${EXAM_NAMESPACES[@]}"; do
            if [ "$pv_ns" = "$ns" ] || [ -z "$pv_ns" ]; then
                is_exam_pv=true
                break
            fi
        done

        # Also check for known exam PV patterns
        if [[ "$pv_name" == *"earth"* ]] || [[ "$pv_name" == *"moon"* ]] || [[ "$pv_name" == *"project"* ]]; then
            is_exam_pv=true
        fi

        if [ "$is_exam_pv" = true ]; then
            kubectl delete pv "$pv_name" --grace-period=0 --force 2>/dev/null || true
            print_success "Deleted PV: $pv_name"
            ((++deleted))
        fi
    done <<< "$pvs"

    if [ $deleted -eq 0 ]; then
        print_skip "No exam PersistentVolumes found"
    fi
}

# Clean up custom StorageClasses created during exam
cleanup_storage_classes() {
    print_section "Cleaning up custom StorageClasses..."

    local deleted=0

    # Known exam StorageClass patterns
    local exam_sc_patterns=("moon-" "earth-" "banana-" "-retain" "-ckad")

    local scs
    scs=$(kubectl get sc -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}' 2>/dev/null)

    while read -r sc_name; do
        [ -z "$sc_name" ] && continue

        # Skip default storage classes
        [[ "$sc_name" == "standard" ]] && continue
        [[ "$sc_name" == "local-path" ]] && continue

        # Check if SC matches exam patterns
        local is_exam_sc=false
        for pattern in "${exam_sc_patterns[@]}"; do
            if [[ "$sc_name" == *"$pattern"* ]]; then
                is_exam_sc=true
                break
            fi
        done

        if [ "$is_exam_sc" = true ]; then
            kubectl delete sc "$sc_name" 2>/dev/null || true
            print_success "Deleted StorageClass: $sc_name"
            ((++deleted))
        fi
    done <<< "$scs"

    if [ $deleted -eq 0 ]; then
        print_skip "No exam StorageClasses found"
    fi
}

# Wait for namespace deletion to complete
wait_for_namespace_deletion() {
    print_section "Waiting for namespace deletion..."

    # Use EXAM_NAMESPACES from config
    if [ ${#EXAM_NAMESPACES[@]} -eq 0 ]; then
        print_skip "No namespaces to wait for"
        return 0
    fi

    local timeout=60
    local elapsed=0

    while [ $elapsed -lt $timeout ]; do
        local remaining=0
        for ns in "${EXAM_NAMESPACES[@]}"; do
            if namespace_exists "$ns"; then
                ((++remaining))
            fi
        done

        if [ $remaining -eq 0 ]; then
            print_success "All namespaces deleted"
            return 0
        fi

        sleep 2
        ((elapsed+=2))
    done

    print_fail "Timeout waiting for namespace deletion"
    return 1
}
