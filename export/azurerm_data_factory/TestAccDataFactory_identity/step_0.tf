
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-221202035526159325"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestDF221202035526159325"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  identity {
    type = "SystemAssigned"
  }
}
