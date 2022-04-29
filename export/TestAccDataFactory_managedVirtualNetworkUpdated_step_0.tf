
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-220429075326819612"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestDF220429075326819612"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
