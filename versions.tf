##Add your terraform core and provider version constrains here.
terraform {
  required_version = ">= 1.7"
  required_providers {
    vault = ">= 3.24.0"
    bitbucket = {
      source  = "zahiar/bitbucket"
      
    }
  }
}
