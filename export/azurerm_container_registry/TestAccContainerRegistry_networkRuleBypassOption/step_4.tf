
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-acr-230728025358773191"
  location = "West Europe"
}

resource "azurerm_container_registry" "test" {
  name                       = "testacccr230728025358773191"
  resource_group_name        = azurerm_resource_group.test.name
  location                   = azurerm_resource_group.test.location
  sku                        = "Premium"
  network_rule_bypass_option = "None"
}
