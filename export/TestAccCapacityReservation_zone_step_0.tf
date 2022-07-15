
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-compute-220715014258819745"
  location = "West Europe"
}

resource "azurerm_capacity_reservation_group" "test" {
  name                = "acctest-ccrg-220715014258819745"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  zones               = ["1", "2"]
}

resource "azurerm_capacity_reservation" "test" {
  name                          = "acctest-ccr-220715014258819745"
  capacity_reservation_group_id = azurerm_capacity_reservation_group.test.id
  zone                          = "2"
  sku {
    name     = "Standard_F2"
    capacity = 2
  }
}
