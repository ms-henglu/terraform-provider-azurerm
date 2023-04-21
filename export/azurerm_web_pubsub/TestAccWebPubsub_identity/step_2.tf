

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-wps-230421022935313372"
  location = "West Europe"
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctest-uai-230421022935313372"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_web_pubsub" "test" {
  name                = "acctestWebPubsub-230421022935313372"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  sku      = "Standard_S1"
  capacity = 1

  public_network_access_enabled = true

  live_trace {
    enabled                   = true
    messaging_logs_enabled    = true
    connectivity_logs_enabled = false
    http_request_logs_enabled = false
  }

  local_auth_enabled = true
  aad_auth_enabled   = true

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.test.id]
  }
}
