#!/bin/bash
# scoring-functions.sh - CKAD Simulation 7 Scoring Functions
# Dojo Tanuki (Forest theme) - 20 questions, 100 points total
# Original questions: https://github.com/dgkanatsios/CKAD-exercises

# Source common utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../scripts/lib/common.sh" 2>/dev/null || true

# Q1: Pod with Exposed Port (4 points)
score_q1() {
	local score=0
	local max_points=4
	local details=""

	# Check Pod exists
	if resource_exists "pod" "nginx" "grove"; then
		((score += 1))
		details+="Pod nginx exists. "

		# Check port
		local port
		port=$(kubectl get pod nginx -n grove -o jsonpath='{.spec.containers[0].ports[0].containerPort}' 2>/dev/null)
		if [[ "$port" == "80" ]]; then
			((score += 1))
			details+="Port 80 configured. "
		else
			details+="Port not configured. "
		fi
	else
		details+="Pod nginx not found. "
	fi

	# Check Service exists
	if resource_exists "service" "nginx" "grove"; then
		((score += 1))
		details+="Service nginx exists. "

		# Check Service port
		local svc_port
		svc_port=$(kubectl get svc nginx -n grove -o jsonpath='{.spec.ports[0].port}' 2>/dev/null)
		if [[ "$svc_port" == "80" ]]; then
			((score += 1))
			details+="Service port 80 correct."
		else
			details+="Service port incorrect."
		fi
	else
		details+="Service nginx not found."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# Q2: Get Pod IP and Test Connectivity (5 points)
score_q2() {
	local score=0
	local max_points=5
	local details=""

	# Check Pod exists
	if resource_exists "pod" "web" "thicket"; then
		((score += 2))
		details+="Pod web exists. "
	else
		details+="Pod web not found. "
	fi

	# Check file exists with IP
	if file_exists_and_not_empty "./exam/course/2/pod-ip.txt"; then
		((score += 2))
		details+="IP file exists. "

		# Validate IP format
		local ip
		ip=$(cat ./exam/course/2/pod-ip.txt 2>/dev/null)
		if [[ "$ip" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
			((score += 1))
			details+="Valid IP format."
		else
			details+="Invalid IP format."
		fi
	else
		details+="IP file not found."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# Q3: Pod Logs (4 points)
score_q3() {
	local score=0
	local max_points=4
	local details=""

	# Check Pod exists
	if resource_exists "pod" "logger" "glade"; then
		((score += 2))
		details+="Pod logger exists. "

		# Check command
		local cmd
		cmd=$(kubectl get pod logger -n glade -o jsonpath='{.spec.containers[0].command}' 2>/dev/null)
		if [[ "$cmd" == *"while"* ]] || [[ "$cmd" == *"echo"* ]]; then
			((score += 1))
			details+="Loop command configured. "
		else
			details+="Command not configured correctly. "
		fi
	else
		details+="Pod logger not found. "
	fi

	# Check logs file
	if file_exists_and_not_empty "./exam/course/3/logs.txt"; then
		((score += 1))
		details+="Logs file exists."
	else
		details+="Logs file not found."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# Q4: Debug Pod with Error (5 points)
score_q4() {
	local score=0
	local max_points=5
	local details=""

	# Check Pod exists (may be in Error state)
	if kubectl get pod debug-pod -n meadow &>/dev/null; then
		((score += 2))
		details+="Pod debug-pod exists. "

		# Check command
		local args
		args=$(kubectl get pod debug-pod -n meadow -o jsonpath='{.spec.containers[0].args}' 2>/dev/null)
		if [[ "$args" == *"notexist"* ]]; then
			((score += 1))
			details+="Error command configured. "
		else
			details+="Command not correct. "
		fi
	else
		details+="Pod debug-pod not found. "
	fi

	# Check error file
	if file_exists_and_not_empty "./exam/course/4/error.txt"; then
		((score += 1))
		details+="Error file exists. "

		# Check for error content
		if grep -qi "no such file\|not exist\|cannot access" ./exam/course/4/error.txt 2>/dev/null; then
			((score += 1))
			details+="Error message captured."
		else
			details+="Error message not found in file."
		fi
	else
		details+="Error file not found."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# Q5: Pod with Node Selector (6 points)
score_q5() {
	local score=0
	local max_points=6
	local details=""

	# Check Pod exists
	if resource_exists "pod" "gpu-pod" "fern"; then
		((score += 2))
		details+="Pod gpu-pod exists. "

		# Check nodeSelector
		local selector
		selector=$(kubectl get pod gpu-pod -n fern -o jsonpath='{.spec.nodeSelector.accelerator}' 2>/dev/null)
		if [[ "$selector" == "nvidia" ]]; then
			((score += 4))
			details+="NodeSelector accelerator=nvidia correct."
		else
			details+="NodeSelector not configured correctly."
		fi
	else
		details+="Pod gpu-pod not found."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# Q6: Pod with Tolerations (6 points)
score_q6() {
	local score=0
	local max_points=6
	local details=""

	# Check Pod exists
	if resource_exists "pod" "tolerate-pod" "moss"; then
		((score += 2))
		details+="Pod tolerate-pod exists. "

		# Check toleration key
		local tol_key
		tol_key=$(kubectl get pod tolerate-pod -n moss -o jsonpath='{.spec.tolerations[?(@.key=="tier")].key}' 2>/dev/null)
		if [[ "$tol_key" == "tier" ]]; then
			((score += 1))
			details+="Toleration key correct. "
		else
			details+="Toleration key missing. "
		fi

		# Check toleration value
		local tol_value
		tol_value=$(kubectl get pod tolerate-pod -n moss -o jsonpath='{.spec.tolerations[?(@.key=="tier")].value}' 2>/dev/null)
		if [[ "$tol_value" == "frontend" ]]; then
			((score += 1))
			details+="Toleration value correct. "
		else
			details+="Toleration value incorrect. "
		fi

		# Check toleration effect
		local tol_effect
		tol_effect=$(kubectl get pod tolerate-pod -n moss -o jsonpath='{.spec.tolerations[?(@.key=="tier")].effect}' 2>/dev/null)
		if [[ "$tol_effect" == "NoSchedule" ]]; then
			((score += 2))
			details+="Toleration effect correct."
		else
			details+="Toleration effect incorrect."
		fi
	else
		details+="Pod tolerate-pod not found."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# Q7: Deployment with Replicas (5 points)
score_q7() {
	local score=0
	local max_points=5
	local details=""

	# Check Deployment exists
	if resource_exists "deployment" "app-deploy" "root"; then
		((score += 1))
		details+="Deployment app-deploy exists. "

		# Check replicas
		local replicas
		replicas=$(kubectl get deployment app-deploy -n root -o jsonpath='{.spec.replicas}' 2>/dev/null)
		if [[ "$replicas" == "3" ]] || [[ "$replicas" == "5" ]]; then
			((score += 1))
			details+="Replicas correct ($replicas). "
		else
			details+="Replicas incorrect ($replicas). "
		fi

		# Check image
		local image
		image=$(kubectl get deployment app-deploy -n root -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null)
		if [[ "$image" == *"nginx:1.18"* ]]; then
			((score += 2))
			details+="Image nginx:1.18 correct. "
		else
			details+="Image incorrect ($image). "
		fi

		# Check container port
		local port
		port=$(kubectl get deployment app-deploy -n root -o jsonpath='{.spec.template.spec.containers[0].ports[0].containerPort}' 2>/dev/null)
		if [[ "$port" == "80" ]]; then
			((score += 1))
			details+="Port 80 correct."
		else
			details+="Port not configured."
		fi
	else
		details+="Deployment app-deploy not found."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# Q8: Scale Deployment (4 points)
score_q8() {
	local score=0
	local max_points=4
	local details=""

	# Check Deployment exists
	if resource_exists "deployment" "app-deploy" "root"; then
		((score += 1))
		details+="Deployment exists. "

		# Check replicas is 5
		local replicas
		replicas=$(kubectl get deployment app-deploy -n root -o jsonpath='{.spec.replicas}' 2>/dev/null)
		if [[ "$replicas" == "5" ]]; then
			((score += 3))
			details+="Scaled to 5 replicas."
		else
			details+="Replicas is $replicas (expected: 5)."
		fi
	else
		details+="Deployment app-deploy not found."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# Q9: Horizontal Pod Autoscaler (6 points)
score_q9() {
	local score=0
	local max_points=6
	local details=""

	# Check HPA exists
	if resource_exists "hpa" "app-deploy" "root"; then
		((score += 2))
		details+="HPA app-deploy exists. "

		# Check min replicas
		local min_replicas
		min_replicas=$(kubectl get hpa app-deploy -n root -o jsonpath='{.spec.minReplicas}' 2>/dev/null)
		if [[ "$min_replicas" == "5" ]]; then
			((score += 1))
			details+="Min replicas 5 correct. "
		else
			details+="Min replicas incorrect ($min_replicas). "
		fi

		# Check max replicas
		local max_replicas
		max_replicas=$(kubectl get hpa app-deploy -n root -o jsonpath='{.spec.maxReplicas}' 2>/dev/null)
		if [[ "$max_replicas" == "10" ]]; then
			((score += 1))
			details+="Max replicas 10 correct. "
		else
			details+="Max replicas incorrect ($max_replicas). "
		fi

		# Check CPU target
		local cpu_target
		cpu_target=$(kubectl get hpa app-deploy -n root -o jsonpath='{.spec.targetCPUUtilizationPercentage}' 2>/dev/null)
		if [[ "$cpu_target" == "80" ]]; then
			((score += 2))
			details+="CPU target 80% correct."
		else
			details+="CPU target incorrect ($cpu_target)."
		fi
	else
		details+="HPA app-deploy not found."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# Q10: Deployment Rollout Pause and Resume (6 points)
score_q10() {
	local score=0
	local max_points=6
	local details=""

	# Check Deployment exists
	if resource_exists "deployment" "pause-deploy" "bark"; then
		((score += 2))
		details+="Deployment pause-deploy exists. "

		# Check image was updated to 1.19.0
		local image
		image=$(kubectl get deployment pause-deploy -n bark -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null)
		if [[ "$image" == *"nginx:1.19"* ]]; then
			((score += 4))
			details+="Image updated to nginx:1.19."
		else
			details+="Image not updated ($image)."
		fi
	else
		details+="Deployment pause-deploy not found."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# Q11: Job with Parallelism (5 points)
score_q11() {
	local score=0
	local max_points=5
	local details=""

	# Check Job exists
	if resource_exists "job" "parallel-job" "canopy"; then
		((score += 2))
		details+="Job parallel-job exists. "

		# Check parallelism
		local parallelism
		parallelism=$(kubectl get job parallel-job -n canopy -o jsonpath='{.spec.parallelism}' 2>/dev/null)
		if [[ "$parallelism" == "5" ]]; then
			((score += 3))
			details+="Parallelism 5 correct."
		else
			details+="Parallelism incorrect ($parallelism)."
		fi
	else
		details+="Job parallel-job not found."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# Q12: Job with Active Deadline (5 points)
score_q12() {
	local score=0
	local max_points=5
	local details=""

	# Check Job exists
	if resource_exists "job" "deadline-job" "hollow"; then
		((score += 2))
		details+="Job deadline-job exists. "

		# Check activeDeadlineSeconds
		local deadline
		deadline=$(kubectl get job deadline-job -n hollow -o jsonpath='{.spec.activeDeadlineSeconds}' 2>/dev/null)
		if [[ "$deadline" == "30" ]]; then
			((score += 3))
			details+="ActiveDeadlineSeconds 30 correct."
		else
			details+="ActiveDeadlineSeconds incorrect ($deadline)."
		fi
	else
		details+="Job deadline-job not found."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# Q13: CronJob with Starting Deadline (5 points)
score_q13() {
	local score=0
	local max_points=5
	local details=""

	# Check CronJob exists
	if resource_exists "cronjob" "deadline-cron" "grove"; then
		((score += 2))
		details+="CronJob deadline-cron exists. "

		# Check startingDeadlineSeconds
		local deadline
		deadline=$(kubectl get cronjob deadline-cron -n grove -o jsonpath='{.spec.startingDeadlineSeconds}' 2>/dev/null)
		if [[ "$deadline" == "17" ]]; then
			((score += 3))
			details+="StartingDeadlineSeconds 17 correct."
		else
			details+="StartingDeadlineSeconds incorrect ($deadline)."
		fi
	else
		details+="CronJob deadline-cron not found."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# Q14: Create Job from CronJob (4 points)
score_q14() {
	local score=0
	local max_points=4
	local details=""

	# Check CronJob exists
	if resource_exists "cronjob" "source-cron" "thicket"; then
		((score += 2))
		details+="CronJob source-cron exists. "
	else
		details+="CronJob source-cron not found. "
	fi

	# Check Job exists
	if resource_exists "job" "manual-job" "thicket"; then
		((score += 2))
		details+="Job manual-job exists."
	else
		details+="Job manual-job not found."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# Q15: ConfigMap from File (5 points)
score_q15() {
	local score=0
	local max_points=5
	local details=""

	# Check file exists
	if file_exists_and_not_empty "./exam/course/15/config.txt"; then
		((score += 2))
		details+="Config file exists. "
	else
		details+="Config file not found. "
	fi

	# Check ConfigMap exists
	if resource_exists "configmap" "file-config" "glade"; then
		((score += 2))
		details+="ConfigMap file-config exists. "

		# Check content
		local content
		content=$(kubectl get configmap file-config -n glade -o jsonpath='{.data}' 2>/dev/null)
		if [[ "$content" == *"foo3"* ]] || [[ "$content" == *"lili"* ]]; then
			((score += 1))
			details+="ConfigMap content correct."
		else
			details+="ConfigMap content incorrect."
		fi
	else
		details+="ConfigMap file-config not found."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# Q16: ConfigMap with envFrom (5 points)
score_q16() {
	local score=0
	local max_points=5
	local details=""

	# Check ConfigMap exists
	if resource_exists "configmap" "env-config" "meadow"; then
		((score += 1))
		details+="ConfigMap env-config exists. "
	else
		details+="ConfigMap env-config not found. "
	fi

	# Check Pod exists
	if resource_exists "pod" "env-pod" "meadow"; then
		((score += 2))
		details+="Pod env-pod exists. "

		# Check envFrom
		local envFrom
		envFrom=$(kubectl get pod env-pod -n meadow -o jsonpath='{.spec.containers[0].envFrom[0].configMapRef.name}' 2>/dev/null)
		if [[ "$envFrom" == "env-config" ]]; then
			((score += 2))
			details+="envFrom configured correctly."
		else
			details+="envFrom not configured correctly."
		fi
	else
		details+="Pod env-pod not found."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# Q17: Secret from File (5 points)
score_q17() {
	local score=0
	local max_points=5
	local details=""

	# Check file exists
	if file_exists_and_not_empty "./exam/course/17/username"; then
		((score += 2))
		details+="Username file exists. "
	else
		details+="Username file not found. "
	fi

	# Check Secret exists
	if resource_exists "secret" "file-secret" "fern"; then
		((score += 2))
		details+="Secret file-secret exists. "

		# Check content
		local content
		content=$(kubectl get secret file-secret -n fern -o jsonpath='{.data.username}' 2>/dev/null | base64 -d 2>/dev/null)
		if [[ "$content" == "admin" ]]; then
			((score += 1))
			details+="Secret content correct."
		else
			details+="Secret content incorrect."
		fi
	else
		details+="Secret file-secret not found."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# Q18: Secret as Environment Variable (5 points)
score_q18() {
	local score=0
	local max_points=5
	local details=""

	# Check Secret exists
	if resource_exists "secret" "api-secret" "moss"; then
		((score += 1))
		details+="Secret api-secret exists. "
	else
		details+="Secret api-secret not found. "
	fi

	# Check Pod exists
	if resource_exists "pod" "api-pod" "moss"; then
		((score += 2))
		details+="Pod api-pod exists. "

		# Check env from secret
		local secretRef
		secretRef=$(kubectl get pod api-pod -n moss -o jsonpath='{.spec.containers[0].env[0].valueFrom.secretKeyRef.name}' 2>/dev/null)
		if [[ "$secretRef" == "api-secret" ]]; then
			((score += 2))
			details+="Secret env configured correctly."
		else
			details+="Secret env not configured correctly."
		fi
	else
		details+="Pod api-pod not found."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# Q19: ServiceAccount and Pod (5 points)
score_q19() {
	local score=0
	local max_points=5
	local details=""

	# Check ServiceAccount exists
	if resource_exists "serviceaccount" "app-sa" "root"; then
		((score += 2))
		details+="ServiceAccount app-sa exists. "
	else
		details+="ServiceAccount app-sa not found. "
	fi

	# Check Pod exists
	if resource_exists "pod" "sa-pod" "root"; then
		((score += 1))
		details+="Pod sa-pod exists. "

		# Check serviceAccountName
		local sa
		sa=$(kubectl get pod sa-pod -n root -o jsonpath='{.spec.serviceAccountName}' 2>/dev/null)
		if [[ "$sa" == "app-sa" ]]; then
			((score += 2))
			details+="ServiceAccount configured correctly."
		else
			details+="ServiceAccount not configured correctly."
		fi
	else
		details+="Pod sa-pod not found."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}

# Q20: Copy File from Pod (5 points)
score_q20() {
	local score=0
	local max_points=5
	local details=""

	# Check Pod exists
	if resource_exists "pod" "copy-pod" "bark"; then
		((score += 2))
		details+="Pod copy-pod exists. "
	else
		details+="Pod copy-pod not found. "
	fi

	# Check file exists
	if file_exists_and_not_empty "./exam/course/20/passwd"; then
		((score += 2))
		details+="Passwd file copied. "

		# Check content
		if grep -q "root:" ./exam/course/20/passwd 2>/dev/null; then
			((score += 1))
			details+="File content valid."
		else
			details+="File content invalid."
		fi
	else
		details+="Passwd file not found."
	fi

	echo "$score/$max_points"
	echo "DETAILS:$details"
}
