
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-210826023258267415"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestDF210826023258267415"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
