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
