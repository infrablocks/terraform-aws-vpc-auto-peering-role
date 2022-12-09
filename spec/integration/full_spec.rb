# frozen_string_literal: true

require 'spec_helper'

describe 'full' do
  let(:region) do
    var(role: :full, name: 'region')
  end
  let(:deployment_identifier) do
    var(role: :full, name: 'deployment_identifier')
  end
  let(:assumable_by_account_ids) do
    %w[
      325795806661
      176145454894
    ]
  end
  let(:role_arn) do
    output(role: :full, name: 'role_arn')
  end

  before(:context) do
    apply(role: :full)
  end

  after(:context) do
    destroy(
      role: :full,
      only_if: -> { !ENV['FORCE_DESTROY'].nil? || ENV['SEED'].nil? }
    )
  end

  describe 'vpc auto peering role' do
    subject(:peering_role) do
      iam_role(role_arn)
    end

    it { is_expected.to exist }

    it 'is assumable by the provided accounts' do
      actual = JSON.parse(
        CGI.unescape(peering_role.assume_role_policy_document),
        symbolize_names: true
      )
      expected = {
        Version: '2012-10-17',
        Statement: [
          {
            Sid: '',
            Effect: 'Allow',
            Action: 'sts:AssumeRole',
            Principal: containing_exactly(
              AWS: containing_exactly(
                "arn:aws:iam::#{assumable_by_account_ids[0]}:root",
                "arn:aws:iam::#{assumable_by_account_ids[1]}:root"
              )
            )
          }
        ]
      }

      expect(actual).to(eq(expected))
    end

    it 'is allowed to manage vpc peering connections' do
      expect(peering_role)
        .to(be_allowed_action('ec2:AcceptVpcPeeringConnection')
              .and(be_allowed_action('ec2:CreateVpcPeeringConnection'))
              .and(be_allowed_action('ec2:DeleteVpcPeeringConnection'))
              .and(be_allowed_action('ec2:DescribeVpcPeeringConnections')))
    end

    it 'is allowed to manage routes' do
      expect(peering_role)
        .to(be_allowed_action('ec2:CreateRoute')
              .and(be_allowed_action('ec2:DeleteRoute'))
              .and(be_allowed_action('ec2:DescribeRouteTables')))
    end

    it 'is allowed to read tags' do
      expect(peering_role)
        .to(be_allowed_action('ec2:DescribeTags'))
    end

    it 'is allowed to read vpcs' do
      expect(peering_role)
        .to(be_allowed_action('ec2:DescribeVpcs'))
    end
  end
end
