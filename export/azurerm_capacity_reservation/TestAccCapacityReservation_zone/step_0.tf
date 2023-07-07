
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-compute-230707003539970461"
  location = "West Europe"
}

resource "azurerm_capacity_reservation_group" "test" {
  name                = "acctest-ccrg-230707003539970461"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  zones               = ["1", "2"]
}

resource "azurerm_capacity_reservation" "test" {
  name                          = "acctest-ccr-230707003539970461"
  capacity_reservation_group_id = azurerm_capacity_reservation_group.test.id
  zone                          = "2"
  sku {
    name     = "Standard_F2"
    capacity = 2
  }
}
