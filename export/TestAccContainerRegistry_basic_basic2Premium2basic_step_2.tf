
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-acr-220712042108812272"
  location = "West Europe"
}

resource "azurerm_container_registry" "test" {
  name                = "testacccr220712042108812272"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Basic"

  # make sure network_rule_set is empty for basic SKU
  # premiuim SKU will automatically populate network_rule_set.default_action to allow
  network_rule_set = []
}
