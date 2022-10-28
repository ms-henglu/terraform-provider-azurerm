

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-compute-221028171853790810"
  location = "West Europe"
}


resource "azurerm_capacity_reservation_group" "test" {
  name                = "acctest-crg-221028171853790810"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
