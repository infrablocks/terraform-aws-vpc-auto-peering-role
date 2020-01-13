variable "region" {
  description = "The region into which the VPC auto peering lambda role is being deployed."
  type = string
}
variable "deployment_identifier" {
  description = "An identifier for this instantiation."
  type = string
}
