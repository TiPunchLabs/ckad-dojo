#!/bin/bash
# CKAD Simulation 17 - Scoring Functions
# Total Points: 116

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
source "$SCRIPT_DIR/../../scripts/lib/common.sh" 2>/dev/null || true

EXAM_DIR="./exam/course"

score_q1() {
    local score=0
    local max_points=5
    local details=""

    if resource_exists pod entry-override fortress; then
        ((score+=1))
        details+="Pod exists. "
        
        local image=$(kubectl get pod entry-override -n fortress -o jsonpath='{.spec.containers[0].image}')
        if [[ "$image" == "nginx:alpine" ]]; then
            ((score+=1))
            details+="Image correct. "
        fi
        
        local cmd=$(kubectl get pod entry-override -n fortress -o jsonpath='{.spec.containers[0].command[0]}')
        if [[ "$cmd" == "sleep" ]]; then
            ((score+=2))
            details+="Command overridden correctly. "
        fi
        
        local arg=$(kubectl get pod entry-override -n fortress -o jsonpath='{.spec.containers[0].args[0]}')
        if [[ "$arg" == "3600" ]]; then
            ((score+=1))
            details+="Args overridden correctly. "
        fi
    else
        details+="Pod entry-override not found. "
    fi

    echo "$score/$max_points"
    echo "DETAILS:$details"
}

score_q2() {
    local score=0
    local max_points=5
    local details=""

    if resource_exists configmap init-script-cm fortress; then
        ((score+=1))
        details+="ConfigMap exists. "
    else
        details+="ConfigMap not found. "
    fi

    if resource_exists pod web-setup fortress; then
        ((score+=1))
        details+="Pod exists. "
        
        local init_image=$(kubectl get pod web-setup -n fortress -o jsonpath='{.spec.initContainers[0].image}')
        if [[ "$init_image" == "busybox:1.36" ]]; then
            ((score+=1))
            details+="Init container image correct. "
        fi
        
        local main_vol=$(kubectl get pod web-setup -n fortress -o jsonpath='{.spec.containers[0].volumeMounts[?(@.name=="work-vol")].mountPath}')
        if [[ "$main_vol" == "/usr/share/nginx/html" ]]; then
            ((score+=2))
            details+="Volumes mounted correctly. "
        fi
    else
        details+="Pod web-setup not found. "
    fi

    echo "$score/$max_points"
    echo "DETAILS:$details"
}

score_q3() {
    local score=0
    local max_points=5
    local details=""

    if resource_exists cronjob siege-report siege; then
        ((score+=1))
        details+="CronJob exists. "
        
        local schedule=$(kubectl get cj siege-report -n siege -o jsonpath='{.spec.schedule}')
        if [[ "$schedule" == "30 * * * *" ]]; then
            ((score+=2))
            details+="Schedule correct. "
        fi
        
        local tz=$(kubectl get cj siege-report -n siege -o jsonpath='{.spec.timeZone}')
        if [[ "$tz" == "Asia/Tokyo" ]]; then
            ((score+=2))
            details+="Timezone correct. "
        fi
    else
        details+="CronJob siege-report not found. "
    fi

    echo "$score/$max_points"
    echo "DETAILS:$details"
}

score_q4() {
    local score=0
    local max_points=8
    local details=""

    if resource_exists pod process-monitor bastion; then
        ((score+=2))
        details+="Pod exists. "
        
        local share_pid=$(kubectl get pod process-monitor -n bastion -o jsonpath='{.spec.shareProcessNamespace}')
        if [[ "$share_pid" == "true" ]]; then
            ((score+=3))
            details+="shareProcessNamespace is true. "
        fi
        
        local container_count=$(kubectl get pod process-monitor -n bastion -o jsonpath='{range .spec.containers[*]}{.name}{"\n"}{end}' | wc -l)
        if [[ "$container_count" -eq 2 ]]; then
            ((score+=3))
            details+="Two containers exist. "
        fi
    else
        details+="Pod process-monitor not found. "
    fi

    echo "$score/$max_points"
    echo "DETAILS:$details"
}

score_q5() {
    local score=0
    local max_points=5
    local details=""

    local release_status=$(helm status battle-web -n garrison -o json 2>/dev/null | grep -i deployed)
    if [[ -n "$release_status" ]]; then
        ((score+=2))
        details+="Helm release is deployed. "
        
        local replicas=$(kubectl get deploy battle-web-battle-chart -n garrison -o jsonpath='{.spec.replicas}' 2>/dev/null)
        if [[ "$replicas" == "3" ]]; then
            ((score+=3))
            details+="ReplicaCount is 3. "
        else
            details+="ReplicaCount is not 3. "
        fi
    else
        details+="Helm release not deployed or failed. "
    fi

    echo "$score/$max_points"
    echo "DETAILS:$details"
}

score_q6() {
    local score=0
    local max_points=6
    local details=""

    if resource_exists deployment citadel-guard citadel; then
        ((score+=2))
        details+="Deployment exists. "
        
        local pds=$(kubectl get deploy citadel-guard -n citadel -o jsonpath='{.spec.progressDeadlineSeconds}')
        if [[ "$pds" == "15" ]]; then
            ((score+=4))
            details+="progressDeadlineSeconds is 15. "
        else
            details+="progressDeadlineSeconds is not 15. "
        fi
    else
        details+="Deployment not found. "
    fi

    echo "$score/$max_points"
    echo "DETAILS:$details"
}

score_q7() {
    local score=0
    local max_points=6
    local details=""

    if resource_exists deployment api-server-green rampart; then
        ((score+=2))
        details+="Green deployment exists. "
        
        local svc_selector=$(kubectl get svc api-svc -n rampart -o jsonpath='{.spec.selector.app}')
        if [[ "$svc_selector" == "api-server-green" ]]; then
            ((score+=4))
            details+="Service routes to green deployment. "
        else
            details+="Service selector is incorrect. "
        fi
    else
        details+="Green deployment not found. "
    fi

    echo "$score/$max_points"
    echo "DETAILS:$details"
}

score_q8() {
    local score=0
    local max_points=6
    local details=""

    if resource_exists deployment vanguard-web vanguard; then
        ((score+=1))
        details+="Deployment exists. "
        
        local image=$(kubectl get deploy vanguard-web -n vanguard -o jsonpath='{.spec.template.spec.containers[0].image}')
        if [[ "$image" == "nginx:1.23.0-alpine" ]]; then
            ((score+=3))
            details+="Image updated via Kustomize. "
        fi
        
        local replicas=$(kubectl get deploy vanguard-web -n vanguard -o jsonpath='{.spec.replicas}')
        if [[ "$replicas" == "5" ]]; then
            ((score+=2))
            details+="Replicas scaled to 5. "
        fi
    else
        details+="Deployment vanguard-web not found. "
    fi

    echo "$score/$max_points"
    echo "DETAILS:$details"
}

score_q9() {
    local score=0
    local max_points=5
    local details=""

    if resource_exists pod data-processor sentinel; then
        local status=$(kubectl get pod data-processor -n sentinel -o jsonpath='{.status.phase}')
        if [[ "$status" == "Running" ]]; then
            ((score+=2))
            details+="Pod is running. "
        fi
        
        local mem_limit=$(kubectl get pod data-processor -n sentinel -o jsonpath='{.spec.containers[0].resources.limits.memory}')
        if [[ "$mem_limit" == "256Mi" ]]; then
            ((score+=3))
            details+="Memory limit is 256Mi. "
        fi
    else
        details+="Pod data-processor not found. "
    fi

    echo "$score/$max_points"
    echo "DETAILS:$details"
}

score_q10() {
    local score=0
    local max_points=6
    local details=""

    if resource_exists pod secure-app outpost; then
        local ephem_count=$(kubectl get pod secure-app -n outpost -o jsonpath='{range .spec.ephemeralContainers[*]}{.name}{"\n"}{end}' | wc -l)
        if [[ "$ephem_count" -ge 1 ]]; then
            ((score+=3))
            details+="Ephemeral container exists. "
            
            local ephem_name=$(kubectl get pod secure-app -n outpost -o jsonpath='{.spec.ephemeralContainers[0].name}')
            if [[ "$ephem_name" == "debugger" ]]; then
                ((score+=3))
                details+="Ephemeral container named debugger. "
            fi
        else
            details+="No ephemeral container found. "
        fi
    else
        details+="Pod secure-app not found. "
    fi

    echo "$score/$max_points"
    echo "DETAILS:$details"
}

score_q11() {
    local score=0
    local max_points=7
    local details=""

    if resource_exists deployment weapon-smith armory; then
        local replicas=$(kubectl get deploy weapon-smith -n armory -o jsonpath='{.spec.replicas}')
        if [[ "$replicas" == "3" ]]; then
            ((score+=3))
            details+="Replicas is 3. "
        fi
        
        local cpu_req=$(kubectl get deploy weapon-smith -n armory -o jsonpath='{.spec.template.spec.containers[0].resources.requests.cpu}')
        local mem_req=$(kubectl get deploy weapon-smith -n armory -o jsonpath='{.spec.template.spec.containers[0].resources.requests.memory}')
        
        if [[ "$cpu_req" == "100m" && "$mem_req" == "128Mi" ]]; then
            ((score+=4))
            details+="Requests are correct. "
        fi
    else
        details+="Deployment weapon-smith not found. "
    fi

    echo "$score/$max_points"
    echo "DETAILS:$details"
}

score_q12() {
    local score=0
    local max_points=5
    local details=""

    if resource_exists pod resource-aware fortress; then
        ((score+=1))
        details+="Pod exists. "
        
        local env_cpu=$(kubectl get pod resource-aware -n fortress -o jsonpath='{.spec.containers[0].env[?(@.name=="MY_CPU_REQUEST")].valueFrom.resourceFieldRef.resource}')
        if [[ "$env_cpu" == "requests.cpu" ]]; then
            ((score+=2))
            details+="MY_CPU_REQUEST mapped correctly. "
        fi
        
        local env_mem=$(kubectl get pod resource-aware -n fortress -o jsonpath='{.spec.containers[0].env[?(@.name=="MY_MEM_LIMIT")].valueFrom.resourceFieldRef.resource}')
        if [[ "$env_mem" == "limits.memory" ]]; then
            ((score+=2))
            details+="MY_MEM_LIMIT mapped correctly. "
        fi
    else
        details+="Pod resource-aware not found. "
    fi

    echo "$score/$max_points"
    echo "DETAILS:$details"
}

score_q13() {
    local score=0
    local max_points=6
    local details=""

    if resource_exists serviceaccount stealth-sa siege; then
        ((score+=1))
        details+="SA exists. "
    fi
    
    if resource_exists pod stealth-pod siege; then
        ((score+=1))
        details+="Pod exists. "
        
        local automount=$(kubectl get pod stealth-pod -n siege -o jsonpath='{.spec.automountServiceAccountToken}')
        if [[ "$automount" == "false" ]]; then
            ((score+=2))
            details+="Automount disabled. "
        fi
        
        local volume_mount=$(kubectl get pod stealth-pod -n siege -o jsonpath='{.spec.containers[0].volumeMounts[?(@.mountPath=="/var/run/secrets/custom-token")].name}')
        if [[ -n "$volume_mount" ]]; then
            ((score+=2))
            details+="Token mounted manually. "
        fi
    fi

    echo "$score/$max_points"
    echo "DETAILS:$details"
}

score_q14() {
    local score=0
    local max_points=5
    local details=""

    if resource_exists pod secure-workload bastion; then
        ((score+=1))
        details+="Pod exists. "
        
        local non_root=$(kubectl get pod secure-workload -n bastion -o jsonpath='{.spec.securityContext.runAsNonRoot}')
        if [[ "$non_root" == "true" ]]; then
            ((score+=2))
            details+="runAsNonRoot is true. "
        fi
        
        local seccomp=$(kubectl get pod secure-workload -n bastion -o jsonpath='{.spec.securityContext.seccompProfile.type}')
        if [[ "$seccomp" == "RuntimeDefault" ]]; then
            ((score+=2))
            details+="seccompProfile is RuntimeDefault. "
        fi
    else
        details+="Pod secure-workload not found. "
    fi

    echo "$score/$max_points"
    echo "DETAILS:$details"
}

score_q15() {
    local score=0
    local max_points=7
    local details=""

    if resource_exists secret db-credentials citadel; then
        ((score+=2))
        details+="Secret exists. "
    fi
    
    if resource_exists pod db-consumer citadel; then
        ((score+=1))
        details+="Pod exists. "
        
        local item_key=$(kubectl get pod db-consumer -n citadel -o jsonpath='{.spec.volumes[?(@.secret.secretName=="db-credentials")].secret.items[0].key}')
        local item_path=$(kubectl get pod db-consumer -n citadel -o jsonpath='{.spec.volumes[?(@.secret.secretName=="db-credentials")].secret.items[0].path}')
        
        if [[ "$item_key" == "password" && "$item_path" == "db-pass.txt" ]]; then
            ((score+=4))
            details+="Specific secret key mounted correctly. "
        else
            details+="Secret keys not mounted correctly. "
        fi
    else
        details+="Pod db-consumer not found. "
    fi

    echo "$score/$max_points"
    echo "DETAILS:$details"
}

score_q16() {
    local score=0
    local max_points=6
    local details=""

    if resource_exists limitrange rampart-limits rampart; then
        ((score+=3))
        details+="LimitRange exists. "
    fi
    
    if resource_exists pod default-pod rampart; then
        local pod_mem_req=$(kubectl get pod default-pod -n rampart -o jsonpath='{.spec.containers[0].resources.requests.memory}')
        if [[ "$pod_mem_req" == "256Mi" ]]; then
            ((score+=3))
            details+="Pod inherited default requests. "
        fi
    fi

    echo "$score/$max_points"
    echo "DETAILS:$details"
}

score_q17() {
    local score=0
    local max_points=7
    local details=""

    if resource_exists networkpolicy protect-db vanguard; then
        ((score+=2))
        details+="NetPol exists. "
        
        local ports=$(kubectl get netpol protect-db -n vanguard -o jsonpath='{.spec.ingress[*].ports[*].port}')
        if [[ "$ports" == *"5432"* ]]; then
            ((score+=2))
            details+="Port 5432 allowed. "
        fi
        
        local namespace_selector=$(kubectl get netpol protect-db -n vanguard -o jsonpath='{.spec.ingress[*].from[*].namespaceSelector.matchLabels}')
        if [[ "$namespace_selector" == *"kubernetes.io/metadata.name"* ]]; then
            ((score+=3))
            details+="Namespace selector used correctly. "
        fi
    else
        details+="NetPol protect-db not found. "
    fi

    echo "$score/$max_points"
    echo "DETAILS:$details"
}

score_q18() {
    local score=0
    local max_points=6
    local details=""

    if resource_exists ingress canary-ingress sentinel; then
        ((score+=2))
        details+="Canary ingress exists. "
        
        local weight=$(kubectl get ingress canary-ingress -n sentinel -o jsonpath='{.metadata.annotations.nginx\.ingress\.kubernetes\.io/canary-weight}')
        if [[ "$weight" == "20" ]]; then
            ((score+=4))
            details+="Canary weight annotation is 20. "
        else
            details+="Canary weight annotation incorrect. "
        fi
    else
        details+="Canary ingress not found. "
    fi

    echo "$score/$max_points"
    echo "DETAILS:$details"
}

score_q19() {
    local score=0
    local max_points=6
    local details=""

    if resource_exists service external-db outpost; then
        ((score+=2))
        details+="Service exists. "
        
        local selector=$(kubectl get svc external-db -n outpost -o jsonpath='{.spec.selector}')
        if [[ -z "$selector" || "$selector" == "{}" ]]; then
            ((score+=2))
            details+="Service has no selector. "
        fi
    fi
    
    if resource_exists endpoints external-db outpost; then
        local ip=$(kubectl get endpoints external-db -n outpost -o jsonpath='{.subsets[0].addresses[0].ip}')
        if [[ "$ip" == "10.50.50.50" ]]; then
            ((score+=2))
            details+="Endpoints mapped to correct IP. "
        fi
    fi

    echo "$score/$max_points"
    echo "DETAILS:$details"
}

score_q20() {
    local score=0
    local max_points=7
    local details=""

    if [[ -f "./exam/course/20/coredns.yaml" ]]; then
        ((score+=2))
        details+="coredns.yaml exists. "
        
        local file_content=$(cat ./exam/course/20/coredns.yaml)
        if [[ "$file_content" == *"rewrite name exact hachiman.local hachiman.garrison.svc.cluster.local"* ]]; then
            ((score+=5))
            details+="Rewrite rule present. "
        else
            details+="Rewrite rule not found. "
        fi
    else
        details+="File ./exam/course/20/coredns.yaml not found. "
    fi

    echo "$score/$max_points"
    echo "DETAILS:$details"
}
