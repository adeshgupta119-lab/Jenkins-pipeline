terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.8"
    }
  }

  # Remote backend (recommended for production use).
  # A storage account + container must already exist before this can be
  # enabled (it cannot bootstrap itself). Create it once manually or via a
  # separate bootstrap script, then uncomment this block and run:
  #   terraform init -migrate-state
  #
  # backend "azurerm" {
  #   resource_group_name  = "rg-axion-tfstate"
  #   storage_account_name = "staxiontfstate"
  #   container_name        = "tfstate"
  #   key                   = "preprod.terraform.tfstate"
  # }
}

provider "azurerm" {
  features {}
}
