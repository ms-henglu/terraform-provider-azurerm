
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230630033952166123"
  location = "West Europe"
}

resource "azurerm_signalr_service" "test" {
  name                = "acctestSignalR-230630033952166123"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  live_trace {
    enabled                   = true
    messaging_logs_enabled    = false
    connectivity_logs_enabled = true
  }

  sku {
    name     = "Free_F1"
    capacity = 1
  }
}
