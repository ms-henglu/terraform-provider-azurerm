
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-230613071730205167"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestDF230613071730205167"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
