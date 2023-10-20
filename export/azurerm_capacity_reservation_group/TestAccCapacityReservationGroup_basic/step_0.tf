

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-compute-231020040746109297"
  location = "West Europe"
}


resource "azurerm_capacity_reservation_group" "test" {
  name                = "acctest-crg-231020040746109297"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
