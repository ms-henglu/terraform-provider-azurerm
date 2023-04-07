
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230407023833830725"
  location = "West Europe"
}

resource "azurerm_network_ddos_protection_plan" "test" {
  name                = "acctestddospplan-230407023833830725"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
