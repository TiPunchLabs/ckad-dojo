#!/bin/bash
# scoring-functions.sh - CKAD Simulation 4 Scoring Functions
# Norse Mythology Theme - 22 questions, 115 points total

# Source common utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../scripts/lib/common.sh" 2>/dev/null || true

# Q1: Multi-container Pod (5 points)
score_q1() {
    local score=0
    local max_points=5

    # Check pod exists
    if kubectl get pod ravens-pod -n odin &>/dev/null; then
        ((score++))

        # Check container huginn exists with correct image
        if kubectl get pod ravens-pod -n odin -o jsonpath='{.spec.containers[*].name}' | grep -q "huginn"; then
            ((score++))
        fi

        # Check container muninn exists
        if kubectl get pod ravens-pod -n odin -o jsonpath='{.spec.containers[*].name}' | grep -q "muninn"; then
            ((score++))
        fi

        # Check emptyDir volume
        if kubectl get pod ravens-pod -n odin -o jsonpath='{.spec.volumes[*].emptyDir}' | grep -q "{}"; then
            ((score++))
        fi

        # Check pod is running
        if kubectl get pod ravens-pod -n odin -o jsonpath='{.status.phase}' | grep -q "Running"; then
            ((score++))
        fi
    fi

    echo "$score/$max_points"
}

# Q2: Job (5 points)
score_q2() {
    local score=0
    local max_points=5

    # Check job exists
    if kubectl get job mjolnir-forge -n thor &>/dev/null; then
        ((score++))

        # Check completions = 4
        if [ "$(kubectl get job mjolnir-forge -n thor -o jsonpath='{.spec.completions}')" = "4" ]; then
            ((score++))
        fi

        # Check parallelism = 2
        if [ "$(kubectl get job mjolnir-forge -n thor -o jsonpath='{.spec.parallelism}')" = "2" ]; then
            ((score++))
        fi

        # Check label on pod template
        if kubectl get job mjolnir-forge -n thor -o jsonpath='{.spec.template.metadata.labels.dwarf}' | grep -q "brokkr"; then
            ((score++))
        fi

        # Check yaml file exists
        if [ -f "./exam/course/2/job.yaml" ]; then
            ((score++))
        fi
    fi

    echo "$score/$max_points"
}

# Q3: Init Container (5 points)
score_q3() {
    local score=0
    local max_points=5

    # Check pod exists
    if kubectl get pod shapeshifter -n loki &>/dev/null; then
        ((score++))

        # Check init container exists
        if kubectl get pod shapeshifter -n loki -o jsonpath='{.spec.initContainers[*].name}' | grep -q "prepare-disguise"; then
            ((score++))
        fi

        # Check main container exists
        if kubectl get pod shapeshifter -n loki -o jsonpath='{.spec.containers[*].name}' | grep -q "loki-main"; then
            ((score++))
        fi

        # Check shared volume
        if kubectl get pod shapeshifter -n loki -o jsonpath='{.spec.volumes[*].name}' | grep -q "shared-data"; then
            ((score++))
        fi

        # Check pod is running
        if kubectl get pod shapeshifter -n loki -o jsonpath='{.status.phase}' | grep -q "Running"; then
            ((score++))
        fi
    fi

    echo "$score/$max_points"
}

# Q4: CronJob (5 points)
score_q4() {
    local score=0
    local max_points=5

    # Check cronjob exists
    if kubectl get cronjob blessing-ritual -n freya &>/dev/null; then
        ((score++))

        # Check schedule
        if kubectl get cronjob blessing-ritual -n freya -o jsonpath='{.spec.schedule}' | grep -q "*/15"; then
            ((score++))
        fi

        # Check successfulJobsHistoryLimit
        if [ "$(kubectl get cronjob blessing-ritual -n freya -o jsonpath='{.spec.successfulJobsHistoryLimit}')" = "3" ]; then
            ((score++))
        fi

        # Check failedJobsHistoryLimit
        if [ "$(kubectl get cronjob blessing-ritual -n freya -o jsonpath='{.spec.failedJobsHistoryLimit}')" = "1" ]; then
            ((score++))
        fi

        # Check yaml file exists
        if [ -f "./exam/course/4/cronjob.yaml" ]; then
            ((score++))
        fi
    fi

    echo "$score/$max_points"
}

# Q5: PV and PVC (6 points)
score_q5() {
    local score=0
    local max_points=6

    # Check PV exists
    if kubectl get pv bifrost-storage &>/dev/null; then
        ((score++))

        # Check PV capacity
        if kubectl get pv bifrost-storage -o jsonpath='{.spec.capacity.storage}' | grep -q "500Mi"; then
            ((score++))
        fi
    fi

    # Check PVC exists
    if kubectl get pvc bifrost-claim -n heimdall &>/dev/null; then
        ((score++))

        # Check PVC request
        if kubectl get pvc bifrost-claim -n heimdall -o jsonpath='{.spec.resources.requests.storage}' | grep -q "200Mi"; then
            ((score++))
        fi

        # Check PVC is bound
        if kubectl get pvc bifrost-claim -n heimdall -o jsonpath='{.status.phase}' | grep -q "Bound"; then
            ((score++))
        fi
    fi

    # Check template file exists
    if [ -f "./exam/course/5/pv-pvc.yaml" ]; then
        ((score++))
    fi

    echo "$score/$max_points"
}

# Q6: StorageClass (4 points)
score_q6() {
    local score=0
    local max_points=4

    # Check storageclass exists
    if kubectl get storageclass light-storage &>/dev/null; then
        ((score++))

        # Check provisioner
        if kubectl get storageclass light-storage -o jsonpath='{.provisioner}' | grep -q "kubernetes.io/no-provisioner"; then
            ((score++))
        fi

        # Check volumeBindingMode
        if kubectl get storageclass light-storage -o jsonpath='{.volumeBindingMode}' | grep -q "WaitForFirstConsumer"; then
            ((score++))
        fi
    fi

    # Check yaml file exists
    if [ -f "./exam/course/6/storageclass.yaml" ]; then
        ((score++))
    fi

    echo "$score/$max_points"
}

# Q7: Deployment with Strategy (5 points)
score_q7() {
    local score=0
    local max_points=5

    # Check deployment exists
    if kubectl get deployment warrior-legion -n tyr &>/dev/null; then
        ((score++))

        # Check replicas = 4
        if [ "$(kubectl get deployment warrior-legion -n tyr -o jsonpath='{.spec.replicas}')" = "4" ]; then
            ((score++))
        fi

        # Check strategy type
        if kubectl get deployment warrior-legion -n tyr -o jsonpath='{.spec.strategy.type}' | grep -q "RollingUpdate"; then
            ((score++))
        fi

        # Check maxSurge
        if kubectl get deployment warrior-legion -n tyr -o jsonpath='{.spec.strategy.rollingUpdate.maxSurge}' | grep -q "1"; then
            ((score++))
        fi
    fi

    # Check yaml file exists
    if [ -f "./exam/course/7/deployment.yaml" ]; then
        ((score++))
    fi

    echo "$score/$max_points"
}

# Q8: Scale Deployment (5 points)
score_q8() {
    local score=0
    local max_points=5

    # Check deployment has 5 replicas
    if kubectl get deployment sea-fleet -n njord &>/dev/null; then
        local replicas=$(kubectl get deployment sea-fleet -n njord -o jsonpath='{.spec.replicas}')
        if [ "$replicas" = "5" ]; then
            ((score+=2))
        fi

        # Check 5 pods are running
        local ready=$(kubectl get deployment sea-fleet -n njord -o jsonpath='{.status.readyReplicas}')
        if [ "$ready" = "5" ]; then
            ((score+=2))
        fi
    fi

    # Check command file exists
    if [ -f "./exam/course/8/scale-command.sh" ]; then
        ((score++))
    fi

    echo "$score/$max_points"
}

# Q9: Rollback Deployment (6 points)
score_q9() {
    local score=0
    local max_points=6

    # Check deployment exists and is healthy
    if kubectl get deployment voyage-app -n njord &>/dev/null; then
        # Check deployment is available
        local available=$(kubectl get deployment voyage-app -n njord -o jsonpath='{.status.availableReplicas}')
        if [ -n "$available" ] && [ "$available" -gt 0 ]; then
            ((score+=3))
        fi

        # Check image is working (not nginx:broken-image)
        local image=$(kubectl get deployment voyage-app -n njord -o jsonpath='{.spec.template.spec.containers[0].image}')
        if [[ ! "$image" =~ "broken" ]]; then
            ((score+=2))
        fi
    fi

    # Check command file exists
    if [ -f "./exam/course/9/rollback-command.sh" ]; then
        ((score++))
    fi

    echo "$score/$max_points"
}

# Q10: Helm Management (5 points)
score_q10() {
    local score=0
    local max_points=5

    # Check asgard-web-v1 is deleted
    if ! helm status asgard-web-v1 -n asgard &>/dev/null; then
        ((score++))
    fi

    # Check asgard-web-v2 exists (upgraded)
    if helm status asgard-web-v2 -n asgard &>/dev/null; then
        ((score++))
    fi

    # Check asgard-gateway is installed
    if helm status asgard-gateway -n asgard &>/dev/null; then
        ((score++))

        # Check it has 2 replicas
        local replicas=$(kubectl get deployment -n asgard -l app.kubernetes.io/instance=asgard-gateway -o jsonpath='{.items[0].spec.replicas}' 2>/dev/null)
        if [ "$replicas" = "2" ]; then
            ((score++))
        fi
    fi

    # Check broken release is deleted
    if ! helm list -n asgard -a 2>/dev/null | grep -q "pending-install"; then
        ((score++))
    fi

    echo "$score/$max_points"
}

# Q11: ClusterIP Service (5 points)
score_q11() {
    local score=0
    local max_points=5

    # Check service exists
    if kubectl get service thunder-svc -n thor &>/dev/null; then
        ((score++))

        # Check type is ClusterIP
        if kubectl get service thunder-svc -n thor -o jsonpath='{.spec.type}' | grep -qE "^ClusterIP$|^$"; then
            ((score++))
        fi

        # Check port is 8080
        if kubectl get service thunder-svc -n thor -o jsonpath='{.spec.ports[0].port}' | grep -q "8080"; then
            ((score++))
        fi

        # Check has endpoints
        local endpoints=$(kubectl get endpoints thunder-svc -n thor -o jsonpath='{.subsets[*].addresses}' 2>/dev/null)
        if [ -n "$endpoints" ]; then
            ((score++))
        fi
    fi

    # Check yaml file exists
    if [ -f "./exam/course/11/service.yaml" ]; then
        ((score++))
    fi

    echo "$score/$max_points"
}

# Q12: NetworkPolicy (6 points)
score_q12() {
    local score=0
    local max_points=6

    # Check networkpolicy exists
    if kubectl get networkpolicy love-protection -n freya &>/dev/null; then
        ((score++))

        # Check podSelector for role: lover
        if kubectl get networkpolicy love-protection -n freya -o jsonpath='{.spec.podSelector.matchLabels.role}' | grep -q "lover"; then
            ((score++))
        fi

        # Check ingress rules exist
        if kubectl get networkpolicy love-protection -n freya -o jsonpath='{.spec.ingress}' | grep -q "protector"; then
            ((score++))
        fi

        # Check egress rules exist
        if kubectl get networkpolicy love-protection -n freya -o jsonpath='{.spec.egress}' | grep -q "."; then
            ((score+=2))
        fi
    fi

    # Check yaml file exists
    if [ -f "./exam/course/12/networkpolicy.yaml" ]; then
        ((score++))
    fi

    echo "$score/$max_points"
}

# Q13: Ingress (5 points)
score_q13() {
    local score=0
    local max_points=5

    # Check ingress exists
    if kubectl get ingress light-gateway -n baldur &>/dev/null; then
        ((score++))

        # Check host
        if kubectl get ingress light-gateway -n baldur -o jsonpath='{.spec.rules[0].host}' | grep -q "baldur.asgard.local"; then
            ((score++))
        fi

        # Check path
        if kubectl get ingress light-gateway -n baldur -o jsonpath='{.spec.rules[0].http.paths[0].path}' | grep -q "/shine"; then
            ((score++))
        fi

        # Check backend service
        if kubectl get ingress light-gateway -n baldur -o jsonpath='{.spec.rules[0].http.paths[0].backend.service.name}' | grep -q "radiance-svc"; then
            ((score++))
        fi
    fi

    # Check template file exists
    if [ -f "./exam/course/13/ingress.yaml" ]; then
        ((score++))
    fi

    echo "$score/$max_points"
}

# Q14: NodePort Service (5 points)
score_q14() {
    local score=0
    local max_points=5

    # Check service exists
    if kubectl get service realm-gateway -n asgard &>/dev/null; then
        ((score++))

        # Check type is NodePort
        if kubectl get service realm-gateway -n asgard -o jsonpath='{.spec.type}' | grep -q "NodePort"; then
            ((score++))
        fi

        # Check nodePort is 30080
        if kubectl get service realm-gateway -n asgard -o jsonpath='{.spec.ports[0].nodePort}' | grep -q "30080"; then
            ((score++))
        fi

        # Check selector
        if kubectl get service realm-gateway -n asgard -o jsonpath='{.spec.selector.app}' | grep -q "bifrost"; then
            ((score++))
        fi
    fi

    # Check yaml file exists
    if [ -f "./exam/course/14/nodeport-service.yaml" ]; then
        ((score++))
    fi

    echo "$score/$max_points"
}

# Q15: RBAC (5 points)
score_q15() {
    local score=0
    local max_points=5

    # Check serviceaccount exists
    if kubectl get serviceaccount mimir-sa -n odin &>/dev/null; then
        ((score++))
    fi

    # Check role exists
    if kubectl get role wisdom-role -n odin &>/dev/null; then
        ((score++))

        # Check role has correct permissions
        if kubectl get role wisdom-role -n odin -o jsonpath='{.rules[*].verbs}' | grep -q "get"; then
            ((score++))
        fi
    fi

    # Check rolebinding exists
    if kubectl get rolebinding wisdom-binding -n odin &>/dev/null; then
        ((score++))

        # Check rolebinding references correct serviceaccount
        if kubectl get rolebinding wisdom-binding -n odin -o jsonpath='{.subjects[*].name}' | grep -q "mimir-sa"; then
            ((score++))
        fi
    fi

    echo "$score/$max_points"
}

# Q16: Secret (5 points)
score_q16() {
    local score=0
    local max_points=5

    # Check secret exists
    if kubectl get secret trick-secret -n loki &>/dev/null; then
        ((score++))

        # Check secret has username key
        if kubectl get secret trick-secret -n loki -o jsonpath='{.data.username}' | grep -q "."; then
            ((score++))
        fi
    fi

    # Check pod exists
    if kubectl get pod trickster-pod -n loki &>/dev/null; then
        ((score++))

        # Check volume mount
        if kubectl get pod trickster-pod -n loki -o jsonpath='{.spec.containers[0].volumeMounts[*].mountPath}' | grep -q "/etc/tricks"; then
            ((score++))
        fi

        # Check env var
        if kubectl get pod trickster-pod -n loki -o jsonpath='{.spec.containers[0].env[*].name}' | grep -q "TRICK_USER"; then
            ((score++))
        fi
    fi

    echo "$score/$max_points"
}

# Q17: SecurityContext (6 points)
score_q17() {
    local score=0
    local max_points=6

    # Check pod exists
    if kubectl get pod guardian-pod -n heimdall &>/dev/null; then
        ((score++))

        # Check runAsUser
        if [ "$(kubectl get pod guardian-pod -n heimdall -o jsonpath='{.spec.containers[0].securityContext.runAsUser}')" = "1000" ]; then
            ((score++))
        fi

        # Check runAsGroup
        if [ "$(kubectl get pod guardian-pod -n heimdall -o jsonpath='{.spec.containers[0].securityContext.runAsGroup}')" = "3000" ]; then
            ((score++))
        fi

        # Check allowPrivilegeEscalation
        if [ "$(kubectl get pod guardian-pod -n heimdall -o jsonpath='{.spec.containers[0].securityContext.allowPrivilegeEscalation}')" = "false" ]; then
            ((score++))
        fi

        # Check capabilities add
        if kubectl get pod guardian-pod -n heimdall -o jsonpath='{.spec.containers[0].securityContext.capabilities.add}' | grep -q "NET_BIND_SERVICE"; then
            ((score++))
        fi
    fi

    # Check yaml file exists
    if [ -f "./exam/course/17/secure-pod.yaml" ]; then
        ((score++))
    fi

    echo "$score/$max_points"
}

# Q18: ResourceQuota (5 points)
score_q18() {
    local score=0
    local max_points=5

    # Check resourcequota exists
    if kubectl get resourcequota war-limits -n tyr &>/dev/null; then
        ((score++))

        # Check pods limit
        if kubectl get resourcequota war-limits -n tyr -o jsonpath='{.spec.hard.pods}' | grep -q "10"; then
            ((score++))
        fi

        # Check cpu requests
        if kubectl get resourcequota war-limits -n tyr -o jsonpath='{.spec.hard.requests\.cpu}' | grep -q "2"; then
            ((score++))
        fi

        # Check memory limits
        if kubectl get resourcequota war-limits -n tyr -o jsonpath='{.spec.hard.limits\.memory}' | grep -q "4Gi"; then
            ((score++))
        fi
    fi

    # Check yaml file exists
    if [ -f "./exam/course/18/quota.yaml" ]; then
        ((score++))
    fi

    echo "$score/$max_points"
}

# Q19: ConfigMap (5 points)
score_q19() {
    local score=0
    local max_points=5

    # Check configmap exists
    if kubectl get configmap navigation-config -n njord &>/dev/null; then
        ((score++))

        # Check configmap has destination key
        if kubectl get configmap navigation-config -n njord -o jsonpath='{.data.destination}' | grep -q "midgard"; then
            ((score++))
        fi
    fi

    # Check pod exists
    if kubectl get pod navigator-pod -n njord &>/dev/null; then
        ((score++))

        # Check envFrom configMapRef
        if kubectl get pod navigator-pod -n njord -o jsonpath='{.spec.containers[0].envFrom[*].configMapRef.name}' | grep -q "navigation-config"; then
            ((score++))
        fi

        # Check pod is running
        if kubectl get pod navigator-pod -n njord -o jsonpath='{.status.phase}' | grep -q "Running"; then
            ((score++))
        fi
    fi

    echo "$score/$max_points"
}

# Q20: Probes (6 points)
score_q20() {
    local score=0
    local max_points=6

    # Check pod exists
    if kubectl get pod watchman-pod -n asgard &>/dev/null; then
        ((score++))

        # Check readiness probe exists
        if kubectl get pod watchman-pod -n asgard -o jsonpath='{.spec.containers[0].readinessProbe}' | grep -q "httpGet"; then
            ((score++))
        fi

        # Check liveness probe exists
        if kubectl get pod watchman-pod -n asgard -o jsonpath='{.spec.containers[0].livenessProbe}' | grep -q "httpGet"; then
            ((score++))
        fi

        # Check readiness initialDelaySeconds
        if [ "$(kubectl get pod watchman-pod -n asgard -o jsonpath='{.spec.containers[0].readinessProbe.initialDelaySeconds}')" = "5" ]; then
            ((score++))
        fi

        # Check liveness initialDelaySeconds
        if [ "$(kubectl get pod watchman-pod -n asgard -o jsonpath='{.spec.containers[0].livenessProbe.initialDelaySeconds}')" = "15" ]; then
            ((score++))
        fi
    fi

    # Check yaml file exists
    if [ -f "./exam/course/20/probe-pod.yaml" ]; then
        ((score++))
    fi

    echo "$score/$max_points"
}

# Q21: Debug Pod (5 points)
score_q21() {
    local score=0
    local max_points=5

    # Check logs file exists
    if [ -f "./exam/course/21/logs.txt" ]; then
        ((score++))
    fi

    # Check fix explanation file exists
    if [ -f "./exam/course/21/fix.txt" ]; then
        ((score++))
    fi

    # Check pod is now running (fixed)
    if kubectl get pod broken-valkyrie -n asgard &>/dev/null; then
        local phase=$(kubectl get pod broken-valkyrie -n asgard -o jsonpath='{.status.phase}')
        if [ "$phase" = "Running" ]; then
            ((score+=3))
        fi
    fi

    echo "$score/$max_points"
}

# Q22: Container Image Build (6 points)
score_q22() {
    local score=0
    local max_points=6

    # Check image was pushed to registry
    if curl -s http://localhost:5000/v2/runescript/tags/list 2>/dev/null | grep -q "v1"; then
        ((score+=2))
    fi

    # Check pod exists
    if kubectl get pod runescript-pod -n asgard &>/dev/null; then
        ((score++))

        # Check pod uses correct image
        if kubectl get pod runescript-pod -n asgard -o jsonpath='{.spec.containers[0].image}' | grep -q "localhost:5000/runescript:v1"; then
            ((score++))
        fi

        # Check pod is running
        if kubectl get pod runescript-pod -n asgard -o jsonpath='{.status.phase}' | grep -q "Running"; then
            ((score+=2))
        fi
    fi

    echo "$score/$max_points"
}
