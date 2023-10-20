
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-231020040940478022"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestDF231020040940478022"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
