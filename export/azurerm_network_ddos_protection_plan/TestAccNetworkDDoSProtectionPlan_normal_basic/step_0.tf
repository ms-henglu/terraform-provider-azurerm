
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221021034418142749"
  location = "West Europe"
}

resource "azurerm_network_ddos_protection_plan" "test" {
  name                = "acctestddospplan-221021034418142749"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
