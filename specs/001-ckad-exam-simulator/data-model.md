# Data Model: CKAD Exam Simulator

**Date**: 2025-12-04
**Updated**: 2025-12-05
**Feature**: 001-ckad-exam-simulator

## Overview

This document describes the Kubernetes resources, file structures, and web interface state required for the CKAD exam simulator. Resources are organized by the questions they support.

## Namespaces

| Namespace | Purpose | Questions |
|-----------|---------|-----------|
| default | Standard namespace | Q1, Q2, Q6 |
| neptune | Team Neptune resources | Q3, Q5, Q7, Q8, Q21 |
| saturn | Team Saturn webservers | Q7 |
| earth | Team Earth storage | Q12 |
| mars | Team Mars containers | Q17, Q18 |
| pluto | Team Pluto APIs | Q9, Q10, P1 |
| jupiter | Team Jupiter services | Q19 |
| mercury | Team Mercury Helm | Q4, Q16 |
| venus | Team Venus network | Q20 |
| moon | Team Moon storage/secrets | Q13, Q14, Q15 |
| sun | Team Sun labeling | Q22 |
| shell-intern | Intern namespace | Q1 (listed in output) |

## Pre-existing Resources by Question

### Q4 - Helm Releases (mercury)

```yaml
# Helm releases to install before exam
releases:
  - name: internal-issue-report-apiv1
    chart: bitnami/nginx
    version: 18.1.14
    namespace: mercury

  - name: internal-issue-report-apiv2
    chart: bitnami/nginx
    version: 18.1.14
    namespace: mercury

  - name: internal-issue-report-app
    chart: bitnami/nginx
    version: 18.1.14
    namespace: mercury

  - name: internal-issue-report-daniel
    chart: bitnami/nginx
    version: 18.1.14
    namespace: mercury
    status: pending-install  # Broken release
```

### Q5 - ServiceAccount and Secret (neptune)

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: neptune-sa-v2
  namespace: neptune
---
apiVersion: v1
kind: Secret
metadata:
  name: neptune-secret-1
  namespace: neptune
  annotations:
    kubernetes.io/service-account.name: neptune-sa-v2
type: kubernetes.io/service-account-token
```

### Q7 - Saturn Webservers (saturn)

```yaml
# 6 pods named webserver-sat-001 through webserver-sat-006
# webserver-sat-003 has annotation: description: "this is the server for the E-Commerce System my-happy-shop"
apiVersion: v1
kind: Pod
metadata:
  name: webserver-sat-003
  namespace: saturn
  annotations:
    description: "this is the server for the E-Commerce System my-happy-shop"
  labels:
    id: webserver-sat-003
spec:
  containers:
  - name: webserver-sat
    image: nginx:1.16.1-alpine
```

### Q8 - Broken Deployment (neptune)

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-new-c32
  namespace: neptune
spec:
  replicas: 3
  selector:
    matchLabels:
      app: api-new-c32
  template:
    metadata:
      labels:
        app: api-new-c32
    spec:
      containers:
      - name: nginx
        image: ngnix:1-alpine  # Typo: ngnix instead of nginx
```

### Q9 - Holy API Pod (pluto)

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: holy-api
  namespace: pluto
  labels:
    id: holy-api
spec:
  containers:
  - name: holy-api-container
    image: nginx:1.17.3-alpine
    env:
    - name: CACHE_KEY_1
      value: "b&MTCi0=[T66RXm!jO@"
    - name: CACHE_KEY_2
      value: "PCAILGej5Ld@Q%{Q1=#"
    - name: CACHE_KEY_3
      value: "2qz-]2OJlWDSTn_;RFQ"
    volumeMounts:
    - name: cache-volume1
      mountPath: /cache1
    - name: cache-volume2
      mountPath: /cache2
    - name: cache-volume3
      mountPath: /cache3
  volumes:
  - name: cache-volume1
    emptyDir: {}
  - name: cache-volume2
    emptyDir: {}
  - name: cache-volume3
    emptyDir: {}
```

### Q14 - Secret Handler Pod (moon)

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: secret-handler
  namespace: moon
  labels:
    id: secret-handler
spec:
  containers:
  - name: secret-handler
    image: bash:5.0.11
    args: ['bash', '-c', 'sleep 2d']
    volumeMounts:
    - name: cache-volume1
      mountPath: /cache1
    - name: cache-volume2
      mountPath: /cache2
    - name: cache-volume3
      mountPath: /cache3
    env:
    - name: SECRET_KEY_1
      value: ">8$kH#kj..i8}HImQd{"
    - name: SECRET_KEY_2
      value: "IO=a4L/XkRdvN8jM=Y+"
    - name: SECRET_KEY_3
      value: "-7PA0_Z]>{pwa43r)__"
  volumes:
  - name: cache-volume1
    emptyDir: {}
  - name: cache-volume2
    emptyDir: {}
  - name: cache-volume3
    emptyDir: {}
```

### Q15 - Web Moon Deployment (moon)

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-moon
  namespace: moon
spec:
  replicas: 5
  selector:
    matchLabels:
      app: web-moon
  template:
    metadata:
      labels:
        app: web-moon
    spec:
      containers:
      - name: nginx
        image: nginx:1.17.3-alpine
        volumeMounts:
        - name: html-volume
          mountPath: /usr/share/nginx/html
      volumes:
      - name: html-volume
        configMap:
          name: configmap-web-moon-html  # Missing - user must create
```

### Q16 - Cleaner Deployment (mercury)

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: cleaner
  namespace: mercury
spec:
  replicas: 2
  selector:
    matchLabels:
      id: cleaner
  template:
    metadata:
      labels:
        id: cleaner
    spec:
      volumes:
      - name: logs
        emptyDir: {}
      initContainers:
      - name: init
        image: bash:5.0.11
        command: ['bash', '-c', 'echo init > /var/log/cleaner/cleaner.log']
        volumeMounts:
        - name: logs
          mountPath: /var/log/cleaner
      containers:
      - name: cleaner-con
        image: bash:5.0.11
        args: ['bash', '-c', 'while true; do echo `date`: "remove random file" >> /var/log/cleaner/cleaner.log; sleep 1; done']
        volumeMounts:
        - name: logs
          mountPath: /var/log/cleaner
```

### Q17 - Test Init Container (mars)

Template file only - deployment created by user.

### Q18 - Manager API (mars)

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: manager-api-deployment
  namespace: mars
spec:
  replicas: 4
  selector:
    matchLabels:
      id: manager-api-pod
  template:
    metadata:
      labels:
        id: manager-api-pod
    spec:
      containers:
      - name: nginx
        image: nginx:1.17.3-alpine
---
apiVersion: v1
kind: Service
metadata:
  name: manager-api-svc
  namespace: mars
spec:
  selector:
    id: manager-api-deployment  # Wrong selector - user must fix
  ports:
  - port: 4444
    targetPort: 80
```

### Q19 - Jupiter Crew (jupiter)

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: jupiter-crew-deploy
  namespace: jupiter
spec:
  replicas: 1
  selector:
    matchLabels:
      id: jupiter-crew
  template:
    metadata:
      labels:
        id: jupiter-crew
    spec:
      containers:
      - name: httpd
        image: httpd:2.4-alpine
---
apiVersion: v1
kind: Service
metadata:
  name: jupiter-crew-svc
  namespace: jupiter
spec:
  type: ClusterIP
  selector:
    id: jupiter-crew
  ports:
  - port: 8080
    targetPort: 80
```

### Q20 - Venus Network (venus)

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api
  namespace: venus
spec:
  replicas: 2
  selector:
    matchLabels:
      id: api
  template:
    metadata:
      labels:
        id: api
    spec:
      containers:
      - name: httpd
        image: httpd:2.4-alpine
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend
  namespace: venus
spec:
  replicas: 5
  selector:
    matchLabels:
      id: frontend
  template:
    metadata:
      labels:
        id: frontend
    spec:
      containers:
      - name: nginx
        image: nginx:1.17.3-alpine
---
apiVersion: v1
kind: Service
metadata:
  name: api
  namespace: venus
spec:
  selector:
    id: api
  ports:
  - port: 2222
    targetPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: frontend
  namespace: venus
spec:
  selector:
    id: frontend
  ports:
  - port: 80
```

### Q22 - Sun Pods (sun)

```yaml
# 16 pods with various labels
# type=runner: 0509649a, 86cda, a004a, a94128196
# type=worker: 0509649b, 1428721e, 1428721f, 4c09, 4c35, 4fe4, afd79200c56a, b667, fdb2
# type=test: 43b9a
# type=messenger: 5555a, 8d1c
```

## Template Files

| File | Location | Purpose |
|------|----------|---------|
| holy-api-pod.yaml | ./exam/course/9/ | Q9 Pod template |
| secret-handler.yaml | ./exam/course/14/ | Q14 Pod template |
| secret2.yaml | ./exam/course/14/ | Q14 Secret template |
| web-moon.html | ./exam/course/15/ | Q15 HTML content |
| cleaner.yaml | ./exam/course/16/ | Q16 Deployment template |
| test-init-container.yaml | ./exam/course/17/ | Q17 Deployment template |
| Dockerfile + main.go | ./exam/course/11/image/ | Q11 container build |
| project-23-api.yaml | ./exam/course/p1/ | Preview Q1 template |

## File Output Locations

Questions requiring file output by user:

| Question | File Path | Content |
|----------|-----------|---------|
| Q1 | ./exam/course/1/namespaces | `kubectl get ns` output |
| Q2 | ./exam/course/2/pod1-status-command.sh | kubectl command script |
| Q3 | ./exam/course/3/job.yaml | Job manifest |
| Q5 | ./exam/course/5/token | Decoded SA token |
| Q9 | ./exam/course/9/holy-api-deployment.yaml | Deployment manifest |
| Q10 | ./exam/course/10/service_test.html | curl output |
| Q10 | ./exam/course/10/service_test.log | Pod logs |
| Q11 | ./exam/course/11/logs | Container logs |
| Q13 | ./exam/course/13/pvc-126-reason | PVC event message |
| Q14 | ./exam/course/14/secret-handler-new.yaml | Modified Pod manifest |
| Q16 | ./exam/course/16/cleaner-new.yaml | Modified Deployment manifest |

## Web Interface State

The web server maintains in-memory state for the exam session:

### Timer State

```python
timer_state = {
    "start_time": None,       # Unix timestamp when exam started
    "duration_minutes": 120,  # Exam duration (from exam.conf)
    "exam_id": None,          # Current exam identifier
    "exam_name": None,        # Display name of exam
    "running": False          # Whether timer is active
}
```

### Flagged Questions

```python
flagged_questions = set()  # Set of question IDs marked for review
```

### Exam Configuration (exam.conf)

```bash
# Located in exams/<exam-id>/exam.conf
EXAM_NAME="CKAD Simulation 1"
EXAM_ID="ckad-simulation1"
EXAM_DURATION=120          # minutes
EXAM_WARNING_TIME=15       # minutes - first warning threshold
TOTAL_QUESTIONS=22
TOTAL_POINTS=113
PASSING_PERCENTAGE=66
```

### API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | /api/exams | List available exams |
| GET | /api/exam/{id}/questions | Get questions for exam |
| GET | /api/exam/{id}/config | Get exam configuration |
| GET | /api/timer | Get current timer state |
| GET | /api/flags | Get flagged question IDs |
| POST | /api/timer/start | Start exam timer |
| POST | /api/timer/stop | Stop exam timer |
| POST | /api/flag | Toggle question flag |
