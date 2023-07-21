
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230721012442090654"
  location = "West Europe"
}

resource "azurerm_signalr_service" "test" {
  name                = "acctestSignalR-230721012442090654"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  sku {
    name     = "Free_F1"
    capacity = 1
  }

  public_network_access_enabled            = true
  local_auth_enabled                       = false
  aad_auth_enabled                         = false
  tls_client_cert_enabled                  = false
  serverless_connection_timeout_in_seconds = 5

  identity {
    type = "SystemAssigned"
  }
}
