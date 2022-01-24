
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-220124124949886397"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestDF220124124949886397"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
