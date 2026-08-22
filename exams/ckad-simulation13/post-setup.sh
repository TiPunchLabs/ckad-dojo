#!/bin/bash

# Post-setup script for CKAD Simulation 13
# This script is executed after the standard setup process

exam_post_setup() {
    echo "Running post-setup for Simulation 13..."
    
    # Deploy the Helm chart for question 5
    helm install storm-app ./exam/course/13/q5/storm-chart -n typhoon
    
    echo "Post-setup complete."
}
