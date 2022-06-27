
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-acr-220627130944195330"
  location = "West Europe"
}

resource "azurerm_container_registry" "test" {
  name                       = "testacccr220627130944195330"
  resource_group_name        = azurerm_resource_group.test.name
  location                   = azurerm_resource_group.test.location
  sku                        = "Premium"
  network_rule_bypass_option = "None"
}
