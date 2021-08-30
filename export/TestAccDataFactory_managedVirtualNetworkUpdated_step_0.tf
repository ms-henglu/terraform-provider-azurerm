
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-210830083901625315"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestDF210830083901625315"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
