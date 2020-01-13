require 'spec_helper'

describe 'IAM policies, profiles and roles' do
  let(:region) { vars.region }
  let(:deployment_identifier) { vars.deployment_identifier }
  let(:role_arn) { output_for(:harness, 'role_arn') }
  let(:assumable_by_account_ids) { vars.assumable_by_account_ids }

  context 'vpc auto peering role' do
    subject {
      iam_role(role_arn)
    }

    it { should exist }

    it 'should be assumable by the provided accounts' do
      actual = JSON.parse(
          URI.decode(subject.assume_role_policy_document),
          symbolize_names: true)
      expected = {
          Version: "2012-10-17",
          Statement: [
              {
                  Sid: "",
                  Effect: "Allow",
                  Action: "sts:AssumeRole",
                  Principal: {
                      AWS: "arn:aws:iam::#{assumable_by_account_ids[0]}:root"
                  }
              }
          ]
      }

      expect(actual).to(eq(expected))
    end

    it 'is allowed to manage vpc peering connections' do
      expect(subject).to(be_allowed_action('ec2:AcceptVpcPeeringConnection'))
      expect(subject).to(be_allowed_action('ec2:CreateVpcPeeringConnection'))
      expect(subject).to(be_allowed_action('ec2:DeleteVpcPeeringConnection'))
      expect(subject).to(be_allowed_action('ec2:DescribeVpcPeeringConnections'))
    end

    it 'is allowed to manage routes' do
      expect(subject).to(be_allowed_action('ec2:CreateRoute'))
      expect(subject).to(be_allowed_action('ec2:DeleteRoute'))
      expect(subject).to(be_allowed_action('ec2:DescribeRouteTables'))
    end

    it 'is allowed to read tags' do
      expect(subject).to(be_allowed_action('ec2:DescribeTags'))
    end

    it 'is allowed to read vpcs' do
      expect(subject).to(be_allowed_action('ec2:DescribeVpcs'))
    end
  end
end
