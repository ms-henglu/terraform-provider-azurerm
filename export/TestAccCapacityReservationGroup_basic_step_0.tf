

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-compute-220818234946068283"
  location = "West Europe"
}


resource "azurerm_capacity_reservation_group" "test" {
  name                = "acctest-crg-220818234946068283"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
