

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-compute-220722035002482844"
  location = "West Europe"
}


resource "azurerm_capacity_reservation_group" "test" {
  name                = "acctest-crg-220722035002482844"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
