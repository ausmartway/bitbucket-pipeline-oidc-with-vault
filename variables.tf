# Define your variables in here.
variable "bitbucket_workspace_name" {
  description = "The name of the Bitbucket workspace"
  type        = string
  default     = "yuleitest"
}

variable "bitbucket_repository_name" {
  description = "The name of the Bitbucket repository"
  type        = string
  default     = "oidc-vault-test"
}

# variable "bitbucket_username" {
# // bitbucket username is sensitive data, it should not be stored in terraform statefile. it is recommended to use BITBUCKET_USERNAME environment variable instead. 
#   description = "The username of the Bitbucket user"
#   type        = string
#   default = "ausmartway"
# }

# variable "bitbucket_password" {
# // bitbucket password is sensitive data, it should not be stored in terraform statefile. it is recommended to use BITBUCKET_PASSWORD environment variable instead.
#   description = "The password of the Bitbucket user, this should be app password"
#   type        = string  
# }

variable "vault_address" {
  // Vault address is not sensitive data, it can be stored in terraform statefile in plaintext, without leaking any secrets.
  description = "The address of the Vault server"
  type        = string
  default     = "https://vault-cluster-public-vault-bb7b95a8.c950b5f7.z1.hashicorp.cloud:8200/"
}

variable "vault_namespace" {
  // Vault namespace is not sensitive data, it can be stored in terraform statefile in plaintext, without leaking any secrets.
  description = "The namespace of the Vault server"
  type        = string
  default     = "admin"
}