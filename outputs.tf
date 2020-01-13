output "role_arn" {
  value = module.cross_account_role.role_arn
  description = "The ARN of the VPC auto-peering role."
}
