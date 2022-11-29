data "aws_iam_policy_document" "vpc_auto_peering_role_policy" {
  statement {
    effect = "Allow"
    resources = ["*"]

    actions = [
      "ec2:AcceptVpcPeeringConnection",
      "ec2:CreateVpcPeeringConnection",
      "ec2:DeleteVpcPeeringConnection",
      "ec2:DescribeVpcPeeringConnections",
      "ec2:CreateRoute",
      "ec2:DeleteRoute",
      "ec2:DescribeRouteTables",
      "ec2:DescribeTags",
      "ec2:DescribeVpcs"
    ]
  }
}

resource "aws_iam_policy" "vpc_auto_auto_peering_policy" {
  name = "vpc-auto-peering-policy"
  description = "vpc-auto-peering-policy"
  policy = data.aws_iam_policy_document.vpc_auto_peering_role_policy.json
}

module "cross_account_role" {
  source = "infrablocks/cross-account-role/aws"
  version = "1.1.0-rc.6"

  role_name = "vpc-auto-peering-role"
  policy_arn = aws_iam_policy.vpc_auto_auto_peering_policy.arn
  assumable_by_account_ids = var.assumable_by_account_ids
}
