
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-220422025048032100"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestDF220422025048032100"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
