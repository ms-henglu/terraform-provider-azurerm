

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-compute-220627130915999624"
  location = "West Europe"
}

resource "azurerm_capacity_reservation_group" "test" {
  name                = "acctest-ccrg-220627130915999624"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}


resource "azurerm_capacity_reservation" "test" {
  name                          = "acctest-ccr-220627130915999624"
  capacity_reservation_group_id = azurerm_capacity_reservation_group.test.id
  sku {
    name     = "Standard_F2"
    capacity = 1
  }
}
