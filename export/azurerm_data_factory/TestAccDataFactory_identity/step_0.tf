
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-230421022033998570"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestDF230421022033998570"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  identity {
    type = "SystemAssigned"
  }
}
