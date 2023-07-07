

variable "primary_location" {
  default = "West Europe"
}
variable "random_integer" {
  default = 230707010154993719
}
variable "random_string" {
  default = "el9g3"
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
  name                = "acctestkfm-${var.random_integer}"
  resource_group_name = azurerm_resource_group.test.name
}
