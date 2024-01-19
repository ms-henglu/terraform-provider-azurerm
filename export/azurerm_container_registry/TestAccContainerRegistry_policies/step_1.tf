
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-acr-240119024742777398"
  location = "West Europe"
}

resource "azurerm_container_registry" "test" {
  name                = "acctestACR240119024742777398"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  admin_enabled       = false
  sku                 = "Premium"

  quarantine_policy_enabled = true

  retention_policy {
    days    = 20
    enabled = true
  }

  trust_policy {
    enabled = true
  }

  export_policy_enabled         = false
  public_network_access_enabled = false

  tags = {
    Environment = "Production"
  }
}
