#!/bin/bash
exam_post_setup() {
  # Install Helm release for Q5
  helm repo add bitnami https://charts.bitnami.com/bitnami > /dev/null 2>&1
  helm repo update > /dev/null 2>&1
  helm install ocean-api bitnami/nginx --namespace current > /dev/null 2>&1
  
  # Generate some warning events for Q10
  kubectl run failing-pod --image=wrong-image-for-event --namespace depths > /dev/null 2>&1
  sleep 5
  kubectl delete pod failing-pod --namespace depths --force --grace-period=0 > /dev/null 2>&1
}
