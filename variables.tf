# Define your variables in here.
variable "bitbucket_workspace_name" {
  description = "The name of the Bitbucket workspace"
  type        = string
  default = "yuleitest"
}

variable "bitbucket_repository_name" {
  description = "The name of the Bitbucket repository"
  type        = string
  default = "oidc-vault-test"
}

variable "bitbucket_username" {
  description = "The username of the Bitbucket user"
  type        = string
  default = "bitbucket-test"
}

variable "bitbucket_password" {
  description = "The password of the Bitbucket user"
  type        = string
  default = "bitbucket-test"
  
}