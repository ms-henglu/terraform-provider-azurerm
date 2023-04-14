

provider "azurerm" {
  features {}
}

locals {
  random_integer   = 230414021028841333
  primary_location = "West Europe"
}


resource "azurerm_resource_group" "test" {
  name     = "acctestrg-${local.random_integer}"
  location = local.primary_location
}


resource "azurerm_kubernetes_fleet_manager" "test" {

  hub_profile {
    dns_prefix = "acctest"
  }

  location            = azurerm_resource_group.test.location
  name                = "acctest-${local.random_integer}"
  resource_group_name = azurerm_resource_group.test.name
}
