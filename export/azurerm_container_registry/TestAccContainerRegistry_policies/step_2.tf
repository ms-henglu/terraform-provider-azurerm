
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-acr-230512010437900483"
  location = "West Europe"
}

resource "azurerm_container_registry" "test" {
  name                = "acctestACR230512010437900483"
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
