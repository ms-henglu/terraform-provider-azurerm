
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231020041911214376"
  location = "West Europe"
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctest-uai-231020041911214376"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_signalr_service" "test" {
  name                = "acctestSignalR-231020041911214376"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  sku {
    name     = "Standard_S1"
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
