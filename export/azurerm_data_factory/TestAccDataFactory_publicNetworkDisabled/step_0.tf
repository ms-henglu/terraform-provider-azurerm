
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-221028164846181499"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestDF221028164846181499"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
