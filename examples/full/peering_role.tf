module "vpc_auto_peering_role" {
  source = "./../../"

  region = var.region
  deployment_identifier = var.deployment_identifier

  assumable_by_account_ids = ["325795806661", "176145454894"]
}
