

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-compute-240119024707311945"
  location = "West Europe"
}

resource "azurerm_capacity_reservation_group" "test" {
  name                = "acctest-ccrg-240119024707311945"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}


resource "azurerm_capacity_reservation" "test" {
  name                          = "acctest-ccr-240119024707311945"
  capacity_reservation_group_id = azurerm_capacity_reservation_group.test.id
  sku {
    name     = "Standard_F2"
    capacity = 2
  }
  tags = {
    ENV = "Test"
  }
}
