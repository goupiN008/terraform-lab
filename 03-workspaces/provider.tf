terraform {
  backend "local" {
    path = "state/terraform.tfstate"
  }
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
#   config_context = "my-context"
}