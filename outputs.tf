output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "efs_file_system_id" {
  value = aws_efs_file_system.this.id
}
