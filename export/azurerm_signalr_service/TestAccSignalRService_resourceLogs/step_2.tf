
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230804030723356756"
  location = "West Europe"
}

resource "azurerm_signalr_service" "test" {
  name                = "acctestSignalR-230804030723356756"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  messaging_logs_enabled    = false
  connectivity_logs_enabled = false
  http_request_logs_enabled = true

  sku {
    name     = "Free_F1"
    capacity = 1
  }
}
