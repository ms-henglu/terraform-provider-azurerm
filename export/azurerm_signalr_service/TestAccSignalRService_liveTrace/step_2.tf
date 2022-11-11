
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221111021222186418"
  location = "West Europe"
}

resource "azurerm_signalr_service" "test" {
  name                = "acctestSignalR-221111021222186418"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  live_trace {
    enabled                   = false
    messaging_logs_enabled    = true
    connectivity_logs_enabled = false
    http_request_logs_enabled = false
  }

  sku {
    name     = "Free_F1"
    capacity = 1
  }
}
