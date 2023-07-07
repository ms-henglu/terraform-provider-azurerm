


variable "primary_location" {
  default = "West Europe"
}
variable "random_integer" {
  default = 230707003619979933
}
variable "random_string" {
  default = "vf2gr"
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


resource "azurerm_kubernetes_fleet_manager" "import" {
  location            = azurerm_kubernetes_fleet_manager.test.location
  name                = azurerm_kubernetes_fleet_manager.test.name
  resource_group_name = azurerm_kubernetes_fleet_manager.test.resource_group_name
}
