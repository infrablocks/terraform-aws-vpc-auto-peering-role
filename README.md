Terraform AWS VPC Auto Peering
==============================

[![CircleCI](https://circleci.com/gh/infrablocks/terraform-aws-vpc-auto-peering.svg?style=svg)](https://circleci.com/gh/infrablocks/terraform-aws-vpc-auto-peering)

A Terraform module for creating a role to allow the 
[vpc-auto-peering-lambda](https://github.com/infrablocks/terraform-aws-vpc-auto-peering) 
to automatically peer VPCs based on dependency information stored in tags.

Usage
-----

To use the module, include something like the following in your Terraform
configuration:

```hcl-terraform
module "vpc-auto-peering" {
  source = "infrablocks/vpc-auto-peering/aws"
  version = "0.1.12"
  
  region = "eu-west-2"
  deployment_identifier = "1bc5defe"

  infrastructure_events_topic_arn = "arn:aws:sns:eu-west-2:579878096224:infrastructure-events-topic-eu-west-2-335e1e54"
}
```

See the 
[Terraform registry entry](https://registry.terraform.io/modules/infrablocks/vpc-auto-peering-role/aws/latest) 
for more details.

### Inputs

| Name                            | Description                                                         | Default | Required |
|---------------------------------|---------------------------------------------------------------------|:-------:|:--------:|
| region                          | The region into which the VPC auto peering lambda is being deployed | -       | yes      |
| deployment_identifier           | An identifier for this instantiation                                | -       | yes      |
| infrastructure_events_topic_arn | The ARN of the SNS topic containing VPC events                      | -       | yes      |
| search_regions                  | AWS regions to search for dependency and dependent VPCs.            | -       | no       |


### Outputs

| Name                         | Description                                          |
|------------------------------|------------------------------------------------------|

### Compatibility

This module is compatible with Terraform versions greater than or equal to 
Terraform 1.0.

Development
-----------

### Machine Requirements

In order for the build to run correctly, a few tools will need to be installed 
on your development machine:

* Ruby (3.1.1)
* Bundler
* git
* git-crypt
* gnupg
* direnv
* aws-vault

#### Mac OS X Setup

Installing the required tools is best managed by [homebrew](http://brew.sh).

To install homebrew:

```
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

Then, to install the required tools:

```
# ruby
brew install rbenv
brew install ruby-build
echo 'eval "$(rbenv init - bash)"' >> ~/.bash_profile
echo 'eval "$(rbenv init - zsh)"' >> ~/.zshrc
eval "$(rbenv init -)"
rbenv install 3.1.1
rbenv rehash
rbenv local 3.1.1
gem install bundler

# git, git-crypt, gnupg
brew install git
brew install git-crypt
brew install gnupg

# aws-vault
brew cask install

# direnv
brew install direnv
echo "$(direnv hook bash)" >> ~/.bash_profile
echo "$(direnv hook zsh)" >> ~/.zshrc
eval "$(direnv hook $SHELL)"

direnv allow <repository-directory>
```

### Running the build

Running the build requires an AWS account and AWS credentials. You are free to 
configure credentials however you like as long as an access key ID and secret
access key are available. These instructions utilise 
[aws-vault](https://github.com/99designs/aws-vault) which makes credential
management easy and secure.

To provision module infrastructure, run tests and then destroy that 
infrastructure, execute:

```bash
aws-vault exec <profile> -- ./go
```

To provision the module prerequisites:

```bash
aws-vault exec <profile> -- ./go deployment:prerequisites:provision[<deployment_identifier>]
```

To provision the module contents:

```bash
aws-vault exec <profile> -- ./go deployment:root:provision[<deployment_identifier>]
```

To destroy the module contents:

```bash
aws-vault exec <profile> -- ./go deployment:root:destroy[<deployment_identifier>]
```

To destroy the module prerequisites:

```bash
aws-vault exec <profile> -- ./go deployment:prerequisites:destroy[<deployment_identifier>]
```

Configuration parameters can be overridden via environment variables:

```bash
DEPLOYMENT_IDENTIFIER=testing aws-vault exec <profile> -- ./go
```

When a deployment identifier is provided via an environment variable, 
infrastructure will not be destroyed at the end of test execution. This can
be useful during development to avoid lengthy provision and destroy cycles.

By default, providers will be downloaded for each terraform execution. To
cache providers between calls:

```bash
TF_PLUGIN_CACHE_DIR="$HOME/.terraform.d/plugin-cache" aws-vault exec <profile> -- ./go
```

### Common Tasks

#### Generating an SSH key pair

To generate an SSH key pair:

```
ssh-keygen -m PEM -t rsa -b 4096 -C integration-test@example.com -N '' -f config/secrets/keys/bastion/ssh
```

#### Generating a self-signed certificate

To generate a self signed certificate:
```
openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -days 365
```

To decrypt the resulting key:

```
openssl rsa -in key.pem -out ssl.key
```

#### Add a git-crypt user

To adding a user to git-crypt using their GPG key: 

```
gpg --import ~/path/xxxx.pub
git-crypt add-gpg-user --trusted GPG-USER-ID

```

#### Managing CircleCI keys

To encrypt a GPG key for use by CircleCI:

```bash
openssl aes-256-cbc \
  -e \
  -md sha1 \
  -in ./config/secrets/ci/gpg.private \
  -out ./.circleci/gpg.private.enc \
  -k "<passphrase>"
```

To check decryption is working correctly:

```bash
openssl aes-256-cbc \
  -d \
  -md sha1 \
  -in ./.circleci/gpg.private.enc \
  -k "<passphrase>"
```

Contributing
------------

Bug reports and pull requests are welcome on GitHub at 
https://github.com/infrablocks/terraform-aws-vpc-auto-peering.
This project is intended to be a safe, welcoming space for collaboration, and 
contributors are expected to adhere to the 
[Contributor Covenant](http://contributor-covenant.org) code of conduct.

License
-------

The library is available as open source under the terms of the 
[MIT License](http://opensource.org/licenses/MIT).
