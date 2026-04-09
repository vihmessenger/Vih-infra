# EKS — AWS Load Balancer Controller (Helm)

Terraform manages the **`aws-load-balancer-controller`** Helm release. The **IAM / IRSA service account** is not created here — create it once (for example with `eksctl create iamserviceaccount` and `AWSLoadBalancerControllerIAMPolicy`), then import or apply.

## First time (release already installed manually)

After `infra-live/prod/application/eks` exists and LBC is running in the cluster:

```bash
cd infra-live/prod/application/eks-lbc
export VIH_TF_STATE_BUCKET=…
export VIH_TF_STATE_KMS_KEY_ARN=…
export TG_AWS_REGION=us-east-1
terragrunt init
terragrunt import helm_release.aws_load_balancer_controller kube-system/aws-load-balancer-controller
terragrunt plan   # should show no or minimal drift
```

If the Helm release does **not** exist yet, run `terragrunt apply` instead (still requires the `kube-system/aws-load-balancer-controller` **ServiceAccount** + IAM role).

## Requirements

- `aws` CLI (for EKS exec auth)
- `kubectl` optional
- Cluster must be reachable from where you run Terraform
