

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-compute-240105063503954968"
  location = "West Europe"
}


resource "azurerm_capacity_reservation_group" "test" {
  name                = "acctest-crg-240105063503954968"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
