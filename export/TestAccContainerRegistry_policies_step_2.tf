
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-acr-220826002518843768"
  location = "West Europe"
}

resource "azurerm_container_registry" "test" {
  name                = "acctestACR220826002518843768"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  admin_enabled       = false
  sku                 = "Basic"
  network_rule_set    = []

  retention_policy {}
  trust_policy {}

  tags = {
    Environment = "Production"
  }
}
