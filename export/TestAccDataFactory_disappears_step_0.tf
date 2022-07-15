
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-220715014409100032"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestDF220715014409100032"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
