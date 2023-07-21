
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-230721011523165685"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestDF230721011523165685"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
