

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-compute-220826002453838364"
  location = "West Europe"
}


resource "azurerm_capacity_reservation_group" "test" {
  name                = "acctest-ccrg-220826002453838364"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  zones               = ["1", "2"]
}
