

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-compute-230316221218607667"
  location = "West Europe"
}


resource "azurerm_capacity_reservation_group" "test" {
  name                = "acctest-crg-230316221218607667"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
