#!/bin/bash
# Script to deploy Hierarchical Namespaces using kubectl

set -e

echo "==> Deploying Hierarchical Namespaces..."

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo "Error: kubectl is not installed or not in PATH"
    exit 1
fi

# Check if HNC is installed
echo "==> Checking if HNC is installed..."
if ! kubectl get crd subnamespaceanchors.hnc.x-k8s.io &> /dev/null; then
    echo "==> HNC is not installed. Installing HNC..."
    kubectl apply -f https://github.com/kubernetes-sigs/hierarchical-namespaces/releases/download/v1.1.0/hnc-manager.yaml
    echo "==> Waiting for HNC to be ready..."
    kubectl wait --for=condition=ready pod -l app=hnc-manager -n hnc-system --timeout=300s
else
    echo "==> HNC is already installed"
fi

# Create parent namespaces
echo "==> Creating parent namespaces..."
kubectl apply -f parent-namespaces.yaml

# Wait a bit for parent namespaces to be ready
sleep 2

# Create child namespaces via SubnamespaceAnchors
echo "==> Creating child namespaces via SubnamespaceAnchors..."
kubectl apply -f subnamespace-anchors.yaml

# Wait for child namespaces to be created
echo "==> Waiting for child namespaces to be created..."
sleep 5

# Apply RBAC policies
echo "==> Applying RBAC policies..."
kubectl apply -f rbac-examples.yaml

# Apply Resource Quotas and Limits
echo "==> Applying Resource Quotas and Limits..."
kubectl apply -f quota-examples.yaml

# Apply Network Policies
echo "==> Applying Network Policies..."
kubectl apply -f networkpolicy-examples.yaml

# Wait for propagation
echo "==> Waiting for policies to propagate to child namespaces..."
sleep 5

# Verify the namespaces
echo ""
echo "==> Verification:"
echo ""
echo "Parent namespaces:"
kubectl get ns ss-automative-nds ss-integrations-nds

echo ""
echo "Child namespaces:"
kubectl get ns application1-nds application2-nds integration1-nds integration2-nds

echo ""
echo "RBAC Roles in ss-automative-nds:"
kubectl get roles -n ss-automative-nds

echo ""
echo "RBAC Roles propagated to application1-nds:"
kubectl get roles -n application1-nds

echo ""
echo "Resource Quotas in ss-automative-nds:"
kubectl get resourcequotas -n ss-automative-nds

echo ""
echo "Resource Quotas propagated to application1-nds:"
kubectl get resourcequotas -n application1-nds

echo ""
echo "Network Policies in ss-automative-nds:"
kubectl get networkpolicies -n ss-automative-nds

echo ""
echo "Network Policies propagated to application1-nds:"
kubectl get networkpolicies -n application1-nds

echo ""
echo "==> Deployment complete!"
echo ""
echo "To view the hierarchy, install the kubectl-hns plugin and run:"
echo "  kubectl hns tree ss-automative-nds"
echo "  kubectl hns tree ss-integrations-nds"
