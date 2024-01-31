# Bitbucket cloud OIDC into HCP Vault

Bitbucket Pipeline need some secrets in both CI and CD phase. These secrets can be stored in Bitbucket as variables, however, secrets spreaded in repositories are hard to manage. HashiCorp Vault is a popular secrects management platform that can manage the lifecycle of many types of secrets. Bitbucket Cloud can use it's native OIDC token to login to Vault and get secrets without having to provide a credential to connect. This eliminates the need to store any secrets in Bitbucket Cloud.

This is a sample project to demonstrate how Bitbucket Cloud pipelines can use it's native OIDC token to log into HCP Vault and get secrets.

You can see this in action at this [Bitbucket Cloud repository](https://bitbucket.org/yuleitest/oidc-vault-test/pipelines/results/page/1).

This is samilar with [Using OIDC with HashiCorp Vault and Github Actions](https://www.hashicorp.com/resources/using-oidc-with-hashicorp-vault-and-github-actions)

## Prerequisites

A working instance of HCP Vault is required. This can be a trial instance or a paid instance.  

A Bitbucket Cloud account is required. This can be a free or paid account.

## Setup

Create a [Bitbucket Cloud app password](https://support.atlassian.com/Bitbucket-cloud/docs/create-an-app-password/). This will be used to authenticate to Bitbucket Cloud. Export the values into Bitbucket_USERNAME and Bitbucket_PASSWORD environment variables.

Create a HCP Vault admin [token](https://learn.hashicorp.com/tutorials/vault/getting-started-token?in=vault/getting-started). Export the value into VAULT_TOKEN environment variable. Also setup VAULT_ADDR and VAULT_NAMESPACE environment variables.

Create Bitbucket Cloud workspace and repository, enable [pipeline](https://support.atlassian.com/Bitbucket-cloud/docs/get-started-with-Bitbucket-pipelines/). Get Bitbucket Cloud workspace name and repository name, provide the values to Bitbucket_workspace_name and Bitbucket_repository_name terraform variables.

## Usage

```bash
terraform init
terraform plan 
terraform apply -auto-approve
```

The workspace is onboarded into hcp vault as a jwt auth method, which can be used by all repositories under the same workspace. The repository is onboarded into hcp vault as a jwt auth role. Vault access details are added as repository variables. An example Bitbucket pipeline file has been provided. The pipeline would login to vault and print the secrets from vault.

![Bitbucket Pipeline OIDC JWT Integration with Vault](./diagrams/Bitbucket-pipeline-oidc-jwt-integration-with-vault.png)

## Cleanup

```bash
terraform destroy -auto-approve
```