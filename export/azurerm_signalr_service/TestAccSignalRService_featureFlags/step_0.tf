
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230630033952169358"
  location = "West Europe"
}

resource "azurerm_signalr_service" "test" {
  name                = "acctestSignalR-230630033952169358"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  sku {
    name     = "Free_F1"
    capacity = 1
  }

  connectivity_logs_enabled = true
  messaging_logs_enabled    = true
  live_trace_enabled        = true
  service_mode              = "Serverless"

}
