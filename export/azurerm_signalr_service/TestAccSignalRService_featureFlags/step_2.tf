
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231016034743391832"
  location = "West Europe"
}

resource "azurerm_signalr_service" "test" {
  name                = "acctestSignalR-231016034743391832"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  sku {
    name     = "Standard_S1"
    capacity = 1
  }

  connectivity_logs_enabled = false
  messaging_logs_enabled    = false
  live_trace_enabled        = false
  service_mode              = "Classic"

}
