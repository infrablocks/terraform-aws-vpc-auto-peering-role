output "role_arn" {
  value = module.vpc_auto_peering_role.role_arn
  description = "The ARN of the created VPC auto-peering role."
}
