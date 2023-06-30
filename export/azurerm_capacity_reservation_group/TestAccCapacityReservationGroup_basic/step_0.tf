

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-compute-230630032848716605"
  location = "West Europe"
}


resource "azurerm_capacity_reservation_group" "test" {
  name                = "acctest-crg-230630032848716605"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
