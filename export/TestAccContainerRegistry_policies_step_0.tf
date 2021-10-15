
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-acr-211015014444950854"
  location = "West Europe"
}

resource "azurerm_container_registry" "test" {
  name                = "acctestACR211015014444950854"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  admin_enabled       = false
  sku                 = "Premium"

  quarantine_policy_enabled = true

  retention_policy {
    days    = 10
    enabled = true
  }

  trust_policy {
    enabled = true
  }

  tags = {
    Environment = "Production"
  }
}
