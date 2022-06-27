

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-compute-220627123942165847"
  location = "West Europe"
}


resource "azurerm_capacity_reservation_group" "test" {
  name                = "acctest-crg-220627123942165847"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
