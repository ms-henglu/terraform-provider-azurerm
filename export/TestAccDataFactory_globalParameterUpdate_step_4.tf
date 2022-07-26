
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-220726001815420467"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestDF220726001815420467"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
