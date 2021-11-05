
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-211105035757898120"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestDF211105035757898120"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  identity {
    type = "SystemAssigned"
  }
}
