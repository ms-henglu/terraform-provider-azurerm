


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-compute-230106034233385288"
  location = "West Europe"
}


resource "azurerm_capacity_reservation_group" "test" {
  name                = "acctest-crg-230106034233385288"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}


resource "azurerm_capacity_reservation_group" "import" {
  name                = azurerm_capacity_reservation_group.test.name
  resource_group_name = azurerm_capacity_reservation_group.test.resource_group_name
  location            = azurerm_capacity_reservation_group.test.location
}
