resource "aws_efs_file_system" "this" {
  creation_token = "${var.cluster_name}-efs"
  encrypted      = true

  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }

  tags = {
    Name = "${var.cluster_name}-efs"
  }
}

# Allow NFS (2049) from EKS node SG to EFS
resource "aws_security_group" "efs" {
  name        = "${var.cluster_name}-efs-sg"
  description = "EFS SG allowing NFS from EKS nodes"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description     = "NFS from EKS nodes"
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [module.eks.node_security_group_id]
  }

  egress {
    description = "all egress"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.cluster_name}-efs-sg"
  }
}

# HA mount targets (one per private subnet / AZ)
resource "aws_efs_mount_target" "private" {
  for_each = toset(module.vpc.private_subnets)

  file_system_id  = aws_efs_file_system.this.id
  subnet_id       = each.value
  security_groups = [aws_security_group.efs.id]
}
