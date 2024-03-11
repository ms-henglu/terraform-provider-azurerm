

variable "primary_location" {
  default = "West Europe"
}
variable "random_integer" {
  default = 240311031710594018
}
variable "random_string" {
  default = "naddz"
}

resource "azurerm_resource_group" "test" {
  name     = "acctestrg-${var.random_integer}"
  location = var.primary_location
}


provider "azurerm" {
  features {}
}

resource "azurerm_kubernetes_fleet_manager" "test" {
  location            = azurerm_resource_group.test.location
  name                = "acctestkfm-${var.random_string}"
  resource_group_name = azurerm_resource_group.test.name
  tags = {
    environment = "terraform-acctests"
    some_key    = "some-value"
  }
  hub_profile {
    dns_prefix = "val-${var.random_string}"
  }
}
