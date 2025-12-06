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
                    ((found_releases++))
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
