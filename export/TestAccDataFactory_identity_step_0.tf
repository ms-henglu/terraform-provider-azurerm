
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-211015014127488659"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestDF211015014127488659"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  identity {
    type = "SystemAssigned"
  }
}
