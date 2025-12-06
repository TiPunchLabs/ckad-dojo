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
        kubectl apply -f "$manifests_dir/namespaces.yaml" 2>/dev/null
        if [ $? -eq 0 ]; then
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

                if kubectl apply -f "$manifest" 2>/dev/null; then
                    print_success "Applied $filename"
                else
                    print_fail "Failed to apply $filename"
                    ((errors++))
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

    # Copy all YAML templates (q##-*.yaml format)
    for template in "$templates_dir"/q[0-9]*-*.yaml; do
        if [ -f "$template" ]; then
            local filename
            filename=$(basename "$template")
            # Extract question number (e.g., q09-pod.yaml -> 9)
            local q_num
            q_num=$(echo "$filename" | sed 's/q0*\([0-9]*\)-.*/\1/')
            # Extract target filename (e.g., q09-pod.yaml -> pod.yaml)
            local target_name
            target_name=$(echo "$filename" | sed 's/q[0-9]*-//')

            if [ -d "$EXAM_DIR/$q_num" ]; then
                cp "$template" "$EXAM_DIR/$q_num/$target_name"
                print_success "Q$q_num: $target_name template"
                ((copied++))
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
                ((copied++))
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
                ((copied++))
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
    docker run -d -p 5000:5000 --restart=always --name registry registry:2 2>/dev/null

    if [ $? -eq 0 ]; then
        print_success "Local registry started at localhost:5000"
    else
        print_fail "Failed to start local registry"
        return 1
    fi
}

# Setup Helm environment for Q4
setup_helm() {
    print_section "Setting up Helm environment..."

    # Check if helm is available
    if ! command_exists helm; then
        print_fail "Helm is not installed"
        return 1
    fi

    # Add bitnami repo for Helm charts
    helm repo add bitnami https://charts.bitnami.com/bitnami 2>/dev/null
    helm repo update 2>/dev/null
    print_success "Helm repo configured"

    # Wait for mercury namespace to be ready
    local wait_count=0
    while ! namespace_exists "mercury" && [ $wait_count -lt 30 ]; do
        sleep 1
        ((wait_count++))
    done

    if ! namespace_exists "mercury"; then
        print_fail "Mercury namespace not available"
        return 1
    fi

    # Install pre-existing Helm releases in mercury namespace using bitnami/nginx

    # Release 1: internal-issue-report-apiv1 (to be deleted by user)
    if ! helm status internal-issue-report-apiv1 -n mercury &>/dev/null; then
        helm install internal-issue-report-apiv1 bitnami/nginx -n mercury \
            --set service.type=ClusterIP \
            --set replicaCount=1 \
            --wait --timeout 120s 2>/dev/null
        if [ $? -eq 0 ]; then
            print_success "Installed Helm release: internal-issue-report-apiv1"
        else
            print_fail "Failed to install internal-issue-report-apiv1"
        fi
    else
        print_skip "internal-issue-report-apiv1 already exists"
    fi

    # Release 2: internal-issue-report-apiv2 (to be upgraded by user)
    if ! helm status internal-issue-report-apiv2 -n mercury &>/dev/null; then
        helm install internal-issue-report-apiv2 bitnami/nginx -n mercury \
            --set service.type=ClusterIP \
            --set replicaCount=1 \
            --wait --timeout 120s 2>/dev/null
        if [ $? -eq 0 ]; then
            print_success "Installed Helm release: internal-issue-report-apiv2"
        else
            print_fail "Failed to install internal-issue-report-apiv2"
        fi
    else
        print_skip "internal-issue-report-apiv2 already exists"
    fi

    # Release 3: internal-issue-report-app (existing, no action needed)
    if ! helm status internal-issue-report-app -n mercury &>/dev/null; then
        helm install internal-issue-report-app bitnami/nginx -n mercury \
            --set service.type=ClusterIP \
            --set replicaCount=1 \
            --wait --timeout 120s 2>/dev/null
        if [ $? -eq 0 ]; then
            print_success "Installed Helm release: internal-issue-report-app"
        else
            print_fail "Failed to install internal-issue-report-app"
        fi
    else
        print_skip "internal-issue-report-app already exists"
    fi

    # Note: Creating a pending-install release is complex and would require
    # interrupting a helm install. For simulation purposes, we skip this.
    # The user can still practice deleting broken releases by checking helm list -a

    return 0
}

# ============================================================================
# CLEANUP FUNCTIONS
# ============================================================================

# Delete all exam namespaces
cleanup_namespaces() {
    print_section "Deleting exam namespaces..."

    local namespaces=("neptune" "saturn" "earth" "mars" "pluto" "jupiter" "mercury" "venus" "moon" "sun" "shell-intern")

    for ns in "${namespaces[@]}"; do
        if namespace_exists "$ns"; then
            kubectl delete namespace "$ns" --wait=false 2>/dev/null
            print_success "Deleting $ns (background)"
        else
            print_skip "$ns (not found)"
        fi
    done
}

# Uninstall Helm releases
cleanup_helm() {
    print_section "Cleaning up Helm releases..."

    # Get all releases in mercury namespace
    if namespace_exists "mercury"; then
        local releases=$(helm list -n mercury -q 2>/dev/null)
        if [ -n "$releases" ]; then
            for release in $releases; do
                helm uninstall "$release" -n mercury 2>/dev/null
                print_success "Uninstalled Helm release: $release"
            done
        else
            print_skip "No Helm releases found in mercury"
        fi
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

# Wait for namespace deletion to complete
wait_for_namespace_deletion() {
    print_section "Waiting for namespace deletion..."

    local namespaces=("neptune" "saturn" "earth" "mars" "pluto" "jupiter" "mercury" "venus" "moon" "sun" "shell-intern")
    local timeout=60
    local elapsed=0

    while [ $elapsed -lt $timeout ]; do
        local remaining=0
        for ns in "${namespaces[@]}"; do
            if namespace_exists "$ns"; then
                ((remaining++))
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
