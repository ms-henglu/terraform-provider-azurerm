
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220726015121239516"
  location = "West Europe"
}

resource "azurerm_network_ddos_protection_plan" "test" {
  name                = "acctestddospplan-220726015121239516"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
