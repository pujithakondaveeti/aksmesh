# Hierarchical Namespaces in AKS

This directory contains Kubernetes manifests for creating hierarchical namespaces using the Hierarchical Namespace Controller (HNC).

## Structure

The hierarchical namespace structure is:

```
ss-automative-nds (parent)
├── application1-nds (child)
└── application2-nds (child)

ss-integrations-nds (parent)
├── integration1-nds (child)
└── integration2-nds (child)
```

## Prerequisites

The Hierarchical Namespace Controller (HNC) must be installed in the cluster. This is handled automatically by the Terraform module in `terraform/modules/hnc/`.

## Deployment Options

### Option 1: Using Terraform (Recommended)

The hierarchical namespaces are automatically created when you apply the Terraform configuration:

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

The Terraform module will:
1. Install HNC via Helm chart
2. Create parent namespaces
3. Create SubnamespaceAnchors that automatically create child namespaces

### Option 2: Using kubectl

If you prefer to create the namespaces manually using kubectl:

1. **Install HNC** (if not already installed via Terraform):
   ```bash
   kubectl apply -f https://github.com/kubernetes-sigs/hierarchical-namespaces/releases/download/v1.1.0/hnc-manager.yaml
   ```

2. **Create parent namespaces**:
   ```bash
   kubectl apply -f parent-namespaces.yaml
   ```

3. **Create child namespaces via SubnamespaceAnchors**:
   ```bash
   kubectl apply -f subnamespace-anchors.yaml
   ```

### Option 3: Using Helm

HNC can be installed via Helm:

```bash
helm repo add hnc https://kubernetes-sigs.github.io/hierarchical-namespaces
helm repo update
helm install hnc hnc/hnc --namespace hnc-system --create-namespace
```

Then apply the manifests as shown in Option 2.

## Verification

To verify the hierarchical structure:

```bash
# Check HNC installation
kubectl get pods -n hnc-system

# View parent namespaces
kubectl get ns ss-automative-nds ss-integrations-nds

# View child namespaces (created automatically by SubnamespaceAnchors)
kubectl get ns application1-nds application2-nds integration1-nds integration2-nds

# Check the hierarchy using HNC plugin
kubectl hns tree ss-automative-nds
kubectl hns tree ss-integrations-nds
```

## Benefits of Hierarchical Namespaces

- **Resource Propagation**: Resources like ConfigMaps, Secrets, and RBAC policies can be propagated from parent to child namespaces
- **Policy Inheritance**: NetworkPolicies and other policies can be inherited by child namespaces
- **Organization**: Better organization of namespaces in large clusters
- **Access Control**: Simplified RBAC management through inheritance

## Customization

To add more child namespaces:

1. Add a new SubnamespaceAnchor in the appropriate parent namespace
2. Apply the updated manifest or run `terraform apply`

Example:
```yaml
apiVersion: hnc.x-k8s.io/v1alpha2
kind: SubnamespaceAnchor
metadata:
  name: application3-nds
  namespace: ss-automative-nds
```
