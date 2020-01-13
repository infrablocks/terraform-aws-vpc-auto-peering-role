data "terraform_remote_state" "prerequisites" {
  backend = "local"

  config = {
    path = "${path.module}/../../../../state/prerequisites.tfstate"
  }
}

module "vpc_auto_peering_role" {
  source = "../../../../"

  region = var.region
  deployment_identifier = var.deployment_identifier

  assumable_by_account_ids = var.assumable_by_account_ids
}
