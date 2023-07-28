
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-230728025538829877"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestDF230728025538829877"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
