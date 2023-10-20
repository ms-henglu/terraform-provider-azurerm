


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-compute-231020040746119272"
  location = "West Europe"
}


resource "azurerm_capacity_reservation_group" "test" {
  name                = "acctest-crg-231020040746119272"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}


resource "azurerm_capacity_reservation_group" "import" {
  name                = azurerm_capacity_reservation_group.test.name
  resource_group_name = azurerm_capacity_reservation_group.test.resource_group_name
  location            = azurerm_capacity_reservation_group.test.location
}
