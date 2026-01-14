EKS High Availability Cluster with Public ALB Ingress and EFS Storage (Terraform)
Overview

This repository provisions a production-ready, highly available Amazon EKS (Elastic Kubernetes Service) cluster using Terraform, designed for running public-facing Kubernetes workloads with shared persistent storage.

The infrastructure is built with:

High availability across multiple Availability Zones

Public internet-facing ingress using AWS Application Load Balancers (ALB)

Shared RWX storage using Amazon EFS

IAM Roles for Service Accounts (IRSA) for secure, least-privilege access

Infrastructure-as-Code best practices

This setup is suitable for web applications, APIs, and services that require horizontal scaling and shared storage.

Architecture Summary

AWS Region

us-east-1

Networking

Custom VPC spanning 3 Availability Zones

Public and private subnets per AZ

One NAT Gateway per AZ for high availability

Public subnets used for ALB ingress

Private subnets used for EKS worker nodes

Kubernetes

Amazon EKS control plane (managed by AWS, HA by default)

Managed node group distributed across AZs

Public and private API access enabled

Ingress

AWS Load Balancer Controller

Internet-facing ALB

TLS termination via ACM

HTTP → HTTPS redirection

Storage

Amazon EFS with mount targets in every AZ

EFS CSI Driver for Kubernetes

Default StorageClass with dynamic Access Point provisioning

Supports ReadWriteMany volumes

What This Terraform Project Creates
1. VPC and Networking

VPC with a /16 CIDR block

3 public subnets (for ALBs)

3 private subnets (for EKS nodes)

Internet Gateway

Highly available NAT Gateways (1 per AZ)

Required subnet tags for Kubernetes and ALB discovery

2. EKS Cluster

EKS cluster running a specified Kubernetes version

Managed node group:

Spread across private subnets

Autoscaling enabled

IAM OIDC provider for IRSA

Secure control plane managed by AWS

3. IAM Roles for Service Accounts (IRSA)

Separate IAM roles are created for:

AWS Load Balancer Controller

EFS CSI Driver

This ensures:

No node-level IAM permissions

Least-privilege access

Better security and auditability

4. AWS Load Balancer Controller

Installed via Helm and configured to:

Create internet-facing ALBs

Route traffic directly to pod IPs

Support HTTP and HTTPS listeners

Integrate with ACM for TLS certificates

Support health checks and ALB tuning options

An IngressClass named alb is created and used by Kubernetes ingress resources.

5. Amazon EFS + EFS CSI Driver

Encrypted EFS file system

Mount targets in every private subnet (multi-AZ access)

Security group allowing NFS from EKS nodes

EFS CSI Driver installed via Helm

Default Kubernetes StorageClass:

Dynamic Access Point provisioning

Supports ReadWriteMany

Ideal for shared application data

6. Kubernetes Ingress

The project can optionally create a production-ready ingress that includes:

Public ALB

TLS termination with ACM

HTTP → HTTPS redirect

Health checks at /

Host-based routing

File Structure
.
├── versions.tf        # Provider versions and constraints
├── providers.tf       # AWS, Kubernetes, and Helm providers
├── variables.tf       # Input variables
├── vpc.tf             # VPC and networking
├── eks.tf             # EKS cluster and node groups
├── efs.tf             # EFS filesystem and mount targets
├── addons.tf          # ALB controller, EFS CSI, StorageClass
├── ingress.tf         # Optional Kubernetes Ingress
├── outputs.tf         # Useful outputs
└── README.md

Deployment Workflow
Prerequisites

AWS CLI configured with sufficient permissions

Terraform ≥ 1.5

kubectl installed

An ACM certificate in us-east-1 (for HTTPS ingress)

Initialize Terraform
terraform init

Deploy Core Infrastructure (recommended first pass)
terraform apply -target=module.vpc -target=module.eks -auto-approve

Deploy Add-ons and Kubernetes Resources
terraform apply -auto-approve

Configure kubectl
aws eks update-kubeconfig --region us-east-1 --name <cluster-name>

Using EFS Storage in Kubernetes

Example PersistentVolumeClaim:

apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: shared-efs-pvc
spec:
  accessModes:
    - ReadWriteMany
  storageClassName: efs-sc
  resources:
    requests:
      storage: 5Gi

Security Considerations

No credentials are stored in code

IAM permissions are scoped via IRSA

Worker nodes are placed in private subnets

TLS termination is handled by ALB with ACM

Terraform state is excluded from Git

Git and State Management

Terraform state files are ignored via .gitignore

Sensitive values should be stored in .tfvars files

For production use, it is recommended to:

Use S3 remote state

Enable DynamoDB state locking

Separate environments (dev, prod)

Why This Design

This architecture balances:

Scalability – managed node groups, ALB ingress

Availability – multi-AZ everything

Security – IRSA, private networking

Simplicity – managed AWS services

Flexibility – supports most Kubernetes workloads

Next Enhancements (Optional)

Remote Terraform state (S3 + DynamoDB)

GitHub Actions for Terraform validation

Cluster Autoscaler or Karpenter

AWS WAF integration

ExternalDNS for automatic DNS records

Cert-Manager for in-cluster cert management

License

This project is provided as-is for infrastructure automation and learning purposes.
