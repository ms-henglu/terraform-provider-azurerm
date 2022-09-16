

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-compute-220916011219770742"
  location = "West Europe"
}


resource "azurerm_capacity_reservation_group" "test" {
  name                = "acctest-ccrg-220916011219770742"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  tags = {
    ENV2 = "Test2"
  }
}
