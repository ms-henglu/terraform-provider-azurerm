
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-acr-211008044217861038"
  location = "West Europe"
}

resource "azurerm_container_registry" "test" {
  name                = "acctestACR211008044217861038"
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
