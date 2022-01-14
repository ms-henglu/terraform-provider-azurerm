
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-220114064035710882"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestDF220114064035710882"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
