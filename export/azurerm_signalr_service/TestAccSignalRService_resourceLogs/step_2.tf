
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231020041911214925"
  location = "West Europe"
}

resource "azurerm_signalr_service" "test" {
  name                = "acctestSignalR-231020041911214925"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  messaging_logs_enabled    = false
  connectivity_logs_enabled = false
  http_request_logs_enabled = true

  sku {
    name     = "Standard_S1"
    capacity = 1
  }
}
