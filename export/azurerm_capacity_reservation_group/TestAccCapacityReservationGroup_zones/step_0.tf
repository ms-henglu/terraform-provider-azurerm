

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-compute-240119024707318918"
  location = "West Europe"
}


resource "azurerm_capacity_reservation_group" "test" {
  name                = "acctest-ccrg-240119024707318918"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  zones               = ["1", "2"]
}
