terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.58.0"
    }
    boundary = {
      source  = "hashicorp/boundary"
      version = "1.1.7"
    }
  }
}