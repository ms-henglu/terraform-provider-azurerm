
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-compute-231020040746113723"
  location = "West Europe"
}

resource "azurerm_capacity_reservation_group" "test" {
  name                = "acctest-ccrg-231020040746113723"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  zones               = ["1", "2"]
}

resource "azurerm_capacity_reservation" "test" {
  name                          = "acctest-ccr-231020040746113723"
  capacity_reservation_group_id = azurerm_capacity_reservation_group.test.id
  zone                          = "2"
  sku {
    name     = "Standard_F2"
    capacity = 2
  }
}
