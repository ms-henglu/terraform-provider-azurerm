

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-compute-220916011219773859"
  location = "West Europe"
}

resource "azurerm_capacity_reservation_group" "test" {
  name                = "acctest-ccrg-220916011219773859"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}


resource "azurerm_capacity_reservation" "test" {
  name                          = "acctest-ccr-220916011219773859"
  capacity_reservation_group_id = azurerm_capacity_reservation_group.test.id
  sku {
    name     = "Standard_F2"
    capacity = 2
  }
}
