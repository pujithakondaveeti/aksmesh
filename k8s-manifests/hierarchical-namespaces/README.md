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
4. Apply RBAC roles and bindings that propagate to child namespaces
5. Set resource quotas and limits that propagate to child namespaces
6. Configure network policies that propagate to child namespaces

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

4. **Apply RBAC policies (optional)**:
   ```bash
   kubectl apply -f rbac-examples.yaml
   ```

5. **Apply Resource Quotas and Limits (optional)**:
   ```bash
   kubectl apply -f quota-examples.yaml
   ```

6. **Apply Network Policies (optional)**:
   ```bash
   kubectl apply -f networkpolicy-examples.yaml
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

# Verify RBAC propagation
kubectl get roles -n ss-automative-nds
kubectl get roles -n application1-nds  # Should show propagated roles

# Verify Resource Quotas propagation
kubectl get resourcequotas -n ss-automative-nds
kubectl get resourcequotas -n application1-nds  # Should show propagated quotas

# Verify Network Policies propagation
kubectl get networkpolicies -n ss-automative-nds
kubectl get networkpolicies -n application1-nds  # Should show propagated policies
```

## Benefits of Hierarchical Namespaces

- **Resource Propagation**: Resources like ConfigMaps, Secrets, and RBAC policies can be propagated from parent to child namespaces
- **Policy Inheritance**: NetworkPolicies and other policies can be inherited by child namespaces
- **Organization**: Better organization of namespaces in large clusters
- **Access Control**: Simplified RBAC management through inheritance
- **Resource Management**: Define quotas once at the parent level and have them apply to all children
- **Security**: Network policies defined at the parent level protect all child namespaces

## Policy Propagation

HNC automatically propagates resources marked with the label `propagate.hnc.x-k8s.io/treeSelect: "true"` from parent to child namespaces. This includes:

### RBAC Resources
- **Roles**: Define access permissions once at the parent level
- **RoleBindings**: Grant permissions to users/groups that apply to all child namespaces
- Example: Admin and Developer roles are defined in parent namespaces and automatically available in children

### Resource Management
- **ResourceQuotas**: Set compute and object limits at the parent level
  - Compute quotas (CPU, Memory, Storage)
  - Object count quotas (Pods, Services, ConfigMaps, Secrets)
- **LimitRanges**: Define default resource limits and requests for containers
  - Default CPU and memory limits
  - Minimum and maximum resource constraints

### Network Policies
- **Default Deny**: Block all ingress traffic by default
- **Allow Same Namespace**: Permit traffic within the namespace
- **Allow Istio Ingress**: Enable traffic from Istio ingress gateway
- **Allow Monitoring**: Permit traffic from monitoring namespace

## Files in This Directory

- **parent-namespaces.yaml**: Definitions for parent namespaces
- **subnamespace-anchors.yaml**: SubnamespaceAnchor resources that create child namespaces
- **rbac-examples.yaml**: Example RBAC roles and bindings with propagation
- **quota-examples.yaml**: Example resource quotas and limit ranges with propagation
- **networkpolicy-examples.yaml**: Example network policies with propagation
- **deploy.sh**: Automated deployment script
- **helm-values/hnc-values.yaml**: HNC Helm chart customization

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
