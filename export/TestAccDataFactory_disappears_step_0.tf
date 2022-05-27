
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-220527034050442910"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestDF220527034050442910"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
