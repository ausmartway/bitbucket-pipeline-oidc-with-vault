##main.tf

provider "bitbucket" {
  username = var.bitbucket_username
  password = var.bitbucket_password
}
data "bitbucket_workspace" "workspace" {
 id = var.bitbucket_workspace_name
}

data "bitbucket_repository" "repository" {
  workspace   = var.bitbucket_workspace_name
  name        = var.bitbucket_repository_name
}

# provider "vault" {
# }

# # Create a KV secrets engine
# resource "vault_mount" "bitbucket" {
#   path        = "bitbucket-workspace"
#   type        = "kv"
#   options     = { version = "2" }
#   description = "KV mount for bitbucket workspace"
# }

# # Create a secret in the KV engine

# resource "vault_kv_secret_v2" "bitbucket" {
#   mount = vault_mount.bitbucket.path
#   name  = "bitbucket-secret"
#   data_json = jsonencode(
#     {
#       test1 = "testvalue1",
#       test2  = "testvalue2"
#     }
#   )
# } 

# # Create a policy granting the TFC workspace access to the KV engine
# resource "vault_policy" "bitbucket-repo-jwt" {
#   name = "bitbucket-repo-jwt"

#   policy = <<EOT
# # Generate child tokens
# path "auth/token/create" {
# capabilities = ["update"]
# }

# # Used by the token to query itself
# path "auth/token/lookup-self" {
# capabilities = ["read"]
# }

# # Get secrets from KV engine
# path "${vault_kv_secret_v2.bitbucket.path}" {
#   capabilities = ["list","read"]
# }
# EOT
# }

# # Create the JWT auth method to use Bitbucket
# resource "vault_jwt_auth_backend" "jwt" {
#   description        = "JWT Backend for Bitbucket Workspace"
#   path               = "jwt-yuleitest"
#   jwks_url = "https://api.bitbucket.org/2.0/workspaces/${var.bitbucket_workspace_name}/pipelines-config/identity/oidc/keys.json"
#   bound_issuer       = "https://api.bitbucket.org/2.0/workspaces/${var.bitbucket_workspace_name}/pipelines-config/identity/oidc"
# }

# # Create the JWT role tied to the repo
# resource "vault_jwt_auth_backend_role" "repository" {
#   backend           = vault_jwt_auth_backend.jwt.path
#   role_name         = "bitbucket-oidc-${var.bitbucket_workspace_name}-${var.bitbucket_repository_name}"
#   token_policies    = [vault_policy.bitbucket-repo-jwt.name]
#   token_max_ttl     = "7200"
#   bound_audiences   = ["ari:cloud:bitbucket::workspace/${data.bitbucket_workspace.workspace.uuid}"]
#   bound_claims_type = "glob"
#   bound_claims = {
#     sub = "{${data.bitbucket_repository.repository.id}}:*"
#   }
#   user_claim = "repositoryUuid"
#   role_type  = "jwt"
# }