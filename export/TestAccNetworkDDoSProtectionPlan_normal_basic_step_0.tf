
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210825030045144606"
  location = "West Europe"
}

resource "azurerm_network_ddos_protection_plan" "test" {
  name                = "acctestddospplan-210825030045144606"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
