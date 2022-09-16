
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220916012044484178"
  location = "West Europe"
}

resource "azurerm_signalr_service" "test" {
  name                = "acctestSignalR-220916012044484178"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  sku {
    name     = "Standard_S1"
    capacity = 1
  }
}
