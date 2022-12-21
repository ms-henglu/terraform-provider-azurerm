
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-221221204215469886"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestDF221221204215469886"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
