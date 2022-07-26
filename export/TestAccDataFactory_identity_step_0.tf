
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-220726014718670897"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestDF220726014718670897"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  identity {
    type = "SystemAssigned"
  }
}
