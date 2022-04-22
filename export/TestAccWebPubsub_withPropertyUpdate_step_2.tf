

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-wps-220422025832453710"
  location = "West Europe"
}


resource "azurerm_web_pubsub" "test" {
  name                = "acctestWebPubsub-220422025832453710"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  sku      = "Standard_S1"
  capacity = 1

  public_network_access_enabled = false

  live_trace {
    enabled                   = false
    messaging_logs_enabled    = false
    connectivity_logs_enabled = true
  }

  local_auth_enabled      = false
  aad_auth_enabled        = false
  tls_client_cert_enabled = true
}
