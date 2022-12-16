
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-221216013416129642"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestDF221216013416129642"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
