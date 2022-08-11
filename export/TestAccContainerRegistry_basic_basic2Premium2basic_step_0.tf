
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-acr-220811053040684187"
  location = "West Europe"
}

resource "azurerm_container_registry" "test" {
  name                = "testacccr220811053040684187"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Basic"

  # make sure network_rule_set is empty for basic SKU
  # premiuim SKU will automatically populate network_rule_set.default_action to allow
  network_rule_set = []
}
