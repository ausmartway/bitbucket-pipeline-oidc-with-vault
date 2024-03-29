##main.tf

provider "bitbucket" {
  # Bitbucket Cloud app password required here. Providing sensitive data to variable is insecure, as it will be stored in terraform statefile in plaintext. It is recommended to use enviroment variables instead.
  # BITBUCKET_USERNAME and BITBUCKET_PASSWORD are the environment variables used in this demo.
  #   username = var.bitbucket_username
  #   password = var.bitbucket_password
}

provider "vault" {
  # HCP Vault address and token required here. Providing sensitive data to variable is insecure, as it will be stored in terraform statefile in plaintext. It is recommended to use enviroment variables instead.
  # VAULT_ADDR and VAULT_TOKEN are the environment variables used in this demo.
  # address = var.vault_address
  # token = var.vault_token
}

data "bitbucket_workspace" "workspace" {
  id = var.bitbucket_workspace_name
}

locals {
  // bitbucket uuid contains 36 characters, besides the opening and closing curly braces, the braces should be removed
  bitbucket_workspace_uuid = substr(data.bitbucket_workspace.workspace.uuid, 1, 36)
}

data "bitbucket_repository" "repository" {
  workspace = var.bitbucket_workspace_name
  name      = var.bitbucket_repository_name
}

// add the vault address and namespace as pipeline variables, so that the pineline can access vault.
resource "bitbucket_pipeline_variable" "vault_addr" {
  workspace  = var.bitbucket_workspace_name
  repository = var.bitbucket_repository_name
  key        = "VAULT_ADDR"
  value      = var.vault_address
  secured    = false
}

resource "bitbucket_pipeline_variable" "vault_namespace" {
  workspace  = var.bitbucket_workspace_name
  repository = var.bitbucket_repository_name
  key        = "VAULT_NAMESPACE"
  value      = var.vault_namespace
  secured    = false
}

# Create a KV secrets engine
resource "vault_mount" "bitbucket" {
  path        = "kv-for-bitbucket-workspace-${var.bitbucket_workspace_name}"
  type        = "kv"
  options     = { version = "2" }
  description = "KV mount for bitbucket workspace ${var.bitbucket_workspace_name}"
}

# Create a secret in the KV engine

resource "vault_kv_secret_v2" "bitbucket" {
  mount = vault_mount.bitbucket.path
  name  = "bitbucket-secret-for-repo-${var.bitbucket_repository_name}"
  data_json = jsonencode(
    {
      DemoKey    = "secrets for repository ${var.bitbucket_workspace_name}/${var.bitbucket_repository_name}",
      DemoSecret = "t0pSecrets that can be used by the pipeline"
    }
  )
}

# Create a policy granting the bitbucket cloud pipeline access to the KV engine
resource "vault_policy" "bitbucket-repo-jwt" {
  name = "bitbucket-pipeline-secrets-for-${var.bitbucket_repository_name}"

  policy = <<EOT
# Generate child tokens
path "auth/token/create" {
capabilities = ["update"]
}

# Used by the token to query itself
path "auth/token/lookup-self" {
capabilities = ["read"]
}

# Get secrets from KV engine
path "${vault_kv_secret_v2.bitbucket.path}" {
  capabilities = ["list","read"]
}
EOT
}

# Create the JWT auth method tied to the bitbucket cloud workspace
resource "vault_jwt_auth_backend" "jwt" {
  description  = "JWT Backend for Bitbucket Workspace ${var.bitbucket_workspace_name}"
  path         = "bitbucket-oidc-for-workspace-${var.bitbucket_workspace_name}"
  jwks_url     = "https://api.bitbucket.org/2.0/workspaces/${var.bitbucket_workspace_name}/pipelines-config/identity/oidc/keys.json"
  bound_issuer = "https://api.bitbucket.org/2.0/workspaces/${var.bitbucket_workspace_name}/pipelines-config/identity/oidc"
}

# Create the JWT role tied to the repository
resource "vault_jwt_auth_backend_role" "repository" {
  backend           = vault_jwt_auth_backend.jwt.path
  role_name         = "bitbucket-oidc-${var.bitbucket_workspace_name}-${var.bitbucket_repository_name}"
  token_policies    = [vault_policy.bitbucket-repo-jwt.name]
  token_max_ttl     = "7200"
  bound_audiences   = ["ari:cloud:bitbucket::workspace/${local.bitbucket_workspace_uuid}"]
  bound_claims_type = "glob"
  bound_claims = {
    sub = "${data.bitbucket_repository.repository.id}:*"
  }
  user_claim = "repositoryUuid"
  role_type  = "jwt"
}