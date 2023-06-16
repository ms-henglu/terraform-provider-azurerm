
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230616075459853393"
  location = "West Europe"
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctest-uai-230616075459853393"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_signalr_service" "test" {
  name                = "acctestSignalR-230616075459853393"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  sku {
    name     = "Free_F1"
    capacity = 1
  }

  public_network_access_enabled            = true
  local_auth_enabled                       = true
  aad_auth_enabled                         = true
  tls_client_cert_enabled                  = false
  serverless_connection_timeout_in_seconds = 10

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.test.id]
  }
}
