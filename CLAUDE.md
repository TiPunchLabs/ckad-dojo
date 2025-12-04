# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

This is a CKAD (Certified Kubernetes Application Developer) exam preparation repository containing practice questions and solutions from the Killershell simulator (killer.sh). It is designed for studying Kubernetes concepts and practicing for the CKAD certification exam.

## Structure

- `simulation1.md` - Contains 22 practice questions with detailed answers covering CKAD exam topics

## Topics Covered

The questions cover core CKAD exam domains:
- Namespaces, Pods, Jobs, Deployments
- Helm management
- ServiceAccounts and Secrets
- Probes (Readiness/Liveness)
- Rollouts and rollbacks
- Services (ClusterIP, NodePort)
- Storage (PV, PVC, StorageClass)
- ConfigMaps and Secrets (volume mounts, environment variables)
- Logging sidecars
- InitContainers
- NetworkPolicies
- Resource requests and limits
- Labels and Annotations

## Exam Environment Notes

- Each question is solved on a specific SSH instance (e.g., `ssh ckad5601`)
- Always `exit` back to main terminal before connecting to a different instance
- Common alias: `k` for `kubectl`
- Solutions often use `--dry-run=client -oyaml` to generate YAML templates
