# frozen_string_literal: true

require 'spec_helper'

describe 'IAM policies, profiles and roles' do
  let(:region) do
    var(role: :root, name: 'region')
  end
  let(:deployment_identifier) do
    var(role: :root, name: 'deployment_identifier')
  end

  describe 'by default' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.assumable_by_account_ids = ['123456789012']
      end
    end

    it 'creates an IAM policy' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_iam_policy')
              .once)
    end

    it 'uses the name "vpc-auto-peering-policy" for the IAM policy' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_iam_policy')
              .with_attribute_value(:name, 'vpc-auto-peering-policy'))
    end

    it 'uses the description "vpc-auto-peering-policy" for the IAM policy' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_iam_policy')
              .with_attribute_value(:description, 'vpc-auto-peering-policy'))
    end

    it 'allows peering connection management in the IAM policy' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_iam_policy')
              .with_attribute_value(
                :policy,
                a_policy_with_statement(
                  Effect: 'Allow',
                  Resource: '*',
                  Action: %w[
                    ec2:AcceptVpcPeeringConnection
                    ec2:CreateVpcPeeringConnection
                    ec2:DeleteVpcPeeringConnection
                    ec2:DescribeVpcPeeringConnections
                    ec2:CreateRoute
                    ec2:DeleteRoute
                    ec2:DescribeRouteTables
                    ec2:DescribeTags
                    ec2:DescribeVpcs
                  ]
                )
              ))
    end

    it 'creates an IAM role' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_iam_role')
              .once)
    end

    it 'uses a role name of "vpc-auto-peering-role"' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_iam_role')
              .with_attribute_value(:name, 'vpc-auto-peering-role'))
    end

    it 'uses an assume role policy allowing the provided accounts to assume' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_iam_role')
              .with_attribute_value(
                :assume_role_policy,
                a_policy_with_statement(
                  Effect: 'Allow',
                  Action: 'sts:AssumeRole',
                  Principal: {
                    AWS: '123456789012'
                  }
                )
              ))
    end

    it 'creates a role policy attachment' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_iam_role_policy_attachment')
              .once)
    end

    it 'outputs the role ARN' do
      expect(@plan)
        .to(include_output_creation(name: 'module_outputs')
              .with_value(including(:role_arn)))
    end
  end
end
