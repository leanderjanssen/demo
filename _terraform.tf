# Configure the Azure provider
terraform {
  # backend "remote" {
  #   hostname = "app.terraform.io"
  #   organization = "itforge"

  #   workspaces {
  #     name = "training"
  #   }
  # }

  cloud {
    organization = "itforge"

    workspaces {
      name = "training"
    }
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.61"
    }
  }
}

provider "azurerm" {
  features {}
}
