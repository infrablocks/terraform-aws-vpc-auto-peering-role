variable "region" {
  description = "The region into which the VPC auto peering lambda role is being deployed."
  type = string
}
variable "deployment_identifier" {
  description = "An identifier for this instantiation."
  type = string
}
variable "assumable_by_account_ids" {
  description = "A list of account IDs for accounts that are allowed to assume this role."
  type = list(string)
}
